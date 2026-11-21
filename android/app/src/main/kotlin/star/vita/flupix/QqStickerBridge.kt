package star.vita.flupix

import android.content.ContentValues
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.ParcelFileDescriptor
import android.provider.MediaStore
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import moe.shizuku.server.IShizukuService
import rikka.shizuku.Shizuku
import rikka.shizuku.ShizukuBinderWrapper
import java.io.ByteArrayOutputStream
import java.io.File
import java.util.concurrent.Executors
import java.util.zip.CRC32

/**
 * 通过 Shizuku（Root 模式）读取 QQ 的表情缓存，解密后保存到相册。
 *
 * QQ 缓存目录：
 * /sdcard/Android/data/com.tencent.mobileqq/Tencent/MobileQQ/.emotionsm/<packId>/
 *
 * 主表情文件被做了轻量混淆：奇数下标字节 XOR 0x01（GIF 仅文件头，PNG 仅前 33 字节），
 * 其余内容（PNG 的 IDAT/IEND）为明文。
 */
class QqStickerBridge(private val context: Context) : MethodChannel.MethodCallHandler {

    private data class Sticker(val name: String, val size: Long, val thumb: String?)

    private data class Pack(val id: String, val stickers: List<Sticker>)

    private data class ShellResult(val code: Int, val stdout: ByteArray, val stderr: ByteArray)

    private val mainHandler = Handler(Looper.getMainLooper())
    private val executor = Executors.newSingleThreadExecutor()
    private var pendingPermissionResult: MethodChannel.Result? = null

    private val permissionListener =
        Shizuku.OnRequestPermissionResultListener { requestCode, grantResult ->
            if (requestCode != PERMISSION_REQUEST_CODE) return@OnRequestPermissionResultListener
            val pending = pendingPermissionResult ?: return@OnRequestPermissionResultListener
            pendingPermissionResult = null
            mainHandler.post { pending.success(grantResult == PackageManager.PERMISSION_GRANTED) }
        }

    fun register(messenger: BinaryMessenger) {
        try {
            Shizuku.addRequestPermissionResultListener(permissionListener)
        } catch (_: Throwable) {
            // Shizuku 未安装时忽略，后续 getStatus 会给出提示。
        }
        MethodChannel(messenger, CHANNEL).setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getStatus" -> runAsync(result) { status() }
            "requestPermission" -> requestPermission(result)
            "openShizuku" -> result.success(openApp(SHIZUKU_PACKAGE))
            "openQq" -> result.success(openApp(QQ_PACKAGE))
            "scanPacks" -> runAsync(result) { scanPacks() }
            "saveStickers" -> runAsync(result) { saveStickers(call) }
            else -> result.notImplemented()
        }
    }

    private fun runAsync(result: MethodChannel.Result, work: () -> Any?) {
        executor.execute {
            try {
                val value = work()
                mainHandler.post { result.success(value) }
            } catch (t: Throwable) {
                val message = t.message?.takeIf { it.isNotBlank() } ?: "操作失败"
                mainHandler.post { result.error("qq_sticker", message, null) }
            }
        }
    }

    private fun status(): Map<String, Any?> {
        val qqInstalled = isPackageInstalled(QQ_PACKAGE)
        val shizukuInstalled = isPackageInstalled(SHIZUKU_PACKAGE)
        var running = false
        var granted = false
        var uid = -1
        try {
            running = Shizuku.pingBinder()
            if (running) {
                granted = Shizuku.checkSelfPermission() == PackageManager.PERMISSION_GRANTED
                uid = Shizuku.getUid()
            }
        } catch (_: Throwable) {
            running = false
            granted = false
            uid = -1
        }
        var cacheExists = false
        if (running && granted && uid == 0) {
            cacheExists = try {
                val out = shell("test -d '$STICKER_BASE' && echo 1 || echo 0")
                out.stdout.toString(Charsets.UTF_8).trim() == "1"
            } catch (_: Throwable) {
                false
            }
        }
        return mapOf(
            "qqInstalled" to qqInstalled,
            "shizukuInstalled" to shizukuInstalled,
            "shizukuRunning" to running,
            "permissionGranted" to granted,
            "uid" to uid,
            "isRoot" to (uid == 0),
            "cacheExists" to cacheExists,
            "androidSdk" to Build.VERSION.SDK_INT,
        )
    }

    private fun requestPermission(result: MethodChannel.Result) {
        try {
            if (!Shizuku.pingBinder()) {
                result.success(false)
                return
            }
            if (Shizuku.checkSelfPermission() == PackageManager.PERMISSION_GRANTED) {
                result.success(true)
                return
            }
            if (pendingPermissionResult != null) {
                result.error("qq_sticker", "正在等待上一次授权结果", null)
                return
            }
            pendingPermissionResult = result
            Shizuku.requestPermission(PERMISSION_REQUEST_CODE)
        } catch (t: Throwable) {
            pendingPermissionResult = null
            result.error("qq_sticker", t.message ?: "请求 Shizuku 授权失败", null)
        }
    }

    private fun scanPacks(): Map<String, Any?> {
        if (!hasRootShizuku()) {
            throw IllegalStateException("请先通过 Root 启动 Shizuku 并完成授权")
        }
        val thumbRoot = File(context.cacheDir, "qq_stickers")
        val thumbRootPath = thumbRoot.absolutePath
        val cmd = """
            BASE='$STICKER_BASE'
            [ -d "${'$'}BASE" ] || { echo 'ERR|missing'; exit 3; }
            CACHE='$thumbRootPath'
            rm -rf "${'$'}CACHE"
            mkdir -p "${'$'}CACHE"
            cd "${'$'}BASE" || exit 4
            for d in */; do
              id=${'$'}{d%/}
              echo "P|${'$'}id"
              for f in "${'$'}d"*; do
                [ -f "${'$'}f" ] || continue
                n=${'$'}{f##*/}
                s=${'$'}(stat -c %s "${'$'}f" 2>/dev/null)
                echo "F|${'$'}id|${'$'}n|${'$'}s"
              done
              mkdir -p "${'$'}CACHE/${'$'}id"
              cp "${'$'}d"*_thu.png "${'$'}CACHE/${'$'}id/" 2>/dev/null
            done
            chmod -R 755 "${'$'}CACHE"
            find "${'$'}CACHE" -type f -exec chmod 644 {} + 2>/dev/null
        """.trimIndent()

        val shellResult = shell(cmd)
        val text = shellResult.stdout.toString(Charsets.UTF_8)
        if (shellResult.code != 0) {
            val message = when {
                text.contains("ERR|missing") -> "未找到 QQ 表情缓存，请先在 QQ 中加载表情"
                else -> shellResult.stderr.toString(Charsets.UTF_8).trim()
                    .ifBlank { "读取 QQ 表情缓存失败" }
            }
            throw IllegalStateException(message)
        }

        val filesByPack = mutableMapOf<String, MutableList<Pair<String, Long>>>()
        for (line in text.lineSequence()) {
            if (!line.startsWith("F|")) continue
            val parts = line.split('|')
            if (parts.size < 4) continue
            val packId = parts[1]
            val name = parts[2]
            val size = parts[3].toLongOrNull() ?: 0L
            if (!PACK_ID.matches(packId) || !SAFE_NAME.matches(name)) continue
            if (name == "." || name == "..") continue
            filesByPack.getOrPut(packId) { mutableListOf() }.add(name to size)
        }

        val packs = mutableListOf<Pack>()
        for ((packId, files) in filesByPack) {
            val mains = files.filter { (name, _) ->
                !name.endsWith("_thu.png") && !name.endsWith("_aio.png") && !name.startsWith(".")
            }
            if (mains.isEmpty()) continue
            val thumbNames = files.asSequence()
                .map { it.first }
                .filter { it.endsWith("_thu.png") }
                .toSet()
            val stickers = mains.map { (name, size) ->
                val candidates = listOf(
                    "${name}_thu.png",
                    "${name.substringBeforeLast('.')}_thu.png",
                )
                val thumbName = candidates.firstOrNull { it in thumbNames }
                val thumbFile = thumbName?.let { File(thumbRoot, "$packId/$it") }
                Sticker(
                    name = name,
                    size = size,
                    thumb = if (thumbFile?.exists() == true) thumbFile.absolutePath else null,
                )
            }.sortedBy { it.name }
            packs.add(Pack(packId, stickers))
        }
        packs.sortWith(compareBy({ it.id.toLongOrNull() ?: Long.MAX_VALUE }, { it.id }))

        return mapOf(
            "cacheDir" to thumbRootPath,
            "packs" to packs.map { pack ->
                mapOf(
                    "id" to pack.id,
                    "stickers" to pack.stickers.map { sticker ->
                        mapOf(
                            "name" to sticker.name,
                            "size" to sticker.size,
                            "thumb" to sticker.thumb,
                        )
                    },
                )
            },
        )
    }

    private fun saveStickers(call: MethodCall): Map<String, Any?> {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
            throw IllegalStateException("保存到相册需要 Android 10 及以上系统")
        }
        if (!hasRootShizuku()) {
            throw IllegalStateException("请先通过 Root 启动 Shizuku 并完成授权")
        }

        val args = call.arguments as? Map<*, *>
        val rawGroups = args?.get("groups") as? List<*> ?: emptyList<Any>()
        val groups = rawGroups.mapNotNull { item ->
            val map = item as? Map<*, *> ?: return@mapNotNull null
            val packId = map["packId"] as? String ?: return@mapNotNull null
            val names = (map["names"] as? List<*>)
                ?.mapNotNull { it as? String }
                ?.filter { SAFE_NAME.matches(it) && it != "." && it != ".." }
                ?: emptyList()
            if (!PACK_ID.matches(packId) || names.isEmpty()) null else packId to names
        }
        if (groups.isEmpty()) throw IllegalArgumentException("没有选择表情")

        var saved = 0
        val failed = mutableListOf<String>()
        for ((packId, names) in groups) {
            val tempDir = File(context.cacheDir, "qq_tmp/$packId")
            val tempPath = tempDir.absolutePath
            val quotedNames = names.joinToString(" ") { "'$it'" }
            val copyCmd = """
                SRC='$STICKER_BASE/$packId'
                DST='$tempPath'
                rm -rf "${'$'}DST"
                mkdir -p "${'$'}DST"
                for n in $quotedNames; do
                  cp "${'$'}SRC/${'$'}n" "${'$'}DST/${'$'}n" 2>/dev/null || true
                done
                chmod 755 "${'$'}DST"
                find "${'$'}DST" -type f -exec chmod 644 {} + 2>/dev/null
            """.trimIndent()
            if (shell(copyCmd).code != 0) {
                failed.addAll(names)
                continue
            }
            for (name in names) {
                val file = File(tempDir, name)
                if (!file.exists()) {
                    failed.add(name)
                    continue
                }
                try {
                    val decoded = decodeSticker(file.readBytes())
                    if (decoded == null) {
                        failed.add(name)
                        continue
                    }
                    val extension = if (decoded.second == "image/gif") "gif" else "png"
                    val displayName = "${name.substringBeforeLast('.')}.$extension"
                    saveToGallery(packId, decoded.first, displayName, decoded.second)
                    saved++
                } catch (_: Throwable) {
                    failed.add(name)
                }
            }
            try {
                shell("rm -rf '$tempPath'")
            } catch (_: Throwable) {
            }
        }
        return mapOf("saved" to saved, "failed" to failed)
    }

    private fun saveToGallery(packId: String, bytes: ByteArray, displayName: String, mime: String) {
        val values = ContentValues().apply {
            put(MediaStore.Images.Media.DISPLAY_NAME, displayName)
            put(MediaStore.Images.Media.MIME_TYPE, mime)
            put(MediaStore.Images.Media.RELATIVE_PATH, "Pictures/Flupix/QQ表情/$packId")
            put(MediaStore.Images.Media.IS_PENDING, 1)
        }
        val resolver = context.contentResolver
        val uri = resolver.insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, values)
            ?: throw IllegalStateException("无法创建相册记录")
        try {
            resolver.openOutputStream(uri)?.use { it.write(bytes) }
                ?: throw IllegalStateException("无法写入相册")
            values.clear()
            values.put(MediaStore.Images.Media.IS_PENDING, 0)
            resolver.update(uri, values, null, null)
        } catch (t: Throwable) {
            try {
                resolver.delete(uri, null, null)
            } catch (_: Throwable) {
            }
            throw t
        }
    }

    private fun decodeSticker(src: ByteArray): Pair<ByteArray, String>? {
        if (src.size < 8) return null
        // 明文 PNG
        if (src[0] == 0x89.toByte() && src[1] == 0x50.toByte() &&
            src[2] == 0x4E.toByte() && src[3] == 0x47.toByte()
        ) {
            return src to "image/png"
        }
        // 明文 GIF
        if (src[0] == 0x47.toByte() && src[1] == 0x49.toByte() && src[2] == 0x46.toByte()) {
            return src to "image/gif"
        }
        // 混淆 PNG（PNG 签名奇数位被 XOR 0x01）
        if (src[0] == 0x89.toByte() && src[1] == 0x51.toByte() &&
            src[2] == 0x4F.toByte() && src[3] == 0x46.toByte()
        ) {
            val decoded = decodePng(src) ?: return null
            return decoded to "image/png"
        }
        // 混淆 GIF（文件头 "GHF99`" -> "GIF89a"）
        if (src[0] == 0x47.toByte() && src[1] == 0x48.toByte() && src[2] == 0x46.toByte()) {
            val out = src.copyOf()
            out[1] = (out[1].toInt() xor 0x01).toByte()
            out[3] = (out[3].toInt() xor 0x01).toByte()
            out[5] = (out[5].toInt() xor 0x01).toByte()
            return out to "image/gif"
        }
        return null
    }

    private fun decodePng(src: ByteArray): ByteArray? {
        val headerEnd = 33 // 8 字节签名 + 25 字节 IHDR
        if (src.size < headerEnd) return null
        val patched = src.copyOf()
        for (i in 1 until headerEnd step 2) {
            patched[i] = (patched[i].toInt() xor 0x01).toByte()
        }
        // IHDR 数据被修改后重新计算 CRC，保证图片可被解码。
        val crc = CRC32()
        crc.update(patched, 12, 17)
        val value = crc.value
        patched[29] = (value ushr 24).toByte()
        patched[30] = (value ushr 16).toByte()
        patched[31] = (value ushr 8).toByte()
        patched[32] = value.toByte()

        val idat = indexOf(patched, IDAT)
        if (idat < 4) return null
        val chunkStart = idat - 4
        val out = ByteArrayOutputStream(patched.size)
        out.write(PNG_SIGNATURE)
        out.write(patched, 8, 25)
        out.write(patched, chunkStart, patched.size - chunkStart)
        return out.toByteArray()
    }

    private fun indexOf(haystack: ByteArray, needle: ByteArray): Int {
        if (needle.isEmpty() || haystack.size < needle.size) return -1
        outer@ for (i in 0..haystack.size - needle.size) {
            for (j in needle.indices) {
                if (haystack[i + j] != needle[j]) continue@outer
            }
            return i
        }
        return -1
    }

    private fun hasRootShizuku(): Boolean {
        return try {
            Shizuku.pingBinder() &&
                Shizuku.checkSelfPermission() == PackageManager.PERMISSION_GRANTED &&
                Shizuku.getUid() == 0
        } catch (_: Throwable) {
            false
        }
    }

    private fun isPackageInstalled(pkg: String): Boolean {
        return try {
            context.packageManager.getPackageInfo(pkg, 0)
            true
        } catch (_: PackageManager.NameNotFoundException) {
            false
        }
    }

    private fun openApp(pkg: String): Boolean {
        return try {
            val intent = context.packageManager.getLaunchIntentForPackage(pkg) ?: return false
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            context.startActivity(intent)
            true
        } catch (_: Throwable) {
            false
        }
    }

    private fun shell(cmd: String): ShellResult {
        val binder = Shizuku.getBinder() ?: throw IllegalStateException("Shizuku 服务不可用")
        val service = IShizukuService.Stub.asInterface(ShizukuBinderWrapper(binder))
        val remote = service.newProcess(arrayOf("sh", "-c", cmd), null, null)
        val stdoutStream = ParcelFileDescriptor.AutoCloseInputStream(remote.inputStream)
        val stderrStream = ParcelFileDescriptor.AutoCloseInputStream(remote.errorStream)
        try {
            ParcelFileDescriptor.AutoCloseOutputStream(remote.outputStream).close()
        } catch (_: Throwable) {
        }
        var stderr = ByteArray(0)
        val stderrThread = Thread {
            try {
                stderr = stderrStream.use { it.readBytes() }
            } catch (_: Throwable) {
            }
        }
        stderrThread.start()
        val stdout = try {
            stdoutStream.use { it.readBytes() }
        } catch (_: Throwable) {
            ByteArray(0)
        }
        val code = try {
            remote.waitFor()
        } catch (_: Throwable) {
            -1
        }
        stderrThread.join(1000)
        return ShellResult(code, stdout, stderr)
    }

    companion object {
        private const val CHANNEL = "flupix/shizuku"
        private const val QQ_PACKAGE = "com.tencent.mobileqq"
        private const val SHIZUKU_PACKAGE = "moe.shizuku.privileged.api"
        private const val STICKER_BASE =
            "/sdcard/Android/data/com.tencent.mobileqq/Tencent/MobileQQ/.emotionsm"
        private const val PERMISSION_REQUEST_CODE = 233
        private val PACK_ID = Regex("^[0-9A-Za-z_-]{1,64}$")
        private val SAFE_NAME = Regex("^[0-9A-Za-z._-]{1,128}$")
        private val IDAT = byteArrayOf(0x49, 0x44, 0x41, 0x54)
        private val PNG_SIGNATURE = byteArrayOf(
            0x89.toByte(), 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A,
        )
    }
}
