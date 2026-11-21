# Flupix

> Material You 风格的多功能工具箱，同时兼容 **Windows** 与 **Android** 平台。

常用小工具，随手即用。所有功能均在本地离线运行，不收集任何数据。

> **AI 生成说明**：本项目由 AI 生成，代码、文档与界面均在 AI 辅助下完成，仅供学习交流使用。

## 功能特性

- 🎨 **Material You 设计** — 由主题色动态生成整套色调，自带 8 种预设主题色（松绿、靛蓝、紫罗兰、天青、苔绿、琥珀、玫红、石墨）
- 🌓 **深浅色模式** — 浅色 / 深色 / 跟随系统，切换即时生效
- 🌐 **多语言** — 简体中文 / English / 跟随系统，全链路文案同步适配
- 🔒 **隐私优先** — 所有工具本地运行，账号凭证与 Cookie 仅保存在本机
- 🧩 **插件式架构** — 工具统一注册、分类展示，可按平台自动屏蔽不可用项

## 工具一览（共 16 项）

### 转换

| 工具 | 说明 |
| --- | --- |
| 单位换算 | 长度、面积、体积、质量、温度、速度、数据存储 |
| 表达式计算 | 支持括号、幂运算与四则混合计算，带历史记录 |
| 时间戳转换 | Unix 时间戳（秒 / 毫秒）与本地、UTC 时间互转 |
| 颜色工具 | HEX / RGB / HSL 互转，基于当前颜色生成 Material You 配色预览 |
| 音频格式转换 | MP3、WAV、FLAC、M4A、AAC、OGG 等格式互转（FFmpeg 离线转码） |

### 文本

| 工具 | 说明 |
| --- | --- |
| 文本编解码 | Base64 与 URL 编码、解码 |
| JSON 格式化 | 校验、格式化与压缩 JSON 文本 |
| Markdown 编辑 | 实时预览、语法快捷插入、草稿自动保存，支持 .md 导入导出 |
| 哈希计算 | MD5、SHA-1、SHA-256、SHA-512 |

### 生成

| 工具 | 说明 |
| --- | --- |
| 密码生成 | 加密安全随机数生成，支持字符集选择、排除易混淆字符与强度评估 |
| 二维码生成 | 文本 / 网址 / 联系方式生成可扫描二维码，可调尺寸与主题色 |

### 其他

| 工具 | 说明 | 平台 |
| --- | --- | --- |
| 节拍器 | BPM 调节、拍号重音、点击测速、音量控制与可视节拍 | 全平台 |
| 数字华容道 | 经典数字模式或自定义图片（1:1 裁切），支持 3×3 至 5×5 | 全平台 |
| QQ 表情包 | 借助 Shizuku（Root 模式）从 QQ 缓存保存表情到相册 | 仅 Android |
| E-Hentai | 搜索、浏览、收藏、下载与阅读 E-Hentai / ExHentai 图库 | 全平台 |
| Pixiv Token | OAuth 登录获取 access_token / refresh_token 与 PHPSESSID | 全平台 |

## 平台差异

- **网络代理**：仅在 Windows 端提供代理地址编辑界面，留空时自动读取系统代理；Android 端请使用系统 VPN。
- **Shizuku**：仅在 Android 端显示，需要 Root 权限的工具（如 QQ 表情包）通过 Shizuku 读取应用私有数据。
- **音频转码**：Android 端使用内置 FFmpegKit；Windows 端调用系统 `ffmpeg` / `ffprobe`，需先安装并加入系统 PATH。

## 环境要求

- Flutter SDK（Dart `^3.13.7`）
- Windows 10+ 或 Android 6.0+
- （可选）Windows 端音频转码需安装 [FFmpeg](https://ffmpeg.org/) 并加入 PATH
- （可选）Android 端 QQ 表情包功能需安装 [Shizuku](https://shizuku.rikka.app/) 并以 Root 模式启动

## 快速开始

```bash
# 安装依赖
flutter pub get

# 运行（Windows 桌面）
flutter run -d windows

# 运行（Android 设备 / 模拟器）
flutter run -d <device_id>

# 静态分析
flutter analyze

# 运行测试
flutter test
```

### 国内网络环境

若直接访问官方仓库超时，可配置镜像源：

```bash
# Flutter / Pub 镜像
set PUB_HOSTED_URL=https://pub.flutter-io.cn
set FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn
```

Android 构建建议在 `init.gradle` 中配置阿里云 Maven 镜像（需跳过子构建，避免与 Flutter 插件注入的仓库冲突）。

## 发布版本

推送 `v*` 标签会触发 [Release 工作流](.github/workflows/release.yml)，自动构建 Android APK 与 Windows x64 压缩包，并创建对应的 GitHub Release：

```bash
git tag v1.0.1
git push origin v1.0.1
```

也可以在 Actions 页面手动触发工作流（仅构建产物，不创建 Release）。应用内「设置 → 软件更新」会读取 GitHub Releases 中的最新版本进行提示。

Android 发布签名可选配置仓库 Secrets：`ANDROID_KEYSTORE_BASE64`（keystore 文件的 Base64）、`ANDROID_KEYSTORE_PASSWORD`、`ANDROID_KEY_ALIAS`、`ANDROID_KEY_PASSWORD`；未配置时使用 debug 签名构建。

## 项目结构

```
lib/
├── main.dart                # 应用入口
├── app.dart                 # MaterialApp 与主题 / 本地化装配
├── core/                    # 核心层（设置、主题、音频转换、网络会话等）
│   └── eh/                  # E-Hentai 客户端（会话、解析、下载、标签等）
├── data/
│   └── tool_registry.dart   # 工具注册与分类配色
├── models/                  # 数据模型
├── screens/                 # 首页、设置页
├── tools/                   # 各工具页面实现
│   └── eh/                  # E-Hentai 相关页面
├── widgets/                 # 通用 UI 组件
└── l10n/                    # 国际化资源（zh / en）与生成代码
```

## 依赖说明

项目主要依赖：`crypto`、`qr_flutter`、`shared_preferences`、`http`、`flutter_inappwebview`、`flutter_markdown_plus`、`file_picker`、`html`、`photo_view`、`path_provider`、`audioplayers`。

`ffmpeg_kit_flutter_new_audio` 以本地副本形式置于 `third_party/`，仅保留 Android 实现；Windows 端改用系统 FFmpeg，避免构建时下载运行时。

## 测试

项目包含单元测试，覆盖音频转换、E-Hentai 解析与下载逻辑：

```bash
flutter test
```

## 参考项目

开发过程中参考了以下开源项目的交互设计与实现思路，特此致谢：

| 项目 | 参考内容 | 来源地址 |
| --- | --- | --- |
| EhViewer（Java 版） | E-Hentai 客户端的交互流程、页面解析与下载状态管理 | https://github.com/seven332/EhViewer |
| EhPanda | ExHentai 登录后换取 igneous 的处理方式 | https://github.com/EhPanda-Team/EhPanda |
| pixivpy | pixiv OAuth 客户端参数与登录流程 | https://github.com/upbit/pixivpy |

## License

本项目仅供学习交流使用。第三方依赖各自遵循其原始许可证，详见对应包的说明。
