import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// No description provided for @commonCopy.
  ///
  /// In zh, this message translates to:
  /// **'复制'**
  String get commonCopy;

  /// No description provided for @commonCopied.
  ///
  /// In zh, this message translates to:
  /// **'已复制到剪贴板'**
  String get commonCopied;

  /// No description provided for @commonClear.
  ///
  /// In zh, this message translates to:
  /// **'清空'**
  String get commonClear;

  /// No description provided for @commonCancel.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get commonCancel;

  /// No description provided for @commonConfirm.
  ///
  /// In zh, this message translates to:
  /// **'确定'**
  String get commonConfirm;

  /// No description provided for @commonSave.
  ///
  /// In zh, this message translates to:
  /// **'保存'**
  String get commonSave;

  /// No description provided for @commonDelete.
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get commonDelete;

  /// No description provided for @commonRetry.
  ///
  /// In zh, this message translates to:
  /// **'重试'**
  String get commonRetry;

  /// No description provided for @commonRefresh.
  ///
  /// In zh, this message translates to:
  /// **'刷新'**
  String get commonRefresh;

  /// No description provided for @commonSearch.
  ///
  /// In zh, this message translates to:
  /// **'搜索'**
  String get commonSearch;

  /// No description provided for @commonClose.
  ///
  /// In zh, this message translates to:
  /// **'关闭'**
  String get commonClose;

  /// No description provided for @commonLoading.
  ///
  /// In zh, this message translates to:
  /// **'加载中…'**
  String get commonLoading;

  /// No description provided for @commonEmpty.
  ///
  /// In zh, this message translates to:
  /// **'暂无内容'**
  String get commonEmpty;

  /// No description provided for @commonAll.
  ///
  /// In zh, this message translates to:
  /// **'全部'**
  String get commonAll;

  /// No description provided for @commonSettings.
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get commonSettings;

  /// No description provided for @commonOpen.
  ///
  /// In zh, this message translates to:
  /// **'打开'**
  String get commonOpen;

  /// No description provided for @commonStart.
  ///
  /// In zh, this message translates to:
  /// **'开始'**
  String get commonStart;

  /// No description provided for @commonStop.
  ///
  /// In zh, this message translates to:
  /// **'停止'**
  String get commonStop;

  /// No description provided for @commonPause.
  ///
  /// In zh, this message translates to:
  /// **'暂停'**
  String get commonPause;

  /// No description provided for @commonResume.
  ///
  /// In zh, this message translates to:
  /// **'继续'**
  String get commonResume;

  /// No description provided for @commonDone.
  ///
  /// In zh, this message translates to:
  /// **'完成'**
  String get commonDone;

  /// No description provided for @commonEdit.
  ///
  /// In zh, this message translates to:
  /// **'编辑'**
  String get commonEdit;

  /// No description provided for @commonAdd.
  ///
  /// In zh, this message translates to:
  /// **'添加'**
  String get commonAdd;

  /// No description provided for @commonRemove.
  ///
  /// In zh, this message translates to:
  /// **'移除'**
  String get commonRemove;

  /// No description provided for @commonSelectAll.
  ///
  /// In zh, this message translates to:
  /// **'全选'**
  String get commonSelectAll;

  /// No description provided for @commonDeselectAll.
  ///
  /// In zh, this message translates to:
  /// **'取消全选'**
  String get commonDeselectAll;

  /// No description provided for @commonUnknown.
  ///
  /// In zh, this message translates to:
  /// **'未知'**
  String get commonUnknown;

  /// No description provided for @commonError.
  ///
  /// In zh, this message translates to:
  /// **'出错了'**
  String get commonError;

  /// No description provided for @commonSuccess.
  ///
  /// In zh, this message translates to:
  /// **'操作成功'**
  String get commonSuccess;

  /// No description provided for @commonYes.
  ///
  /// In zh, this message translates to:
  /// **'是'**
  String get commonYes;

  /// No description provided for @commonNo.
  ///
  /// In zh, this message translates to:
  /// **'否'**
  String get commonNo;

  /// No description provided for @commonBrowse.
  ///
  /// In zh, this message translates to:
  /// **'浏览'**
  String get commonBrowse;

  /// No description provided for @commonPickFile.
  ///
  /// In zh, this message translates to:
  /// **'选择文件'**
  String get commonPickFile;

  /// No description provided for @commonShare.
  ///
  /// In zh, this message translates to:
  /// **'分享'**
  String get commonShare;

  /// No description provided for @commonPreview.
  ///
  /// In zh, this message translates to:
  /// **'预览'**
  String get commonPreview;

  /// No description provided for @commonApply.
  ///
  /// In zh, this message translates to:
  /// **'应用'**
  String get commonApply;

  /// No description provided for @commonMore.
  ///
  /// In zh, this message translates to:
  /// **'更多'**
  String get commonMore;

  /// No description provided for @commonBack.
  ///
  /// In zh, this message translates to:
  /// **'返回'**
  String get commonBack;

  /// No description provided for @homeSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'常用小工具，随手即用'**
  String get homeSubtitle;

  /// No description provided for @homeToolCount.
  ///
  /// In zh, this message translates to:
  /// **'共 {count} 项 · 全部离线运行'**
  String homeToolCount(int count);

  /// No description provided for @homeFilterAll.
  ///
  /// In zh, this message translates to:
  /// **'全部'**
  String get homeFilterAll;

  /// No description provided for @homeSettingsTooltip.
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get homeSettingsTooltip;

  /// No description provided for @homeDisabledBadge.
  ///
  /// In zh, this message translates to:
  /// **'当前平台不可用'**
  String get homeDisabledBadge;

  /// No description provided for @homeShizukuPermissionTitle.
  ///
  /// In zh, this message translates to:
  /// **'需要 Shizuku 授权'**
  String get homeShizukuPermissionTitle;

  /// No description provided for @homeShizukuCannotRead.
  ///
  /// In zh, this message translates to:
  /// **'无法读取 Shizuku 状态，请前往设置检查授权。'**
  String get homeShizukuCannotRead;

  /// No description provided for @homeShizukuNotInstalled.
  ///
  /// In zh, this message translates to:
  /// **'未安装 Shizuku。请先安装 Shizuku，再到设置中完成授权。'**
  String get homeShizukuNotInstalled;

  /// No description provided for @homeShizukuNotRunning.
  ///
  /// In zh, this message translates to:
  /// **'Shizuku 未运行。请打开 Shizuku 并通过 Root 启动服务，再到设置中授权。'**
  String get homeShizukuNotRunning;

  /// No description provided for @homeShizukuNotGranted.
  ///
  /// In zh, this message translates to:
  /// **'尚未授权 Flupix 使用 Shizuku，请前往设置完成授权。'**
  String get homeShizukuNotGranted;

  /// No description provided for @homeShizukuNotRoot.
  ///
  /// In zh, this message translates to:
  /// **'Shizuku 当前不是 Root 模式，请以 Root 启动后到设置中授权。'**
  String get homeShizukuNotRoot;

  /// No description provided for @homeShizukuGoSettingsHint.
  ///
  /// In zh, this message translates to:
  /// **'请前往设置完成 Shizuku 授权。'**
  String get homeShizukuGoSettingsHint;

  /// No description provided for @homeShizukuGoSettings.
  ///
  /// In zh, this message translates to:
  /// **'去设置'**
  String get homeShizukuGoSettings;

  /// No description provided for @categoryConvert.
  ///
  /// In zh, this message translates to:
  /// **'转换'**
  String get categoryConvert;

  /// No description provided for @categoryText.
  ///
  /// In zh, this message translates to:
  /// **'文本'**
  String get categoryText;

  /// No description provided for @categoryGenerate.
  ///
  /// In zh, this message translates to:
  /// **'生成'**
  String get categoryGenerate;

  /// No description provided for @categoryOther.
  ///
  /// In zh, this message translates to:
  /// **'其他'**
  String get categoryOther;

  /// No description provided for @toolUnitConverterTitle.
  ///
  /// In zh, this message translates to:
  /// **'单位换算'**
  String get toolUnitConverterTitle;

  /// No description provided for @toolUnitConverterDesc.
  ///
  /// In zh, this message translates to:
  /// **'长度、面积、体积、质量、温度、速度、数据存储'**
  String get toolUnitConverterDesc;

  /// No description provided for @toolCalculatorTitle.
  ///
  /// In zh, this message translates to:
  /// **'表达式计算'**
  String get toolCalculatorTitle;

  /// No description provided for @toolCalculatorDesc.
  ///
  /// In zh, this message translates to:
  /// **'支持括号、幂运算与四则混合计算'**
  String get toolCalculatorDesc;

  /// No description provided for @toolTextCodecTitle.
  ///
  /// In zh, this message translates to:
  /// **'文本编解码'**
  String get toolTextCodecTitle;

  /// No description provided for @toolTextCodecDesc.
  ///
  /// In zh, this message translates to:
  /// **'Base64 与 URL 编码、解码'**
  String get toolTextCodecDesc;

  /// No description provided for @toolJsonTitle.
  ///
  /// In zh, this message translates to:
  /// **'JSON 格式化'**
  String get toolJsonTitle;

  /// No description provided for @toolJsonDesc.
  ///
  /// In zh, this message translates to:
  /// **'校验、格式化与压缩 JSON 文本'**
  String get toolJsonDesc;

  /// No description provided for @toolMarkdownTitle.
  ///
  /// In zh, this message translates to:
  /// **'Markdown 编辑'**
  String get toolMarkdownTitle;

  /// No description provided for @toolMarkdownDesc.
  ///
  /// In zh, this message translates to:
  /// **'实时预览、语法快捷插入与草稿保存'**
  String get toolMarkdownDesc;

  /// No description provided for @toolHashTitle.
  ///
  /// In zh, this message translates to:
  /// **'哈希计算'**
  String get toolHashTitle;

  /// No description provided for @toolHashDesc.
  ///
  /// In zh, this message translates to:
  /// **'MD5、SHA-1、SHA-256、SHA-512'**
  String get toolHashDesc;

  /// No description provided for @toolTimestampTitle.
  ///
  /// In zh, this message translates to:
  /// **'时间戳转换'**
  String get toolTimestampTitle;

  /// No description provided for @toolTimestampDesc.
  ///
  /// In zh, this message translates to:
  /// **'Unix 时间戳与日期时间互转'**
  String get toolTimestampDesc;

  /// No description provided for @toolColorTitle.
  ///
  /// In zh, this message translates to:
  /// **'颜色工具'**
  String get toolColorTitle;

  /// No description provided for @toolColorDesc.
  ///
  /// In zh, this message translates to:
  /// **'HEX / RGB / HSL 互转与配色预览'**
  String get toolColorDesc;

  /// No description provided for @toolAudioConvertTitle.
  ///
  /// In zh, this message translates to:
  /// **'音频格式转换'**
  String get toolAudioConvertTitle;

  /// No description provided for @toolAudioConvertDesc.
  ///
  /// In zh, this message translates to:
  /// **'MP3、WAV、FLAC、M4A 等格式互转'**
  String get toolAudioConvertDesc;

  /// No description provided for @toolPasswordTitle.
  ///
  /// In zh, this message translates to:
  /// **'密码生成'**
  String get toolPasswordTitle;

  /// No description provided for @toolPasswordDesc.
  ///
  /// In zh, this message translates to:
  /// **'安全随机密码与强度评估'**
  String get toolPasswordDesc;

  /// No description provided for @toolQrTitle.
  ///
  /// In zh, this message translates to:
  /// **'二维码生成'**
  String get toolQrTitle;

  /// No description provided for @toolQrDesc.
  ///
  /// In zh, this message translates to:
  /// **'将文本生成可扫描的二维码'**
  String get toolQrDesc;

  /// No description provided for @toolMetronomeTitle.
  ///
  /// In zh, this message translates to:
  /// **'节拍器'**
  String get toolMetronomeTitle;

  /// No description provided for @toolMetronomeDesc.
  ///
  /// In zh, this message translates to:
  /// **'BPM 调节、拍号重音、点击测速与可视节拍'**
  String get toolMetronomeDesc;

  /// No description provided for @toolPuzzleTitle.
  ///
  /// In zh, this message translates to:
  /// **'数字华容道'**
  String get toolPuzzleTitle;

  /// No description provided for @toolPuzzleDesc.
  ///
  /// In zh, this message translates to:
  /// **'自定义图片与 1:1 裁切，支持 3×3 至 5×5'**
  String get toolPuzzleDesc;

  /// No description provided for @toolQqStickerTitle.
  ///
  /// In zh, this message translates to:
  /// **'QQ 表情包'**
  String get toolQqStickerTitle;

  /// No description provided for @toolQqStickerDesc.
  ///
  /// In zh, this message translates to:
  /// **'借助 Shizuku Root 权限，从 QQ 缓存保存表情到相册'**
  String get toolQqStickerDesc;

  /// No description provided for @toolEhTitle.
  ///
  /// In zh, this message translates to:
  /// **'E-Hentai'**
  String get toolEhTitle;

  /// No description provided for @toolEhDesc.
  ///
  /// In zh, this message translates to:
  /// **'搜索、浏览与阅读 E-Hentai / ExHentai 图库'**
  String get toolEhDesc;

  /// No description provided for @toolPixivTitle.
  ///
  /// In zh, this message translates to:
  /// **'Pixiv Token'**
  String get toolPixivTitle;

  /// No description provided for @toolPixivDesc.
  ///
  /// In zh, this message translates to:
  /// **'OAuth 登录获取 access_token 与 PHPSESSID'**
  String get toolPixivDesc;

  /// No description provided for @settingsTitle.
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get settingsTitle;

  /// No description provided for @settingsSubtitleAndroid.
  ///
  /// In zh, this message translates to:
  /// **'外观、主题与权限'**
  String get settingsSubtitleAndroid;

  /// No description provided for @settingsSubtitleDesktop.
  ///
  /// In zh, this message translates to:
  /// **'外观、主题与网络'**
  String get settingsSubtitleDesktop;

  /// No description provided for @settingsAppearanceMode.
  ///
  /// In zh, this message translates to:
  /// **'外观模式'**
  String get settingsAppearanceMode;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In zh, this message translates to:
  /// **'系统'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeLight.
  ///
  /// In zh, this message translates to:
  /// **'浅色'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In zh, this message translates to:
  /// **'深色'**
  String get settingsThemeDark;

  /// No description provided for @settingsSeedColor.
  ///
  /// In zh, this message translates to:
  /// **'主题色'**
  String get settingsSeedColor;

  /// No description provided for @settingsSeedColorHint.
  ///
  /// In zh, this message translates to:
  /// **'Material You 会由主题色生成整套色调'**
  String get settingsSeedColorHint;

  /// No description provided for @settingsLanguage.
  ///
  /// In zh, this message translates to:
  /// **'语言'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageSystem.
  ///
  /// In zh, this message translates to:
  /// **'跟随系统'**
  String get settingsLanguageSystem;

  /// No description provided for @settingsLanguageChinese.
  ///
  /// In zh, this message translates to:
  /// **'简体中文'**
  String get settingsLanguageChinese;

  /// No description provided for @settingsLanguageEnglish.
  ///
  /// In zh, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglish;

  /// No description provided for @settingsShowDisabled.
  ///
  /// In zh, this message translates to:
  /// **'显示已禁用的功能'**
  String get settingsShowDisabled;

  /// No description provided for @settingsShowDisabledHint.
  ///
  /// In zh, this message translates to:
  /// **'在首页显示当前系统无法使用或尚未实现的功能，卡片会置灰且不可点击。'**
  String get settingsShowDisabledHint;

  /// No description provided for @settingsProxyTitle.
  ///
  /// In zh, this message translates to:
  /// **'网络代理'**
  String get settingsProxyTitle;

  /// No description provided for @settingsProxyDescription.
  ///
  /// In zh, this message translates to:
  /// **'供 Pixiv 与 E-Hentai 等工具使用；留空时自动读取 Windows 系统代理，Android 端请使用系统 VPN。'**
  String get settingsProxyDescription;

  /// No description provided for @settingsProxyAddress.
  ///
  /// In zh, this message translates to:
  /// **'代理地址'**
  String get settingsProxyAddress;

  /// No description provided for @settingsProxySave.
  ///
  /// In zh, this message translates to:
  /// **'保存代理'**
  String get settingsProxySave;

  /// No description provided for @settingsProxySaving.
  ///
  /// In zh, this message translates to:
  /// **'保存中…'**
  String get settingsProxySaving;

  /// No description provided for @settingsProxyReadSystem.
  ///
  /// In zh, this message translates to:
  /// **'读取系统代理'**
  String get settingsProxyReadSystem;

  /// No description provided for @settingsProxySaved.
  ///
  /// In zh, this message translates to:
  /// **'代理已保存：{address}'**
  String settingsProxySaved(String address);

  /// No description provided for @settingsProxyDirect.
  ///
  /// In zh, this message translates to:
  /// **'已切换为直连'**
  String get settingsProxyDirect;

  /// No description provided for @settingsProxySystemMissing.
  ///
  /// In zh, this message translates to:
  /// **'未检测到已启用的系统代理，请先开启代理软件'**
  String get settingsProxySystemMissing;

  /// No description provided for @settingsShizukuTitle.
  ///
  /// In zh, this message translates to:
  /// **'Shizuku 授权'**
  String get settingsShizukuTitle;

  /// No description provided for @settingsShizukuDescription.
  ///
  /// In zh, this message translates to:
  /// **'需要 Root 权限的工具会通过 Shizuku 读取应用私有数据。'**
  String get settingsShizukuDescription;

  /// No description provided for @settingsShizukuChecking.
  ///
  /// In zh, this message translates to:
  /// **'正在检测 Shizuku…'**
  String get settingsShizukuChecking;

  /// No description provided for @settingsShizukuError.
  ///
  /// In zh, this message translates to:
  /// **'无法读取 Shizuku 状态，请确认设备为 Android 且已安装 Shizuku。'**
  String get settingsShizukuError;

  /// No description provided for @settingsShizukuGrant.
  ///
  /// In zh, this message translates to:
  /// **'授权 Shizuku'**
  String get settingsShizukuGrant;

  /// No description provided for @settingsShizukuGranting.
  ///
  /// In zh, this message translates to:
  /// **'授权中…'**
  String get settingsShizukuGranting;

  /// No description provided for @settingsShizukuOpen.
  ///
  /// In zh, this message translates to:
  /// **'打开 Shizuku'**
  String get settingsShizukuOpen;

  /// No description provided for @settingsShizukuRefresh.
  ///
  /// In zh, this message translates to:
  /// **'重新检测'**
  String get settingsShizukuRefresh;

  /// No description provided for @settingsShizukuGrantedRoot.
  ///
  /// In zh, this message translates to:
  /// **'已授权（Root）'**
  String get settingsShizukuGrantedRoot;

  /// No description provided for @settingsShizukuNotInstalled.
  ///
  /// In zh, this message translates to:
  /// **'未安装 Shizuku'**
  String get settingsShizukuNotInstalled;

  /// No description provided for @settingsShizukuNotRunning.
  ///
  /// In zh, this message translates to:
  /// **'Shizuku 未运行'**
  String get settingsShizukuNotRunning;

  /// No description provided for @settingsShizukuNotGranted.
  ///
  /// In zh, this message translates to:
  /// **'未授权'**
  String get settingsShizukuNotGranted;

  /// No description provided for @settingsShizukuInsufficient.
  ///
  /// In zh, this message translates to:
  /// **'权限不足（uid={uid}）'**
  String settingsShizukuInsufficient(String uid);

  /// No description provided for @settingsShizukuInstallHint.
  ///
  /// In zh, this message translates to:
  /// **'请先安装 Shizuku 应用，再返回此处授权。'**
  String get settingsShizukuInstallHint;

  /// No description provided for @settingsShizukuRunHint.
  ///
  /// In zh, this message translates to:
  /// **'请打开 Shizuku，并通过 Root 启动服务。'**
  String get settingsShizukuRunHint;

  /// No description provided for @settingsShizukuGrantHint.
  ///
  /// In zh, this message translates to:
  /// **'允许 Flupix 访问 Shizuku 后才能读取 QQ 表情缓存。'**
  String get settingsShizukuGrantHint;

  /// No description provided for @settingsShizukuRootHint.
  ///
  /// In zh, this message translates to:
  /// **'请停止 Shizuku，并以 Root（uid=0）重新启动。'**
  String get settingsShizukuRootHint;

  /// No description provided for @settingsShizukuReadyHint.
  ///
  /// In zh, this message translates to:
  /// **'Flupix 已获得 Root 权限，可用于需要 Shizuku 的工具。'**
  String get settingsShizukuReadyHint;

  /// No description provided for @settingsShizukuGrantedMessage.
  ///
  /// In zh, this message translates to:
  /// **'Shizuku 授权成功'**
  String get settingsShizukuGrantedMessage;

  /// No description provided for @settingsShizukuDeniedMessage.
  ///
  /// In zh, this message translates to:
  /// **'Shizuku 授权被拒绝'**
  String get settingsShizukuDeniedMessage;

  /// No description provided for @settingsShizukuRequestFailed.
  ///
  /// In zh, this message translates to:
  /// **'请求授权失败：{error}'**
  String settingsShizukuRequestFailed(String error);

  /// No description provided for @settingsShizukuNotFound.
  ///
  /// In zh, this message translates to:
  /// **'未找到 Shizuku 应用'**
  String get settingsShizukuNotFound;

  /// No description provided for @settingsShizukuOpenFailed.
  ///
  /// In zh, this message translates to:
  /// **'无法打开 Shizuku：{error}'**
  String settingsShizukuOpenFailed(String error);

  /// No description provided for @settingsUpdateCurrentVersion.
  ///
  /// In zh, this message translates to:
  /// **'当前版本 {version}'**
  String settingsUpdateCurrentVersion(String version);

  /// No description provided for @settingsUpdateCheck.
  ///
  /// In zh, this message translates to:
  /// **'检查更新'**
  String get settingsUpdateCheck;

  /// No description provided for @settingsUpdateChecking.
  ///
  /// In zh, this message translates to:
  /// **'检查中…'**
  String get settingsUpdateChecking;

  /// No description provided for @settingsUpdateLatest.
  ///
  /// In zh, this message translates to:
  /// **'已是最新版本（{version}）'**
  String settingsUpdateLatest(String version);

  /// No description provided for @settingsUpdateCheckFailed.
  ///
  /// In zh, this message translates to:
  /// **'检查更新失败：{error}'**
  String settingsUpdateCheckFailed(String error);

  /// No description provided for @settingsUpdateAvailableTitle.
  ///
  /// In zh, this message translates to:
  /// **'发现新版本 {version}'**
  String settingsUpdateAvailableTitle(String version);

  /// No description provided for @settingsUpdateReleaseNotes.
  ///
  /// In zh, this message translates to:
  /// **'更新内容'**
  String get settingsUpdateReleaseNotes;

  /// No description provided for @settingsUpdateNoNotes.
  ///
  /// In zh, this message translates to:
  /// **'该版本没有提供更新说明。'**
  String get settingsUpdateNoNotes;

  /// No description provided for @settingsUpdateDownload.
  ///
  /// In zh, this message translates to:
  /// **'前往下载'**
  String get settingsUpdateDownload;

  /// No description provided for @settingsUpdateInstall.
  ///
  /// In zh, this message translates to:
  /// **'下载并安装'**
  String get settingsUpdateInstall;

  /// No description provided for @settingsUpdateInstallPermission.
  ///
  /// In zh, this message translates to:
  /// **'请在系统设置中允许安装未知应用后重试'**
  String get settingsUpdateInstallPermission;

  /// No description provided for @settingsUpdateDownloading.
  ///
  /// In zh, this message translates to:
  /// **'正在下载 {version}…'**
  String settingsUpdateDownloading(String version);

  /// No description provided for @settingsUpdateInstalling.
  ///
  /// In zh, this message translates to:
  /// **'下载完成，正在安装…'**
  String get settingsUpdateInstalling;

  /// No description provided for @settingsUpdateFailed.
  ///
  /// In zh, this message translates to:
  /// **'更新失败：{error}'**
  String settingsUpdateFailed(String error);

  /// No description provided for @settingsUpdateOpenReleases.
  ///
  /// In zh, this message translates to:
  /// **'打开发布页'**
  String get settingsUpdateOpenReleases;

  /// No description provided for @settingsUpdateOpenFailed.
  ///
  /// In zh, this message translates to:
  /// **'无法打开链接'**
  String get settingsUpdateOpenFailed;

  /// No description provided for @settingsAboutVersion.
  ///
  /// In zh, this message translates to:
  /// **'版本 {version} · Flutter + Material You'**
  String settingsAboutVersion(String version);

  /// No description provided for @settingsAboutPrivacy.
  ///
  /// In zh, this message translates to:
  /// **'所有工具均在本地运行，不收集任何数据。'**
  String get settingsAboutPrivacy;

  /// No description provided for @seedPine.
  ///
  /// In zh, this message translates to:
  /// **'松绿'**
  String get seedPine;

  /// No description provided for @seedIndigo.
  ///
  /// In zh, this message translates to:
  /// **'靛蓝'**
  String get seedIndigo;

  /// No description provided for @seedViolet.
  ///
  /// In zh, this message translates to:
  /// **'紫罗兰'**
  String get seedViolet;

  /// No description provided for @seedSky.
  ///
  /// In zh, this message translates to:
  /// **'天青'**
  String get seedSky;

  /// No description provided for @seedMoss.
  ///
  /// In zh, this message translates to:
  /// **'苔绿'**
  String get seedMoss;

  /// No description provided for @seedAmber.
  ///
  /// In zh, this message translates to:
  /// **'琥珀'**
  String get seedAmber;

  /// No description provided for @seedRose.
  ///
  /// In zh, this message translates to:
  /// **'玫红'**
  String get seedRose;

  /// No description provided for @seedGraphite.
  ///
  /// In zh, this message translates to:
  /// **'石墨'**
  String get seedGraphite;

  /// No description provided for @textCodecTitle.
  ///
  /// In zh, this message translates to:
  /// **'文本编解码'**
  String get textCodecTitle;

  /// No description provided for @textCodecSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'Base64 与 URL 编码互转'**
  String get textCodecSubtitle;

  /// No description provided for @textCodecEncode.
  ///
  /// In zh, this message translates to:
  /// **'编码'**
  String get textCodecEncode;

  /// No description provided for @textCodecDecode.
  ///
  /// In zh, this message translates to:
  /// **'解码'**
  String get textCodecDecode;

  /// No description provided for @textCodecInputLabel.
  ///
  /// In zh, this message translates to:
  /// **'输入内容'**
  String get textCodecInputLabel;

  /// No description provided for @textCodecInputEncodeHint.
  ///
  /// In zh, this message translates to:
  /// **'输入需要编码的文本'**
  String get textCodecInputEncodeHint;

  /// No description provided for @textCodecInputDecodeHint.
  ///
  /// In zh, this message translates to:
  /// **'粘贴需要解码的内容'**
  String get textCodecInputDecodeHint;

  /// No description provided for @textCodecCharCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 个字符'**
  String textCodecCharCount(int count);

  /// No description provided for @textCodecResultTitle.
  ///
  /// In zh, this message translates to:
  /// **'转换结果'**
  String get textCodecResultTitle;

  /// No description provided for @textCodecCopyResult.
  ///
  /// In zh, this message translates to:
  /// **'复制结果'**
  String get textCodecCopyResult;

  /// No description provided for @textCodecResultPlaceholder.
  ///
  /// In zh, this message translates to:
  /// **'结果会显示在这里'**
  String get textCodecResultPlaceholder;

  /// No description provided for @textCodecInvalidBase64.
  ///
  /// In zh, this message translates to:
  /// **'Base64 内容无效，无法解码'**
  String get textCodecInvalidBase64;

  /// No description provided for @textCodecInvalidUrl.
  ///
  /// In zh, this message translates to:
  /// **'URL 编码格式无效，无法解码'**
  String get textCodecInvalidUrl;

  /// No description provided for @textCodecConvertFailed.
  ///
  /// In zh, this message translates to:
  /// **'转换失败，请检查输入内容'**
  String get textCodecConvertFailed;

  /// No description provided for @jsonTitle.
  ///
  /// In zh, this message translates to:
  /// **'JSON 格式化'**
  String get jsonTitle;

  /// No description provided for @jsonSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'校验、格式化与压缩 JSON 文本'**
  String get jsonSubtitle;

  /// No description provided for @jsonInputLabel.
  ///
  /// In zh, this message translates to:
  /// **'JSON 内容'**
  String get jsonInputLabel;

  /// No description provided for @jsonInputHint.
  ///
  /// In zh, this message translates to:
  /// **'粘贴 JSON 文本，例如 {leftBrace}\"name\": \"Flupix\"{rightBrace}'**
  String jsonInputHint(String leftBrace, String rightBrace);

  /// No description provided for @jsonFormat.
  ///
  /// In zh, this message translates to:
  /// **'格式化'**
  String get jsonFormat;

  /// No description provided for @jsonMinify.
  ///
  /// In zh, this message translates to:
  /// **'压缩'**
  String get jsonMinify;

  /// No description provided for @jsonOutputTitle.
  ///
  /// In zh, this message translates to:
  /// **'输出结果'**
  String get jsonOutputTitle;

  /// No description provided for @jsonCopyResult.
  ///
  /// In zh, this message translates to:
  /// **'复制结果'**
  String get jsonCopyResult;

  /// No description provided for @jsonOutputPlaceholder.
  ///
  /// In zh, this message translates to:
  /// **'格式化后的 JSON 会显示在这里'**
  String get jsonOutputPlaceholder;

  /// No description provided for @jsonEmptyInput.
  ///
  /// In zh, this message translates to:
  /// **'请输入 JSON 内容'**
  String get jsonEmptyInput;

  /// No description provided for @jsonValidMeta.
  ///
  /// In zh, this message translates to:
  /// **'JSON 有效 · {count} 个字符'**
  String jsonValidMeta(int count);

  /// No description provided for @jsonParseFailed.
  ///
  /// In zh, this message translates to:
  /// **'解析失败：{error}'**
  String jsonParseFailed(String error);

  /// No description provided for @markdownTitle.
  ///
  /// In zh, this message translates to:
  /// **'Markdown 编辑'**
  String get markdownTitle;

  /// No description provided for @markdownSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'GFM 预览 · .md 导入导出'**
  String get markdownSubtitle;

  /// No description provided for @markdownOpenFileTooltip.
  ///
  /// In zh, this message translates to:
  /// **'打开 .md 文件'**
  String get markdownOpenFileTooltip;

  /// No description provided for @markdownExportTooltip.
  ///
  /// In zh, this message translates to:
  /// **'导出为 .md 文件'**
  String get markdownExportTooltip;

  /// No description provided for @markdownStats.
  ///
  /// In zh, this message translates to:
  /// **'{lines} 行 · {chars} 字符'**
  String markdownStats(int lines, int chars);

  /// No description provided for @markdownHeading1.
  ///
  /// In zh, this message translates to:
  /// **'一级标题'**
  String get markdownHeading1;

  /// No description provided for @markdownHeading2.
  ///
  /// In zh, this message translates to:
  /// **'二级标题'**
  String get markdownHeading2;

  /// No description provided for @markdownBold.
  ///
  /// In zh, this message translates to:
  /// **'粗体'**
  String get markdownBold;

  /// No description provided for @markdownItalic.
  ///
  /// In zh, this message translates to:
  /// **'斜体'**
  String get markdownItalic;

  /// No description provided for @markdownInlineCode.
  ///
  /// In zh, this message translates to:
  /// **'行内代码'**
  String get markdownInlineCode;

  /// No description provided for @markdownBulletList.
  ///
  /// In zh, this message translates to:
  /// **'无序列表'**
  String get markdownBulletList;

  /// No description provided for @markdownOrderedList.
  ///
  /// In zh, this message translates to:
  /// **'有序列表'**
  String get markdownOrderedList;

  /// No description provided for @markdownTaskList.
  ///
  /// In zh, this message translates to:
  /// **'任务列表'**
  String get markdownTaskList;

  /// No description provided for @markdownQuote.
  ///
  /// In zh, this message translates to:
  /// **'引用'**
  String get markdownQuote;

  /// No description provided for @markdownLink.
  ///
  /// In zh, this message translates to:
  /// **'链接'**
  String get markdownLink;

  /// No description provided for @markdownLinkPlaceholder.
  ///
  /// In zh, this message translates to:
  /// **'链接文字'**
  String get markdownLinkPlaceholder;

  /// No description provided for @markdownCodeBlock.
  ///
  /// In zh, this message translates to:
  /// **'代码块'**
  String get markdownCodeBlock;

  /// No description provided for @markdownTable.
  ///
  /// In zh, this message translates to:
  /// **'表格'**
  String get markdownTable;

  /// No description provided for @markdownTableTemplate.
  ///
  /// In zh, this message translates to:
  /// **'| 列一 | 列二 |\n| --- | --- |\n| 内容 | 内容 |'**
  String get markdownTableTemplate;

  /// No description provided for @markdownDivider.
  ///
  /// In zh, this message translates to:
  /// **'分隔线'**
  String get markdownDivider;

  /// No description provided for @markdownEditorHint.
  ///
  /// In zh, this message translates to:
  /// **'# 在这里开始写 Markdown…'**
  String get markdownEditorHint;

  /// No description provided for @markdownDraftSavedLocally.
  ///
  /// In zh, this message translates to:
  /// **'草稿自动保存在本机'**
  String get markdownDraftSavedLocally;

  /// No description provided for @markdownDraftAutoSaved.
  ///
  /// In zh, this message translates to:
  /// **'{name} · 草稿自动保存'**
  String markdownDraftAutoSaved(String name);

  /// No description provided for @markdownSourceCopied.
  ///
  /// In zh, this message translates to:
  /// **'已复制 Markdown 源码'**
  String get markdownSourceCopied;

  /// No description provided for @markdownPreviewPlaceholder.
  ///
  /// In zh, this message translates to:
  /// **'左侧输入的 Markdown 会实时渲染在这里'**
  String get markdownPreviewPlaceholder;

  /// No description provided for @markdownClearTitle.
  ///
  /// In zh, this message translates to:
  /// **'清空内容？'**
  String get markdownClearTitle;

  /// No description provided for @markdownClearMessage.
  ///
  /// In zh, this message translates to:
  /// **'当前草稿会被删除，且无法恢复。'**
  String get markdownClearMessage;

  /// No description provided for @markdownLinkCopied.
  ///
  /// In zh, this message translates to:
  /// **'已复制链接'**
  String get markdownLinkCopied;

  /// No description provided for @markdownOpenDialogTitle.
  ///
  /// In zh, this message translates to:
  /// **'打开 Markdown 文件'**
  String get markdownOpenDialogTitle;

  /// No description provided for @markdownOpened.
  ///
  /// In zh, this message translates to:
  /// **'已打开 {name}'**
  String markdownOpened(String name);

  /// No description provided for @markdownOpenFailed.
  ///
  /// In zh, this message translates to:
  /// **'打开失败：{error}'**
  String markdownOpenFailed(String error);

  /// No description provided for @markdownUntitledFileName.
  ///
  /// In zh, this message translates to:
  /// **'未命名.md'**
  String get markdownUntitledFileName;

  /// No description provided for @markdownExportDialogTitle.
  ///
  /// In zh, this message translates to:
  /// **'导出 Markdown'**
  String get markdownExportDialogTitle;

  /// No description provided for @markdownExported.
  ///
  /// In zh, this message translates to:
  /// **'已导出 {name}'**
  String markdownExported(String name);

  /// No description provided for @markdownExportFailed.
  ///
  /// In zh, this message translates to:
  /// **'导出失败：{error}'**
  String markdownExportFailed(String error);

  /// No description provided for @hashTitle.
  ///
  /// In zh, this message translates to:
  /// **'哈希计算'**
  String get hashTitle;

  /// No description provided for @hashSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'把文本转换为不可逆的摘要值'**
  String get hashSubtitle;

  /// No description provided for @hashInputLabel.
  ///
  /// In zh, this message translates to:
  /// **'输入文本'**
  String get hashInputLabel;

  /// No description provided for @hashInputHint.
  ///
  /// In zh, this message translates to:
  /// **'输入或粘贴需要计算哈希的内容'**
  String get hashInputHint;

  /// No description provided for @hashByteCount.
  ///
  /// In zh, this message translates to:
  /// **'UTF-8 编码 · {count} 字节'**
  String hashByteCount(int count);

  /// No description provided for @hashEmptyHint.
  ///
  /// In zh, this message translates to:
  /// **'输入文本后会自动计算 MD5、SHA-1、SHA-256 与 SHA-512。'**
  String get hashEmptyHint;

  /// No description provided for @unitPageTitle.
  ///
  /// In zh, this message translates to:
  /// **'单位换算'**
  String get unitPageTitle;

  /// No description provided for @unitPageSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'选择分类后输入数值，实时换算'**
  String get unitPageSubtitle;

  /// No description provided for @unitCategoryLength.
  ///
  /// In zh, this message translates to:
  /// **'长度'**
  String get unitCategoryLength;

  /// No description provided for @unitCategoryArea.
  ///
  /// In zh, this message translates to:
  /// **'面积'**
  String get unitCategoryArea;

  /// No description provided for @unitCategoryVolume.
  ///
  /// In zh, this message translates to:
  /// **'体积'**
  String get unitCategoryVolume;

  /// No description provided for @unitCategoryMass.
  ///
  /// In zh, this message translates to:
  /// **'质量'**
  String get unitCategoryMass;

  /// No description provided for @unitCategoryTemperature.
  ///
  /// In zh, this message translates to:
  /// **'温度'**
  String get unitCategoryTemperature;

  /// No description provided for @unitCategorySpeed.
  ///
  /// In zh, this message translates to:
  /// **'速度'**
  String get unitCategorySpeed;

  /// No description provided for @unitCategoryDataStorage.
  ///
  /// In zh, this message translates to:
  /// **'数据存储'**
  String get unitCategoryDataStorage;

  /// No description provided for @unitKilometer.
  ///
  /// In zh, this message translates to:
  /// **'千米'**
  String get unitKilometer;

  /// No description provided for @unitMeter.
  ///
  /// In zh, this message translates to:
  /// **'米'**
  String get unitMeter;

  /// No description provided for @unitDecimeter.
  ///
  /// In zh, this message translates to:
  /// **'分米'**
  String get unitDecimeter;

  /// No description provided for @unitCentimeter.
  ///
  /// In zh, this message translates to:
  /// **'厘米'**
  String get unitCentimeter;

  /// No description provided for @unitMillimeter.
  ///
  /// In zh, this message translates to:
  /// **'毫米'**
  String get unitMillimeter;

  /// No description provided for @unitMicrometer.
  ///
  /// In zh, this message translates to:
  /// **'微米'**
  String get unitMicrometer;

  /// No description provided for @unitNanometer.
  ///
  /// In zh, this message translates to:
  /// **'纳米'**
  String get unitNanometer;

  /// No description provided for @unitMile.
  ///
  /// In zh, this message translates to:
  /// **'英里'**
  String get unitMile;

  /// No description provided for @unitYard.
  ///
  /// In zh, this message translates to:
  /// **'码'**
  String get unitYard;

  /// No description provided for @unitFoot.
  ///
  /// In zh, this message translates to:
  /// **'英尺'**
  String get unitFoot;

  /// No description provided for @unitInch.
  ///
  /// In zh, this message translates to:
  /// **'英寸'**
  String get unitInch;

  /// No description provided for @unitNauticalMile.
  ///
  /// In zh, this message translates to:
  /// **'海里'**
  String get unitNauticalMile;

  /// No description provided for @unitLi.
  ///
  /// In zh, this message translates to:
  /// **'里'**
  String get unitLi;

  /// No description provided for @unitZhang.
  ///
  /// In zh, this message translates to:
  /// **'丈'**
  String get unitZhang;

  /// No description provided for @unitChi.
  ///
  /// In zh, this message translates to:
  /// **'尺'**
  String get unitChi;

  /// No description provided for @unitCun.
  ///
  /// In zh, this message translates to:
  /// **'寸'**
  String get unitCun;

  /// No description provided for @unitSquareKilometer.
  ///
  /// In zh, this message translates to:
  /// **'平方千米'**
  String get unitSquareKilometer;

  /// No description provided for @unitHectare.
  ///
  /// In zh, this message translates to:
  /// **'公顷'**
  String get unitHectare;

  /// No description provided for @unitMu.
  ///
  /// In zh, this message translates to:
  /// **'亩'**
  String get unitMu;

  /// No description provided for @unitSquareMeter.
  ///
  /// In zh, this message translates to:
  /// **'平方米'**
  String get unitSquareMeter;

  /// No description provided for @unitSquareDecimeter.
  ///
  /// In zh, this message translates to:
  /// **'平方分米'**
  String get unitSquareDecimeter;

  /// No description provided for @unitSquareCentimeter.
  ///
  /// In zh, this message translates to:
  /// **'平方厘米'**
  String get unitSquareCentimeter;

  /// No description provided for @unitAcre.
  ///
  /// In zh, this message translates to:
  /// **'英亩'**
  String get unitAcre;

  /// No description provided for @unitSquareFoot.
  ///
  /// In zh, this message translates to:
  /// **'平方英尺'**
  String get unitSquareFoot;

  /// No description provided for @unitSquareInch.
  ///
  /// In zh, this message translates to:
  /// **'平方英寸'**
  String get unitSquareInch;

  /// No description provided for @unitCubicMeter.
  ///
  /// In zh, this message translates to:
  /// **'立方米'**
  String get unitCubicMeter;

  /// No description provided for @unitLiter.
  ///
  /// In zh, this message translates to:
  /// **'升'**
  String get unitLiter;

  /// No description provided for @unitMilliliter.
  ///
  /// In zh, this message translates to:
  /// **'毫升'**
  String get unitMilliliter;

  /// No description provided for @unitCubicCentimeter.
  ///
  /// In zh, this message translates to:
  /// **'立方厘米'**
  String get unitCubicCentimeter;

  /// No description provided for @unitGallonUs.
  ///
  /// In zh, this message translates to:
  /// **'加仑（美）'**
  String get unitGallonUs;

  /// No description provided for @unitQuartUs.
  ///
  /// In zh, this message translates to:
  /// **'夸脱（美）'**
  String get unitQuartUs;

  /// No description provided for @unitCubicFoot.
  ///
  /// In zh, this message translates to:
  /// **'立方英尺'**
  String get unitCubicFoot;

  /// No description provided for @unitCubicInch.
  ///
  /// In zh, this message translates to:
  /// **'立方英寸'**
  String get unitCubicInch;

  /// No description provided for @unitTonne.
  ///
  /// In zh, this message translates to:
  /// **'吨'**
  String get unitTonne;

  /// No description provided for @unitKilogram.
  ///
  /// In zh, this message translates to:
  /// **'千克'**
  String get unitKilogram;

  /// No description provided for @unitGram.
  ///
  /// In zh, this message translates to:
  /// **'克'**
  String get unitGram;

  /// No description provided for @unitMilligram.
  ///
  /// In zh, this message translates to:
  /// **'毫克'**
  String get unitMilligram;

  /// No description provided for @unitJin.
  ///
  /// In zh, this message translates to:
  /// **'斤'**
  String get unitJin;

  /// No description provided for @unitLiang.
  ///
  /// In zh, this message translates to:
  /// **'两'**
  String get unitLiang;

  /// No description provided for @unitPound.
  ///
  /// In zh, this message translates to:
  /// **'磅'**
  String get unitPound;

  /// No description provided for @unitOunce.
  ///
  /// In zh, this message translates to:
  /// **'盎司'**
  String get unitOunce;

  /// No description provided for @unitCarat.
  ///
  /// In zh, this message translates to:
  /// **'克拉'**
  String get unitCarat;

  /// No description provided for @unitCelsius.
  ///
  /// In zh, this message translates to:
  /// **'摄氏度'**
  String get unitCelsius;

  /// No description provided for @unitFahrenheit.
  ///
  /// In zh, this message translates to:
  /// **'华氏度'**
  String get unitFahrenheit;

  /// No description provided for @unitKelvin.
  ///
  /// In zh, this message translates to:
  /// **'开尔文'**
  String get unitKelvin;

  /// No description provided for @unitMeterPerSecond.
  ///
  /// In zh, this message translates to:
  /// **'米/秒'**
  String get unitMeterPerSecond;

  /// No description provided for @unitKilometerPerHour.
  ///
  /// In zh, this message translates to:
  /// **'千米/时'**
  String get unitKilometerPerHour;

  /// No description provided for @unitMeterPerMinute.
  ///
  /// In zh, this message translates to:
  /// **'米/分'**
  String get unitMeterPerMinute;

  /// No description provided for @unitMilePerHour.
  ///
  /// In zh, this message translates to:
  /// **'英里/时'**
  String get unitMilePerHour;

  /// No description provided for @unitKnot.
  ///
  /// In zh, this message translates to:
  /// **'节'**
  String get unitKnot;

  /// No description provided for @unitFootPerSecond.
  ///
  /// In zh, this message translates to:
  /// **'英尺/秒'**
  String get unitFootPerSecond;

  /// No description provided for @unitBit.
  ///
  /// In zh, this message translates to:
  /// **'位'**
  String get unitBit;

  /// No description provided for @unitByte.
  ///
  /// In zh, this message translates to:
  /// **'字节'**
  String get unitByte;

  /// No description provided for @unitKilobyte.
  ///
  /// In zh, this message translates to:
  /// **'千字节'**
  String get unitKilobyte;

  /// No description provided for @unitMegabyte.
  ///
  /// In zh, this message translates to:
  /// **'兆字节'**
  String get unitMegabyte;

  /// No description provided for @unitGigabyte.
  ///
  /// In zh, this message translates to:
  /// **'吉字节'**
  String get unitGigabyte;

  /// No description provided for @unitTerabyte.
  ///
  /// In zh, this message translates to:
  /// **'太字节'**
  String get unitTerabyte;

  /// No description provided for @unitInputLabel.
  ///
  /// In zh, this message translates to:
  /// **'输入'**
  String get unitInputLabel;

  /// No description provided for @unitFromLabel.
  ///
  /// In zh, this message translates to:
  /// **'单位'**
  String get unitFromLabel;

  /// No description provided for @unitValueLabel.
  ///
  /// In zh, this message translates to:
  /// **'数值'**
  String get unitValueLabel;

  /// No description provided for @unitSwapTooltip.
  ///
  /// In zh, this message translates to:
  /// **'交换单位'**
  String get unitSwapTooltip;

  /// No description provided for @unitToLabel.
  ///
  /// In zh, this message translates to:
  /// **'换算为'**
  String get unitToLabel;

  /// No description provided for @unitResultTitle.
  ///
  /// In zh, this message translates to:
  /// **'换算结果'**
  String get unitResultTitle;

  /// No description provided for @unitCopyResultTooltip.
  ///
  /// In zh, this message translates to:
  /// **'复制结果'**
  String get unitCopyResultTooltip;

  /// No description provided for @unitEnterValidValue.
  ///
  /// In zh, this message translates to:
  /// **'请输入有效数值'**
  String get unitEnterValidValue;

  /// No description provided for @unitConversionFormula.
  ///
  /// In zh, this message translates to:
  /// **'1 {from} = {value} {to}'**
  String unitConversionFormula(String from, String value, String to);

  /// No description provided for @timestampPageTitle.
  ///
  /// In zh, this message translates to:
  /// **'时间戳转换'**
  String get timestampPageTitle;

  /// No description provided for @timestampPageSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'Unix 时间戳与本地、UTC 时间互转'**
  String get timestampPageSubtitle;

  /// No description provided for @timestampCurrentTime.
  ///
  /// In zh, this message translates to:
  /// **'当前时间'**
  String get timestampCurrentTime;

  /// No description provided for @timestampSeconds.
  ///
  /// In zh, this message translates to:
  /// **'秒级时间戳'**
  String get timestampSeconds;

  /// No description provided for @timestampMilliseconds.
  ///
  /// In zh, this message translates to:
  /// **'毫秒级时间戳'**
  String get timestampMilliseconds;

  /// No description provided for @timestampUtcIso.
  ///
  /// In zh, this message translates to:
  /// **'UTC 时间（ISO 8601）'**
  String get timestampUtcIso;

  /// No description provided for @timestampToDateTime.
  ///
  /// In zh, this message translates to:
  /// **'时间戳 → 日期时间'**
  String get timestampToDateTime;

  /// No description provided for @timestampLabel.
  ///
  /// In zh, this message translates to:
  /// **'时间戳'**
  String get timestampLabel;

  /// No description provided for @timestampHint.
  ///
  /// In zh, this message translates to:
  /// **'支持秒级或毫秒级，自动识别'**
  String get timestampHint;

  /// No description provided for @timestampNow.
  ///
  /// In zh, this message translates to:
  /// **'当前'**
  String get timestampNow;

  /// No description provided for @timestampLocalTime.
  ///
  /// In zh, this message translates to:
  /// **'本地时间'**
  String get timestampLocalTime;

  /// No description provided for @timestampUtcTime.
  ///
  /// In zh, this message translates to:
  /// **'UTC 时间'**
  String get timestampUtcTime;

  /// No description provided for @timestampIso8601.
  ///
  /// In zh, this message translates to:
  /// **'ISO 8601'**
  String get timestampIso8601;

  /// No description provided for @timestampEmptyHint.
  ///
  /// In zh, this message translates to:
  /// **'输入时间戳后显示对应日期时间'**
  String get timestampEmptyHint;

  /// No description provided for @timestampFromDateTime.
  ///
  /// In zh, this message translates to:
  /// **'日期时间 → 时间戳'**
  String get timestampFromDateTime;

  /// No description provided for @timestampPick.
  ///
  /// In zh, this message translates to:
  /// **'选择'**
  String get timestampPick;

  /// No description provided for @timestampErrorNotInteger.
  ///
  /// In zh, this message translates to:
  /// **'请输入整数时间戳'**
  String get timestampErrorNotInteger;

  /// No description provided for @timestampErrorOutOfRange.
  ///
  /// In zh, this message translates to:
  /// **'时间戳超出可表示范围'**
  String get timestampErrorOutOfRange;

  /// No description provided for @colorPageTitle.
  ///
  /// In zh, this message translates to:
  /// **'颜色工具'**
  String get colorPageTitle;

  /// No description provided for @colorPageSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'HEX / RGB / HSL 互转与 Material You 配色'**
  String get colorPageSubtitle;

  /// No description provided for @colorHexLabel.
  ///
  /// In zh, this message translates to:
  /// **'HEX 颜色'**
  String get colorHexLabel;

  /// No description provided for @colorChannelAdjust.
  ///
  /// In zh, this message translates to:
  /// **'调整通道'**
  String get colorChannelAdjust;

  /// No description provided for @colorPreviewTitle.
  ///
  /// In zh, this message translates to:
  /// **'配色预览'**
  String get colorPreviewTitle;

  /// No description provided for @colorPreviewSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'基于当前颜色生成的 Material You 色调'**
  String get colorPreviewSubtitle;

  /// No description provided for @colorSwatchPrimary.
  ///
  /// In zh, this message translates to:
  /// **'主色'**
  String get colorSwatchPrimary;

  /// No description provided for @colorSwatchSecondary.
  ///
  /// In zh, this message translates to:
  /// **'次色'**
  String get colorSwatchSecondary;

  /// No description provided for @colorSwatchTertiary.
  ///
  /// In zh, this message translates to:
  /// **'第三色'**
  String get colorSwatchTertiary;

  /// No description provided for @colorSwatchContainer.
  ///
  /// In zh, this message translates to:
  /// **'容器色'**
  String get colorSwatchContainer;

  /// No description provided for @colorSwatchSurface.
  ///
  /// In zh, this message translates to:
  /// **'表面'**
  String get colorSwatchSurface;

  /// No description provided for @colorSwatchSurfaceHigh.
  ///
  /// In zh, this message translates to:
  /// **'强调表面'**
  String get colorSwatchSurfaceHigh;

  /// No description provided for @colorErrorInvalidHex.
  ///
  /// In zh, this message translates to:
  /// **'请输入有效的 HEX 颜色，如 #3A7BD5'**
  String get colorErrorInvalidHex;

  /// No description provided for @calculatorPageTitle.
  ///
  /// In zh, this message translates to:
  /// **'表达式计算'**
  String get calculatorPageTitle;

  /// No description provided for @calculatorPageSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'支持括号、幂与四则混合运算'**
  String get calculatorPageSubtitle;

  /// No description provided for @calculatorHint.
  ///
  /// In zh, this message translates to:
  /// **'输入表达式，如 (3+5)×2^3'**
  String get calculatorHint;

  /// No description provided for @calculatorHistory.
  ///
  /// In zh, this message translates to:
  /// **'历史记录'**
  String get calculatorHistory;

  /// No description provided for @calculatorClearHistory.
  ///
  /// In zh, this message translates to:
  /// **'清空历史'**
  String get calculatorClearHistory;

  /// No description provided for @calculatorEmptyExpression.
  ///
  /// In zh, this message translates to:
  /// **'请输入表达式'**
  String get calculatorEmptyExpression;

  /// No description provided for @expressionEmpty.
  ///
  /// In zh, this message translates to:
  /// **'请输入表达式'**
  String get expressionEmpty;

  /// No description provided for @expressionUnmatchedParenthesis.
  ///
  /// In zh, this message translates to:
  /// **'括号不匹配'**
  String get expressionUnmatchedParenthesis;

  /// No description provided for @expressionIncomplete.
  ///
  /// In zh, this message translates to:
  /// **'表达式不完整'**
  String get expressionIncomplete;

  /// No description provided for @expressionInvalidResult.
  ///
  /// In zh, this message translates to:
  /// **'结果无效'**
  String get expressionInvalidResult;

  /// No description provided for @expressionDivideByZero.
  ///
  /// In zh, this message translates to:
  /// **'除数不能为 0'**
  String get expressionDivideByZero;

  /// No description provided for @expressionUnknownOperator.
  ///
  /// In zh, this message translates to:
  /// **'未知运算符 {operator}'**
  String expressionUnknownOperator(String operator);

  /// No description provided for @expressionInvalidNumber.
  ///
  /// In zh, this message translates to:
  /// **'数字格式有误: {number}'**
  String expressionInvalidNumber(String number);

  /// No description provided for @expressionUnknownCharacter.
  ///
  /// In zh, this message translates to:
  /// **'无法识别字符 \"{char}\"'**
  String expressionUnknownCharacter(String char);

  /// No description provided for @weekdayMonday.
  ///
  /// In zh, this message translates to:
  /// **'周一'**
  String get weekdayMonday;

  /// No description provided for @weekdayTuesday.
  ///
  /// In zh, this message translates to:
  /// **'周二'**
  String get weekdayTuesday;

  /// No description provided for @weekdayWednesday.
  ///
  /// In zh, this message translates to:
  /// **'周三'**
  String get weekdayWednesday;

  /// No description provided for @weekdayThursday.
  ///
  /// In zh, this message translates to:
  /// **'周四'**
  String get weekdayThursday;

  /// No description provided for @weekdayFriday.
  ///
  /// In zh, this message translates to:
  /// **'周五'**
  String get weekdayFriday;

  /// No description provided for @weekdaySaturday.
  ///
  /// In zh, this message translates to:
  /// **'周六'**
  String get weekdaySaturday;

  /// No description provided for @weekdaySunday.
  ///
  /// In zh, this message translates to:
  /// **'周日'**
  String get weekdaySunday;

  /// No description provided for @audioConvertTitle.
  ///
  /// In zh, this message translates to:
  /// **'音频格式转换'**
  String get audioConvertTitle;

  /// No description provided for @audioConvertSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'MP3、WAV、FLAC、M4A 等格式互转'**
  String get audioConvertSubtitle;

  /// No description provided for @audioSelectAudioFile.
  ///
  /// In zh, this message translates to:
  /// **'选择音频文件'**
  String get audioSelectAudioFile;

  /// No description provided for @audioReadFailed.
  ///
  /// In zh, this message translates to:
  /// **'读取音频失败：{error}'**
  String audioReadFailed(String error);

  /// No description provided for @audioConvertDoneHint.
  ///
  /// In zh, this message translates to:
  /// **'转换完成，可保存到本地'**
  String get audioConvertDoneHint;

  /// No description provided for @audioConvertCancelled.
  ///
  /// In zh, this message translates to:
  /// **'已取消转换'**
  String get audioConvertCancelled;

  /// No description provided for @audioConvertFailedToast.
  ///
  /// In zh, this message translates to:
  /// **'转换失败'**
  String get audioConvertFailedToast;

  /// No description provided for @audioSavedName.
  ///
  /// In zh, this message translates to:
  /// **'已保存 {name}'**
  String audioSavedName(String name);

  /// No description provided for @audioSaveFailed.
  ///
  /// In zh, this message translates to:
  /// **'保存失败：{error}'**
  String audioSaveFailed(String error);

  /// No description provided for @audioSaveAudioFile.
  ///
  /// In zh, this message translates to:
  /// **'保存音频文件'**
  String get audioSaveAudioFile;

  /// No description provided for @audioSizeUnknown.
  ///
  /// In zh, this message translates to:
  /// **'大小未知'**
  String get audioSizeUnknown;

  /// No description provided for @audioChannelsUnknown.
  ///
  /// In zh, this message translates to:
  /// **'声道未知'**
  String get audioChannelsUnknown;

  /// No description provided for @audioMono.
  ///
  /// In zh, this message translates to:
  /// **'单声道'**
  String get audioMono;

  /// No description provided for @audioStereo.
  ///
  /// In zh, this message translates to:
  /// **'立体声'**
  String get audioStereo;

  /// No description provided for @audioChannelsCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 声道'**
  String audioChannelsCount(int count);

  /// No description provided for @audioConvertTo.
  ///
  /// In zh, this message translates to:
  /// **'转换为 {format}'**
  String audioConvertTo(String format);

  /// No description provided for @audioEngineLine.
  ///
  /// In zh, this message translates to:
  /// **'FFmpeg {version} · 转码在本机离线完成'**
  String audioEngineLine(String version);

  /// No description provided for @audioEngineLoading.
  ///
  /// In zh, this message translates to:
  /// **'加载中'**
  String get audioEngineLoading;

  /// No description provided for @audioSupportedFormats.
  ///
  /// In zh, this message translates to:
  /// **'支持 MP3、WAV、FLAC、M4A、AAC、OGG 等格式'**
  String get audioSupportedFormats;

  /// No description provided for @audioChangeFile.
  ///
  /// In zh, this message translates to:
  /// **'更换文件'**
  String get audioChangeFile;

  /// No description provided for @audioUnknownCodec.
  ///
  /// In zh, this message translates to:
  /// **'未知编码'**
  String get audioUnknownCodec;

  /// No description provided for @audioBrowseLocal.
  ///
  /// In zh, this message translates to:
  /// **'浏览本地文件'**
  String get audioBrowseLocal;

  /// No description provided for @audioOutputFormat.
  ///
  /// In zh, this message translates to:
  /// **'输出格式'**
  String get audioOutputFormat;

  /// No description provided for @audioBitrate.
  ///
  /// In zh, this message translates to:
  /// **'码率'**
  String get audioBitrate;

  /// No description provided for @audioBitrateValue.
  ///
  /// In zh, this message translates to:
  /// **'{value} kbps'**
  String audioBitrateValue(String value);

  /// No description provided for @audioBitDepth.
  ///
  /// In zh, this message translates to:
  /// **'位深'**
  String get audioBitDepth;

  /// No description provided for @audioBitDepth16.
  ///
  /// In zh, this message translates to:
  /// **'16 位'**
  String get audioBitDepth16;

  /// No description provided for @audioBitDepth24.
  ///
  /// In zh, this message translates to:
  /// **'24 位'**
  String get audioBitDepth24;

  /// No description provided for @audioBitDepthFloat32.
  ///
  /// In zh, this message translates to:
  /// **'32 位浮点'**
  String get audioBitDepthFloat32;

  /// No description provided for @audioSampleRate.
  ///
  /// In zh, this message translates to:
  /// **'采样率'**
  String get audioSampleRate;

  /// No description provided for @audioKeepOriginal.
  ///
  /// In zh, this message translates to:
  /// **'保持原样'**
  String get audioKeepOriginal;

  /// No description provided for @audioChannels.
  ///
  /// In zh, this message translates to:
  /// **'声道'**
  String get audioChannels;

  /// No description provided for @audioConvertingTo.
  ///
  /// In zh, this message translates to:
  /// **'正在转换为 {format}'**
  String audioConvertingTo(String format);

  /// No description provided for @audioProcessing.
  ///
  /// In zh, this message translates to:
  /// **'处理中'**
  String get audioProcessing;

  /// No description provided for @audioSpeedValue.
  ///
  /// In zh, this message translates to:
  /// **'速度 {speed}x'**
  String audioSpeedValue(String speed);

  /// No description provided for @audioPreparing.
  ///
  /// In zh, this message translates to:
  /// **'准备中…'**
  String get audioPreparing;

  /// No description provided for @audioConvertDoneTitle.
  ///
  /// In zh, this message translates to:
  /// **'转换完成'**
  String get audioConvertDoneTitle;

  /// No description provided for @audioSaving.
  ///
  /// In zh, this message translates to:
  /// **'保存中…'**
  String get audioSaving;

  /// No description provided for @audioSaveFile.
  ///
  /// In zh, this message translates to:
  /// **'保存文件'**
  String get audioSaveFile;

  /// No description provided for @audioFfprobeNotFound.
  ///
  /// In zh, this message translates to:
  /// **'未找到 ffprobe，请先安装 FFmpeg 并加入系统 PATH'**
  String get audioFfprobeNotFound;

  /// No description provided for @audioFfmpegNotFound.
  ///
  /// In zh, this message translates to:
  /// **'未找到 ffmpeg，请先安装 FFmpeg 并加入系统 PATH'**
  String get audioFfmpegNotFound;

  /// No description provided for @audioProbeParseFailed.
  ///
  /// In zh, this message translates to:
  /// **'无法解析音频信息'**
  String get audioProbeParseFailed;

  /// No description provided for @audioNoAudioStream.
  ///
  /// In zh, this message translates to:
  /// **'未在文件中找到音频流'**
  String get audioNoAudioStream;

  /// No description provided for @audioConvertFailedHint.
  ///
  /// In zh, this message translates to:
  /// **'转码失败，请确认音频文件可正常播放'**
  String get audioConvertFailedHint;

  /// No description provided for @audioConvertFailed.
  ///
  /// In zh, this message translates to:
  /// **'转码失败'**
  String get audioConvertFailed;

  /// No description provided for @metronomeTitle.
  ///
  /// In zh, this message translates to:
  /// **'节拍器'**
  String get metronomeTitle;

  /// No description provided for @metronomeSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'调节 BPM、拍号重音与音量，支持点击测速'**
  String get metronomeSubtitle;

  /// No description provided for @metronomeDecreaseBpm.
  ///
  /// In zh, this message translates to:
  /// **'减少 1 BPM'**
  String get metronomeDecreaseBpm;

  /// No description provided for @metronomeIncreaseBpm.
  ///
  /// In zh, this message translates to:
  /// **'增加 1 BPM'**
  String get metronomeIncreaseBpm;

  /// No description provided for @metronomeTapTempo.
  ///
  /// In zh, this message translates to:
  /// **'点击测速'**
  String get metronomeTapTempo;

  /// No description provided for @metronomeTempo.
  ///
  /// In zh, this message translates to:
  /// **'速度'**
  String get metronomeTempo;

  /// No description provided for @metronomeBpmValue.
  ///
  /// In zh, this message translates to:
  /// **'{bpm} BPM'**
  String metronomeBpmValue(int bpm);

  /// No description provided for @metronomeBeatsPerBar.
  ///
  /// In zh, this message translates to:
  /// **'每小节拍数'**
  String get metronomeBeatsPerBar;

  /// No description provided for @metronomeAccent.
  ///
  /// In zh, this message translates to:
  /// **'小节重音'**
  String get metronomeAccent;

  /// No description provided for @metronomeAccentHint.
  ///
  /// In zh, this message translates to:
  /// **'每小节第一拍使用更高音与高亮显示'**
  String get metronomeAccentHint;

  /// No description provided for @metronomeSound.
  ///
  /// In zh, this message translates to:
  /// **'声音提示'**
  String get metronomeSound;

  /// No description provided for @metronomeSoundHint.
  ///
  /// In zh, this message translates to:
  /// **'关闭后仅保留可视节拍'**
  String get metronomeSoundHint;

  /// No description provided for @metronomeVolume.
  ///
  /// In zh, this message translates to:
  /// **'音量'**
  String get metronomeVolume;

  /// No description provided for @puzzleTitle.
  ///
  /// In zh, this message translates to:
  /// **'数字华容道'**
  String get puzzleTitle;

  /// No description provided for @puzzleSubtitlePlaying.
  ///
  /// In zh, this message translates to:
  /// **'点击与空格相邻的方块滑动'**
  String get puzzleSubtitlePlaying;

  /// No description provided for @puzzleSubtitleSetup.
  ///
  /// In zh, this message translates to:
  /// **'自定义图片与 1:1 裁切'**
  String get puzzleSubtitleSetup;

  /// No description provided for @puzzleSelectImage.
  ///
  /// In zh, this message translates to:
  /// **'选择图片'**
  String get puzzleSelectImage;

  /// No description provided for @puzzleImportFailed.
  ///
  /// In zh, this message translates to:
  /// **'导入图片失败：{error}'**
  String puzzleImportFailed(String error);

  /// No description provided for @puzzleSolvedTitle.
  ///
  /// In zh, this message translates to:
  /// **'拼好了'**
  String get puzzleSolvedTitle;

  /// No description provided for @puzzleSolvedStats.
  ///
  /// In zh, this message translates to:
  /// **'用时 {elapsed} · {moves} 步'**
  String puzzleSolvedStats(String elapsed, int moves);

  /// No description provided for @puzzleBackToSetup.
  ///
  /// In zh, this message translates to:
  /// **'返回设置'**
  String get puzzleBackToSetup;

  /// No description provided for @puzzlePlayAgain.
  ///
  /// In zh, this message translates to:
  /// **'再来一局'**
  String get puzzlePlayAgain;

  /// No description provided for @puzzleClassicMode.
  ///
  /// In zh, this message translates to:
  /// **'经典数字模式'**
  String get puzzleClassicMode;

  /// No description provided for @puzzleCustomImage.
  ///
  /// In zh, this message translates to:
  /// **'自定义图片'**
  String get puzzleCustomImage;

  /// No description provided for @puzzlePickImageHint.
  ///
  /// In zh, this message translates to:
  /// **'选择一张图片，导入时可拖动、缩放决定 1:1 裁切区域。'**
  String get puzzlePickImageHint;

  /// No description provided for @puzzleCropSavedHint.
  ///
  /// In zh, this message translates to:
  /// **'已保存 1:1 裁切区域，可随时更换图片或重新裁切。'**
  String get puzzleCropSavedHint;

  /// No description provided for @puzzleImporting.
  ///
  /// In zh, this message translates to:
  /// **'导入中…'**
  String get puzzleImporting;

  /// No description provided for @puzzleChangeImage.
  ///
  /// In zh, this message translates to:
  /// **'更换图片'**
  String get puzzleChangeImage;

  /// No description provided for @puzzleDifficulty.
  ///
  /// In zh, this message translates to:
  /// **'难度'**
  String get puzzleDifficulty;

  /// No description provided for @puzzleDifficultyHint.
  ///
  /// In zh, this message translates to:
  /// **'方块越多越难，建议从 3 × 3 开始。'**
  String get puzzleDifficultyHint;

  /// No description provided for @puzzleHowToPlay.
  ///
  /// In zh, this message translates to:
  /// **'点击空格相邻的方块即可交换位置，把图片或数字按顺序还原即获胜。'**
  String get puzzleHowToPlay;

  /// No description provided for @puzzleStartGame.
  ///
  /// In zh, this message translates to:
  /// **'开始游戏'**
  String get puzzleStartGame;

  /// No description provided for @puzzleMoves.
  ///
  /// In zh, this message translates to:
  /// **'步数'**
  String get puzzleMoves;

  /// No description provided for @puzzleTime.
  ///
  /// In zh, this message translates to:
  /// **'用时'**
  String get puzzleTime;

  /// No description provided for @puzzleViewOriginal.
  ///
  /// In zh, this message translates to:
  /// **'查看原图'**
  String get puzzleViewOriginal;

  /// No description provided for @puzzleShuffle.
  ///
  /// In zh, this message translates to:
  /// **'重新打乱'**
  String get puzzleShuffle;

  /// No description provided for @puzzleShowNumbers.
  ///
  /// In zh, this message translates to:
  /// **'显示数字'**
  String get puzzleShowNumbers;

  /// No description provided for @puzzleSolvedHint.
  ///
  /// In zh, this message translates to:
  /// **'已完成，点击「重新打乱」再来一局'**
  String get puzzleSolvedHint;

  /// No description provided for @puzzleSlideHint.
  ///
  /// In zh, this message translates to:
  /// **'点击与空格相邻的方块即可滑动'**
  String get puzzleSlideHint;

  /// No description provided for @puzzleSelectCrop.
  ///
  /// In zh, this message translates to:
  /// **'选择裁切区域'**
  String get puzzleSelectCrop;

  /// No description provided for @puzzleCropHint.
  ///
  /// In zh, this message translates to:
  /// **'拖动图片调整位置，双指缩放或使用滑块放大；方框内即为最终 1:1 画面。'**
  String get puzzleCropHint;

  /// No description provided for @puzzleReset.
  ///
  /// In zh, this message translates to:
  /// **'重置'**
  String get puzzleReset;

  /// No description provided for @puzzleUseArea.
  ///
  /// In zh, this message translates to:
  /// **'使用此区域'**
  String get puzzleUseArea;

  /// No description provided for @qqStickerTitle.
  ///
  /// In zh, this message translates to:
  /// **'QQ 表情包'**
  String get qqStickerTitle;

  /// No description provided for @qqStickerSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'从 QQ 缓存提取并保存到相册'**
  String get qqStickerSubtitle;

  /// No description provided for @qqStickerReadStatusFailed.
  ///
  /// In zh, this message translates to:
  /// **'读取 Shizuku 状态失败'**
  String get qqStickerReadStatusFailed;

  /// No description provided for @qqStickerReadStatusFailedDetail.
  ///
  /// In zh, this message translates to:
  /// **'读取 Shizuku 状态失败：{error}'**
  String qqStickerReadStatusFailedDetail(String error);

  /// No description provided for @qqStickerNoStickers.
  ///
  /// In zh, this message translates to:
  /// **'未找到可保存的表情'**
  String get qqStickerNoStickers;

  /// No description provided for @qqStickerFoundPacks.
  ///
  /// In zh, this message translates to:
  /// **'共找到 {count} 个表情包'**
  String qqStickerFoundPacks(int count);

  /// No description provided for @qqStickerScanFailed.
  ///
  /// In zh, this message translates to:
  /// **'扫描 QQ 表情缓存失败'**
  String get qqStickerScanFailed;

  /// No description provided for @qqStickerScanFailedDetail.
  ///
  /// In zh, this message translates to:
  /// **'扫描失败：{error}'**
  String qqStickerScanFailedDetail(String error);

  /// No description provided for @qqStickerSaveFailedRetry.
  ///
  /// In zh, this message translates to:
  /// **'保存失败，请重试'**
  String get qqStickerSaveFailedRetry;

  /// No description provided for @qqStickerSavedToFolder.
  ///
  /// In zh, this message translates to:
  /// **'已保存 {saved} 张表情到 Pictures/Flupix/QQ表情'**
  String qqStickerSavedToFolder(int saved);

  /// No description provided for @qqStickerSaveFailedSuffix.
  ///
  /// In zh, this message translates to:
  /// **'，{failed} 张失败'**
  String qqStickerSaveFailedSuffix(int failed);

  /// No description provided for @qqStickerSavedToGallery.
  ///
  /// In zh, this message translates to:
  /// **'已保存 {saved} 张表情到相册'**
  String qqStickerSavedToGallery(int saved);

  /// No description provided for @qqStickerSaveFailed.
  ///
  /// In zh, this message translates to:
  /// **'保存失败'**
  String get qqStickerSaveFailed;

  /// No description provided for @qqStickerSaveFailedDetail.
  ///
  /// In zh, this message translates to:
  /// **'保存失败：{error}'**
  String qqStickerSaveFailedDetail(String error);

  /// No description provided for @qqStickerAndroidOnly.
  ///
  /// In zh, this message translates to:
  /// **'该工具仅在 Android 设备上可用'**
  String get qqStickerAndroidOnly;

  /// No description provided for @qqStickerPacks.
  ///
  /// In zh, this message translates to:
  /// **'表情包'**
  String get qqStickerPacks;

  /// No description provided for @qqStickerPacksCount.
  ///
  /// In zh, this message translates to:
  /// **'共 {count} 个'**
  String qqStickerPacksCount(int count);

  /// No description provided for @qqStickerSaveLocation.
  ///
  /// In zh, this message translates to:
  /// **'保存位置：Pictures/Flupix/QQ表情/<表情包ID>'**
  String get qqStickerSaveLocation;

  /// No description provided for @qqStickerQqMissing.
  ///
  /// In zh, this message translates to:
  /// **'未检测到 QQ'**
  String get qqStickerQqMissing;

  /// No description provided for @qqStickerQqMissingDetail.
  ///
  /// In zh, this message translates to:
  /// **'本工具读取 QQ 的表情缓存，请先安装并登录 QQ。'**
  String get qqStickerQqMissingDetail;

  /// No description provided for @qqStickerShizukuMissing.
  ///
  /// In zh, this message translates to:
  /// **'未安装 Shizuku'**
  String get qqStickerShizukuMissing;

  /// No description provided for @qqStickerShizukuMissingDetail.
  ///
  /// In zh, this message translates to:
  /// **'需要 Shizuku（Root 模式）才能访问 QQ 的私有缓存目录。'**
  String get qqStickerShizukuMissingDetail;

  /// No description provided for @qqStickerShizukuStopped.
  ///
  /// In zh, this message translates to:
  /// **'Shizuku 未运行'**
  String get qqStickerShizukuStopped;

  /// No description provided for @qqStickerShizukuStoppedDetail.
  ///
  /// In zh, this message translates to:
  /// **'请在设置中打开并启动 Shizuku（Root 模式）。'**
  String get qqStickerShizukuStoppedDetail;

  /// No description provided for @qqStickerShizukuDenied.
  ///
  /// In zh, this message translates to:
  /// **'等待 Shizuku 授权'**
  String get qqStickerShizukuDenied;

  /// No description provided for @qqStickerShizukuDeniedDetail.
  ///
  /// In zh, this message translates to:
  /// **'请前往设置完成 Shizuku 授权。'**
  String get qqStickerShizukuDeniedDetail;

  /// No description provided for @qqStickerShizukuInsufficient.
  ///
  /// In zh, this message translates to:
  /// **'Shizuku 权限不足'**
  String get qqStickerShizukuInsufficient;

  /// No description provided for @qqStickerShizukuInsufficientDetail.
  ///
  /// In zh, this message translates to:
  /// **'当前以 uid={uid} 运行，请在设置中改为 Root（uid=0）启动。'**
  String qqStickerShizukuInsufficientDetail(int uid);

  /// No description provided for @qqStickerNoCache.
  ///
  /// In zh, this message translates to:
  /// **'未找到 QQ 表情缓存'**
  String get qqStickerNoCache;

  /// No description provided for @qqStickerNoCacheDetail.
  ///
  /// In zh, this message translates to:
  /// **'请先在 QQ 中打开表情面板并加载表情，再重新检测。'**
  String get qqStickerNoCacheDetail;

  /// No description provided for @qqStickerReady.
  ///
  /// In zh, this message translates to:
  /// **'环境就绪'**
  String get qqStickerReady;

  /// No description provided for @qqStickerReadyHintEmpty.
  ///
  /// In zh, this message translates to:
  /// **'已取得 Root 权限，可以扫描 QQ 表情缓存。'**
  String get qqStickerReadyHintEmpty;

  /// No description provided for @qqStickerReadyHintCount.
  ///
  /// In zh, this message translates to:
  /// **'已读取 {count} 个表情包，可勾选后保存。'**
  String qqStickerReadyHintCount(int count);

  /// No description provided for @qqStickerUnknownStatus.
  ///
  /// In zh, this message translates to:
  /// **'无法读取状态'**
  String get qqStickerUnknownStatus;

  /// No description provided for @qqStickerUnknownStatusDetail.
  ///
  /// In zh, this message translates to:
  /// **'Shizuku 状态未知，请重新检测。'**
  String get qqStickerUnknownStatusDetail;

  /// No description provided for @qqStickerGoSettings.
  ///
  /// In zh, this message translates to:
  /// **'前往设置'**
  String get qqStickerGoSettings;

  /// No description provided for @qqStickerScanning.
  ///
  /// In zh, this message translates to:
  /// **'扫描中…'**
  String get qqStickerScanning;

  /// No description provided for @qqStickerScan.
  ///
  /// In zh, this message translates to:
  /// **'扫描表情包'**
  String get qqStickerScan;

  /// No description provided for @qqStickerRescan.
  ///
  /// In zh, this message translates to:
  /// **'重新扫描'**
  String get qqStickerRescan;

  /// No description provided for @qqStickerPackTitle.
  ///
  /// In zh, this message translates to:
  /// **'表情包 {id}'**
  String qqStickerPackTitle(String id);

  /// No description provided for @qqStickerPackSelectedSummary.
  ///
  /// In zh, this message translates to:
  /// **'{total} 个 · 已选 {selected}'**
  String qqStickerPackSelectedSummary(int total, int selected);

  /// No description provided for @qqStickerPackSummary.
  ///
  /// In zh, this message translates to:
  /// **'{count} 个表情'**
  String qqStickerPackSummary(int count);

  /// No description provided for @qqStickerTapToSelect.
  ///
  /// In zh, this message translates to:
  /// **'点击表情选择'**
  String get qqStickerTapToSelect;

  /// No description provided for @qqStickerSelectPack.
  ///
  /// In zh, this message translates to:
  /// **'全选本包'**
  String get qqStickerSelectPack;

  /// No description provided for @qqStickerSelectedCount.
  ///
  /// In zh, this message translates to:
  /// **'已选 {count} 张'**
  String qqStickerSelectedCount(int count);

  /// No description provided for @qqStickerSaveToAlbum.
  ///
  /// In zh, this message translates to:
  /// **'保存到 相册/Pictures/Flupix/QQ表情'**
  String get qqStickerSaveToAlbum;

  /// No description provided for @qqStickerSaving.
  ///
  /// In zh, this message translates to:
  /// **'保存中…'**
  String get qqStickerSaving;

  /// No description provided for @passwordSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'使用加密安全随机数生成密码'**
  String get passwordSubtitle;

  /// No description provided for @passwordResult.
  ///
  /// In zh, this message translates to:
  /// **'生成结果'**
  String get passwordResult;

  /// No description provided for @passwordEmptyHint.
  ///
  /// In zh, this message translates to:
  /// **'请选择至少一种字符类型'**
  String get passwordEmptyHint;

  /// No description provided for @passwordSelectAtLeastOne.
  ///
  /// In zh, this message translates to:
  /// **'至少选择一种字符类型'**
  String get passwordSelectAtLeastOne;

  /// No description provided for @passwordEntropy.
  ///
  /// In zh, this message translates to:
  /// **'约 {bits} 位熵'**
  String passwordEntropy(String bits);

  /// No description provided for @passwordRegenerate.
  ///
  /// In zh, this message translates to:
  /// **'重新生成'**
  String get passwordRegenerate;

  /// No description provided for @passwordCopyTooltip.
  ///
  /// In zh, this message translates to:
  /// **'复制密码'**
  String get passwordCopyTooltip;

  /// No description provided for @passwordLength.
  ///
  /// In zh, this message translates to:
  /// **'密码长度'**
  String get passwordLength;

  /// No description provided for @passwordUppercase.
  ///
  /// In zh, this message translates to:
  /// **'大写字母'**
  String get passwordUppercase;

  /// No description provided for @passwordLowercase.
  ///
  /// In zh, this message translates to:
  /// **'小写字母'**
  String get passwordLowercase;

  /// No description provided for @passwordDigits.
  ///
  /// In zh, this message translates to:
  /// **'数字'**
  String get passwordDigits;

  /// No description provided for @passwordSymbols.
  ///
  /// In zh, this message translates to:
  /// **'符号'**
  String get passwordSymbols;

  /// No description provided for @passwordExcludeAmbiguous.
  ///
  /// In zh, this message translates to:
  /// **'排除易混淆字符'**
  String get passwordExcludeAmbiguous;

  /// No description provided for @passwordExcludeAmbiguousHint.
  ///
  /// In zh, this message translates to:
  /// **'去掉 O、0、l、1、I 等容易看错的字符'**
  String get passwordExcludeAmbiguousHint;

  /// No description provided for @passwordStrengthWeak.
  ///
  /// In zh, this message translates to:
  /// **'较弱'**
  String get passwordStrengthWeak;

  /// No description provided for @passwordStrengthFair.
  ///
  /// In zh, this message translates to:
  /// **'一般'**
  String get passwordStrengthFair;

  /// No description provided for @passwordStrengthStrong.
  ///
  /// In zh, this message translates to:
  /// **'强'**
  String get passwordStrengthStrong;

  /// No description provided for @passwordStrengthVeryStrong.
  ///
  /// In zh, this message translates to:
  /// **'很强'**
  String get passwordStrengthVeryStrong;

  /// No description provided for @qrSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'输入文本即可生成可扫描的二维码'**
  String get qrSubtitle;

  /// No description provided for @qrContentLabel.
  ///
  /// In zh, this message translates to:
  /// **'二维码内容'**
  String get qrContentLabel;

  /// No description provided for @qrContentHint.
  ///
  /// In zh, this message translates to:
  /// **'支持文本、网址、联系方式等'**
  String get qrContentHint;

  /// No description provided for @qrEmptyTip.
  ///
  /// In zh, this message translates to:
  /// **'输入内容后生成二维码'**
  String get qrEmptyTip;

  /// No description provided for @qrTooLong.
  ///
  /// In zh, this message translates to:
  /// **'内容过长（{bytes} 字节），请精简到约 1800 字节以内'**
  String qrTooLong(int bytes);

  /// No description provided for @qrCharCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 个字符'**
  String qrCharCount(int count);

  /// No description provided for @qrCopiedContent.
  ///
  /// In zh, this message translates to:
  /// **'内容已复制'**
  String get qrCopiedContent;

  /// No description provided for @qrCopyContent.
  ///
  /// In zh, this message translates to:
  /// **'复制内容'**
  String get qrCopyContent;

  /// No description provided for @qrSize.
  ///
  /// In zh, this message translates to:
  /// **'二维码尺寸'**
  String get qrSize;

  /// No description provided for @qrSizePx.
  ///
  /// In zh, this message translates to:
  /// **'{size} px'**
  String qrSizePx(int size);

  /// No description provided for @qrUseThemeColor.
  ///
  /// In zh, this message translates to:
  /// **'使用主题色'**
  String get qrUseThemeColor;

  /// No description provided for @qrUseThemeColorHint.
  ///
  /// In zh, this message translates to:
  /// **'开启后二维码模块使用当前主题主色'**
  String get qrUseThemeColorHint;

  /// No description provided for @pixivTokenSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'OAuth 登录获取与刷新令牌'**
  String get pixivTokenSubtitle;

  /// No description provided for @pixivLoginTitle.
  ///
  /// In zh, this message translates to:
  /// **'登录 pixiv'**
  String get pixivLoginTitle;

  /// No description provided for @pixivLoginCancelled.
  ///
  /// In zh, this message translates to:
  /// **'已取消登录'**
  String get pixivLoginCancelled;

  /// No description provided for @pixivLoginSuccess.
  ///
  /// In zh, this message translates to:
  /// **'登录成功，已获取 Token'**
  String get pixivLoginSuccess;

  /// No description provided for @pixivLoginFailed.
  ///
  /// In zh, this message translates to:
  /// **'登录失败：{error}'**
  String pixivLoginFailed(String error);

  /// No description provided for @pixivTokenRefreshed.
  ///
  /// In zh, this message translates to:
  /// **'Token 已刷新'**
  String get pixivTokenRefreshed;

  /// No description provided for @pixivRefreshFailed.
  ///
  /// In zh, this message translates to:
  /// **'刷新失败：{error}'**
  String pixivRefreshFailed(String error);

  /// No description provided for @pixivClearDataTitle.
  ///
  /// In zh, this message translates to:
  /// **'清除本地数据'**
  String get pixivClearDataTitle;

  /// No description provided for @pixivClearDataBody.
  ///
  /// In zh, this message translates to:
  /// **'将删除本机保存的 access_token 与 refresh_token，之后需要重新登录。'**
  String get pixivClearDataBody;

  /// No description provided for @pixivClearAction.
  ///
  /// In zh, this message translates to:
  /// **'清除'**
  String get pixivClearAction;

  /// No description provided for @pixivTokenCleared.
  ///
  /// In zh, this message translates to:
  /// **'已清除本地 Token'**
  String get pixivTokenCleared;

  /// No description provided for @pixivPhpSessionObtained.
  ///
  /// In zh, this message translates to:
  /// **'已获取 PHPSESSID'**
  String get pixivPhpSessionObtained;

  /// No description provided for @pixivTokenExpired.
  ///
  /// In zh, this message translates to:
  /// **'已过期，请刷新'**
  String get pixivTokenExpired;

  /// No description provided for @pixivTokenRemaining.
  ///
  /// In zh, this message translates to:
  /// **'剩余 {time}'**
  String pixivTokenRemaining(String time);

  /// No description provided for @pixivTokenSection.
  ///
  /// In zh, this message translates to:
  /// **'令牌'**
  String get pixivTokenSection;

  /// No description provided for @pixivTokenCopyAll.
  ///
  /// In zh, this message translates to:
  /// **'复制全部'**
  String get pixivTokenCopyAll;

  /// No description provided for @pixivWebCookieTitle.
  ///
  /// In zh, this message translates to:
  /// **'Web 端 Cookie'**
  String get pixivWebCookieTitle;

  /// No description provided for @pixivWebCookieDesc.
  ///
  /// In zh, this message translates to:
  /// **'Pixeval 等使用 WebAPI 的工具需要 PHPSESSID，需在 pixiv 网页版登录后读取。'**
  String get pixivWebCookieDesc;

  /// No description provided for @pixivFetchCookie.
  ///
  /// In zh, this message translates to:
  /// **'获取 pixiv.net Cookie'**
  String get pixivFetchCookie;

  /// No description provided for @pixivFetchCookieAgain.
  ///
  /// In zh, this message translates to:
  /// **'重新获取'**
  String get pixivFetchCookieAgain;

  /// No description provided for @pixivSecurityTitle.
  ///
  /// In zh, this message translates to:
  /// **'安全提示'**
  String get pixivSecurityTitle;

  /// No description provided for @pixivSecurityBody.
  ///
  /// In zh, this message translates to:
  /// **'access_token 与 refresh_token 等同于账号凭证，请勿分享或提交到公开仓库。令牌仅保存在本机，除 pixiv 官方域名外不会向任何服务器发送数据。'**
  String get pixivSecurityBody;

  /// No description provided for @pixivNotLoggedIn.
  ///
  /// In zh, this message translates to:
  /// **'未登录'**
  String get pixivNotLoggedIn;

  /// No description provided for @pixivLoggedIn.
  ///
  /// In zh, this message translates to:
  /// **'已登录'**
  String get pixivLoggedIn;

  /// No description provided for @pixivLoginHint.
  ///
  /// In zh, this message translates to:
  /// **'登录后可获取 access_token 与 refresh_token'**
  String get pixivLoginHint;

  /// No description provided for @pixivProcessing.
  ///
  /// In zh, this message translates to:
  /// **'处理中…'**
  String get pixivProcessing;

  /// No description provided for @pixivRefreshTokenButton.
  ///
  /// In zh, this message translates to:
  /// **'刷新 Token'**
  String get pixivRefreshTokenButton;

  /// No description provided for @pixivReloginButton.
  ///
  /// In zh, this message translates to:
  /// **'重新登录'**
  String get pixivReloginButton;

  /// No description provided for @pixivTokenHide.
  ///
  /// In zh, this message translates to:
  /// **'隐藏'**
  String get pixivTokenHide;

  /// No description provided for @pixivTokenShow.
  ///
  /// In zh, this message translates to:
  /// **'显示'**
  String get pixivTokenShow;

  /// No description provided for @pixivLoginPageHint.
  ///
  /// In zh, this message translates to:
  /// **'请在页面中完成 pixiv 登录。登录成功后会自动返回，若弹出「打开 Pixiv 应用」提示可忽略。'**
  String get pixivLoginPageHint;

  /// No description provided for @pixivPhpSessionMissing.
  ///
  /// In zh, this message translates to:
  /// **'未找到 PHPSESSID，请先在页面中登录 pixiv'**
  String get pixivPhpSessionMissing;

  /// No description provided for @pixivCookieReadFailed.
  ///
  /// In zh, this message translates to:
  /// **'读取 Cookie 失败，请重试'**
  String get pixivCookieReadFailed;

  /// No description provided for @pixivCookiePageTitle.
  ///
  /// In zh, this message translates to:
  /// **'登录 pixiv 网页版'**
  String get pixivCookiePageTitle;

  /// No description provided for @pixivReadingCookie.
  ///
  /// In zh, this message translates to:
  /// **'读取中…'**
  String get pixivReadingCookie;

  /// No description provided for @pixivConnectionFailed.
  ///
  /// In zh, this message translates to:
  /// **'无法连接 pixiv 服务器（{reason}）。oauth.secure.pixiv.net 在中国大陆通常无法直连，请先配置代理。'**
  String pixivConnectionFailed(String reason);

  /// No description provided for @pixivTimeout.
  ///
  /// In zh, this message translates to:
  /// **'请求超时，请检查网络状态或代理地址是否正确。'**
  String get pixivTimeout;

  /// No description provided for @pixivDirectConnection.
  ///
  /// In zh, this message translates to:
  /// **'当前为直连'**
  String get pixivDirectConnection;

  /// No description provided for @pixivErrorWithAddress.
  ///
  /// In zh, this message translates to:
  /// **'当前代理 {address}'**
  String pixivErrorWithAddress(String address);

  /// No description provided for @pixivConnectionFailedWithTarget.
  ///
  /// In zh, this message translates to:
  /// **'无法连接 pixiv 服务器（{target}），请确认代理已开启且地址正确。'**
  String pixivConnectionFailedWithTarget(String target);

  /// No description provided for @pixivNetworkError.
  ///
  /// In zh, this message translates to:
  /// **'网络请求失败：{message}'**
  String pixivNetworkError(String message);

  /// No description provided for @pixivInvalidResponse.
  ///
  /// In zh, this message translates to:
  /// **'服务器返回了无法解析的内容（HTTP {status}）'**
  String pixivInvalidResponse(int status);

  /// No description provided for @ehSiteEHentai.
  ///
  /// In zh, this message translates to:
  /// **'E-Hentai'**
  String get ehSiteEHentai;

  /// No description provided for @ehSiteExHentai.
  ///
  /// In zh, this message translates to:
  /// **'ExHentai'**
  String get ehSiteExHentai;

  /// No description provided for @ehCategoryMisc.
  ///
  /// In zh, this message translates to:
  /// **'杂项'**
  String get ehCategoryMisc;

  /// No description provided for @ehCategoryDoujinshi.
  ///
  /// In zh, this message translates to:
  /// **'同人志'**
  String get ehCategoryDoujinshi;

  /// No description provided for @ehCategoryManga.
  ///
  /// In zh, this message translates to:
  /// **'漫画'**
  String get ehCategoryManga;

  /// No description provided for @ehCategoryArtistCg.
  ///
  /// In zh, this message translates to:
  /// **'画师 CG'**
  String get ehCategoryArtistCg;

  /// No description provided for @ehCategoryGameCg.
  ///
  /// In zh, this message translates to:
  /// **'游戏 CG'**
  String get ehCategoryGameCg;

  /// No description provided for @ehCategoryImageSet.
  ///
  /// In zh, this message translates to:
  /// **'图集'**
  String get ehCategoryImageSet;

  /// No description provided for @ehCategoryCosplay.
  ///
  /// In zh, this message translates to:
  /// **'Cosplay'**
  String get ehCategoryCosplay;

  /// No description provided for @ehCategoryAsian.
  ///
  /// In zh, this message translates to:
  /// **'亚洲'**
  String get ehCategoryAsian;

  /// No description provided for @ehCategoryNonH.
  ///
  /// In zh, this message translates to:
  /// **'非 H'**
  String get ehCategoryNonH;

  /// No description provided for @ehCategoryWestern.
  ///
  /// In zh, this message translates to:
  /// **'欧美'**
  String get ehCategoryWestern;

  /// No description provided for @ehBrowseLoggedIn.
  ///
  /// In zh, this message translates to:
  /// **'已登录'**
  String get ehBrowseLoggedIn;

  /// No description provided for @ehBrowseGuest.
  ///
  /// In zh, this message translates to:
  /// **'访客'**
  String get ehBrowseGuest;

  /// No description provided for @ehBrowseSwitchSite.
  ///
  /// In zh, this message translates to:
  /// **'切换站点'**
  String get ehBrowseSwitchSite;

  /// No description provided for @ehBrowseRelogin.
  ///
  /// In zh, this message translates to:
  /// **'重新登录'**
  String get ehBrowseRelogin;

  /// No description provided for @ehBrowseLogin.
  ///
  /// In zh, this message translates to:
  /// **'登录'**
  String get ehBrowseLogin;

  /// No description provided for @ehBrowseMyLibrary.
  ///
  /// In zh, this message translates to:
  /// **'我的图库'**
  String get ehBrowseMyLibrary;

  /// No description provided for @ehBrowseDownloads.
  ///
  /// In zh, this message translates to:
  /// **'下载管理'**
  String get ehBrowseDownloads;

  /// No description provided for @ehBrowseLogout.
  ///
  /// In zh, this message translates to:
  /// **'退出登录'**
  String get ehBrowseLogout;

  /// No description provided for @ehBrowseSearchHint.
  ///
  /// In zh, this message translates to:
  /// **'搜索标题、标签或上传者'**
  String get ehBrowseSearchHint;

  /// No description provided for @ehBrowseGuestBanner.
  ///
  /// In zh, this message translates to:
  /// **'未登录只能浏览列表，阅读与 ExHentai 需要登录。'**
  String get ehBrowseGuestBanner;

  /// No description provided for @ehBrowseNoResults.
  ///
  /// In zh, this message translates to:
  /// **'没有找到结果'**
  String get ehBrowseNoResults;

  /// No description provided for @ehBrowseTotalResults.
  ///
  /// In zh, this message translates to:
  /// **'共约 {count} 个结果'**
  String ehBrowseTotalResults(int count);

  /// No description provided for @ehBrowseReachedPage.
  ///
  /// In zh, this message translates to:
  /// **'已到第 {page} 页'**
  String ehBrowseReachedPage(int page);

  /// No description provided for @ehBrowseNoMore.
  ///
  /// In zh, this message translates to:
  /// **'没有更多了'**
  String get ehBrowseNoMore;

  /// No description provided for @ehBrowseInitFailed.
  ///
  /// In zh, this message translates to:
  /// **'初始化失败：{error}'**
  String ehBrowseInitFailed(String error);

  /// No description provided for @ehFilterExcludeHint.
  ///
  /// In zh, this message translates to:
  /// **'选中表示排除该分类'**
  String get ehFilterExcludeHint;

  /// No description provided for @ehDetailTitle.
  ///
  /// In zh, this message translates to:
  /// **'图库详情'**
  String get ehDetailTitle;

  /// No description provided for @ehDetailCannotRead.
  ///
  /// In zh, this message translates to:
  /// **'无法获取页数，暂时不能阅读'**
  String get ehDetailCannotRead;

  /// No description provided for @ehDetailFavoriteAdded.
  ///
  /// In zh, this message translates to:
  /// **'已加入收藏'**
  String get ehDetailFavoriteAdded;

  /// No description provided for @ehDetailFavoriteRemoved.
  ///
  /// In zh, this message translates to:
  /// **'已取消收藏'**
  String get ehDetailFavoriteRemoved;

  /// No description provided for @ehDetailDownloadToLocal.
  ///
  /// In zh, this message translates to:
  /// **'下载到本地'**
  String get ehDetailDownloadToLocal;

  /// No description provided for @ehDetailDownloaded.
  ///
  /// In zh, this message translates to:
  /// **'已下载'**
  String get ehDetailDownloaded;

  /// No description provided for @ehDetailPauseDownload.
  ///
  /// In zh, this message translates to:
  /// **'暂停下载'**
  String get ehDetailPauseDownload;

  /// No description provided for @ehDetailCancelQueue.
  ///
  /// In zh, this message translates to:
  /// **'取消排队'**
  String get ehDetailCancelQueue;

  /// No description provided for @ehDetailRetryDownload.
  ///
  /// In zh, this message translates to:
  /// **'重试下载'**
  String get ehDetailRetryDownload;

  /// No description provided for @ehDetailResumeDownload.
  ///
  /// In zh, this message translates to:
  /// **'继续下载'**
  String get ehDetailResumeDownload;

  /// No description provided for @ehDetailQueuedWithPages.
  ///
  /// In zh, this message translates to:
  /// **'已加入下载队列（共 {total} 页）'**
  String ehDetailQueuedWithPages(int total);

  /// No description provided for @ehDetailQueued.
  ///
  /// In zh, this message translates to:
  /// **'已加入下载队列'**
  String get ehDetailQueued;

  /// No description provided for @ehDetailDownloadProgress.
  ///
  /// In zh, this message translates to:
  /// **'{downloaded}/{total} 页'**
  String ehDetailDownloadProgress(int downloaded, int total);

  /// No description provided for @ehDetailQueuedProgress.
  ///
  /// In zh, this message translates to:
  /// **'已加入下载队列 · {progress}'**
  String ehDetailQueuedProgress(String progress);

  /// No description provided for @ehDetailDownloadingProgress.
  ///
  /// In zh, this message translates to:
  /// **'正在下载 · {progress}'**
  String ehDetailDownloadingProgress(String progress);

  /// No description provided for @ehDetailPausedProgress.
  ///
  /// In zh, this message translates to:
  /// **'已暂停 · {progress}'**
  String ehDetailPausedProgress(String progress);

  /// No description provided for @ehDetailPausedError.
  ///
  /// In zh, this message translates to:
  /// **'已暂停 · {error}'**
  String ehDetailPausedError(String error);

  /// No description provided for @ehDetailCompletedProgress.
  ///
  /// In zh, this message translates to:
  /// **'已下载 · {progress}'**
  String ehDetailCompletedProgress(String progress);

  /// No description provided for @ehDetailFailedError.
  ///
  /// In zh, this message translates to:
  /// **'下载失败 · {error}'**
  String ehDetailFailedError(String error);

  /// No description provided for @ehDetailUnknownError.
  ///
  /// In zh, this message translates to:
  /// **'未知错误'**
  String get ehDetailUnknownError;

  /// No description provided for @ehDetailUnfavorite.
  ///
  /// In zh, this message translates to:
  /// **'取消收藏'**
  String get ehDetailUnfavorite;

  /// No description provided for @ehDetailFavorite.
  ///
  /// In zh, this message translates to:
  /// **'收藏'**
  String get ehDetailFavorite;

  /// No description provided for @ehDetailTags.
  ///
  /// In zh, this message translates to:
  /// **'标签'**
  String get ehDetailTags;

  /// No description provided for @ehDetailTapToJump.
  ///
  /// In zh, this message translates to:
  /// **'点击跳页'**
  String get ehDetailTapToJump;

  /// No description provided for @ehDetailStartReading.
  ///
  /// In zh, this message translates to:
  /// **'开始阅读'**
  String get ehDetailStartReading;

  /// No description provided for @ehDetailContinueReading.
  ///
  /// In zh, this message translates to:
  /// **'继续阅读 第 {page} 页'**
  String ehDetailContinueReading(int page);

  /// No description provided for @ehDetailPagesCount.
  ///
  /// In zh, this message translates to:
  /// **'{pages} 页'**
  String ehDetailPagesCount(int pages);

  /// No description provided for @ehDetailUploader.
  ///
  /// In zh, this message translates to:
  /// **'上传者：{uploader}'**
  String ehDetailUploader(String uploader);

  /// No description provided for @ehReaderLocalImageFailed.
  ///
  /// In zh, this message translates to:
  /// **'本地图片读取失败'**
  String get ehReaderLocalImageFailed;

  /// No description provided for @ehReaderImageFailed.
  ///
  /// In zh, this message translates to:
  /// **'图片加载失败'**
  String get ehReaderImageFailed;

  /// No description provided for @ehReaderRestartFromFirstPage.
  ///
  /// In zh, this message translates to:
  /// **'从第一页开始'**
  String get ehReaderRestartFromFirstPage;

  /// No description provided for @ehReaderLtr.
  ///
  /// In zh, this message translates to:
  /// **'切换为从左到右'**
  String get ehReaderLtr;

  /// No description provided for @ehReaderRtl.
  ///
  /// In zh, this message translates to:
  /// **'切换为从右到左'**
  String get ehReaderRtl;

  /// No description provided for @ehReaderGestureHint.
  ///
  /// In zh, this message translates to:
  /// **'双击或双指缩放 · 点击中部显示/隐藏工具栏'**
  String get ehReaderGestureHint;

  /// No description provided for @ehReaderRateLimited.
  ///
  /// In zh, this message translates to:
  /// **'站点限流或临时封禁，{seconds} 秒后可重试'**
  String ehReaderRateLimited(int seconds);

  /// No description provided for @ehReaderPageLoadFailed.
  ///
  /// In zh, this message translates to:
  /// **'该页加载失败'**
  String get ehReaderPageLoadFailed;

  /// No description provided for @ehTagTitle.
  ///
  /// In zh, this message translates to:
  /// **'标签检索'**
  String get ehTagTitle;

  /// No description provided for @ehTagImportTitle.
  ///
  /// In zh, this message translates to:
  /// **'导入标签翻译'**
  String get ehTagImportTitle;

  /// No description provided for @ehTagImportAction.
  ///
  /// In zh, this message translates to:
  /// **'导入'**
  String get ehTagImportAction;

  /// No description provided for @ehTagImported.
  ///
  /// In zh, this message translates to:
  /// **'已导入 {count} 条翻译'**
  String ehTagImported(int count);

  /// No description provided for @ehTagImportFailed.
  ///
  /// In zh, this message translates to:
  /// **'导入失败：{error}'**
  String ehTagImportFailed(String error);

  /// No description provided for @ehTagClearHistoryTitle.
  ///
  /// In zh, this message translates to:
  /// **'清空标签历史'**
  String get ehTagClearHistoryTitle;

  /// No description provided for @ehTagClearHistoryMessage.
  ///
  /// In zh, this message translates to:
  /// **'将删除全部本地标签记录。'**
  String get ehTagClearHistoryMessage;

  /// No description provided for @ehTagHistoryCleared.
  ///
  /// In zh, this message translates to:
  /// **'标签历史已清空'**
  String get ehTagHistoryCleared;

  /// No description provided for @ehTagClearTranslationsTitle.
  ///
  /// In zh, this message translates to:
  /// **'清空导入的翻译'**
  String get ehTagClearTranslationsTitle;

  /// No description provided for @ehTagClearTranslationsMessage.
  ///
  /// In zh, this message translates to:
  /// **'内置翻译仍会保留。'**
  String get ehTagClearTranslationsMessage;

  /// No description provided for @ehTagTranslationsCleared.
  ///
  /// In zh, this message translates to:
  /// **'导入的翻译已清空'**
  String get ehTagTranslationsCleared;

  /// No description provided for @ehTagLocalCount.
  ///
  /// In zh, this message translates to:
  /// **'共 {count} 个本地标签'**
  String ehTagLocalCount(int count);

  /// No description provided for @ehTagImportTooltip.
  ///
  /// In zh, this message translates to:
  /// **'导入翻译'**
  String get ehTagImportTooltip;

  /// No description provided for @ehTagSearchHint.
  ///
  /// In zh, this message translates to:
  /// **'搜索标签或中文翻译'**
  String get ehTagSearchHint;

  /// No description provided for @ehTagNoMatch.
  ///
  /// In zh, this message translates to:
  /// **'没有匹配的标签'**
  String get ehTagNoMatch;

  /// No description provided for @ehTagNoRecords.
  ///
  /// In zh, this message translates to:
  /// **'还没有标签记录'**
  String get ehTagNoRecords;

  /// No description provided for @ehTagNoMatchHint.
  ///
  /// In zh, this message translates to:
  /// **'试试其它关键词，或直接在图库详情中点击标签。'**
  String get ehTagNoMatchHint;

  /// No description provided for @ehTagNoRecordsHint.
  ///
  /// In zh, this message translates to:
  /// **'打开任意图库详情后会自动收集标签，也可以先导入翻译库。'**
  String get ehTagNoRecordsHint;

  /// No description provided for @ehTagImportLibrary.
  ///
  /// In zh, this message translates to:
  /// **'导入翻译库'**
  String get ehTagImportLibrary;

  /// No description provided for @ehLoginTitle.
  ///
  /// In zh, this message translates to:
  /// **'E-Hentai 登录'**
  String get ehLoginTitle;

  /// No description provided for @ehLoginTabWeb.
  ///
  /// In zh, this message translates to:
  /// **'网页登录'**
  String get ehLoginTabWeb;

  /// No description provided for @ehLoginTabManual.
  ///
  /// In zh, this message translates to:
  /// **'手动 Cookie'**
  String get ehLoginTabManual;

  /// No description provided for @ehLoginReading.
  ///
  /// In zh, this message translates to:
  /// **'读取中…'**
  String get ehLoginReading;

  /// No description provided for @ehLoginHint.
  ///
  /// In zh, this message translates to:
  /// **'登录 Cookie 仅保存在本机，用于访问 E-Hentai / ExHentai。'**
  String get ehLoginHint;

  /// No description provided for @ehLoginNoCookie.
  ///
  /// In zh, this message translates to:
  /// **'尚未检测到登录 Cookie，请先在网页中完成登录'**
  String get ehLoginNoCookie;

  /// No description provided for @ehLoginNotEffective.
  ///
  /// In zh, this message translates to:
  /// **'网页登录未生效：请确认已通过验证并成功登录账号'**
  String get ehLoginNotEffective;

  /// No description provided for @ehLoginGotCookies.
  ///
  /// In zh, this message translates to:
  /// **'已获取登录与 ExHentai Cookie，可点击右上角完成'**
  String get ehLoginGotCookies;

  /// No description provided for @ehLoginRefreshingExAfterLogin.
  ///
  /// In zh, this message translates to:
  /// **'已登录，正在获取 ExHentai 权限…'**
  String get ehLoginRefreshingExAfterLogin;

  /// No description provided for @ehLoginRefreshingEx.
  ///
  /// In zh, this message translates to:
  /// **'正在获取 ExHentai 权限…'**
  String get ehLoginRefreshingEx;

  /// No description provided for @ehLoginExGranted.
  ///
  /// In zh, this message translates to:
  /// **'已获得 ExHentai 权限，可返回浏览里站'**
  String get ehLoginExGranted;

  /// No description provided for @ehLoginExGrantedViaWeb.
  ///
  /// In zh, this message translates to:
  /// **'已通过网页获取 ExHentai 权限，可返回浏览里站'**
  String get ehLoginExGrantedViaWeb;

  /// No description provided for @ehLoginClearWebCookiesTitle.
  ///
  /// In zh, this message translates to:
  /// **'清空网页 Cookie'**
  String get ehLoginClearWebCookiesTitle;

  /// No description provided for @ehLoginClearWebCookiesMessage.
  ///
  /// In zh, this message translates to:
  /// **'将清除 E-Hentai / ExHentai 的网页登录状态，并重新打开论坛登录页。'**
  String get ehLoginClearWebCookiesMessage;

  /// No description provided for @ehLoginClearWebCookiesConfirm.
  ///
  /// In zh, this message translates to:
  /// **'清空并重新登录'**
  String get ehLoginClearWebCookiesConfirm;

  /// No description provided for @ehLoginClearingCookies.
  ///
  /// In zh, this message translates to:
  /// **'正在清空 Cookie…'**
  String get ehLoginClearingCookies;

  /// No description provided for @ehLoginClearedCookies.
  ///
  /// In zh, this message translates to:
  /// **'已清空网页 Cookie，请重新登录'**
  String get ehLoginClearedCookies;

  /// No description provided for @ehLoginLoginFirst.
  ///
  /// In zh, this message translates to:
  /// **'请先在网页中完成登录'**
  String get ehLoginLoginFirst;

  /// No description provided for @ehLoginManualMissing.
  ///
  /// In zh, this message translates to:
  /// **'需要至少包含 ipb_member_id 与 ipb_pass_hash'**
  String get ehLoginManualMissing;

  /// No description provided for @ehLoginCookieInvalid.
  ///
  /// In zh, this message translates to:
  /// **'Cookie 无效或已过期，请重新获取'**
  String get ehLoginCookieInvalid;

  /// No description provided for @ehLoginPageLoadFailed.
  ///
  /// In zh, this message translates to:
  /// **'页面加载失败：{error}'**
  String ehLoginPageLoadFailed(String error);

  /// No description provided for @ehLoginAutoHint.
  ///
  /// In zh, this message translates to:
  /// **'登录后自动读取 Cookie 并换取 ExHentai 凭证。'**
  String get ehLoginAutoHint;

  /// No description provided for @ehLoginClearCookie.
  ///
  /// In zh, this message translates to:
  /// **'清空 Cookie'**
  String get ehLoginClearCookie;

  /// No description provided for @ehLoginDetecting.
  ///
  /// In zh, this message translates to:
  /// **'检测中…'**
  String get ehLoginDetecting;

  /// No description provided for @ehLoginDetectEx.
  ///
  /// In zh, this message translates to:
  /// **'检测 EX'**
  String get ehLoginDetectEx;

  /// No description provided for @ehLoginManualHint.
  ///
  /// In zh, this message translates to:
  /// **'从已登录的浏览器复制完整 Cookie，至少包含 ipb_member_id、ipb_pass_hash，使用 ExHentai 时还需要 igneous。支持 key=value 或 key: value 换行格式。'**
  String get ehLoginManualHint;

  /// No description provided for @ehLoginValidating.
  ///
  /// In zh, this message translates to:
  /// **'校验中…'**
  String get ehLoginValidating;

  /// No description provided for @ehLoginValidateAndSave.
  ///
  /// In zh, this message translates to:
  /// **'校验并保存'**
  String get ehLoginValidateAndSave;

  /// No description provided for @ehLibraryTitle.
  ///
  /// In zh, this message translates to:
  /// **'我的图库'**
  String get ehLibraryTitle;

  /// No description provided for @ehLibrarySubtitle.
  ///
  /// In zh, this message translates to:
  /// **'{site} · 收藏 {favorites} · 历史 {history}'**
  String ehLibrarySubtitle(String site, int favorites, int history);

  /// No description provided for @ehLibraryFavoritesSegment.
  ///
  /// In zh, this message translates to:
  /// **'收藏 {count}'**
  String ehLibraryFavoritesSegment(int count);

  /// No description provided for @ehLibraryHistorySegment.
  ///
  /// In zh, this message translates to:
  /// **'历史 {count}'**
  String ehLibraryHistorySegment(int count);

  /// No description provided for @ehLibraryNoFavorites.
  ///
  /// In zh, this message translates to:
  /// **'还没有收藏'**
  String get ehLibraryNoFavorites;

  /// No description provided for @ehLibraryNoFavoritesHint.
  ///
  /// In zh, this message translates to:
  /// **'打开图库详情后点击右上角的心形按钮即可收藏。'**
  String get ehLibraryNoFavoritesHint;

  /// No description provided for @ehLibraryTileSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'{category} · {pages} 页{rating}'**
  String ehLibraryTileSubtitle(String category, int pages, String rating);

  /// No description provided for @ehLibraryRemoveFavorite.
  ///
  /// In zh, this message translates to:
  /// **'取消收藏'**
  String get ehLibraryRemoveFavorite;

  /// No description provided for @ehLibraryNoHistory.
  ///
  /// In zh, this message translates to:
  /// **'还没有阅读记录'**
  String get ehLibraryNoHistory;

  /// No description provided for @ehLibraryNoHistoryHint.
  ///
  /// In zh, this message translates to:
  /// **'阅读任意图库后会自动记录进度，方便下次继续。'**
  String get ehLibraryNoHistoryHint;

  /// No description provided for @ehLibraryHistorySubtitle.
  ///
  /// In zh, this message translates to:
  /// **'已读 {lastPage}/{totalPages} 页 · {time}'**
  String ehLibraryHistorySubtitle(int lastPage, int totalPages, String time);

  /// No description provided for @ehLibraryRemoveHistory.
  ///
  /// In zh, this message translates to:
  /// **'移除记录'**
  String get ehLibraryRemoveHistory;

  /// No description provided for @ehLibraryTodayTime.
  ///
  /// In zh, this message translates to:
  /// **'今天 {time}'**
  String ehLibraryTodayTime(String time);

  /// No description provided for @ehDownloadTitle.
  ///
  /// In zh, this message translates to:
  /// **'下载管理'**
  String get ehDownloadTitle;

  /// No description provided for @ehDownloadSummary.
  ///
  /// In zh, this message translates to:
  /// **'共 {total} 个 · 完成 {completed} 个'**
  String ehDownloadSummary(int total, int completed);

  /// No description provided for @ehDownloadEmpty.
  ///
  /// In zh, this message translates to:
  /// **'还没有下载任务'**
  String get ehDownloadEmpty;

  /// No description provided for @ehDownloadEmptyHint.
  ///
  /// In zh, this message translates to:
  /// **'在图库详情页点击下载按钮，即可保存整本到本地并离线阅读。'**
  String get ehDownloadEmptyHint;

  /// No description provided for @ehDownloadDelete.
  ///
  /// In zh, this message translates to:
  /// **'删除下载'**
  String get ehDownloadDelete;

  /// No description provided for @ehDownloadDeleteConfirm.
  ///
  /// In zh, this message translates to:
  /// **'确定删除「{title}」的本地文件吗？'**
  String ehDownloadDeleteConfirm(String title);

  /// No description provided for @ehDownloadDownloaded.
  ///
  /// In zh, this message translates to:
  /// **'已下载'**
  String get ehDownloadDownloaded;

  /// No description provided for @ehDownloadNoPages.
  ///
  /// In zh, this message translates to:
  /// **'该图库还没有可阅读的页面'**
  String get ehDownloadNoPages;

  /// No description provided for @ehDownloadNoDownloadedPages.
  ///
  /// In zh, this message translates to:
  /// **'还没有下载完成的页面'**
  String get ehDownloadNoDownloadedPages;

  /// No description provided for @ehDownloadPagesProgress.
  ///
  /// In zh, this message translates to:
  /// **'{downloaded}/{total} 页'**
  String ehDownloadPagesProgress(int downloaded, int total);

  /// No description provided for @ehDownloadStatusQueued.
  ///
  /// In zh, this message translates to:
  /// **'等待下载 · {progress}'**
  String ehDownloadStatusQueued(String progress);

  /// No description provided for @ehDownloadStatusDownloading.
  ///
  /// In zh, this message translates to:
  /// **'正在下载 · {progress}'**
  String ehDownloadStatusDownloading(String progress);

  /// No description provided for @ehDownloadStatusPaused.
  ///
  /// In zh, this message translates to:
  /// **'已暂停 · {progress}'**
  String ehDownloadStatusPaused(String progress);

  /// No description provided for @ehDownloadStatusPausedError.
  ///
  /// In zh, this message translates to:
  /// **'已暂停 · {error}'**
  String ehDownloadStatusPausedError(String error);

  /// No description provided for @ehDownloadStatusCompleted.
  ///
  /// In zh, this message translates to:
  /// **'已完成 · {progress}'**
  String ehDownloadStatusCompleted(String progress);

  /// No description provided for @ehDownloadStatusFailed.
  ///
  /// In zh, this message translates to:
  /// **'下载失败 · {error}'**
  String ehDownloadStatusFailed(String error);

  /// No description provided for @ehDownloadUnknownError.
  ///
  /// In zh, this message translates to:
  /// **'未知错误'**
  String get ehDownloadUnknownError;

  /// No description provided for @ehStatusQueued.
  ///
  /// In zh, this message translates to:
  /// **'等待下载'**
  String get ehStatusQueued;

  /// No description provided for @ehStatusDownloading.
  ///
  /// In zh, this message translates to:
  /// **'下载中'**
  String get ehStatusDownloading;

  /// No description provided for @ehStatusPaused.
  ///
  /// In zh, this message translates to:
  /// **'已暂停'**
  String get ehStatusPaused;

  /// No description provided for @ehStatusCompleted.
  ///
  /// In zh, this message translates to:
  /// **'已完成'**
  String get ehStatusCompleted;

  /// No description provided for @ehStatusFailed.
  ///
  /// In zh, this message translates to:
  /// **'下载失败'**
  String get ehStatusFailed;

  /// No description provided for @ehDownloadPagesUnknown.
  ///
  /// In zh, this message translates to:
  /// **'无法获取图库页数'**
  String get ehDownloadPagesUnknown;

  /// No description provided for @ehDownloadFailedWith.
  ///
  /// In zh, this message translates to:
  /// **'下载失败：{error}'**
  String ehDownloadFailedWith(String error);

  /// No description provided for @ehDownloadPartial.
  ///
  /// In zh, this message translates to:
  /// **'部分页面未下载，可继续重试'**
  String get ehDownloadPartial;

  /// No description provided for @ehDownloadEmptyPage.
  ///
  /// In zh, this message translates to:
  /// **'页面内容为空'**
  String get ehDownloadEmptyPage;

  /// No description provided for @ehDownloadDirUninitialized.
  ///
  /// In zh, this message translates to:
  /// **'下载目录未初始化'**
  String get ehDownloadDirUninitialized;

  /// No description provided for @ehDownloadPausedInManager.
  ///
  /// In zh, this message translates to:
  /// **'已暂停，可在下载管理中继续'**
  String get ehDownloadPausedInManager;

  /// No description provided for @ehAuthEmptyExPage.
  ///
  /// In zh, this message translates to:
  /// **'ExHentai 返回了空页面：请重新登录，并在登录页点击「检测 EX」获取里站权限'**
  String get ehAuthEmptyExPage;

  /// No description provided for @ehAuthEmptyList.
  ///
  /// In zh, this message translates to:
  /// **'ExHentai 未返回列表：请确认登录有效，并在登录页点击「检测 EX」重新获取里站权限'**
  String get ehAuthEmptyList;

  /// No description provided for @ehAuthGetExExpired.
  ///
  /// In zh, this message translates to:
  /// **'登录已失效，请重新登录后再获取 ExHentai 权限'**
  String get ehAuthGetExExpired;

  /// No description provided for @ehAuthIgneousMystery.
  ///
  /// In zh, this message translates to:
  /// **'账号尚未获得 ExHentai 里站权限（igneous=mystery），请确认账号资格后重试'**
  String get ehAuthIgneousMystery;

  /// No description provided for @ehAuthIgneousNoContent.
  ///
  /// In zh, this message translates to:
  /// **'已获取 igneous，但 ExHentai 没有返回内容：账号可能没有里站权限或登录已失效'**
  String get ehAuthIgneousNoContent;

  /// No description provided for @ehAuthLoginExpired.
  ///
  /// In zh, this message translates to:
  /// **'登录已失效，请重新登录'**
  String get ehAuthLoginExpired;

  /// No description provided for @ehAuthMissingCredential.
  ///
  /// In zh, this message translates to:
  /// **'登录状态有效，但站点没有下发 ExHentai 凭证：请确认账号已获得里站权限'**
  String get ehAuthMissingCredential;

  /// No description provided for @ehAuthSadPanda.
  ///
  /// In zh, this message translates to:
  /// **'ExHentai 需要 igneous 凭证：请在登录页点击「检测 EX」重新授权'**
  String get ehAuthSadPanda;

  /// No description provided for @ehAuthSadPandaCookie.
  ///
  /// In zh, this message translates to:
  /// **'ExHentai 需要 igneous Cookie：请在登录页点击「检测 EX」完成授权'**
  String get ehAuthSadPandaCookie;

  /// No description provided for @ehBanLabelHoursMinutes.
  ///
  /// In zh, this message translates to:
  /// **'{hours} 小时 {minutes} 分钟'**
  String ehBanLabelHoursMinutes(int hours, int minutes);

  /// No description provided for @ehBanLabelMinutes.
  ///
  /// In zh, this message translates to:
  /// **'{minutes} 分钟'**
  String ehBanLabelMinutes(int minutes);

  /// No description provided for @ehBanRecoverAfter.
  ///
  /// In zh, this message translates to:
  /// **'当前 IP 被站点临时封禁，约 {duration}后恢复'**
  String ehBanRecoverAfter(String duration);

  /// No description provided for @ehBanTemporary.
  ///
  /// In zh, this message translates to:
  /// **'当前 IP 被站点临时封禁，请稍后重试'**
  String get ehBanTemporary;

  /// No description provided for @ehBanWaitRecovery.
  ///
  /// In zh, this message translates to:
  /// **'当前 IP 被站点临时封禁，请等待站点提示的恢复时间'**
  String get ehBanWaitRecovery;

  /// No description provided for @ehErrorCloudflare.
  ///
  /// In zh, this message translates to:
  /// **'被 Cloudflare 拦截，请打开网页完成验证'**
  String get ehErrorCloudflare;

  /// No description provided for @ehErrorRateLimited.
  ///
  /// In zh, this message translates to:
  /// **'图片服务器限流（509），请稍后再试'**
  String get ehErrorRateLimited;

  /// No description provided for @ehNetConnectFailed.
  ///
  /// In zh, this message translates to:
  /// **'网络连接失败：{error}'**
  String ehNetConnectFailed(String error);

  /// No description provided for @ehNetEmptyPage.
  ///
  /// In zh, this message translates to:
  /// **'站点返回了空页面，可能被临时封禁或限流，请稍后重试'**
  String get ehNetEmptyPage;

  /// No description provided for @ehNetImageStatusError.
  ///
  /// In zh, this message translates to:
  /// **'图片请求失败（{status}）'**
  String ehNetImageStatusError(int status);

  /// No description provided for @ehNetRequestFailed.
  ///
  /// In zh, this message translates to:
  /// **'网络请求失败：{error}'**
  String ehNetRequestFailed(String error);

  /// No description provided for @ehNetRequestStatusError.
  ///
  /// In zh, this message translates to:
  /// **'请求失败（{status}）'**
  String ehNetRequestStatusError(int status);

  /// No description provided for @ehNetServerError.
  ///
  /// In zh, this message translates to:
  /// **'服务器错误（{status}）'**
  String ehNetServerError(int status);

  /// No description provided for @ehNetTimeout.
  ///
  /// In zh, this message translates to:
  /// **'请求超时，请检查网络或代理设置'**
  String get ehNetTimeout;

  /// No description provided for @ehNetTooManyRedirects.
  ///
  /// In zh, this message translates to:
  /// **'页面跳转次数过多，请稍后重试'**
  String get ehNetTooManyRedirects;

  /// No description provided for @ehParseApiInvalid.
  ///
  /// In zh, this message translates to:
  /// **'api.php 返回了无法解析的内容'**
  String get ehParseApiInvalid;

  /// No description provided for @ehParseDetailStructure.
  ///
  /// In zh, this message translates to:
  /// **'详情页结构异常，无法找到标题'**
  String get ehParseDetailStructure;

  /// No description provided for @ehParseGalleryUnavailable.
  ///
  /// In zh, this message translates to:
  /// **'图库不可用或已被删除'**
  String get ehParseGalleryUnavailable;

  /// No description provided for @ehParseImageNotImage.
  ///
  /// In zh, this message translates to:
  /// **'图片地址返回了非图片内容'**
  String get ehParseImageNotImage;

  /// No description provided for @ehParseImageUrlFailed.
  ///
  /// In zh, this message translates to:
  /// **'无法解析该页图片地址'**
  String get ehParseImageUrlFailed;

  /// No description provided for @ehParseOtherTagGroup.
  ///
  /// In zh, this message translates to:
  /// **'其它'**
  String get ehParseOtherTagGroup;

  /// No description provided for @ehParsePTokenMissing.
  ///
  /// In zh, this message translates to:
  /// **'无法获取该页的 pToken，请从第一页开始阅读'**
  String get ehParsePTokenMissing;

  /// No description provided for @ehParseShowkeyMissing.
  ///
  /// In zh, this message translates to:
  /// **'图片页缺少 showkey，无法重新获取图片地址'**
  String get ehParseShowkeyMissing;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
