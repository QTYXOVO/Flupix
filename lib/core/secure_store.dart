import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 敏感凭据（站点 Cookie、账号 Token）的加密存储。
///
/// Android 端使用 Keystore 加密，Windows 端由系统凭据管理器保管密钥后加密落盘，
/// 不再以明文写入 SharedPreferences。旧版本遗留的明文值会在首次读取时迁移并删除。
class SecureStore {
  const SecureStore._();

  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static Future<String?> read(String key) async {
    try {
      final value = await _storage.read(key: key);
      if (value != null) {
        if (value.isEmpty) return null;
        await _removeLegacy(key);
        return value;
      }
    } catch (error) {
      debugPrint('读取安全存储失败 [$key]：$error');
      return null;
    }
    return _migrateLegacy(key);
  }

  static Future<void> write(String key, String value) async {
    var stored = false;
    try {
      await _storage.write(key: key, value: value);
      stored = true;
    } catch (error) {
      // 写入失败时不阻塞当前会话，但保留旧值以免数据丢失。
      debugPrint('写入安全存储失败 [$key]：$error');
    }
    if (stored) await _removeLegacy(key);
  }

  static Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (error) {
      debugPrint('删除安全存储失败 [$key]：$error');
    }
    await _removeLegacy(key);
  }

  static Future<String?> _migrateLegacy(String key) async {
    final preferences = await SharedPreferences.getInstance();
    final legacy = preferences.getString(key);
    if (legacy == null || legacy.isEmpty) return null;
    try {
      await _storage.write(key: key, value: legacy);
      await preferences.remove(key);
      debugPrint('已将 [$key] 迁移到安全存储');
    } catch (error) {
      debugPrint('迁移到安全存储失败 [$key]：$error');
    }
    return legacy;
  }

  static Future<void> _removeLegacy(String key) async {
    final preferences = await SharedPreferences.getInstance();
    if (preferences.containsKey(key)) {
      await preferences.remove(key);
    }
  }
}
