import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'app.dart';
import 'core/app_settings.dart';
import 'core/platform_capabilities.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (AppCapabilities.usesCustomWindowChrome) {
    await _configureWindow();
  }
  final settings = await AppSettings.load();
  runApp(FlupixApp(settings: settings));
}

/// Windows 桌面端：在首帧渲染（窗口显示）之前隐藏原生标题栏，
/// 改由 Flutter 自绘的标题栏接管，避免原生标题栏闪烁。
Future<void> _configureWindow() async {
  try {
    final window = WindowManager.instance.getCurrent();
    if (window == null) return;
    // hidden 仅隐藏标题栏与原生控制按钮，保留可拖拽调整大小的窗口边框。
    window.titleBarStyle = TitleBarStyle.hidden;
    window.title = 'Flupix';
  } catch (_) {
    // 窗口管理器不可用时回退到原生标题栏，不影响应用启动。
  }
}
