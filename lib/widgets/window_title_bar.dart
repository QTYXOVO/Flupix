import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import '../core/platform_capabilities.dart';
import '../l10n/l10n.dart';

/// 自定义标题栏高度，与 Windows 原生标题栏（32px）保持一致，
/// 这样隐藏原生标题栏后整体高度不会发生跳变。
const double kWindowTitleBarHeight = 32;

/// 自定义无边框窗口标题栏：
/// 左侧可拖拽区域（含应用图标与标题），右侧为最小化 / 最大化 / 关闭按钮。
///
/// 仅在 Windows 桌面端渲染；其他平台返回零尺寸占位。
class WindowTitleBar extends StatefulWidget {
  const WindowTitleBar({super.key, this.title = 'Flupix'});

  final String title;

  @override
  State<WindowTitleBar> createState() => _WindowTitleBarState();
}

class _WindowTitleBarState extends State<WindowTitleBar> {
  ListenerId? _listenerId;
  bool _isMaximized = false;

  Window? get _window {
    if (!AppCapabilities.usesCustomWindowChrome) return null;
    try {
      return WindowManager.instance.getCurrent();
    } catch (_) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _isMaximized = _readMaximized();
    if (AppCapabilities.usesCustomWindowChrome) {
      _listenerId = _addListener();
    }
  }

  bool _readMaximized() {
    final window = _window;
    if (window == null) return false;
    try {
      return window.isMaximized;
    } catch (_) {
      return false;
    }
  }

  ListenerId? _addListener() {
    try {
      // 在 WindowManager 级别监听最大化 / 还原事件，实时切换按钮图标。
      return WindowManager.instance.addListener((event) {
        if (event is WindowMaximizedEvent || event is WindowRestoredEvent) {
          final maximized = _readMaximized();
          if (mounted && maximized != _isMaximized) {
            setState(() => _isMaximized = maximized);
          }
        }
      });
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    final id = _listenerId;
    if (id != null) {
      try {
        WindowManager.instance.removeListener(id);
      } catch (_) {}
    }
    super.dispose();
  }

  void _minimize() {
    final window = _window;
    if (window == null) return;
    try {
      if (window.isMinimized) {
        window.restore();
      } else {
        window.minimize();
      }
    } catch (_) {}
  }

  void _toggleMaximize() {
    final window = _window;
    if (window == null) return;
    try {
      if (_isMaximized) {
        window.unmaximize();
      } else {
        window.maximize();
      }
    } catch (_) {}
  }

  void _close() {
    final window = _window;
    if (window == null) return;
    try {
      if (Window.isCloseSupported()) {
        window.close();
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (!AppCapabilities.usesCustomWindowChrome) {
      return const SizedBox.shrink();
    }

    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;

    return SizedBox(
      height: kWindowTitleBarHeight,
      child: Material(
        color: scheme.surface,
        child: Row(
          children: [
            Expanded(
              child: DragToMoveArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/app_icon.png',
                        width: 16,
                        height: 16,
                        filterQuality: FilterQuality.medium,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          widget.title,
                          style: textTheme.titleSmall?.copyWith(
                            color: scheme.onSurface,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _CaptionButton(
              icon: Icons.minimize_rounded,
              tooltip: l10n.windowMinimize,
              onTap: _minimize,
            ),
            MaximizeButtonArea(
              child: _CaptionButton(
                icon: _isMaximized
                    ? Icons.filter_none_rounded
                    : Icons.crop_square_rounded,
                tooltip: _isMaximized
                    ? l10n.windowRestore
                    : l10n.windowMaximize,
                onTap: _toggleMaximize,
              ),
            ),
            _CaptionButton(
              icon: Icons.close_rounded,
              tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
              onTap: _close,
              isClose: true,
            ),
          ],
        ),
      ),
    );
  }
}

/// 标题栏右侧的窗口控制按钮，带悬停高亮，关闭按钮悬停时变红。
class _CaptionButton extends StatefulWidget {
  const _CaptionButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.isClose = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool isClose;

  @override
  State<_CaptionButton> createState() => _CaptionButtonState();
}

class _CaptionButtonState extends State<_CaptionButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // 默认透明，与标题栏背景融为一体；悬停时浮现淡色高亮，关闭按钮悬停变红。
    final background = widget.isClose
        ? (_hovering ? scheme.error : Colors.transparent)
        : (_hovering
              ? scheme.onSurface.withValues(alpha: 0.08)
              : Colors.transparent);
    final foreground = widget.isClose
        ? (_hovering ? scheme.onError : scheme.onSurfaceVariant)
        : (_hovering ? scheme.onSurface : scheme.onSurfaceVariant);

    // 注：标题栏通过 MaterialApp.builder 注入在 Navigator 之上，没有 Overlay 祖先，
    // 因此不能使用 Tooltip（会抛 No Overlay widget found）。改用 Semantics 提供无障碍标签。
    return Semantics(
      label: widget.tooltip,
      button: true,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            width: 46,
            height: kWindowTitleBarHeight,
            color: background,
            alignment: Alignment.center,
            child: Icon(widget.icon, size: 18, color: foreground),
          ),
        ),
      ),
    );
  }
}
