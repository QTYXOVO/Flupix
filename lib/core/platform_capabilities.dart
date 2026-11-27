import 'package:flutter/foundation.dart';

/// 应用运行所在的宿主平台。Web 单独建模：dart:io 在 Web 上不可用。
enum HostPlatform { windows, android, ios, macos, linux, web, unknown }

/// 平台能力的唯一探测入口。
///
/// 业务代码不要直接读 `Platform.isXxx` 或 `kIsWeb`；新增/适配平台时只改这里。
abstract final class AppCapabilities {
  static HostPlatform get platform {
    if (kIsWeb) return HostPlatform.web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
        return HostPlatform.windows;
      case TargetPlatform.android:
        return HostPlatform.android;
      case TargetPlatform.iOS:
        return HostPlatform.ios;
      case TargetPlatform.macOS:
        return HostPlatform.macos;
      case TargetPlatform.linux:
        return HostPlatform.linux;
      case TargetPlatform.fuchsia:
        return HostPlatform.unknown;
    }
  }

  static bool get isWeb => platform == HostPlatform.web;
  static bool get isWindows => platform == HostPlatform.windows;
  static bool get isAndroid => platform == HostPlatform.android;
  static bool get isLinux => platform == HostPlatform.linux;
  static bool get isDesktop =>
      platform == HostPlatform.windows ||
      platform == HostPlatform.macos ||
      platform == HostPlatform.linux;
  static bool get isMobile =>
      platform == HostPlatform.android || platform == HostPlatform.ios;

  /// 是否使用 Flutter 自绘标题栏（无边框窗口）。
  static bool get usesCustomWindowChrome => isWindows;

  /// Shizuku 仅 Android 提供。
  static bool get supportsShizuku => isAndroid;

  /// 读取 Windows 系统代理（其余平台暂未实现）。
  static bool get supportsSystemProxy => isWindows;

  /// 阅读器的沉浸式系统 UI。
  static bool get usesImmersiveSystemUi => isAndroid;

  /// 音频转码走系统 ffmpeg。
  static bool get usesSystemAudioEngine => isWindows || isLinux;

  /// 保存文件走 Android MediaStore。
  static bool get savesFilesToMediaStore => isAndroid;

  /// 应用内下载安装使用的安装包后缀；null 表示当前平台不支持。
  static String? get installerExtension {
    if (isWindows) return '.exe';
    if (isAndroid) return '.apk';
    return null;
  }

  static bool get supportsInAppInstall => installerExtension != null;

  /// [pathOrUrl] 是否是可以应用内安装的包。
  static bool canInstallPackage(String pathOrUrl) {
    final extension = installerExtension;
    return extension != null && pathOrUrl.toLowerCase().endsWith(extension);
  }
}
