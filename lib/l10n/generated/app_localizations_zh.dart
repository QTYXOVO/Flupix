// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get commonCopy => '复制';

  @override
  String get commonCopied => '已复制到剪贴板';

  @override
  String get commonClear => '清空';

  @override
  String get commonCancel => '取消';

  @override
  String get commonConfirm => '确定';

  @override
  String get commonSave => '保存';

  @override
  String get commonDelete => '删除';

  @override
  String get commonRetry => '重试';

  @override
  String get commonRefresh => '刷新';

  @override
  String get commonSearch => '搜索';

  @override
  String get commonClose => '关闭';

  @override
  String get commonLoading => '加载中…';

  @override
  String get commonEmpty => '暂无内容';

  @override
  String get commonAll => '全部';

  @override
  String get commonSettings => '设置';

  @override
  String get commonOpen => '打开';

  @override
  String get commonStart => '开始';

  @override
  String get commonStop => '停止';

  @override
  String get commonPause => '暂停';

  @override
  String get commonResume => '继续';

  @override
  String get commonDone => '完成';

  @override
  String get commonEdit => '编辑';

  @override
  String get commonAdd => '添加';

  @override
  String get commonRemove => '移除';

  @override
  String get commonSelectAll => '全选';

  @override
  String get commonDeselectAll => '取消全选';

  @override
  String get commonUnknown => '未知';

  @override
  String get commonError => '出错了';

  @override
  String get commonSuccess => '操作成功';

  @override
  String get commonYes => '是';

  @override
  String get commonNo => '否';

  @override
  String get commonBrowse => '浏览';

  @override
  String get commonPickFile => '选择文件';

  @override
  String get commonShare => '分享';

  @override
  String get commonPreview => '预览';

  @override
  String get commonApply => '应用';

  @override
  String get commonMore => '更多';

  @override
  String get commonBack => '返回';

  @override
  String get homeSubtitle => '常用小工具，随手即用';

  @override
  String homeToolCount(int count) {
    return '共 $count 项 · 全部离线运行';
  }

  @override
  String get homeFilterAll => '全部';

  @override
  String get homeSettingsTooltip => '设置';

  @override
  String get homeDisabledBadge => '当前平台不可用';

  @override
  String get homeShizukuPermissionTitle => '需要 Shizuku 授权';

  @override
  String get homeShizukuCannotRead => '无法读取 Shizuku 状态，请前往设置检查授权。';

  @override
  String get homeShizukuNotInstalled => '未安装 Shizuku。请先安装 Shizuku，再到设置中完成授权。';

  @override
  String get homeShizukuNotRunning =>
      'Shizuku 未运行。请打开 Shizuku 并通过 Root 启动服务，再到设置中授权。';

  @override
  String get homeShizukuNotGranted => '尚未授权 Flupix 使用 Shizuku，请前往设置完成授权。';

  @override
  String get homeShizukuNotRoot => 'Shizuku 当前不是 Root 模式，请以 Root 启动后到设置中授权。';

  @override
  String get homeShizukuGoSettingsHint => '请前往设置完成 Shizuku 授权。';

  @override
  String get homeShizukuGoSettings => '去设置';

  @override
  String get categoryConvert => '转换';

  @override
  String get categoryText => '文本';

  @override
  String get categoryGenerate => '生成';

  @override
  String get categoryOther => '其他';

  @override
  String get toolUnitConverterTitle => '单位换算';

  @override
  String get toolUnitConverterDesc => '长度、面积、体积、质量、温度、速度、数据存储';

  @override
  String get toolCalculatorTitle => '表达式计算';

  @override
  String get toolCalculatorDesc => '支持括号、幂运算与四则混合计算';

  @override
  String get toolTextCodecTitle => '文本编解码';

  @override
  String get toolTextCodecDesc => 'Base64 与 URL 编码、解码';

  @override
  String get toolJsonTitle => 'JSON 格式化';

  @override
  String get toolJsonDesc => '校验、格式化与压缩 JSON 文本';

  @override
  String get toolMarkdownTitle => 'Markdown 编辑';

  @override
  String get toolMarkdownDesc => '实时预览、语法快捷插入与草稿保存';

  @override
  String get toolHashTitle => '哈希计算';

  @override
  String get toolHashDesc => 'MD5、SHA-1、SHA-256、SHA-512';

  @override
  String get toolTimestampTitle => '时间戳转换';

  @override
  String get toolTimestampDesc => 'Unix 时间戳与日期时间互转';

  @override
  String get toolColorTitle => '颜色工具';

  @override
  String get toolColorDesc => 'HEX / RGB / HSL 互转与配色预览';

  @override
  String get toolAudioConvertTitle => '音频格式转换';

  @override
  String get toolAudioConvertDesc => 'MP3、WAV、FLAC、M4A 等格式互转';

  @override
  String get toolPasswordTitle => '密码生成';

  @override
  String get toolPasswordDesc => '安全随机密码与强度评估';

  @override
  String get toolQrTitle => '二维码生成';

  @override
  String get toolQrDesc => '将文本生成可扫描的二维码';

  @override
  String get toolMetronomeTitle => '节拍器';

  @override
  String get toolMetronomeDesc => 'BPM 调节、拍号重音、点击测速与可视节拍';

  @override
  String get toolPuzzleTitle => '数字华容道';

  @override
  String get toolPuzzleDesc => '自定义图片与 1:1 裁切，支持 3×3 至 5×5';

  @override
  String get toolQqStickerTitle => 'QQ 表情包';

  @override
  String get toolQqStickerDesc => '借助 Shizuku Root 权限，从 QQ 缓存保存表情到相册';

  @override
  String get toolEhTitle => 'E-Hentai';

  @override
  String get toolEhDesc => '搜索、浏览与阅读 E-Hentai / ExHentai 图库';

  @override
  String get toolPixivTitle => 'Pixiv Token';

  @override
  String get toolPixivDesc => 'OAuth 登录获取 access_token 与 PHPSESSID';

  @override
  String get settingsTitle => '设置';

  @override
  String get settingsSubtitleAndroid => '外观、主题与权限';

  @override
  String get settingsSubtitleDesktop => '外观、主题与网络';

  @override
  String get settingsAppearanceMode => '外观模式';

  @override
  String get settingsThemeSystem => '系统';

  @override
  String get settingsThemeLight => '浅色';

  @override
  String get settingsThemeDark => '深色';

  @override
  String get settingsSeedColor => '主题色';

  @override
  String get settingsSeedColorHint => 'Material You 会由主题色生成整套色调';

  @override
  String get settingsLanguage => '语言';

  @override
  String get settingsLanguageSystem => '跟随系统';

  @override
  String get settingsLanguageChinese => '简体中文';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsShowDisabled => '显示已禁用的功能';

  @override
  String get settingsShowDisabledHint => '在首页显示当前系统无法使用或尚未实现的功能，卡片会置灰且不可点击。';

  @override
  String get settingsProxyTitle => '网络代理';

  @override
  String get settingsProxyDescription =>
      '供 Pixiv 与 E-Hentai 等工具使用；留空时自动读取 Windows 系统代理，Android 端请使用系统 VPN。';

  @override
  String get settingsProxyAddress => '代理地址';

  @override
  String get settingsProxySave => '保存代理';

  @override
  String get settingsProxySaving => '保存中…';

  @override
  String get settingsProxyReadSystem => '读取系统代理';

  @override
  String settingsProxySaved(String address) {
    return '代理已保存：$address';
  }

  @override
  String get settingsProxyDirect => '已切换为直连';

  @override
  String get settingsProxySystemMissing => '未检测到已启用的系统代理，请先开启代理软件';

  @override
  String get settingsShizukuTitle => 'Shizuku 授权';

  @override
  String get settingsShizukuDescription => '需要 Root 权限的工具会通过 Shizuku 读取应用私有数据。';

  @override
  String get settingsShizukuChecking => '正在检测 Shizuku…';

  @override
  String get settingsShizukuError =>
      '无法读取 Shizuku 状态，请确认设备为 Android 且已安装 Shizuku。';

  @override
  String get settingsShizukuGrant => '授权 Shizuku';

  @override
  String get settingsShizukuGranting => '授权中…';

  @override
  String get settingsShizukuOpen => '打开 Shizuku';

  @override
  String get settingsShizukuRefresh => '重新检测';

  @override
  String get settingsShizukuGrantedRoot => '已授权（Root）';

  @override
  String get settingsShizukuNotInstalled => '未安装 Shizuku';

  @override
  String get settingsShizukuNotRunning => 'Shizuku 未运行';

  @override
  String get settingsShizukuNotGranted => '未授权';

  @override
  String settingsShizukuInsufficient(String uid) {
    return '权限不足（uid=$uid）';
  }

  @override
  String get settingsShizukuInstallHint => '请先安装 Shizuku 应用，再返回此处授权。';

  @override
  String get settingsShizukuRunHint => '请打开 Shizuku，并通过 Root 启动服务。';

  @override
  String get settingsShizukuGrantHint => '允许 Flupix 访问 Shizuku 后才能读取 QQ 表情缓存。';

  @override
  String get settingsShizukuRootHint => '请停止 Shizuku，并以 Root（uid=0）重新启动。';

  @override
  String get settingsShizukuReadyHint =>
      'Flupix 已获得 Root 权限，可用于需要 Shizuku 的工具。';

  @override
  String get settingsShizukuGrantedMessage => 'Shizuku 授权成功';

  @override
  String get settingsShizukuDeniedMessage => 'Shizuku 授权被拒绝';

  @override
  String settingsShizukuRequestFailed(String error) {
    return '请求授权失败：$error';
  }

  @override
  String get settingsShizukuNotFound => '未找到 Shizuku 应用';

  @override
  String settingsShizukuOpenFailed(String error) {
    return '无法打开 Shizuku：$error';
  }

  @override
  String settingsUpdateCurrentVersion(String version) {
    return '当前版本 $version';
  }

  @override
  String get settingsUpdateCheck => '检查更新';

  @override
  String get settingsUpdateChecking => '检查中…';

  @override
  String settingsUpdateLatest(String version) {
    return '已是最新版本（$version）';
  }

  @override
  String settingsUpdateCheckFailed(String error) {
    return '检查更新失败：$error';
  }

  @override
  String settingsUpdateAvailableTitle(String version) {
    return '发现新版本 $version';
  }

  @override
  String get settingsUpdateReleaseNotes => '更新内容';

  @override
  String get settingsUpdateNoNotes => '该版本没有提供更新说明。';

  @override
  String get settingsUpdateDownload => '前往下载';

  @override
  String get settingsUpdateOpenReleases => '打开发布页';

  @override
  String get settingsUpdateOpenFailed => '无法打开链接';

  @override
  String settingsAboutVersion(String version) {
    return '版本 $version · Flutter + Material You';
  }

  @override
  String get settingsAboutPrivacy => '所有工具均在本地运行，不收集任何数据。';

  @override
  String get seedPine => '松绿';

  @override
  String get seedIndigo => '靛蓝';

  @override
  String get seedViolet => '紫罗兰';

  @override
  String get seedSky => '天青';

  @override
  String get seedMoss => '苔绿';

  @override
  String get seedAmber => '琥珀';

  @override
  String get seedRose => '玫红';

  @override
  String get seedGraphite => '石墨';

  @override
  String get textCodecTitle => '文本编解码';

  @override
  String get textCodecSubtitle => 'Base64 与 URL 编码互转';

  @override
  String get textCodecEncode => '编码';

  @override
  String get textCodecDecode => '解码';

  @override
  String get textCodecInputLabel => '输入内容';

  @override
  String get textCodecInputEncodeHint => '输入需要编码的文本';

  @override
  String get textCodecInputDecodeHint => '粘贴需要解码的内容';

  @override
  String textCodecCharCount(int count) {
    return '$count 个字符';
  }

  @override
  String get textCodecResultTitle => '转换结果';

  @override
  String get textCodecCopyResult => '复制结果';

  @override
  String get textCodecResultPlaceholder => '结果会显示在这里';

  @override
  String get textCodecInvalidBase64 => 'Base64 内容无效，无法解码';

  @override
  String get textCodecInvalidUrl => 'URL 编码格式无效，无法解码';

  @override
  String get textCodecConvertFailed => '转换失败，请检查输入内容';

  @override
  String get jsonTitle => 'JSON 格式化';

  @override
  String get jsonSubtitle => '校验、格式化与压缩 JSON 文本';

  @override
  String get jsonInputLabel => 'JSON 内容';

  @override
  String jsonInputHint(String leftBrace, String rightBrace) {
    return '粘贴 JSON 文本，例如 $leftBrace\"name\": \"Flupix\"$rightBrace';
  }

  @override
  String get jsonFormat => '格式化';

  @override
  String get jsonMinify => '压缩';

  @override
  String get jsonOutputTitle => '输出结果';

  @override
  String get jsonCopyResult => '复制结果';

  @override
  String get jsonOutputPlaceholder => '格式化后的 JSON 会显示在这里';

  @override
  String get jsonEmptyInput => '请输入 JSON 内容';

  @override
  String jsonValidMeta(int count) {
    return 'JSON 有效 · $count 个字符';
  }

  @override
  String jsonParseFailed(String error) {
    return '解析失败：$error';
  }

  @override
  String get markdownTitle => 'Markdown 编辑';

  @override
  String get markdownSubtitle => 'GFM 预览 · .md 导入导出';

  @override
  String get markdownOpenFileTooltip => '打开 .md 文件';

  @override
  String get markdownExportTooltip => '导出为 .md 文件';

  @override
  String markdownStats(int lines, int chars) {
    return '$lines 行 · $chars 字符';
  }

  @override
  String get markdownHeading1 => '一级标题';

  @override
  String get markdownHeading2 => '二级标题';

  @override
  String get markdownBold => '粗体';

  @override
  String get markdownItalic => '斜体';

  @override
  String get markdownInlineCode => '行内代码';

  @override
  String get markdownBulletList => '无序列表';

  @override
  String get markdownOrderedList => '有序列表';

  @override
  String get markdownTaskList => '任务列表';

  @override
  String get markdownQuote => '引用';

  @override
  String get markdownLink => '链接';

  @override
  String get markdownLinkPlaceholder => '链接文字';

  @override
  String get markdownCodeBlock => '代码块';

  @override
  String get markdownTable => '表格';

  @override
  String get markdownTableTemplate => '| 列一 | 列二 |\n| --- | --- |\n| 内容 | 内容 |';

  @override
  String get markdownDivider => '分隔线';

  @override
  String get markdownEditorHint => '# 在这里开始写 Markdown…';

  @override
  String get markdownDraftSavedLocally => '草稿自动保存在本机';

  @override
  String markdownDraftAutoSaved(String name) {
    return '$name · 草稿自动保存';
  }

  @override
  String get markdownSourceCopied => '已复制 Markdown 源码';

  @override
  String get markdownPreviewPlaceholder => '左侧输入的 Markdown 会实时渲染在这里';

  @override
  String get markdownClearTitle => '清空内容？';

  @override
  String get markdownClearMessage => '当前草稿会被删除，且无法恢复。';

  @override
  String get markdownLinkCopied => '已复制链接';

  @override
  String get markdownOpenDialogTitle => '打开 Markdown 文件';

  @override
  String markdownOpened(String name) {
    return '已打开 $name';
  }

  @override
  String markdownOpenFailed(String error) {
    return '打开失败：$error';
  }

  @override
  String get markdownUntitledFileName => '未命名.md';

  @override
  String get markdownExportDialogTitle => '导出 Markdown';

  @override
  String markdownExported(String name) {
    return '已导出 $name';
  }

  @override
  String markdownExportFailed(String error) {
    return '导出失败：$error';
  }

  @override
  String get hashTitle => '哈希计算';

  @override
  String get hashSubtitle => '把文本转换为不可逆的摘要值';

  @override
  String get hashInputLabel => '输入文本';

  @override
  String get hashInputHint => '输入或粘贴需要计算哈希的内容';

  @override
  String hashByteCount(int count) {
    return 'UTF-8 编码 · $count 字节';
  }

  @override
  String get hashEmptyHint => '输入文本后会自动计算 MD5、SHA-1、SHA-256 与 SHA-512。';

  @override
  String get unitPageTitle => '单位换算';

  @override
  String get unitPageSubtitle => '选择分类后输入数值，实时换算';

  @override
  String get unitCategoryLength => '长度';

  @override
  String get unitCategoryArea => '面积';

  @override
  String get unitCategoryVolume => '体积';

  @override
  String get unitCategoryMass => '质量';

  @override
  String get unitCategoryTemperature => '温度';

  @override
  String get unitCategorySpeed => '速度';

  @override
  String get unitCategoryDataStorage => '数据存储';

  @override
  String get unitKilometer => '千米';

  @override
  String get unitMeter => '米';

  @override
  String get unitDecimeter => '分米';

  @override
  String get unitCentimeter => '厘米';

  @override
  String get unitMillimeter => '毫米';

  @override
  String get unitMicrometer => '微米';

  @override
  String get unitNanometer => '纳米';

  @override
  String get unitMile => '英里';

  @override
  String get unitYard => '码';

  @override
  String get unitFoot => '英尺';

  @override
  String get unitInch => '英寸';

  @override
  String get unitNauticalMile => '海里';

  @override
  String get unitLi => '里';

  @override
  String get unitZhang => '丈';

  @override
  String get unitChi => '尺';

  @override
  String get unitCun => '寸';

  @override
  String get unitSquareKilometer => '平方千米';

  @override
  String get unitHectare => '公顷';

  @override
  String get unitMu => '亩';

  @override
  String get unitSquareMeter => '平方米';

  @override
  String get unitSquareDecimeter => '平方分米';

  @override
  String get unitSquareCentimeter => '平方厘米';

  @override
  String get unitAcre => '英亩';

  @override
  String get unitSquareFoot => '平方英尺';

  @override
  String get unitSquareInch => '平方英寸';

  @override
  String get unitCubicMeter => '立方米';

  @override
  String get unitLiter => '升';

  @override
  String get unitMilliliter => '毫升';

  @override
  String get unitCubicCentimeter => '立方厘米';

  @override
  String get unitGallonUs => '加仑（美）';

  @override
  String get unitQuartUs => '夸脱（美）';

  @override
  String get unitCubicFoot => '立方英尺';

  @override
  String get unitCubicInch => '立方英寸';

  @override
  String get unitTonne => '吨';

  @override
  String get unitKilogram => '千克';

  @override
  String get unitGram => '克';

  @override
  String get unitMilligram => '毫克';

  @override
  String get unitJin => '斤';

  @override
  String get unitLiang => '两';

  @override
  String get unitPound => '磅';

  @override
  String get unitOunce => '盎司';

  @override
  String get unitCarat => '克拉';

  @override
  String get unitCelsius => '摄氏度';

  @override
  String get unitFahrenheit => '华氏度';

  @override
  String get unitKelvin => '开尔文';

  @override
  String get unitMeterPerSecond => '米/秒';

  @override
  String get unitKilometerPerHour => '千米/时';

  @override
  String get unitMeterPerMinute => '米/分';

  @override
  String get unitMilePerHour => '英里/时';

  @override
  String get unitKnot => '节';

  @override
  String get unitFootPerSecond => '英尺/秒';

  @override
  String get unitBit => '位';

  @override
  String get unitByte => '字节';

  @override
  String get unitKilobyte => '千字节';

  @override
  String get unitMegabyte => '兆字节';

  @override
  String get unitGigabyte => '吉字节';

  @override
  String get unitTerabyte => '太字节';

  @override
  String get unitInputLabel => '输入';

  @override
  String get unitFromLabel => '单位';

  @override
  String get unitValueLabel => '数值';

  @override
  String get unitSwapTooltip => '交换单位';

  @override
  String get unitToLabel => '换算为';

  @override
  String get unitResultTitle => '换算结果';

  @override
  String get unitCopyResultTooltip => '复制结果';

  @override
  String get unitEnterValidValue => '请输入有效数值';

  @override
  String unitConversionFormula(String from, String value, String to) {
    return '1 $from = $value $to';
  }

  @override
  String get timestampPageTitle => '时间戳转换';

  @override
  String get timestampPageSubtitle => 'Unix 时间戳与本地、UTC 时间互转';

  @override
  String get timestampCurrentTime => '当前时间';

  @override
  String get timestampSeconds => '秒级时间戳';

  @override
  String get timestampMilliseconds => '毫秒级时间戳';

  @override
  String get timestampUtcIso => 'UTC 时间（ISO 8601）';

  @override
  String get timestampToDateTime => '时间戳 → 日期时间';

  @override
  String get timestampLabel => '时间戳';

  @override
  String get timestampHint => '支持秒级或毫秒级，自动识别';

  @override
  String get timestampNow => '当前';

  @override
  String get timestampLocalTime => '本地时间';

  @override
  String get timestampUtcTime => 'UTC 时间';

  @override
  String get timestampIso8601 => 'ISO 8601';

  @override
  String get timestampEmptyHint => '输入时间戳后显示对应日期时间';

  @override
  String get timestampFromDateTime => '日期时间 → 时间戳';

  @override
  String get timestampPick => '选择';

  @override
  String get timestampErrorNotInteger => '请输入整数时间戳';

  @override
  String get timestampErrorOutOfRange => '时间戳超出可表示范围';

  @override
  String get colorPageTitle => '颜色工具';

  @override
  String get colorPageSubtitle => 'HEX / RGB / HSL 互转与 Material You 配色';

  @override
  String get colorHexLabel => 'HEX 颜色';

  @override
  String get colorChannelAdjust => '调整通道';

  @override
  String get colorPreviewTitle => '配色预览';

  @override
  String get colorPreviewSubtitle => '基于当前颜色生成的 Material You 色调';

  @override
  String get colorSwatchPrimary => '主色';

  @override
  String get colorSwatchSecondary => '次色';

  @override
  String get colorSwatchTertiary => '第三色';

  @override
  String get colorSwatchContainer => '容器色';

  @override
  String get colorSwatchSurface => '表面';

  @override
  String get colorSwatchSurfaceHigh => '强调表面';

  @override
  String get colorErrorInvalidHex => '请输入有效的 HEX 颜色，如 #3A7BD5';

  @override
  String get calculatorPageTitle => '表达式计算';

  @override
  String get calculatorPageSubtitle => '支持括号、幂与四则混合运算';

  @override
  String get calculatorHint => '输入表达式，如 (3+5)×2^3';

  @override
  String get calculatorHistory => '历史记录';

  @override
  String get calculatorClearHistory => '清空历史';

  @override
  String get calculatorEmptyExpression => '请输入表达式';

  @override
  String get expressionEmpty => '请输入表达式';

  @override
  String get expressionUnmatchedParenthesis => '括号不匹配';

  @override
  String get expressionIncomplete => '表达式不完整';

  @override
  String get expressionInvalidResult => '结果无效';

  @override
  String get expressionDivideByZero => '除数不能为 0';

  @override
  String expressionUnknownOperator(String operator) {
    return '未知运算符 $operator';
  }

  @override
  String expressionInvalidNumber(String number) {
    return '数字格式有误: $number';
  }

  @override
  String expressionUnknownCharacter(String char) {
    return '无法识别字符 \"$char\"';
  }

  @override
  String get weekdayMonday => '周一';

  @override
  String get weekdayTuesday => '周二';

  @override
  String get weekdayWednesday => '周三';

  @override
  String get weekdayThursday => '周四';

  @override
  String get weekdayFriday => '周五';

  @override
  String get weekdaySaturday => '周六';

  @override
  String get weekdaySunday => '周日';

  @override
  String get audioConvertTitle => '音频格式转换';

  @override
  String get audioConvertSubtitle => 'MP3、WAV、FLAC、M4A 等格式互转';

  @override
  String get audioSelectAudioFile => '选择音频文件';

  @override
  String audioReadFailed(String error) {
    return '读取音频失败：$error';
  }

  @override
  String get audioConvertDoneHint => '转换完成，可保存到本地';

  @override
  String get audioConvertCancelled => '已取消转换';

  @override
  String get audioConvertFailedToast => '转换失败';

  @override
  String audioSavedName(String name) {
    return '已保存 $name';
  }

  @override
  String audioSaveFailed(String error) {
    return '保存失败：$error';
  }

  @override
  String get audioSaveAudioFile => '保存音频文件';

  @override
  String get audioSizeUnknown => '大小未知';

  @override
  String get audioChannelsUnknown => '声道未知';

  @override
  String get audioMono => '单声道';

  @override
  String get audioStereo => '立体声';

  @override
  String audioChannelsCount(int count) {
    return '$count 声道';
  }

  @override
  String audioConvertTo(String format) {
    return '转换为 $format';
  }

  @override
  String audioEngineLine(String version) {
    return 'FFmpeg $version · 转码在本机离线完成';
  }

  @override
  String get audioEngineLoading => '加载中';

  @override
  String get audioSupportedFormats => '支持 MP3、WAV、FLAC、M4A、AAC、OGG 等格式';

  @override
  String get audioChangeFile => '更换文件';

  @override
  String get audioUnknownCodec => '未知编码';

  @override
  String get audioBrowseLocal => '浏览本地文件';

  @override
  String get audioOutputFormat => '输出格式';

  @override
  String get audioBitrate => '码率';

  @override
  String audioBitrateValue(String value) {
    return '$value kbps';
  }

  @override
  String get audioBitDepth => '位深';

  @override
  String get audioBitDepth16 => '16 位';

  @override
  String get audioBitDepth24 => '24 位';

  @override
  String get audioBitDepthFloat32 => '32 位浮点';

  @override
  String get audioSampleRate => '采样率';

  @override
  String get audioKeepOriginal => '保持原样';

  @override
  String get audioChannels => '声道';

  @override
  String audioConvertingTo(String format) {
    return '正在转换为 $format';
  }

  @override
  String get audioProcessing => '处理中';

  @override
  String audioSpeedValue(String speed) {
    return '速度 ${speed}x';
  }

  @override
  String get audioPreparing => '准备中…';

  @override
  String get audioConvertDoneTitle => '转换完成';

  @override
  String get audioSaving => '保存中…';

  @override
  String get audioSaveFile => '保存文件';

  @override
  String get audioFfprobeNotFound => '未找到 ffprobe，请先安装 FFmpeg 并加入系统 PATH';

  @override
  String get audioFfmpegNotFound => '未找到 ffmpeg，请先安装 FFmpeg 并加入系统 PATH';

  @override
  String get audioProbeParseFailed => '无法解析音频信息';

  @override
  String get audioNoAudioStream => '未在文件中找到音频流';

  @override
  String get audioConvertFailedHint => '转码失败，请确认音频文件可正常播放';

  @override
  String get audioConvertFailed => '转码失败';

  @override
  String get metronomeTitle => '节拍器';

  @override
  String get metronomeSubtitle => '调节 BPM、拍号重音与音量，支持点击测速';

  @override
  String get metronomeDecreaseBpm => '减少 1 BPM';

  @override
  String get metronomeIncreaseBpm => '增加 1 BPM';

  @override
  String get metronomeTapTempo => '点击测速';

  @override
  String get metronomeTempo => '速度';

  @override
  String metronomeBpmValue(int bpm) {
    return '$bpm BPM';
  }

  @override
  String get metronomeBeatsPerBar => '每小节拍数';

  @override
  String get metronomeAccent => '小节重音';

  @override
  String get metronomeAccentHint => '每小节第一拍使用更高音与高亮显示';

  @override
  String get metronomeSound => '声音提示';

  @override
  String get metronomeSoundHint => '关闭后仅保留可视节拍';

  @override
  String get metronomeVolume => '音量';

  @override
  String get puzzleTitle => '数字华容道';

  @override
  String get puzzleSubtitlePlaying => '点击与空格相邻的方块滑动';

  @override
  String get puzzleSubtitleSetup => '自定义图片与 1:1 裁切';

  @override
  String get puzzleSelectImage => '选择图片';

  @override
  String puzzleImportFailed(String error) {
    return '导入图片失败：$error';
  }

  @override
  String get puzzleSolvedTitle => '拼好了';

  @override
  String puzzleSolvedStats(String elapsed, int moves) {
    return '用时 $elapsed · $moves 步';
  }

  @override
  String get puzzleBackToSetup => '返回设置';

  @override
  String get puzzlePlayAgain => '再来一局';

  @override
  String get puzzleClassicMode => '经典数字模式';

  @override
  String get puzzleCustomImage => '自定义图片';

  @override
  String get puzzlePickImageHint => '选择一张图片，导入时可拖动、缩放决定 1:1 裁切区域。';

  @override
  String get puzzleCropSavedHint => '已保存 1:1 裁切区域，可随时更换图片或重新裁切。';

  @override
  String get puzzleImporting => '导入中…';

  @override
  String get puzzleChangeImage => '更换图片';

  @override
  String get puzzleDifficulty => '难度';

  @override
  String get puzzleDifficultyHint => '方块越多越难，建议从 3 × 3 开始。';

  @override
  String get puzzleHowToPlay => '点击空格相邻的方块即可交换位置，把图片或数字按顺序还原即获胜。';

  @override
  String get puzzleStartGame => '开始游戏';

  @override
  String get puzzleMoves => '步数';

  @override
  String get puzzleTime => '用时';

  @override
  String get puzzleViewOriginal => '查看原图';

  @override
  String get puzzleShuffle => '重新打乱';

  @override
  String get puzzleShowNumbers => '显示数字';

  @override
  String get puzzleSolvedHint => '已完成，点击「重新打乱」再来一局';

  @override
  String get puzzleSlideHint => '点击与空格相邻的方块即可滑动';

  @override
  String get puzzleSelectCrop => '选择裁切区域';

  @override
  String get puzzleCropHint => '拖动图片调整位置，双指缩放或使用滑块放大；方框内即为最终 1:1 画面。';

  @override
  String get puzzleReset => '重置';

  @override
  String get puzzleUseArea => '使用此区域';

  @override
  String get qqStickerTitle => 'QQ 表情包';

  @override
  String get qqStickerSubtitle => '从 QQ 缓存提取并保存到相册';

  @override
  String get qqStickerReadStatusFailed => '读取 Shizuku 状态失败';

  @override
  String qqStickerReadStatusFailedDetail(String error) {
    return '读取 Shizuku 状态失败：$error';
  }

  @override
  String get qqStickerNoStickers => '未找到可保存的表情';

  @override
  String qqStickerFoundPacks(int count) {
    return '共找到 $count 个表情包';
  }

  @override
  String get qqStickerScanFailed => '扫描 QQ 表情缓存失败';

  @override
  String qqStickerScanFailedDetail(String error) {
    return '扫描失败：$error';
  }

  @override
  String get qqStickerSaveFailedRetry => '保存失败，请重试';

  @override
  String qqStickerSavedToFolder(int saved) {
    return '已保存 $saved 张表情到 Pictures/Flupix/QQ表情';
  }

  @override
  String qqStickerSaveFailedSuffix(int failed) {
    return '，$failed 张失败';
  }

  @override
  String qqStickerSavedToGallery(int saved) {
    return '已保存 $saved 张表情到相册';
  }

  @override
  String get qqStickerSaveFailed => '保存失败';

  @override
  String qqStickerSaveFailedDetail(String error) {
    return '保存失败：$error';
  }

  @override
  String get qqStickerAndroidOnly => '该工具仅在 Android 设备上可用';

  @override
  String get qqStickerPacks => '表情包';

  @override
  String qqStickerPacksCount(int count) {
    return '共 $count 个';
  }

  @override
  String get qqStickerSaveLocation => '保存位置：Pictures/Flupix/QQ表情/<表情包ID>';

  @override
  String get qqStickerQqMissing => '未检测到 QQ';

  @override
  String get qqStickerQqMissingDetail => '本工具读取 QQ 的表情缓存，请先安装并登录 QQ。';

  @override
  String get qqStickerShizukuMissing => '未安装 Shizuku';

  @override
  String get qqStickerShizukuMissingDetail =>
      '需要 Shizuku（Root 模式）才能访问 QQ 的私有缓存目录。';

  @override
  String get qqStickerShizukuStopped => 'Shizuku 未运行';

  @override
  String get qqStickerShizukuStoppedDetail => '请在设置中打开并启动 Shizuku（Root 模式）。';

  @override
  String get qqStickerShizukuDenied => '等待 Shizuku 授权';

  @override
  String get qqStickerShizukuDeniedDetail => '请前往设置完成 Shizuku 授权。';

  @override
  String get qqStickerShizukuInsufficient => 'Shizuku 权限不足';

  @override
  String qqStickerShizukuInsufficientDetail(int uid) {
    return '当前以 uid=$uid 运行，请在设置中改为 Root（uid=0）启动。';
  }

  @override
  String get qqStickerNoCache => '未找到 QQ 表情缓存';

  @override
  String get qqStickerNoCacheDetail => '请先在 QQ 中打开表情面板并加载表情，再重新检测。';

  @override
  String get qqStickerReady => '环境就绪';

  @override
  String get qqStickerReadyHintEmpty => '已取得 Root 权限，可以扫描 QQ 表情缓存。';

  @override
  String qqStickerReadyHintCount(int count) {
    return '已读取 $count 个表情包，可勾选后保存。';
  }

  @override
  String get qqStickerUnknownStatus => '无法读取状态';

  @override
  String get qqStickerUnknownStatusDetail => 'Shizuku 状态未知，请重新检测。';

  @override
  String get qqStickerGoSettings => '前往设置';

  @override
  String get qqStickerScanning => '扫描中…';

  @override
  String get qqStickerScan => '扫描表情包';

  @override
  String get qqStickerRescan => '重新扫描';

  @override
  String qqStickerPackTitle(String id) {
    return '表情包 $id';
  }

  @override
  String qqStickerPackSelectedSummary(int total, int selected) {
    return '$total 个 · 已选 $selected';
  }

  @override
  String qqStickerPackSummary(int count) {
    return '$count 个表情';
  }

  @override
  String get qqStickerTapToSelect => '点击表情选择';

  @override
  String get qqStickerSelectPack => '全选本包';

  @override
  String qqStickerSelectedCount(int count) {
    return '已选 $count 张';
  }

  @override
  String get qqStickerSaveToAlbum => '保存到 相册/Pictures/Flupix/QQ表情';

  @override
  String get qqStickerSaving => '保存中…';

  @override
  String get passwordSubtitle => '使用加密安全随机数生成密码';

  @override
  String get passwordResult => '生成结果';

  @override
  String get passwordEmptyHint => '请选择至少一种字符类型';

  @override
  String get passwordSelectAtLeastOne => '至少选择一种字符类型';

  @override
  String passwordEntropy(String bits) {
    return '约 $bits 位熵';
  }

  @override
  String get passwordRegenerate => '重新生成';

  @override
  String get passwordCopyTooltip => '复制密码';

  @override
  String get passwordLength => '密码长度';

  @override
  String get passwordUppercase => '大写字母';

  @override
  String get passwordLowercase => '小写字母';

  @override
  String get passwordDigits => '数字';

  @override
  String get passwordSymbols => '符号';

  @override
  String get passwordExcludeAmbiguous => '排除易混淆字符';

  @override
  String get passwordExcludeAmbiguousHint => '去掉 O、0、l、1、I 等容易看错的字符';

  @override
  String get passwordStrengthWeak => '较弱';

  @override
  String get passwordStrengthFair => '一般';

  @override
  String get passwordStrengthStrong => '强';

  @override
  String get passwordStrengthVeryStrong => '很强';

  @override
  String get qrSubtitle => '输入文本即可生成可扫描的二维码';

  @override
  String get qrContentLabel => '二维码内容';

  @override
  String get qrContentHint => '支持文本、网址、联系方式等';

  @override
  String get qrEmptyTip => '输入内容后生成二维码';

  @override
  String qrTooLong(int bytes) {
    return '内容过长（$bytes 字节），请精简到约 1800 字节以内';
  }

  @override
  String qrCharCount(int count) {
    return '$count 个字符';
  }

  @override
  String get qrCopiedContent => '内容已复制';

  @override
  String get qrCopyContent => '复制内容';

  @override
  String get qrSize => '二维码尺寸';

  @override
  String qrSizePx(int size) {
    return '$size px';
  }

  @override
  String get qrUseThemeColor => '使用主题色';

  @override
  String get qrUseThemeColorHint => '开启后二维码模块使用当前主题主色';

  @override
  String get pixivTokenSubtitle => 'OAuth 登录获取与刷新令牌';

  @override
  String get pixivLoginTitle => '登录 pixiv';

  @override
  String get pixivLoginCancelled => '已取消登录';

  @override
  String get pixivLoginSuccess => '登录成功，已获取 Token';

  @override
  String pixivLoginFailed(String error) {
    return '登录失败：$error';
  }

  @override
  String get pixivTokenRefreshed => 'Token 已刷新';

  @override
  String pixivRefreshFailed(String error) {
    return '刷新失败：$error';
  }

  @override
  String get pixivClearDataTitle => '清除本地数据';

  @override
  String get pixivClearDataBody =>
      '将删除本机保存的 access_token 与 refresh_token，之后需要重新登录。';

  @override
  String get pixivClearAction => '清除';

  @override
  String get pixivTokenCleared => '已清除本地 Token';

  @override
  String get pixivPhpSessionObtained => '已获取 PHPSESSID';

  @override
  String get pixivTokenExpired => '已过期，请刷新';

  @override
  String pixivTokenRemaining(String time) {
    return '剩余 $time';
  }

  @override
  String get pixivTokenSection => '令牌';

  @override
  String get pixivTokenCopyAll => '复制全部';

  @override
  String get pixivWebCookieTitle => 'Web 端 Cookie';

  @override
  String get pixivWebCookieDesc =>
      'Pixeval 等使用 WebAPI 的工具需要 PHPSESSID，需在 pixiv 网页版登录后读取。';

  @override
  String get pixivFetchCookie => '获取 pixiv.net Cookie';

  @override
  String get pixivFetchCookieAgain => '重新获取';

  @override
  String get pixivSecurityTitle => '安全提示';

  @override
  String get pixivSecurityBody =>
      'access_token 与 refresh_token 等同于账号凭证，请勿分享或提交到公开仓库。令牌仅保存在本机，除 pixiv 官方域名外不会向任何服务器发送数据。';

  @override
  String get pixivNotLoggedIn => '未登录';

  @override
  String get pixivLoggedIn => '已登录';

  @override
  String get pixivLoginHint => '登录后可获取 access_token 与 refresh_token';

  @override
  String get pixivProcessing => '处理中…';

  @override
  String get pixivRefreshTokenButton => '刷新 Token';

  @override
  String get pixivReloginButton => '重新登录';

  @override
  String get pixivTokenHide => '隐藏';

  @override
  String get pixivTokenShow => '显示';

  @override
  String get pixivLoginPageHint =>
      '请在页面中完成 pixiv 登录。登录成功后会自动返回，若弹出「打开 Pixiv 应用」提示可忽略。';

  @override
  String get pixivPhpSessionMissing => '未找到 PHPSESSID，请先在页面中登录 pixiv';

  @override
  String get pixivCookieReadFailed => '读取 Cookie 失败，请重试';

  @override
  String get pixivCookiePageTitle => '登录 pixiv 网页版';

  @override
  String get pixivReadingCookie => '读取中…';

  @override
  String pixivConnectionFailed(String reason) {
    return '无法连接 pixiv 服务器（$reason）。oauth.secure.pixiv.net 在中国大陆通常无法直连，请先配置代理。';
  }

  @override
  String get pixivTimeout => '请求超时，请检查网络状态或代理地址是否正确。';

  @override
  String get pixivDirectConnection => '当前为直连';

  @override
  String pixivErrorWithAddress(String address) {
    return '当前代理 $address';
  }

  @override
  String pixivConnectionFailedWithTarget(String target) {
    return '无法连接 pixiv 服务器（$target），请确认代理已开启且地址正确。';
  }

  @override
  String pixivNetworkError(String message) {
    return '网络请求失败：$message';
  }

  @override
  String pixivInvalidResponse(int status) {
    return '服务器返回了无法解析的内容（HTTP $status）';
  }

  @override
  String get ehSiteEHentai => 'E-Hentai';

  @override
  String get ehSiteExHentai => 'ExHentai';

  @override
  String get ehCategoryMisc => '杂项';

  @override
  String get ehCategoryDoujinshi => '同人志';

  @override
  String get ehCategoryManga => '漫画';

  @override
  String get ehCategoryArtistCg => '画师 CG';

  @override
  String get ehCategoryGameCg => '游戏 CG';

  @override
  String get ehCategoryImageSet => '图集';

  @override
  String get ehCategoryCosplay => 'Cosplay';

  @override
  String get ehCategoryAsian => '亚洲';

  @override
  String get ehCategoryNonH => '非 H';

  @override
  String get ehCategoryWestern => '欧美';

  @override
  String get ehBrowseLoggedIn => '已登录';

  @override
  String get ehBrowseGuest => '访客';

  @override
  String get ehBrowseSwitchSite => '切换站点';

  @override
  String get ehBrowseRelogin => '重新登录';

  @override
  String get ehBrowseLogin => '登录';

  @override
  String get ehBrowseMyLibrary => '我的图库';

  @override
  String get ehBrowseDownloads => '下载管理';

  @override
  String get ehBrowseLogout => '退出登录';

  @override
  String get ehBrowseSearchHint => '搜索标题、标签或上传者';

  @override
  String get ehBrowseGuestBanner => '未登录只能浏览列表，阅读与 ExHentai 需要登录。';

  @override
  String get ehBrowseNoResults => '没有找到结果';

  @override
  String ehBrowseTotalResults(int count) {
    return '共约 $count 个结果';
  }

  @override
  String ehBrowseReachedPage(int page) {
    return '已到第 $page 页';
  }

  @override
  String get ehBrowseNoMore => '没有更多了';

  @override
  String ehBrowseInitFailed(String error) {
    return '初始化失败：$error';
  }

  @override
  String get ehFilterExcludeHint => '选中表示排除该分类';

  @override
  String get ehDetailTitle => '图库详情';

  @override
  String get ehDetailCannotRead => '无法获取页数，暂时不能阅读';

  @override
  String get ehDetailFavoriteAdded => '已加入收藏';

  @override
  String get ehDetailFavoriteRemoved => '已取消收藏';

  @override
  String get ehDetailDownloadToLocal => '下载到本地';

  @override
  String get ehDetailDownloaded => '已下载';

  @override
  String get ehDetailPauseDownload => '暂停下载';

  @override
  String get ehDetailCancelQueue => '取消排队';

  @override
  String get ehDetailRetryDownload => '重试下载';

  @override
  String get ehDetailResumeDownload => '继续下载';

  @override
  String ehDetailQueuedWithPages(int total) {
    return '已加入下载队列（共 $total 页）';
  }

  @override
  String get ehDetailQueued => '已加入下载队列';

  @override
  String ehDetailDownloadProgress(int downloaded, int total) {
    return '$downloaded/$total 页';
  }

  @override
  String ehDetailQueuedProgress(String progress) {
    return '已加入下载队列 · $progress';
  }

  @override
  String ehDetailDownloadingProgress(String progress) {
    return '正在下载 · $progress';
  }

  @override
  String ehDetailPausedProgress(String progress) {
    return '已暂停 · $progress';
  }

  @override
  String ehDetailPausedError(String error) {
    return '已暂停 · $error';
  }

  @override
  String ehDetailCompletedProgress(String progress) {
    return '已下载 · $progress';
  }

  @override
  String ehDetailFailedError(String error) {
    return '下载失败 · $error';
  }

  @override
  String get ehDetailUnknownError => '未知错误';

  @override
  String get ehDetailUnfavorite => '取消收藏';

  @override
  String get ehDetailFavorite => '收藏';

  @override
  String get ehDetailTags => '标签';

  @override
  String get ehDetailTapToJump => '点击跳页';

  @override
  String get ehDetailStartReading => '开始阅读';

  @override
  String ehDetailContinueReading(int page) {
    return '继续阅读 第 $page 页';
  }

  @override
  String ehDetailPagesCount(int pages) {
    return '$pages 页';
  }

  @override
  String ehDetailUploader(String uploader) {
    return '上传者：$uploader';
  }

  @override
  String get ehReaderLocalImageFailed => '本地图片读取失败';

  @override
  String get ehReaderImageFailed => '图片加载失败';

  @override
  String get ehReaderRestartFromFirstPage => '从第一页开始';

  @override
  String get ehReaderLtr => '切换为从左到右';

  @override
  String get ehReaderRtl => '切换为从右到左';

  @override
  String get ehReaderGestureHint => '双击或双指缩放 · 点击中部显示/隐藏工具栏';

  @override
  String ehReaderRateLimited(int seconds) {
    return '站点限流或临时封禁，$seconds 秒后可重试';
  }

  @override
  String get ehReaderPageLoadFailed => '该页加载失败';

  @override
  String get ehTagTitle => '标签检索';

  @override
  String get ehTagImportTitle => '导入标签翻译';

  @override
  String get ehTagImportAction => '导入';

  @override
  String ehTagImported(int count) {
    return '已导入 $count 条翻译';
  }

  @override
  String ehTagImportFailed(String error) {
    return '导入失败：$error';
  }

  @override
  String get ehTagClearHistoryTitle => '清空标签历史';

  @override
  String get ehTagClearHistoryMessage => '将删除全部本地标签记录。';

  @override
  String get ehTagHistoryCleared => '标签历史已清空';

  @override
  String get ehTagClearTranslationsTitle => '清空导入的翻译';

  @override
  String get ehTagClearTranslationsMessage => '内置翻译仍会保留。';

  @override
  String get ehTagTranslationsCleared => '导入的翻译已清空';

  @override
  String ehTagLocalCount(int count) {
    return '共 $count 个本地标签';
  }

  @override
  String get ehTagImportTooltip => '导入翻译';

  @override
  String get ehTagSearchHint => '搜索标签或中文翻译';

  @override
  String get ehTagNoMatch => '没有匹配的标签';

  @override
  String get ehTagNoRecords => '还没有标签记录';

  @override
  String get ehTagNoMatchHint => '试试其它关键词，或直接在图库详情中点击标签。';

  @override
  String get ehTagNoRecordsHint => '打开任意图库详情后会自动收集标签，也可以先导入翻译库。';

  @override
  String get ehTagImportLibrary => '导入翻译库';

  @override
  String get ehLoginTitle => 'E-Hentai 登录';

  @override
  String get ehLoginTabWeb => '网页登录';

  @override
  String get ehLoginTabManual => '手动 Cookie';

  @override
  String get ehLoginReading => '读取中…';

  @override
  String get ehLoginHint => '登录 Cookie 仅保存在本机，用于访问 E-Hentai / ExHentai。';

  @override
  String get ehLoginNoCookie => '尚未检测到登录 Cookie，请先在网页中完成登录';

  @override
  String get ehLoginNotEffective => '网页登录未生效：请确认已通过验证并成功登录账号';

  @override
  String get ehLoginGotCookies => '已获取登录与 ExHentai Cookie，可点击右上角完成';

  @override
  String get ehLoginRefreshingExAfterLogin => '已登录，正在获取 ExHentai 权限…';

  @override
  String get ehLoginRefreshingEx => '正在获取 ExHentai 权限…';

  @override
  String get ehLoginExGranted => '已获得 ExHentai 权限，可返回浏览里站';

  @override
  String get ehLoginExGrantedViaWeb => '已通过网页获取 ExHentai 权限，可返回浏览里站';

  @override
  String get ehLoginClearWebCookiesTitle => '清空网页 Cookie';

  @override
  String get ehLoginClearWebCookiesMessage =>
      '将清除 E-Hentai / ExHentai 的网页登录状态，并重新打开论坛登录页。';

  @override
  String get ehLoginClearWebCookiesConfirm => '清空并重新登录';

  @override
  String get ehLoginClearingCookies => '正在清空 Cookie…';

  @override
  String get ehLoginClearedCookies => '已清空网页 Cookie，请重新登录';

  @override
  String get ehLoginLoginFirst => '请先在网页中完成登录';

  @override
  String get ehLoginManualMissing => '需要至少包含 ipb_member_id 与 ipb_pass_hash';

  @override
  String get ehLoginCookieInvalid => 'Cookie 无效或已过期，请重新获取';

  @override
  String ehLoginPageLoadFailed(String error) {
    return '页面加载失败：$error';
  }

  @override
  String get ehLoginAutoHint => '登录后自动读取 Cookie 并换取 ExHentai 凭证。';

  @override
  String get ehLoginClearCookie => '清空 Cookie';

  @override
  String get ehLoginDetecting => '检测中…';

  @override
  String get ehLoginDetectEx => '检测 EX';

  @override
  String get ehLoginManualHint =>
      '从已登录的浏览器复制完整 Cookie，至少包含 ipb_member_id、ipb_pass_hash，使用 ExHentai 时还需要 igneous。支持 key=value 或 key: value 换行格式。';

  @override
  String get ehLoginValidating => '校验中…';

  @override
  String get ehLoginValidateAndSave => '校验并保存';

  @override
  String get ehLibraryTitle => '我的图库';

  @override
  String ehLibrarySubtitle(String site, int favorites, int history) {
    return '$site · 收藏 $favorites · 历史 $history';
  }

  @override
  String ehLibraryFavoritesSegment(int count) {
    return '收藏 $count';
  }

  @override
  String ehLibraryHistorySegment(int count) {
    return '历史 $count';
  }

  @override
  String get ehLibraryNoFavorites => '还没有收藏';

  @override
  String get ehLibraryNoFavoritesHint => '打开图库详情后点击右上角的心形按钮即可收藏。';

  @override
  String ehLibraryTileSubtitle(String category, int pages, String rating) {
    return '$category · $pages 页$rating';
  }

  @override
  String get ehLibraryRemoveFavorite => '取消收藏';

  @override
  String get ehLibraryNoHistory => '还没有阅读记录';

  @override
  String get ehLibraryNoHistoryHint => '阅读任意图库后会自动记录进度，方便下次继续。';

  @override
  String ehLibraryHistorySubtitle(int lastPage, int totalPages, String time) {
    return '已读 $lastPage/$totalPages 页 · $time';
  }

  @override
  String get ehLibraryRemoveHistory => '移除记录';

  @override
  String ehLibraryTodayTime(String time) {
    return '今天 $time';
  }

  @override
  String get ehDownloadTitle => '下载管理';

  @override
  String ehDownloadSummary(int total, int completed) {
    return '共 $total 个 · 完成 $completed 个';
  }

  @override
  String get ehDownloadEmpty => '还没有下载任务';

  @override
  String get ehDownloadEmptyHint => '在图库详情页点击下载按钮，即可保存整本到本地并离线阅读。';

  @override
  String get ehDownloadDelete => '删除下载';

  @override
  String ehDownloadDeleteConfirm(String title) {
    return '确定删除「$title」的本地文件吗？';
  }

  @override
  String get ehDownloadDownloaded => '已下载';

  @override
  String get ehDownloadNoPages => '该图库还没有可阅读的页面';

  @override
  String get ehDownloadNoDownloadedPages => '还没有下载完成的页面';

  @override
  String ehDownloadPagesProgress(int downloaded, int total) {
    return '$downloaded/$total 页';
  }

  @override
  String ehDownloadStatusQueued(String progress) {
    return '等待下载 · $progress';
  }

  @override
  String ehDownloadStatusDownloading(String progress) {
    return '正在下载 · $progress';
  }

  @override
  String ehDownloadStatusPaused(String progress) {
    return '已暂停 · $progress';
  }

  @override
  String ehDownloadStatusPausedError(String error) {
    return '已暂停 · $error';
  }

  @override
  String ehDownloadStatusCompleted(String progress) {
    return '已完成 · $progress';
  }

  @override
  String ehDownloadStatusFailed(String error) {
    return '下载失败 · $error';
  }

  @override
  String get ehDownloadUnknownError => '未知错误';

  @override
  String get ehStatusQueued => '等待下载';

  @override
  String get ehStatusDownloading => '下载中';

  @override
  String get ehStatusPaused => '已暂停';

  @override
  String get ehStatusCompleted => '已完成';

  @override
  String get ehStatusFailed => '下载失败';

  @override
  String get ehDownloadPagesUnknown => '无法获取图库页数';

  @override
  String ehDownloadFailedWith(String error) {
    return '下载失败：$error';
  }

  @override
  String get ehDownloadPartial => '部分页面未下载，可继续重试';

  @override
  String get ehDownloadEmptyPage => '页面内容为空';

  @override
  String get ehDownloadDirUninitialized => '下载目录未初始化';

  @override
  String get ehDownloadPausedInManager => '已暂停，可在下载管理中继续';

  @override
  String get ehAuthEmptyExPage => 'ExHentai 返回了空页面：请重新登录，并在登录页点击「检测 EX」获取里站权限';

  @override
  String get ehAuthEmptyList => 'ExHentai 未返回列表：请确认登录有效，并在登录页点击「检测 EX」重新获取里站权限';

  @override
  String get ehAuthGetExExpired => '登录已失效，请重新登录后再获取 ExHentai 权限';

  @override
  String get ehAuthIgneousMystery =>
      '账号尚未获得 ExHentai 里站权限（igneous=mystery），请确认账号资格后重试';

  @override
  String get ehAuthIgneousNoContent =>
      '已获取 igneous，但 ExHentai 没有返回内容：账号可能没有里站权限或登录已失效';

  @override
  String get ehAuthLoginExpired => '登录已失效，请重新登录';

  @override
  String get ehAuthMissingCredential =>
      '登录状态有效，但站点没有下发 ExHentai 凭证：请确认账号已获得里站权限';

  @override
  String get ehAuthSadPanda => 'ExHentai 需要 igneous 凭证：请在登录页点击「检测 EX」重新授权';

  @override
  String get ehAuthSadPandaCookie =>
      'ExHentai 需要 igneous Cookie：请在登录页点击「检测 EX」完成授权';

  @override
  String ehBanLabelHoursMinutes(int hours, int minutes) {
    return '$hours 小时 $minutes 分钟';
  }

  @override
  String ehBanLabelMinutes(int minutes) {
    return '$minutes 分钟';
  }

  @override
  String ehBanRecoverAfter(String duration) {
    return '当前 IP 被站点临时封禁，约 $duration后恢复';
  }

  @override
  String get ehBanTemporary => '当前 IP 被站点临时封禁，请稍后重试';

  @override
  String get ehBanWaitRecovery => '当前 IP 被站点临时封禁，请等待站点提示的恢复时间';

  @override
  String get ehErrorCloudflare => '被 Cloudflare 拦截，请打开网页完成验证';

  @override
  String get ehErrorRateLimited => '图片服务器限流（509），请稍后再试';

  @override
  String ehNetConnectFailed(String error) {
    return '网络连接失败：$error';
  }

  @override
  String get ehNetEmptyPage => '站点返回了空页面，可能被临时封禁或限流，请稍后重试';

  @override
  String ehNetImageStatusError(int status) {
    return '图片请求失败（$status）';
  }

  @override
  String ehNetRequestFailed(String error) {
    return '网络请求失败：$error';
  }

  @override
  String ehNetRequestStatusError(int status) {
    return '请求失败（$status）';
  }

  @override
  String ehNetServerError(int status) {
    return '服务器错误（$status）';
  }

  @override
  String get ehNetTimeout => '请求超时，请检查网络或代理设置';

  @override
  String get ehNetTooManyRedirects => '页面跳转次数过多，请稍后重试';

  @override
  String get ehParseApiInvalid => 'api.php 返回了无法解析的内容';

  @override
  String get ehParseDetailStructure => '详情页结构异常，无法找到标题';

  @override
  String get ehParseGalleryUnavailable => '图库不可用或已被删除';

  @override
  String get ehParseImageNotImage => '图片地址返回了非图片内容';

  @override
  String get ehParseImageUrlFailed => '无法解析该页图片地址';

  @override
  String get ehParseOtherTagGroup => '其它';

  @override
  String get ehParsePTokenMissing => '无法获取该页的 pToken，请从第一页开始阅读';

  @override
  String get ehParseShowkeyMissing => '图片页缺少 showkey，无法重新获取图片地址';
}
