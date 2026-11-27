import 'package:flutter/services.dart';

import 'platform_capabilities.dart';

/// Shizuku 服务状态，供设置页与需要 Root 权限的工具共用。
class ShizukuStatus {
  const ShizukuStatus({
    required this.qqInstalled,
    required this.shizukuInstalled,
    required this.shizukuRunning,
    required this.permissionGranted,
    required this.isRoot,
    required this.cacheExists,
    required this.uid,
  });

  factory ShizukuStatus.fromMap(Map<dynamic, dynamic>? map) {
    return ShizukuStatus(
      qqInstalled: map?['qqInstalled'] == true,
      shizukuInstalled: map?['shizukuInstalled'] == true,
      shizukuRunning: map?['shizukuRunning'] == true,
      permissionGranted: map?['permissionGranted'] == true,
      isRoot: map?['isRoot'] == true,
      cacheExists: map?['cacheExists'] == true,
      uid: (map?['uid'] as num?)?.toInt() ?? -1,
    );
  }

  final bool qqInstalled;
  final bool shizukuInstalled;
  final bool shizukuRunning;
  final bool permissionGranted;
  final bool isRoot;
  final bool cacheExists;
  final int uid;

  /// 已运行、已授权且为 Root 模式时才可用于读取 QQ 缓存。
  bool get ready =>
      shizukuInstalled && shizukuRunning && permissionGranted && isRoot;
}

class ShizukuService {
  static const MethodChannel channel = MethodChannel('flupix/shizuku');

  Future<ShizukuStatus> status() async {
    if (!AppCapabilities.supportsShizuku) {
      return const ShizukuStatus(
        qqInstalled: false,
        shizukuInstalled: false,
        shizukuRunning: false,
        permissionGranted: false,
        isRoot: false,
        cacheExists: false,
        uid: -1,
      );
    }
    final map = await channel.invokeMethod<Map<dynamic, dynamic>>('getStatus');
    return ShizukuStatus.fromMap(map);
  }

  Future<bool> requestPermission() async {
    if (!AppCapabilities.supportsShizuku) return false;
    return await channel.invokeMethod<bool>('requestPermission') ?? false;
  }

  Future<bool> openShizuku() async {
    if (!AppCapabilities.supportsShizuku) return false;
    return await channel.invokeMethod<bool>('openShizuku') ?? false;
  }
}
