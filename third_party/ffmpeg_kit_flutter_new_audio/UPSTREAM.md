# 本地副本说明

本目录是 [ffmpeg_kit_flutter_new_audio](https://pub.dev/packages/ffmpeg_kit_flutter_new_audio) 的**裁剪副本**，不是本仓库的原创代码。

- 固定版本：**2.5.8**
- 上游仓库：<https://github.com/sk3llo/ffmpeg_kit_flutter/tree/audio>
- 许可证：LGPL-3.0（见 [LICENSE](LICENSE)）

## 与上游发布包的差异

| 项目 | 处理 |
| --- | --- |
| `ios/`、`macos/`、`windows/`、`linux/` | 删除 |
| `example/`、`test/`、`scripts/`、`analysis_options.yaml` | 删除 |
| `pubspec.yaml` 的 `description` | 改为 `(vendored, Android only)` |
| `pubspec.yaml` 的 `flutter.plugin.platforms` | 仅保留 `android` |

`lib/` 与 `android/` 与上游 2.5.8 发布包逐字节一致。

## 为什么要裁剪

Windows 端的音频转码改用系统 `ffmpeg` / `ffprobe`（见 `lib/core/audio_converter.dart`）。保留上游的 Windows 实现会让 Flutter 注册该插件，并在构建时下载 FFmpeg 运行时。

## 升级

```powershell
pwsh tool/sync_ffmpeg_kit.ps1 -Version <新版本>
flutter pub get
flutter build apk --debug
```

脚本会重新下载上游发布包、删除非 Android 平台目录并收窄 `pubspec.yaml`；本文件不会被覆盖。升级后请查看 `CHANGELOG.md` 的破坏性改动。
