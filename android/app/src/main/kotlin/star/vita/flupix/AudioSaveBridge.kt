package star.vita.flupix

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.provider.OpenableColumns
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * 音频转换结果的保存桥接。
 *
 * 有意使用通配 MIME 类型：部分 Android 文件提供方会按 MIME 的默认扩展名
 * 给建议文件名追加后缀（例如 audio/ogg 被补成 ".oga"）。通配类型没有默认
 * 扩展名，可保证最终文件名与传入的 fileName 一致。
 */
class AudioSaveBridge(private val activity: Activity) : MethodChannel.MethodCallHandler {

    private var pendingResult: MethodChannel.Result? = null
    private var pendingBytes: ByteArray? = null

    fun register(messenger: BinaryMessenger) {
        MethodChannel(messenger, CHANNEL).setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method != "saveFile") {
            result.notImplemented()
            return
        }
        if (pendingResult != null) {
            result.error("busy", "已有保存任务在进行中", null)
            return
        }

        val fileName = call.argument<String>("fileName")
        val bytes = call.argument<ByteArray>("bytes")
        if (fileName.isNullOrBlank() || bytes == null) {
            result.error("invalid_args", "缺少文件名或文件内容", null)
            return
        }

        pendingResult = result
        pendingBytes = bytes
        val intent = Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            type = "*/*"
            putExtra(Intent.EXTRA_TITLE, fileName)
        }
        activity.startActivityForResult(intent, REQUEST_CODE)
    }

    /** 返回 true 表示该结果已由本桥接处理。 */
    fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode != REQUEST_CODE) return false

        val result = pendingResult ?: return true
        val bytes = pendingBytes
        pendingResult = null
        pendingBytes = null

        val uri = data?.data
        if (resultCode != Activity.RESULT_OK || uri == null || bytes == null) {
            result.success(null)
            return true
        }

        try {
            val output = activity.contentResolver.openOutputStream(uri)
                ?: throw IllegalStateException("无法打开目标文件")
            output.use { it.write(bytes) }
            result.success(displayName(uri) ?: uri.toString())
        } catch (error: Exception) {
            result.error("save_failed", error.message ?: "保存失败", null)
        }
        return true
    }

    private fun displayName(uri: Uri): String? {
        activity.contentResolver.query(
            uri,
            arrayOf(OpenableColumns.DISPLAY_NAME),
            null,
            null,
            null,
        )?.use { cursor ->
            if (cursor.moveToFirst()) return cursor.getString(0)
        }
        return null
    }

    private companion object {
        const val CHANNEL = "flupix/audio_save"
        const val REQUEST_CODE = 4107
    }
}
