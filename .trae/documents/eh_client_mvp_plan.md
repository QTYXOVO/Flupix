# Flupix E-Hentai 客户端（第一期 MVP）实施计划

## Context

Flupix 目前是 Material You 风格的工具箱，已有 Pixiv 登录/Token 能力，但没有图库浏览能力。用户希望新增一个 E-Hentai 客户端，交互参考 Java 版 EhViewer，并确认：

- 平台：Android + Windows。
- 登录：内置 WebView 抓 Cookie（`ipb_member_id` / `ipb_pass_hash` / `sk` / `igneous`），同时支持手动粘贴 Cookie 兜底。
- 顺序：第一期只做「浏览 + 阅读」MVP；下载、收藏、历史、标签检索放到第二期。

第一期目标：用户能登录、搜索/筛选图库、打开详情、进入大图阅读器、退出后恢复阅读进度。所有解析与网络逻辑可单测，不引入重型状态管理框架。

## 范围

**做**：登录态、站点切换（E-Hentai / ExHentai）、Windows 代理、列表搜索与分类筛选、滚动分页、详情页、预览缩略图、阅读器（翻页/缩放/进度恢复）、509 与未登录提示、基础错误重试。

**不做（第二期）**：下载队列与离线库、收藏夹读写、历史页、标签翻译库、评论/评分、种子/归档、图片保存到相册。

## 架构

沿用 Flupix 现有约定：`StatefulWidget` + `ChangeNotifier`，无 Provider/Bloc；页面统一 `ToolPage`；网络用 `dart:io HttpClient + IOClient`；持久化用 `SharedPreferences`。

```
lib/core/eh/
  eh_models.dart        模型 + JSON 序列化
  eh_url.dart           E/EX 域名与各类 URL 构造
  eh_exceptions.dart    509 / Cloudflare / 未登录 / 解析 / 网络异常
  eh_client.dart        HTTP、Cookie、Referer、代理、重试
  eh_parser.dart        列表 / 详情 / 图片页解析（纯函数）
  eh_cookie_store.dart  Cookie 读写、手动粘贴解析、登录态判断
  eh_repository.dart    client + parser 编排、详情 LRU、pToken 补全
  eh_image.dart         EhImageProvider + 磁盘缓存
lib/tools/eh/
  eh_login_page.dart       WebView 登录 + 手动 Cookie + 站点/代理
  eh_browse_page.dart      搜索、分类、列表/网格、下拉刷新、分页
  eh_detail_page.dart      详情、标签、预览缩略图、继续阅读
  eh_reader_controller.dart 页状态机、预读、进度落盘
  eh_reader_page.dart      全屏阅读器 + 页码/进度条/错误层
```

修改：

- `lib/data/tool_registry.dart`：新增 `ToolItem(title: 'E-Hentai', icon: Icons.collections_bookmark, category: ToolCategory.other, builder: ...)`。
- `pubspec.yaml`：新增 `html`、`photo_view`、`path_provider`。
- 不改 `tool_item.dart`、AndroidManifest（`INTERNET` 已存在）。

## 数据模型

```dart
class GalleryItem {
  final int gid; final String token;
  final String title; final String thumbUrl;
  final String category; final double rating;
  final int pages; final String? uploader;
  String get detailUrl;
}

class GalleryDetail extends GalleryItem {
  final String? titleJpn;
  final int ratingCount; final int favoriteCount;
  final Map<String, List<String>> tags;
  final List<PreviewSet> previews;
}

class PreviewSet {           // 每 20 页一组
  final int startIndex;      // 0 基
  final String pToken;
  final List<String> thumbUrls;
}

class GalleryPage {
  final int index; final String pToken;
  final String pageUrl; final String imageUrl;
}

class EhCookie {
  final Map<String, String> values;
  String get headerValue;
  bool get isLoggedIn;       // ipb_member_id + ipb_pass_hash
  bool get hasExAccess;      // igneous 存在
}

class ReadingProgress {
  final int gid; final String token; final String title;
  final String thumbUrl; final int lastPage; // 1 基
  final int totalPages; final DateTime updatedAt;
}
```

## 网络与会话

`EhClient` 接口：

```dart
class EhClient {
  EhClient({required EhSession session});
  Future<String> getHtml(Uri url, {String? referer});
  Future<Uint8List> getBytes(Uri url, {required String referer});
  Future<Map<String, dynamic>> apiJson(Map<String, Object?> body);
}
```

- 代理：仅 `Platform.isWindows`。手动值优先，否则复用 `lib/core/pixiv_auth.dart` 中公开的 `readSystemProxy()`；Android 不加代理，交给系统 VPN。
- 请求头：桌面 Chrome UA、`Accept-Language: en-US,en;q=0.9`；HTML/API 请求带 `Cookie`，API 另带 `Origin`；图片请求只带 `Referer`（不把账号 Cookie 发给图片 CDN）。
- Cookie：`EhCookieStore` 存 `SharedPreferences` JSON，key `eh_cookie`；手动解析支持 `k=v; k=v` 和换行格式；站点切换时选 `e-hentai.org` 或 `exhentai.org` 作为主域。
- 超时 30s；仅网络异常与 5xx 重试 2 次（400ms / 900ms）；509、未登录、Cloudflare 不重试。
- 异常分类：
  - 509 / `Exceeded allowed hits` → `EhRateLimited`
  - 403/503 或正文含 `Just a moment` / `Cloudflare` → `EhCloudflare`
  - 正文含 `Sad Panda` / `not logged in` / 跳到登录页 → `EhAuthRequired`
  - 图片 content-type 非图片或魔数不匹配 → `EhParseException`

## 解析层

使用 `package:html`（DOM 自动解码实体），所有解析函数只接收字符串，便于单测。

**列表**（`https://{host}/?page=N&f_search=...&f_cats=...`）：

- 容器：`table.itg`（`.itg`）的第一个子节点，跳过表头行。
- 条目：参照 EhViewer 的 `.glname` / `.gl1t` / `.gl2c` / `.gl3c` / `.gl4c` / `.glhide` / `.ir` 结构；标题链接 `a[href^="/g/"]`，正则 `/g/(\d+)/([0-9a-f]+)/` 取 gid/token。
- 缩略图：`img[data-src]`，回退 `src`；只保留 URL，不下载。
- 分类：`.cn` / `.cs` 文本；评分：`.ir` 的 style 宽度解析（失败则留空）。
- 页数：条目内 `(\d+) page`；上传者：`.glhide` / `.gl3e` 对应子节点。
- 分页：`.ptt` 倒数第二个子节点为总页数；下一页链接正则 `page=(\d+)`。
- 缺 title/rating/pages 时按 25 条一批调 `api.php` 的 `gdata` 回填。

**详情**（`/g/{gid}/{token}/`）：

- `#gn` 标题、`#gj` 日文标题、`#gdc .cn/.cs` 分类、`#gdn` 上传者、`#rating_label` 评分、`#rating_count`。
- 页数：`#gdd` 中 `Length:` 行的 `([\d,]+) pages`。
- 标签：`#taglist tr`，`td.tc` 为分组名，`div.gt`/`.gtl` 为标签。
- 预览：`#gdt .gdtl`（大图）或 `.gdtm`（普通），取 `a[href*="/s/"]` 与 `img`；`a` 的 href 正则 `/s/([^/]+)/` 得 pToken，页号取 `alt` 或 URL 结尾 `-(\d+)`（转换为 0 基）。
- 详情 LRU：内存上限 25 条，避免重复请求。

**图片页**（`/s/{pToken}/{gid}-{page}`）：

- 优先 GET HTML，正则取：
  - `#img` 或首个带 `style` 的 `<img ... src="...">`
  - `var showkey="..."`（失败时无法走 API）
  - `onclick="return nl('...')"` 作为 `skipHathKey`
- HTML 解析不到图片 URL 时，POST `api.php`：

```json
{"method":"showpage","gid":123,"page":1,"imgkey":"<pToken>","showkey":"<showKey>"}
```

返回 `i3` 中解析 imageUrl、`i6` 中解析 skipHathKey。`api.php` 用 JSON body，不是表单。

**pToken 策略**：

1. 详情页 previews 建立 `index → pToken` 映射。
2. 缺页时请求详情 `?p={index ~/ 20}`（每个详情预览页 20 张），重新解析 previews 补全。
3. 不猜 pToken；补全失败直接报错并给出「从第一页开始」按钮。

## UI 与状态

**登录页** `EhLoginPage`：

- `InAppWebView` 打开 `https://forums.e-hentai.org/index.php?act=Login&CODE=01`。
- `onLoadStop` 依次读取 `https://forums.e-hentai.org/`、`https://e-hentai.org/`、`https://exhentai.org/` 的 Cookie 并合并；检测到 `ipb_member_id` + `ipb_pass_hash` 后允许完成。
- 切换 ExHentai 时访问 `https://exhentai.org/`，出现 `Sad Panda` 则提示无 EX 权限。
- 手动 Cookie 输入框 + 「校验」按钮：请求主页，正文含 `Logout` 视为成功。
- Windows 提供代理输入与「读取系统代理」；Android 隐藏代理配置。
- 参考 `lib/tools/pixiv_login_page.dart` 的 WebView 初始化/销毁与 `lib/tools/pixiv_token_page.dart` 的代理交互样式。

**浏览页** `EhBrowsePage`：

- `ToolPage(title: 'E-Hentai', actions: [站点切换, 设置])`。
- 顶部搜索框（提交重置到第 1 页）与分类 Chip（`f_cats` 是“隐藏分类”位掩码，默认 0；选中表示排除）。
- 宽屏 4 列 `SliverGrid`，窄屏列表；`RefreshIndicator`；`ScrollController` 距底约 600px 加载下一页；按 gid 去重。
- 空态 / 错误态 / 加载态用现有 `ui_kit.dart` 的风格。
- 未登录时列表仍可浏览（E-Hentai 允许游客看列表），详情/阅读页提示登录。

**详情页** `EhDetailPage`：

- 进入调用 `repository.detail(gid, token)`，命中缓存不再请求。
- 顶部封面 + 标题/日文标题 + 分类/页数/评分/上传者；标签分组展示（`Wrap` + Chip）。
- 前 20 页缩略图横向列表，点击直接跳到对应页。
- 主按钮：有进度显示「继续阅读 第 N 页」，否则「开始阅读」。

**阅读器** `EhReaderPage`：

- 依赖 `photo_view` 的 `PhotoViewGallery.builder`。理由：`PageView + InteractiveViewer` 放大后横滑存在手势竞技场冲突，需要大量自定义；`photo_view` 已处理缩放、双击、边界回弹，并支持自定义 `ImageProvider`。
- 全屏深色 `Scaffold`，点击中部切换工具栏；底部进度条可拖动跳页；右上角显示 `当前/总数`。
- 阅读方向 LTR/RTL 可切换（`reverse`）；双击缩放；加载失败显示单页重试。
- `EhReaderController extends ChangeNotifier`：持有模型、当前页、页状态（`idle/loading/ready/error`）、`Set<int> _inflight`；页变化时预读后 3 页，最多 2 并发；509 时暂停预读并显示倒计时。
- 进度：每次页变化防抖 500ms 写 `SharedPreferences`，key `eh_progress_{gid}`；`dispose` 立即补写。MVP 不引入 sqflite。

## 图片加载与缓存

`EhImageProvider extends ImageProvider<EhImageProvider>`：

- key = imageUrl + referer + Cookie 哈希。
- 先查磁盘缓存（`getApplicationSupportDirectory()/eh_image_cache`），命中直接解码；未命中用 `EhClient.getBytes`，校验图片魔数（JPEG `FFD8`、PNG `8950`、GIF、WebP `RIFF`）后写盘。
- 磁盘上限 512MB，按修改时间淘汰；内存交给 Flutter `imageCache`。
- Android 与 Windows 共用同一路径逻辑；不引入 `cached_network_image`（无法注入代理与动态 Cookie）。

## 分阶段实施

1. **基础设施**：新增依赖；实现 models / urls / exceptions / cookie store；`flutter analyze` 通过。
2. **网络与解析**：`EhClient` + `EhParser`；用固定 HTML 样例写 `test/eh_parser_test.dart`（列表、详情、图片页、Cookie 解析）；`flutter test` 通过。
3. **登录页**：WebView 抓 Cookie + 手动粘贴 + 站点/代理；Windows 先用手动 Cookie 验证登录态。
4. **入口与浏览**：注册工具卡片；列表搜索、分类、分页、刷新；Windows 手动测试。
5. **详情页**：详情解析、标签、预览缩略图、进度入口。
6. **阅读器**：pToken 补全、图片页解析、`PhotoViewGallery`、进度恢复、509/Cloudflare 错误层。
7. **回归**：`flutter analyze`、`flutter test`；Windows 全流程；Android 无线调试安装测试（WebView 登录、竖屏阅读、缩放）。

## 验证

- Windows：`flutter run -d windows`，手动 Cookie 登录 → 搜索 → 打开详情 → 阅读 3 页 → 退出重进恢复到原页；代理开关前后各验证一次。
- Android：`adb connect <ip>:5555` → `flutter devices` → `flutter run -d <device>`；验证 WebView 登录、ExHentai 切换、图片加载、返回键与进度保存。
- 单元测试：列表/详情/图片页各至少 1 个 HTML fixture；Cookie 解析覆盖分号与换行两种格式。
- 静态检查：`flutter analyze` 零 issue。

## 风险与规避

- **Cloudflare / ExHentai 未登录**：固定桌面 UA + 完整 Cookie（含 `igneous`）；失败时提供「打开网页验证」跳 WebView，验证后重抓 Cookie。
- **509 限流**：全局提示并停止预读/重试，倒计时结束后再试；不要并发重试。
- **图片防盗链**：图片请求必须带对应页面的 `Referer`；返回 HTML/403 时重新抓图片页换新 `showkey`。
- **HTML 结构变化**：选择器全部做「主路径 + 兜底」，缺字段不抛异常，尽量用 `api.php` 回填；解析异常保留状态码与响应片段用于诊断。
- **WebView Cookie 读取不全（HttpOnly）**：手动 Cookie 始终作为一级兜底；Windows WebView2 异常时直接引导手动粘贴。
- **photo_view 兼容性**：若与当前 Flutter SDK 冲突，退回 `PageView + InteractiveViewer` 并接受手势限制（该方案作为备选，不默认实施）。
- **平台差异**：Windows 代理手动/系统代理，Android 由 VPN 接管；两端图片缓存路径统一用 `path_provider`。

## 第二期预留

- 下载：单图库串行队列 + 图库内多并发，目录索引 JSON（对应 SpiderInfo），Windows 写用户选择目录，Android 用前台服务与通知。
- 收藏：本地表 + 云端 `favorites.php` 同步。
- 历史：独立页面与 100 条上限。
- 标签检索：标签翻译库与本地搜索建议。
