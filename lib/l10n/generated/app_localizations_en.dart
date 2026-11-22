// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get commonCopy => 'Copy';

  @override
  String get commonCopied => 'Copied to clipboard';

  @override
  String get commonClear => 'Clear';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonConfirm => 'OK';

  @override
  String get commonSave => 'Save';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonRefresh => 'Refresh';

  @override
  String get commonSearch => 'Search';

  @override
  String get commonClose => 'Close';

  @override
  String get commonLoading => 'Loading…';

  @override
  String get commonEmpty => 'Nothing here';

  @override
  String get commonAll => 'All';

  @override
  String get commonSettings => 'Settings';

  @override
  String get commonOpen => 'Open';

  @override
  String get commonStart => 'Start';

  @override
  String get commonStop => 'Stop';

  @override
  String get commonPause => 'Pause';

  @override
  String get commonResume => 'Resume';

  @override
  String get commonDone => 'Done';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonAdd => 'Add';

  @override
  String get commonRemove => 'Remove';

  @override
  String get commonSelectAll => 'Select all';

  @override
  String get commonDeselectAll => 'Deselect all';

  @override
  String get commonUnknown => 'Unknown';

  @override
  String get commonError => 'Something went wrong';

  @override
  String get commonSuccess => 'Done';

  @override
  String get commonYes => 'Yes';

  @override
  String get commonNo => 'No';

  @override
  String get commonBrowse => 'Browse';

  @override
  String get commonPickFile => 'Choose file';

  @override
  String get commonShare => 'Share';

  @override
  String get commonPreview => 'Preview';

  @override
  String get commonApply => 'Apply';

  @override
  String get commonMore => 'More';

  @override
  String get commonBack => 'Back';

  @override
  String get homeSubtitle => 'Handy tools, always at hand';

  @override
  String homeToolCount(int count) {
    return 'Total $count · All run offline';
  }

  @override
  String get homeFilterAll => 'All';

  @override
  String get homeSettingsTooltip => 'Settings';

  @override
  String get homeDisabledBadge => 'Not available on this platform';

  @override
  String get homeShizukuPermissionTitle => 'Shizuku permission required';

  @override
  String get homeShizukuCannotRead =>
      'Can\'t read Shizuku status. Check the permission in Settings.';

  @override
  String get homeShizukuNotInstalled =>
      'Shizuku isn\'t installed. Install Shizuku first, then grant permission in Settings.';

  @override
  String get homeShizukuNotRunning =>
      'Shizuku isn\'t running. Open Shizuku, start the service with Root, then grant permission in Settings.';

  @override
  String get homeShizukuNotGranted =>
      'Flupix hasn\'t been granted access to Shizuku. Grant permission in Settings.';

  @override
  String get homeShizukuNotRoot =>
      'Shizuku isn\'t running in Root mode. Start it with Root, then grant permission in Settings.';

  @override
  String get homeShizukuGoSettingsHint =>
      'Grant Shizuku permission in Settings.';

  @override
  String get homeShizukuGoSettings => 'Go to Settings';

  @override
  String get categoryConvert => 'Convert';

  @override
  String get categoryText => 'Text';

  @override
  String get categoryGenerate => 'Generate';

  @override
  String get categoryOther => 'Other';

  @override
  String get toolUnitConverterTitle => 'Unit Converter';

  @override
  String get toolUnitConverterDesc =>
      'Length, area, volume, mass, temperature, speed, data storage';

  @override
  String get toolCalculatorTitle => 'Expression Calculator';

  @override
  String get toolCalculatorDesc =>
      'Parentheses, exponents and mixed arithmetic';

  @override
  String get toolTextCodecTitle => 'Text Codec';

  @override
  String get toolTextCodecDesc => 'Base64 and URL encoding and decoding';

  @override
  String get toolJsonTitle => 'JSON Formatter';

  @override
  String get toolJsonDesc => 'Validate, format and minify JSON text';

  @override
  String get toolMarkdownTitle => 'Markdown Editor';

  @override
  String get toolMarkdownDesc =>
      'Live preview, quick syntax inserts and draft saving';

  @override
  String get toolHashTitle => 'Hash Calculator';

  @override
  String get toolHashDesc => 'MD5, SHA-1, SHA-256, SHA-512';

  @override
  String get toolTimestampTitle => 'Timestamp Converter';

  @override
  String get toolTimestampDesc =>
      'Convert between Unix timestamps and date-time';

  @override
  String get toolColorTitle => 'Color Tools';

  @override
  String get toolColorDesc => 'HEX / RGB / HSL conversion with palette preview';

  @override
  String get toolAudioConvertTitle => 'Audio Converter';

  @override
  String get toolAudioConvertDesc =>
      'Convert between MP3, WAV, FLAC, M4A and more';

  @override
  String get toolPasswordTitle => 'Password Generator';

  @override
  String get toolPasswordDesc => 'Secure random passwords with strength rating';

  @override
  String get toolQrTitle => 'QR Code Generator';

  @override
  String get toolQrDesc => 'Turn text into a scannable QR code';

  @override
  String get toolMetronomeTitle => 'Metronome';

  @override
  String get toolMetronomeDesc =>
      'BPM, beat accents, tap tempo and visual beat';

  @override
  String get toolPuzzleTitle => 'Sliding Puzzle';

  @override
  String get toolPuzzleDesc => 'Custom images with 1:1 cropping, 3×3 to 5×5';

  @override
  String get toolQqStickerTitle => 'QQ Stickers';

  @override
  String get toolQqStickerDesc =>
      'Save stickers from the QQ cache to your gallery using Shizuku Root access';

  @override
  String get toolEhTitle => 'E-Hentai';

  @override
  String get toolEhDesc =>
      'Search, browse and read E-Hentai / ExHentai galleries';

  @override
  String get toolPixivTitle => 'Pixiv Token';

  @override
  String get toolPixivDesc =>
      'Sign in with OAuth to get access_token and PHPSESSID';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSubtitleAndroid => 'Appearance, theme and permissions';

  @override
  String get settingsSubtitleDesktop => 'Appearance, theme and network';

  @override
  String get settingsAppearanceMode => 'Appearance mode';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsSeedColor => 'Theme color';

  @override
  String get settingsSeedColorHint =>
      'Material You builds a full color scheme from the theme color';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageSystem => 'System default';

  @override
  String get settingsLanguageChinese => '简体中文';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsShowDisabled => 'Show disabled features';

  @override
  String get settingsShowDisabledHint =>
      'Show features that are unavailable or not yet implemented on this system. Their cards are grayed out and can\'t be tapped.';

  @override
  String get settingsProxyTitle => 'Network proxy';

  @override
  String get settingsProxyDescription =>
      'Used by tools such as Pixiv and E-Hentai. Leave blank to use the Windows system proxy; on Android, use a system VPN instead.';

  @override
  String get settingsProxyAddress => 'Proxy address';

  @override
  String get settingsProxySave => 'Save proxy';

  @override
  String get settingsProxySaving => 'Saving…';

  @override
  String get settingsProxyReadSystem => 'Read system proxy';

  @override
  String settingsProxySaved(String address) {
    return 'Proxy saved: $address';
  }

  @override
  String get settingsProxyDirect => 'Switched to direct connection';

  @override
  String get settingsProxySystemMissing =>
      'No system proxy is enabled. Turn on your proxy software first.';

  @override
  String get settingsShizukuTitle => 'Shizuku permission';

  @override
  String get settingsShizukuDescription =>
      'Tools that need Root access read app-private data through Shizuku.';

  @override
  String get settingsShizukuChecking => 'Checking Shizuku…';

  @override
  String get settingsShizukuError =>
      'Can\'t read Shizuku status. Make sure the device is Android and Shizuku is installed.';

  @override
  String get settingsShizukuGrant => 'Grant Shizuku';

  @override
  String get settingsShizukuGranting => 'Granting…';

  @override
  String get settingsShizukuOpen => 'Open Shizuku';

  @override
  String get settingsShizukuRefresh => 'Check again';

  @override
  String get settingsShizukuGrantedRoot => 'Granted (Root)';

  @override
  String get settingsShizukuNotInstalled => 'Shizuku not installed';

  @override
  String get settingsShizukuNotRunning => 'Shizuku not running';

  @override
  String get settingsShizukuNotGranted => 'Not granted';

  @override
  String settingsShizukuInsufficient(String uid) {
    return 'Insufficient permission (uid=$uid)';
  }

  @override
  String get settingsShizukuInstallHint =>
      'Install the Shizuku app first, then come back here to grant access.';

  @override
  String get settingsShizukuRunHint =>
      'Open Shizuku and start the service with Root.';

  @override
  String get settingsShizukuGrantHint =>
      'Allow Flupix to access Shizuku to read the QQ sticker cache.';

  @override
  String get settingsShizukuRootHint =>
      'Stop Shizuku and restart it as Root (uid=0).';

  @override
  String get settingsShizukuReadyHint =>
      'Flupix has Root access and can use tools that require Shizuku.';

  @override
  String get settingsShizukuGrantedMessage => 'Shizuku permission granted';

  @override
  String get settingsShizukuDeniedMessage => 'Shizuku permission denied';

  @override
  String settingsShizukuRequestFailed(String error) {
    return 'Failed to request permission: $error';
  }

  @override
  String get settingsShizukuNotFound => 'Shizuku app not found';

  @override
  String settingsShizukuOpenFailed(String error) {
    return 'Can\'t open Shizuku: $error';
  }

  @override
  String settingsUpdateCurrentVersion(String version) {
    return 'Current version $version';
  }

  @override
  String get settingsUpdateCheck => 'Check for updates';

  @override
  String get settingsUpdateChecking => 'Checking…';

  @override
  String settingsUpdateLatest(String version) {
    return 'You\'re up to date ($version)';
  }

  @override
  String settingsUpdateCheckFailed(String error) {
    return 'Update check failed: $error';
  }

  @override
  String settingsUpdateAvailableTitle(String version) {
    return 'New version $version';
  }

  @override
  String get settingsUpdateReleaseNotes => 'What\'s new';

  @override
  String get settingsUpdateNoNotes =>
      'No release notes were provided for this version.';

  @override
  String get settingsUpdateDownload => 'Download';

  @override
  String get settingsUpdateInstall => 'Download and install';

  @override
  String get settingsUpdateInstallPermission =>
      'Allow installing unknown apps in system settings, then try again.';

  @override
  String settingsUpdateDownloading(String version) {
    return 'Downloading $version…';
  }

  @override
  String get settingsUpdateInstalling => 'Download complete, installing…';

  @override
  String settingsUpdateFailed(String error) {
    return 'Update failed: $error';
  }

  @override
  String get settingsUpdateOpenReleases => 'Open releases';

  @override
  String get settingsUpdateOpenFailed => 'Can\'t open link';

  @override
  String settingsAboutVersion(String version) {
    return 'Version $version · Flutter + Material You';
  }

  @override
  String get settingsAboutPrivacy =>
      'All tools run locally and collect no data.';

  @override
  String get seedPine => 'Pine';

  @override
  String get seedIndigo => 'Indigo';

  @override
  String get seedViolet => 'Violet';

  @override
  String get seedSky => 'Sky';

  @override
  String get seedMoss => 'Moss';

  @override
  String get seedAmber => 'Amber';

  @override
  String get seedRose => 'Rose';

  @override
  String get seedGraphite => 'Graphite';

  @override
  String get textCodecTitle => 'Text Codec';

  @override
  String get textCodecSubtitle => 'Convert between Base64 and URL encoding';

  @override
  String get textCodecEncode => 'Encode';

  @override
  String get textCodecDecode => 'Decode';

  @override
  String get textCodecInputLabel => 'Input';

  @override
  String get textCodecInputEncodeHint => 'Enter the text to encode';

  @override
  String get textCodecInputDecodeHint => 'Paste the content to decode';

  @override
  String textCodecCharCount(int count) {
    return '$count characters';
  }

  @override
  String get textCodecResultTitle => 'Result';

  @override
  String get textCodecCopyResult => 'Copy result';

  @override
  String get textCodecResultPlaceholder => 'The result will appear here';

  @override
  String get textCodecInvalidBase64 =>
      'Invalid Base64 content, unable to decode';

  @override
  String get textCodecInvalidUrl => 'Invalid URL encoding, unable to decode';

  @override
  String get textCodecConvertFailed =>
      'Conversion failed. Please check your input';

  @override
  String get jsonTitle => 'JSON Formatter';

  @override
  String get jsonSubtitle => 'Validate, format, and minify JSON text';

  @override
  String get jsonInputLabel => 'JSON content';

  @override
  String jsonInputHint(String leftBrace, String rightBrace) {
    return 'Paste JSON text, for example $leftBrace\"name\": \"Flupix\"$rightBrace';
  }

  @override
  String get jsonFormat => 'Format';

  @override
  String get jsonMinify => 'Minify';

  @override
  String get jsonOutputTitle => 'Output';

  @override
  String get jsonCopyResult => 'Copy result';

  @override
  String get jsonOutputPlaceholder => 'The formatted JSON will appear here';

  @override
  String get jsonEmptyInput => 'Please enter JSON content';

  @override
  String jsonValidMeta(int count) {
    return 'Valid JSON · $count characters';
  }

  @override
  String jsonParseFailed(String error) {
    return 'JSON parse failed: $error';
  }

  @override
  String get markdownTitle => 'Markdown Editor';

  @override
  String get markdownSubtitle => 'GFM preview · .md import and export';

  @override
  String get markdownOpenFileTooltip => 'Open .md file';

  @override
  String get markdownExportTooltip => 'Export as .md file';

  @override
  String markdownStats(int lines, int chars) {
    return '$lines lines · $chars characters';
  }

  @override
  String get markdownHeading1 => 'Heading 1';

  @override
  String get markdownHeading2 => 'Heading 2';

  @override
  String get markdownBold => 'Bold';

  @override
  String get markdownItalic => 'Italic';

  @override
  String get markdownInlineCode => 'Inline code';

  @override
  String get markdownBulletList => 'Bullet list';

  @override
  String get markdownOrderedList => 'Numbered list';

  @override
  String get markdownTaskList => 'Task list';

  @override
  String get markdownQuote => 'Quote';

  @override
  String get markdownLink => 'Link';

  @override
  String get markdownLinkPlaceholder => 'Link text';

  @override
  String get markdownCodeBlock => 'Code block';

  @override
  String get markdownTable => 'Table';

  @override
  String get markdownTableTemplate =>
      '| Column 1 | Column 2 |\n| --- | --- |\n| Content | Content |';

  @override
  String get markdownDivider => 'Divider';

  @override
  String get markdownEditorHint => '# Start writing Markdown here…';

  @override
  String get markdownDraftSavedLocally =>
      'Draft saved automatically on this device';

  @override
  String markdownDraftAutoSaved(String name) {
    return '$name · Draft auto-saved';
  }

  @override
  String get markdownSourceCopied => 'Markdown source copied';

  @override
  String get markdownPreviewPlaceholder =>
      'Markdown entered on the left will render here in real time';

  @override
  String get markdownClearTitle => 'Clear content?';

  @override
  String get markdownClearMessage =>
      'The current draft will be deleted and cannot be recovered.';

  @override
  String get markdownLinkCopied => 'Link copied';

  @override
  String get markdownOpenDialogTitle => 'Open Markdown file';

  @override
  String markdownOpened(String name) {
    return 'Opened $name';
  }

  @override
  String markdownOpenFailed(String error) {
    return 'Open failed: $error';
  }

  @override
  String get markdownUntitledFileName => 'Untitled.md';

  @override
  String get markdownExportDialogTitle => 'Export Markdown';

  @override
  String markdownExported(String name) {
    return 'Exported $name';
  }

  @override
  String markdownExportFailed(String error) {
    return 'Export failed: $error';
  }

  @override
  String get hashTitle => 'Hash Calculator';

  @override
  String get hashSubtitle => 'Turn text into an irreversible digest';

  @override
  String get hashInputLabel => 'Input text';

  @override
  String get hashInputHint => 'Enter or paste the content to hash';

  @override
  String hashByteCount(int count) {
    return 'UTF-8 encoded · $count bytes';
  }

  @override
  String get hashEmptyHint =>
      'MD5, SHA-1, SHA-256, and SHA-512 are calculated automatically as you type.';

  @override
  String get unitPageTitle => 'Unit Converter';

  @override
  String get unitPageSubtitle =>
      'Pick a category, enter a value, and convert instantly';

  @override
  String get unitCategoryLength => 'Length';

  @override
  String get unitCategoryArea => 'Area';

  @override
  String get unitCategoryVolume => 'Volume';

  @override
  String get unitCategoryMass => 'Mass';

  @override
  String get unitCategoryTemperature => 'Temperature';

  @override
  String get unitCategorySpeed => 'Speed';

  @override
  String get unitCategoryDataStorage => 'Data Storage';

  @override
  String get unitKilometer => 'Kilometer';

  @override
  String get unitMeter => 'Meter';

  @override
  String get unitDecimeter => 'Decimeter';

  @override
  String get unitCentimeter => 'Centimeter';

  @override
  String get unitMillimeter => 'Millimeter';

  @override
  String get unitMicrometer => 'Micrometer';

  @override
  String get unitNanometer => 'Nanometer';

  @override
  String get unitMile => 'Mile';

  @override
  String get unitYard => 'Yard';

  @override
  String get unitFoot => 'Foot';

  @override
  String get unitInch => 'Inch';

  @override
  String get unitNauticalMile => 'Nautical mile';

  @override
  String get unitLi => 'Li';

  @override
  String get unitZhang => 'Zhang';

  @override
  String get unitChi => 'Chi';

  @override
  String get unitCun => 'Cun';

  @override
  String get unitSquareKilometer => 'Square kilometer';

  @override
  String get unitHectare => 'Hectare';

  @override
  String get unitMu => 'Mu';

  @override
  String get unitSquareMeter => 'Square meter';

  @override
  String get unitSquareDecimeter => 'Square decimeter';

  @override
  String get unitSquareCentimeter => 'Square centimeter';

  @override
  String get unitAcre => 'Acre';

  @override
  String get unitSquareFoot => 'Square foot';

  @override
  String get unitSquareInch => 'Square inch';

  @override
  String get unitCubicMeter => 'Cubic meter';

  @override
  String get unitLiter => 'Liter';

  @override
  String get unitMilliliter => 'Milliliter';

  @override
  String get unitCubicCentimeter => 'Cubic centimeter';

  @override
  String get unitGallonUs => 'Gallon (US)';

  @override
  String get unitQuartUs => 'Quart (US)';

  @override
  String get unitCubicFoot => 'Cubic foot';

  @override
  String get unitCubicInch => 'Cubic inch';

  @override
  String get unitTonne => 'Tonne';

  @override
  String get unitKilogram => 'Kilogram';

  @override
  String get unitGram => 'Gram';

  @override
  String get unitMilligram => 'Milligram';

  @override
  String get unitJin => 'Jin';

  @override
  String get unitLiang => 'Liang';

  @override
  String get unitPound => 'Pound';

  @override
  String get unitOunce => 'Ounce';

  @override
  String get unitCarat => 'Carat';

  @override
  String get unitCelsius => 'Celsius';

  @override
  String get unitFahrenheit => 'Fahrenheit';

  @override
  String get unitKelvin => 'Kelvin';

  @override
  String get unitMeterPerSecond => 'Meters per second';

  @override
  String get unitKilometerPerHour => 'Kilometers per hour';

  @override
  String get unitMeterPerMinute => 'Meters per minute';

  @override
  String get unitMilePerHour => 'Miles per hour';

  @override
  String get unitKnot => 'Knot';

  @override
  String get unitFootPerSecond => 'Feet per second';

  @override
  String get unitBit => 'Bit';

  @override
  String get unitByte => 'Byte';

  @override
  String get unitKilobyte => 'Kilobyte';

  @override
  String get unitMegabyte => 'Megabyte';

  @override
  String get unitGigabyte => 'Gigabyte';

  @override
  String get unitTerabyte => 'Terabyte';

  @override
  String get unitInputLabel => 'Input';

  @override
  String get unitFromLabel => 'From';

  @override
  String get unitValueLabel => 'Value';

  @override
  String get unitSwapTooltip => 'Swap units';

  @override
  String get unitToLabel => 'To';

  @override
  String get unitResultTitle => 'Result';

  @override
  String get unitCopyResultTooltip => 'Copy result';

  @override
  String get unitEnterValidValue => 'Enter a valid number';

  @override
  String unitConversionFormula(String from, String value, String to) {
    return '1 $from = $value $to';
  }

  @override
  String get timestampPageTitle => 'Timestamp Converter';

  @override
  String get timestampPageSubtitle =>
      'Convert Unix timestamps to and from local and UTC time';

  @override
  String get timestampCurrentTime => 'Current time';

  @override
  String get timestampSeconds => 'Timestamp (seconds)';

  @override
  String get timestampMilliseconds => 'Timestamp (milliseconds)';

  @override
  String get timestampUtcIso => 'UTC time (ISO 8601)';

  @override
  String get timestampToDateTime => 'Timestamp → Date time';

  @override
  String get timestampLabel => 'Timestamp';

  @override
  String get timestampHint => 'Seconds or milliseconds, detected automatically';

  @override
  String get timestampNow => 'Now';

  @override
  String get timestampLocalTime => 'Local time';

  @override
  String get timestampUtcTime => 'UTC time';

  @override
  String get timestampIso8601 => 'ISO 8601';

  @override
  String get timestampEmptyHint =>
      'Enter a timestamp to see the corresponding date and time';

  @override
  String get timestampFromDateTime => 'Date time → Timestamp';

  @override
  String get timestampPick => 'Pick';

  @override
  String get timestampErrorNotInteger => 'Enter an integer timestamp';

  @override
  String get timestampErrorOutOfRange => 'Timestamp is out of range';

  @override
  String get colorPageTitle => 'Color Tools';

  @override
  String get colorPageSubtitle =>
      'Convert between HEX / RGB / HSL and generate Material You palettes';

  @override
  String get colorHexLabel => 'HEX color';

  @override
  String get colorChannelAdjust => 'Adjust channels';

  @override
  String get colorPreviewTitle => 'Palette preview';

  @override
  String get colorPreviewSubtitle =>
      'Material You tones generated from the current color';

  @override
  String get colorSwatchPrimary => 'Primary';

  @override
  String get colorSwatchSecondary => 'Secondary';

  @override
  String get colorSwatchTertiary => 'Tertiary';

  @override
  String get colorSwatchContainer => 'Container';

  @override
  String get colorSwatchSurface => 'Surface';

  @override
  String get colorSwatchSurfaceHigh => 'Surface high';

  @override
  String get colorErrorInvalidHex => 'Enter a valid HEX color, such as #3A7BD5';

  @override
  String get calculatorPageTitle => 'Expression Calculator';

  @override
  String get calculatorPageSubtitle =>
      'Supports parentheses, powers, and mixed arithmetic';

  @override
  String get calculatorHint => 'Enter an expression, e.g. (3+5)×2^3';

  @override
  String get calculatorHistory => 'History';

  @override
  String get calculatorClearHistory => 'Clear history';

  @override
  String get calculatorEmptyExpression => 'Enter an expression';

  @override
  String get expressionEmpty => 'Enter an expression';

  @override
  String get expressionUnmatchedParenthesis => 'Unmatched parentheses';

  @override
  String get expressionIncomplete => 'Incomplete expression';

  @override
  String get expressionInvalidResult => 'Invalid result';

  @override
  String get expressionDivideByZero => 'Cannot divide by zero';

  @override
  String expressionUnknownOperator(String operator) {
    return 'Unknown operator $operator';
  }

  @override
  String expressionInvalidNumber(String number) {
    return 'Invalid number format: $number';
  }

  @override
  String expressionUnknownCharacter(String char) {
    return 'Unrecognized character \"$char\"';
  }

  @override
  String get weekdayMonday => 'Mon';

  @override
  String get weekdayTuesday => 'Tue';

  @override
  String get weekdayWednesday => 'Wed';

  @override
  String get weekdayThursday => 'Thu';

  @override
  String get weekdayFriday => 'Fri';

  @override
  String get weekdaySaturday => 'Sat';

  @override
  String get weekdaySunday => 'Sun';

  @override
  String get audioConvertTitle => 'Audio conversion';

  @override
  String get audioConvertSubtitle =>
      'Convert between MP3, WAV, FLAC, M4A and more';

  @override
  String get audioSelectAudioFile => 'Choose audio file';

  @override
  String audioReadFailed(String error) {
    return 'Failed to read audio: $error';
  }

  @override
  String get audioConvertDoneHint =>
      'Conversion complete, ready to save locally';

  @override
  String get audioConvertCancelled => 'Conversion cancelled';

  @override
  String get audioConvertFailedToast => 'Conversion failed';

  @override
  String audioSavedName(String name) {
    return 'Saved $name';
  }

  @override
  String audioSaveFailed(String error) {
    return 'Failed to save: $error';
  }

  @override
  String get audioSaveAudioFile => 'Save audio file';

  @override
  String get audioSizeUnknown => 'Size unknown';

  @override
  String get audioChannelsUnknown => 'Channels unknown';

  @override
  String get audioMono => 'Mono';

  @override
  String get audioStereo => 'Stereo';

  @override
  String audioChannelsCount(int count) {
    return '$count channels';
  }

  @override
  String audioConvertTo(String format) {
    return 'Convert to $format';
  }

  @override
  String audioEngineLine(String version) {
    return 'FFmpeg $version · Transcoding runs offline on this device';
  }

  @override
  String get audioEngineLoading => 'Loading…';

  @override
  String get audioSupportedFormats =>
      'Supports MP3, WAV, FLAC, M4A, AAC, OGG and more';

  @override
  String get audioChangeFile => 'Change file';

  @override
  String get audioUnknownCodec => 'Unknown codec';

  @override
  String get audioBrowseLocal => 'Browse local files';

  @override
  String get audioOutputFormat => 'Output format';

  @override
  String get audioBitrate => 'Bitrate';

  @override
  String audioBitrateValue(String value) {
    return '$value kbps';
  }

  @override
  String get audioBitDepth => 'Bit depth';

  @override
  String get audioBitDepth16 => '16-bit';

  @override
  String get audioBitDepth24 => '24-bit';

  @override
  String get audioBitDepthFloat32 => '32-bit float';

  @override
  String get audioSampleRate => 'Sample rate';

  @override
  String get audioKeepOriginal => 'Keep original';

  @override
  String get audioChannels => 'Channels';

  @override
  String audioConvertingTo(String format) {
    return 'Converting to $format';
  }

  @override
  String get audioProcessing => 'Processing';

  @override
  String audioSpeedValue(String speed) {
    return 'Speed ${speed}x';
  }

  @override
  String get audioPreparing => 'Preparing…';

  @override
  String get audioConvertDoneTitle => 'Conversion complete';

  @override
  String get audioSaving => 'Saving…';

  @override
  String get audioSaveFile => 'Save file';

  @override
  String get audioFfprobeNotFound =>
      'ffprobe not found. Please install FFmpeg and add it to your system PATH.';

  @override
  String get audioFfmpegNotFound =>
      'ffmpeg not found. Please install FFmpeg and add it to your system PATH.';

  @override
  String get audioProbeParseFailed => 'Unable to parse audio info';

  @override
  String get audioNoAudioStream => 'No audio stream found in the file';

  @override
  String get audioConvertFailedHint =>
      'Transcoding failed. Please make sure the audio file plays normally.';

  @override
  String get audioConvertFailed => 'Transcoding failed';

  @override
  String get metronomeTitle => 'Metronome';

  @override
  String get metronomeSubtitle =>
      'Adjust BPM, bar accents and volume, with tap tempo';

  @override
  String get metronomeDecreaseBpm => 'Decrease by 1 BPM';

  @override
  String get metronomeIncreaseBpm => 'Increase by 1 BPM';

  @override
  String get metronomeTapTempo => 'Tap tempo';

  @override
  String get metronomeTempo => 'Tempo';

  @override
  String metronomeBpmValue(int bpm) {
    return '$bpm BPM';
  }

  @override
  String get metronomeBeatsPerBar => 'Beats per bar';

  @override
  String get metronomeAccent => 'Bar accent';

  @override
  String get metronomeAccentHint =>
      'The first beat of each bar uses a higher tone and is highlighted';

  @override
  String get metronomeSound => 'Sound';

  @override
  String get metronomeSoundHint => 'When off, only the visual beat is shown';

  @override
  String get metronomeVolume => 'Volume';

  @override
  String get puzzleTitle => 'Sliding Number Puzzle';

  @override
  String get puzzleSubtitlePlaying =>
      'Tap a tile next to the empty space to slide it';

  @override
  String get puzzleSubtitleSetup => 'Custom image with 1:1 cropping';

  @override
  String get puzzleSelectImage => 'Choose image';

  @override
  String puzzleImportFailed(String error) {
    return 'Failed to import image: $error';
  }

  @override
  String get puzzleSolvedTitle => 'Solved!';

  @override
  String puzzleSolvedStats(String elapsed, int moves) {
    return '$elapsed · $moves moves';
  }

  @override
  String get puzzleBackToSetup => 'Back to setup';

  @override
  String get puzzlePlayAgain => 'Play again';

  @override
  String get puzzleClassicMode => 'Classic numbers';

  @override
  String get puzzleCustomImage => 'Custom image';

  @override
  String get puzzlePickImageHint =>
      'Choose an image. When importing, drag and zoom to set the 1:1 crop area.';

  @override
  String get puzzleCropSavedHint =>
      '1:1 crop area saved. You can change the image or re-crop at any time.';

  @override
  String get puzzleImporting => 'Importing…';

  @override
  String get puzzleChangeImage => 'Change image';

  @override
  String get puzzleDifficulty => 'Difficulty';

  @override
  String get puzzleDifficultyHint =>
      'More tiles means harder. Starting with 3 × 3 is recommended.';

  @override
  String get puzzleHowToPlay =>
      'Tap a tile adjacent to the empty space to swap positions. Restore the image or numbers in order to win.';

  @override
  String get puzzleStartGame => 'Start game';

  @override
  String get puzzleMoves => 'Moves';

  @override
  String get puzzleTime => 'Time';

  @override
  String get puzzleViewOriginal => 'View original';

  @override
  String get puzzleShuffle => 'Shuffle';

  @override
  String get puzzleShowNumbers => 'Show numbers';

  @override
  String get puzzleSolvedHint => 'Solved! Tap \"Shuffle\" to play again';

  @override
  String get puzzleSlideHint =>
      'Tap a tile adjacent to the empty space to slide it';

  @override
  String get puzzleSelectCrop => 'Select crop area';

  @override
  String get puzzleCropHint =>
      'Drag the image to reposition, pinch or use the slider to zoom. The frame shows the final 1:1 view.';

  @override
  String get puzzleReset => 'Reset';

  @override
  String get puzzleUseArea => 'Use this area';

  @override
  String get qqStickerTitle => 'QQ Stickers';

  @override
  String get qqStickerSubtitle =>
      'Extract stickers from the QQ cache and save them to the gallery';

  @override
  String get qqStickerReadStatusFailed => 'Failed to read Shizuku status';

  @override
  String qqStickerReadStatusFailedDetail(String error) {
    return 'Failed to read Shizuku status: $error';
  }

  @override
  String get qqStickerNoStickers => 'No stickers found to save';

  @override
  String qqStickerFoundPacks(int count) {
    return 'Found $count sticker packs';
  }

  @override
  String get qqStickerScanFailed => 'Failed to scan the QQ sticker cache';

  @override
  String qqStickerScanFailedDetail(String error) {
    return 'Scan failed: $error';
  }

  @override
  String get qqStickerSaveFailedRetry => 'Failed to save, please try again';

  @override
  String qqStickerSavedToFolder(int saved) {
    return 'Saved $saved stickers to Pictures/Flupix/QQ表情';
  }

  @override
  String qqStickerSaveFailedSuffix(int failed) {
    return ', $failed failed';
  }

  @override
  String qqStickerSavedToGallery(int saved) {
    return 'Saved $saved stickers to the gallery';
  }

  @override
  String get qqStickerSaveFailed => 'Failed to save';

  @override
  String qqStickerSaveFailedDetail(String error) {
    return 'Failed to save: $error';
  }

  @override
  String get qqStickerAndroidOnly =>
      'This tool is only available on Android devices';

  @override
  String get qqStickerPacks => 'Sticker packs';

  @override
  String qqStickerPacksCount(int count) {
    return '$count total';
  }

  @override
  String get qqStickerSaveLocation =>
      'Save location: Pictures/Flupix/QQ表情/<pack ID>';

  @override
  String get qqStickerQqMissing => 'QQ not detected';

  @override
  String get qqStickerQqMissingDetail =>
      'This tool reads QQ\'s sticker cache. Please install and sign in to QQ first.';

  @override
  String get qqStickerShizukuMissing => 'Shizuku not installed';

  @override
  String get qqStickerShizukuMissingDetail =>
      'Shizuku (Root mode) is required to access QQ\'s private cache directory.';

  @override
  String get qqStickerShizukuStopped => 'Shizuku not running';

  @override
  String get qqStickerShizukuStoppedDetail =>
      'Please enable and start Shizuku (Root mode) in Settings.';

  @override
  String get qqStickerShizukuDenied => 'Waiting for Shizuku authorization';

  @override
  String get qqStickerShizukuDeniedDetail =>
      'Please go to Settings to complete Shizuku authorization.';

  @override
  String get qqStickerShizukuInsufficient => 'Insufficient Shizuku permissions';

  @override
  String qqStickerShizukuInsufficientDetail(int uid) {
    return 'Currently running as uid=$uid. Please switch to Root (uid=0) in Settings and restart.';
  }

  @override
  String get qqStickerNoCache => 'QQ sticker cache not found';

  @override
  String get qqStickerNoCacheDetail =>
      'Open the sticker panel in QQ and load some stickers, then refresh.';

  @override
  String get qqStickerReady => 'Environment ready';

  @override
  String get qqStickerReadyHintEmpty =>
      'Root access granted. You can scan the QQ sticker cache.';

  @override
  String qqStickerReadyHintCount(int count) {
    return 'Read $count sticker packs. Select the ones you want and save.';
  }

  @override
  String get qqStickerUnknownStatus => 'Unable to read status';

  @override
  String get qqStickerUnknownStatusDetail =>
      'Shizuku status unknown. Please refresh.';

  @override
  String get qqStickerGoSettings => 'Go to settings';

  @override
  String get qqStickerScanning => 'Scanning…';

  @override
  String get qqStickerScan => 'Scan sticker packs';

  @override
  String get qqStickerRescan => 'Rescan';

  @override
  String qqStickerPackTitle(String id) {
    return 'Sticker pack $id';
  }

  @override
  String qqStickerPackSelectedSummary(int total, int selected) {
    return '$total total · $selected selected';
  }

  @override
  String qqStickerPackSummary(int count) {
    return '$count stickers';
  }

  @override
  String get qqStickerTapToSelect => 'Tap a sticker to select';

  @override
  String get qqStickerSelectPack => 'Select all in this pack';

  @override
  String qqStickerSelectedCount(int count) {
    return '$count selected';
  }

  @override
  String get qqStickerSaveToAlbum => 'Save to Gallery/Pictures/Flupix/QQ表情';

  @override
  String get qqStickerSaving => 'Saving…';

  @override
  String get passwordSubtitle =>
      'Generate passwords with a cryptographically secure random number generator';

  @override
  String get passwordResult => 'Generated password';

  @override
  String get passwordEmptyHint => 'Please select at least one character type';

  @override
  String get passwordSelectAtLeastOne => 'Select at least one character type';

  @override
  String passwordEntropy(String bits) {
    return 'About $bits bits of entropy';
  }

  @override
  String get passwordRegenerate => 'Regenerate';

  @override
  String get passwordCopyTooltip => 'Copy password';

  @override
  String get passwordLength => 'Password length';

  @override
  String get passwordUppercase => 'Uppercase letters';

  @override
  String get passwordLowercase => 'Lowercase letters';

  @override
  String get passwordDigits => 'Digits';

  @override
  String get passwordSymbols => 'Symbols';

  @override
  String get passwordExcludeAmbiguous => 'Exclude ambiguous characters';

  @override
  String get passwordExcludeAmbiguousHint =>
      'Remove easily confused characters such as O, 0, l, 1, and I';

  @override
  String get passwordStrengthWeak => 'Weak';

  @override
  String get passwordStrengthFair => 'Fair';

  @override
  String get passwordStrengthStrong => 'Strong';

  @override
  String get passwordStrengthVeryStrong => 'Very strong';

  @override
  String get qrSubtitle => 'Enter text to generate a scannable QR code';

  @override
  String get qrContentLabel => 'QR code content';

  @override
  String get qrContentHint => 'Supports text, URLs, contact details, and more';

  @override
  String get qrEmptyTip => 'Enter content to generate a QR code';

  @override
  String qrTooLong(int bytes) {
    return 'Content is too long ($bytes bytes). Please shorten it to about 1800 bytes or less';
  }

  @override
  String qrCharCount(int count) {
    return '$count characters';
  }

  @override
  String get qrCopiedContent => 'Content copied';

  @override
  String get qrCopyContent => 'Copy content';

  @override
  String get qrSize => 'QR code size';

  @override
  String qrSizePx(int size) {
    return '$size px';
  }

  @override
  String get qrUseThemeColor => 'Use theme color';

  @override
  String get qrUseThemeColorHint =>
      'When enabled, the QR code modules use the current theme\'s primary color';

  @override
  String get pixivTokenSubtitle =>
      'Sign in with OAuth to get and refresh tokens';

  @override
  String get pixivLoginTitle => 'Log in to pixiv';

  @override
  String get pixivLoginCancelled => 'Login cancelled';

  @override
  String get pixivLoginSuccess => 'Logged in successfully, token obtained';

  @override
  String pixivLoginFailed(String error) {
    return 'Login failed: $error';
  }

  @override
  String get pixivTokenRefreshed => 'Token refreshed';

  @override
  String pixivRefreshFailed(String error) {
    return 'Refresh failed: $error';
  }

  @override
  String get pixivClearDataTitle => 'Clear local data';

  @override
  String get pixivClearDataBody =>
      'The access_token and refresh_token saved on this device will be deleted, and you will need to log in again.';

  @override
  String get pixivClearAction => 'Clear';

  @override
  String get pixivTokenCleared => 'Local token cleared';

  @override
  String get pixivPhpSessionObtained => 'PHPSESSID obtained';

  @override
  String get pixivTokenExpired => 'Expired, please refresh';

  @override
  String pixivTokenRemaining(String time) {
    return '$time remaining';
  }

  @override
  String get pixivTokenSection => 'Tokens';

  @override
  String get pixivTokenCopyAll => 'Copy all';

  @override
  String get pixivWebCookieTitle => 'Web cookies';

  @override
  String get pixivWebCookieDesc =>
      'Tools that use the WebAPI, such as Pixeval, require a PHPSESSID, which must be read after logging in on the pixiv website.';

  @override
  String get pixivFetchCookie => 'Get pixiv.net cookies';

  @override
  String get pixivFetchCookieAgain => 'Fetch again';

  @override
  String get pixivSecurityTitle => 'Security notice';

  @override
  String get pixivSecurityBody =>
      'access_token and refresh_token are equivalent to account credentials. Do not share them or commit them to public repositories. Tokens are stored only on this device and are never sent to any server other than pixiv\'s official domains.';

  @override
  String get pixivNotLoggedIn => 'Not logged in';

  @override
  String get pixivLoggedIn => 'Logged in';

  @override
  String get pixivLoginHint => 'Log in to get access_token and refresh_token';

  @override
  String get pixivProcessing => 'Processing…';

  @override
  String get pixivRefreshTokenButton => 'Refresh token';

  @override
  String get pixivReloginButton => 'Log in again';

  @override
  String get pixivTokenHide => 'Hide';

  @override
  String get pixivTokenShow => 'Show';

  @override
  String get pixivLoginPageHint =>
      'Please complete the pixiv login on the page. You will be returned automatically after a successful login; if a prompt to open the Pixiv app appears, you can ignore it.';

  @override
  String get pixivPhpSessionMissing =>
      'PHPSESSID not found. Please log in to pixiv on the page first';

  @override
  String get pixivCookieReadFailed =>
      'Failed to read cookies, please try again';

  @override
  String get pixivCookiePageTitle => 'Log in to pixiv web';

  @override
  String get pixivReadingCookie => 'Reading…';

  @override
  String pixivConnectionFailed(String reason) {
    return 'Unable to connect to the pixiv server ($reason). oauth.secure.pixiv.net is usually unreachable directly from mainland China; please configure a proxy first.';
  }

  @override
  String get pixivTimeout =>
      'Request timed out. Please check your network connection or proxy address.';

  @override
  String get pixivDirectConnection => 'Currently using a direct connection';

  @override
  String pixivErrorWithAddress(String address) {
    return 'Current proxy $address';
  }

  @override
  String pixivConnectionFailedWithTarget(String target) {
    return 'Unable to connect to the pixiv server ($target). Please make sure the proxy is enabled and the address is correct.';
  }

  @override
  String pixivNetworkError(String message) {
    return 'Network request failed: $message';
  }

  @override
  String pixivInvalidResponse(int status) {
    return 'The server returned a response that could not be parsed (HTTP $status)';
  }

  @override
  String get ehSiteEHentai => 'E-Hentai';

  @override
  String get ehSiteExHentai => 'ExHentai';

  @override
  String get ehCategoryMisc => 'Misc';

  @override
  String get ehCategoryDoujinshi => 'Doujinshi';

  @override
  String get ehCategoryManga => 'Manga';

  @override
  String get ehCategoryArtistCg => 'Artist CG';

  @override
  String get ehCategoryGameCg => 'Game CG';

  @override
  String get ehCategoryImageSet => 'Image Set';

  @override
  String get ehCategoryCosplay => 'Cosplay';

  @override
  String get ehCategoryAsian => 'Asian Porn';

  @override
  String get ehCategoryNonH => 'Non-H';

  @override
  String get ehCategoryWestern => 'Western';

  @override
  String get ehBrowseLoggedIn => 'Signed in';

  @override
  String get ehBrowseGuest => 'Guest';

  @override
  String get ehBrowseSwitchSite => 'Switch site';

  @override
  String get ehBrowseRelogin => 'Log in again';

  @override
  String get ehBrowseLogin => 'Log in';

  @override
  String get ehBrowseMyLibrary => 'My Library';

  @override
  String get ehBrowseDownloads => 'Downloads';

  @override
  String get ehBrowseLogout => 'Log out';

  @override
  String get ehBrowseSearchHint => 'Search titles, tags, or uploaders';

  @override
  String get ehBrowseGuestBanner =>
      'While logged out you can only browse lists. Reading and ExHentai require a login.';

  @override
  String get ehBrowseNoResults => 'No results found';

  @override
  String ehBrowseTotalResults(int count) {
    return '$count results';
  }

  @override
  String ehBrowseReachedPage(int page) {
    return 'Reached page $page';
  }

  @override
  String get ehBrowseNoMore => 'No more results';

  @override
  String ehBrowseInitFailed(String error) {
    return 'Initialization failed: $error';
  }

  @override
  String get ehFilterExcludeHint => 'Checked means exclude this category';

  @override
  String get ehDetailTitle => 'Gallery details';

  @override
  String get ehDetailCannotRead =>
      'Page count unavailable, so it cannot be read for now';

  @override
  String get ehDetailFavoriteAdded => 'Added to favorites';

  @override
  String get ehDetailFavoriteRemoved => 'Removed from favorites';

  @override
  String get ehDetailDownloadToLocal => 'Download to device';

  @override
  String get ehDetailDownloaded => 'Downloaded';

  @override
  String get ehDetailPauseDownload => 'Pause download';

  @override
  String get ehDetailCancelQueue => 'Cancel queue';

  @override
  String get ehDetailRetryDownload => 'Retry download';

  @override
  String get ehDetailResumeDownload => 'Resume download';

  @override
  String ehDetailQueuedWithPages(int total) {
    return 'Added to the download queue ($total pages)';
  }

  @override
  String get ehDetailQueued => 'Added to the download queue';

  @override
  String ehDetailDownloadProgress(int downloaded, int total) {
    return '$downloaded/$total pages';
  }

  @override
  String ehDetailQueuedProgress(String progress) {
    return 'Queued · $progress';
  }

  @override
  String ehDetailDownloadingProgress(String progress) {
    return 'Downloading · $progress';
  }

  @override
  String ehDetailPausedProgress(String progress) {
    return 'Paused · $progress';
  }

  @override
  String ehDetailPausedError(String error) {
    return 'Paused · $error';
  }

  @override
  String ehDetailCompletedProgress(String progress) {
    return 'Downloaded · $progress';
  }

  @override
  String ehDetailFailedError(String error) {
    return 'Download failed · $error';
  }

  @override
  String get ehDetailUnknownError => 'Unknown error';

  @override
  String get ehDetailUnfavorite => 'Remove from favorites';

  @override
  String get ehDetailFavorite => 'Add to favorites';

  @override
  String get ehDetailTags => 'Tags';

  @override
  String get ehDetailTapToJump => 'Tap to jump to a page';

  @override
  String get ehDetailStartReading => 'Start reading';

  @override
  String ehDetailContinueReading(int page) {
    return 'Continue reading from page $page';
  }

  @override
  String ehDetailPagesCount(int pages) {
    return '$pages pages';
  }

  @override
  String ehDetailUploader(String uploader) {
    return 'Uploader: $uploader';
  }

  @override
  String get ehReaderLocalImageFailed => 'Failed to read the local image';

  @override
  String get ehReaderImageFailed => 'Image failed to load';

  @override
  String get ehReaderRestartFromFirstPage => 'Start from the first page';

  @override
  String get ehReaderLtr => 'Switch to left-to-right';

  @override
  String get ehReaderRtl => 'Switch to right-to-left';

  @override
  String get ehReaderGestureHint =>
      'Double-tap or pinch to zoom · Tap the middle to show or hide the toolbar';

  @override
  String ehReaderRateLimited(int seconds) {
    return 'The site is rate limiting or temporarily banning you. Retry in $seconds seconds.';
  }

  @override
  String get ehReaderPageLoadFailed => 'This page failed to load';

  @override
  String get ehTagTitle => 'Tag lookup';

  @override
  String get ehTagImportTitle => 'Import tag translations';

  @override
  String get ehTagImportAction => 'Import';

  @override
  String ehTagImported(int count) {
    return 'Imported $count translations';
  }

  @override
  String ehTagImportFailed(String error) {
    return 'Import failed: $error';
  }

  @override
  String get ehTagClearHistoryTitle => 'Clear tag history';

  @override
  String get ehTagClearHistoryMessage =>
      'All local tag records will be deleted.';

  @override
  String get ehTagHistoryCleared => 'Tag history cleared';

  @override
  String get ehTagClearTranslationsTitle => 'Clear imported translations';

  @override
  String get ehTagClearTranslationsMessage =>
      'Built-in translations will be kept.';

  @override
  String get ehTagTranslationsCleared => 'Imported translations cleared';

  @override
  String ehTagLocalCount(int count) {
    return '$count local tags';
  }

  @override
  String get ehTagImportTooltip => 'Import translations';

  @override
  String get ehTagSearchHint => 'Search tags or Chinese translations';

  @override
  String get ehTagNoMatch => 'No matching tags';

  @override
  String get ehTagNoRecords => 'No tag records yet';

  @override
  String get ehTagNoMatchHint =>
      'Try another keyword, or tap a tag directly in the gallery details.';

  @override
  String get ehTagNoRecordsHint =>
      'Tags are collected automatically when you open any gallery details. You can also import a translation library first.';

  @override
  String get ehTagImportLibrary => 'Import translation library';

  @override
  String get ehLoginTitle => 'E-Hentai Login';

  @override
  String get ehLoginTabWeb => 'Web login';

  @override
  String get ehLoginTabManual => 'Manual Cookie';

  @override
  String get ehLoginReading => 'Reading…';

  @override
  String get ehLoginHint =>
      'Login cookies are stored only on this device and are used to access E-Hentai / ExHentai.';

  @override
  String get ehLoginNoCookie =>
      'No login Cookie detected yet. Please log in on the web page first.';

  @override
  String get ehLoginNotEffective =>
      'Web login did not take effect: make sure you passed verification and signed in successfully.';

  @override
  String get ehLoginGotCookies =>
      'Login and ExHentai cookies obtained. Tap the top-right button to finish.';

  @override
  String get ehLoginRefreshingExAfterLogin =>
      'Signed in. Fetching ExHentai access…';

  @override
  String get ehLoginRefreshingEx => 'Fetching ExHentai access…';

  @override
  String get ehLoginExGranted =>
      'ExHentai access granted. You can go back and browse ExHentai.';

  @override
  String get ehLoginExGrantedViaWeb =>
      'ExHentai access obtained via the web page. You can go back and browse ExHentai.';

  @override
  String get ehLoginClearWebCookiesTitle => 'Clear web cookies';

  @override
  String get ehLoginClearWebCookiesMessage =>
      'This will clear the E-Hentai / ExHentai web login state and reopen the forum login page.';

  @override
  String get ehLoginClearWebCookiesConfirm => 'Clear and log in again';

  @override
  String get ehLoginClearingCookies => 'Clearing cookies…';

  @override
  String get ehLoginClearedCookies =>
      'Web cookies cleared. Please log in again.';

  @override
  String get ehLoginLoginFirst => 'Please log in on the web page first';

  @override
  String get ehLoginManualMissing =>
      'Must include at least ipb_member_id and ipb_pass_hash';

  @override
  String get ehLoginCookieInvalid =>
      'The Cookie is invalid or has expired. Please get it again.';

  @override
  String ehLoginPageLoadFailed(String error) {
    return 'Page failed to load: $error';
  }

  @override
  String get ehLoginAutoHint =>
      'Cookies are read automatically after logging in and exchanged for ExHentai credentials.';

  @override
  String get ehLoginClearCookie => 'Clear cookies';

  @override
  String get ehLoginDetecting => 'Detecting…';

  @override
  String get ehLoginDetectEx => 'Check EX';

  @override
  String get ehLoginManualHint =>
      'Copy the full Cookie from a logged-in browser. It must include at least ipb_member_id and ipb_pass_hash; igneous is also required for ExHentai. Both key=value and key: value line formats are supported.';

  @override
  String get ehLoginValidating => 'Validating…';

  @override
  String get ehLoginValidateAndSave => 'Validate and save';

  @override
  String get ehLibraryTitle => 'My Library';

  @override
  String ehLibrarySubtitle(String site, int favorites, int history) {
    return '$site · Favorites $favorites · History $history';
  }

  @override
  String ehLibraryFavoritesSegment(int count) {
    return 'Favorites $count';
  }

  @override
  String ehLibraryHistorySegment(int count) {
    return 'History $count';
  }

  @override
  String get ehLibraryNoFavorites => 'No favorites yet';

  @override
  String get ehLibraryNoFavoritesHint =>
      'Open a gallery\'s details and tap the heart button in the top-right corner to add it to favorites.';

  @override
  String ehLibraryTileSubtitle(String category, int pages, String rating) {
    return '$category · $pages pages$rating';
  }

  @override
  String get ehLibraryRemoveFavorite => 'Remove from favorites';

  @override
  String get ehLibraryNoHistory => 'No reading history yet';

  @override
  String get ehLibraryNoHistoryHint =>
      'Your progress is recorded automatically after reading any gallery, so you can continue next time.';

  @override
  String ehLibraryHistorySubtitle(int lastPage, int totalPages, String time) {
    return 'Read $lastPage/$totalPages pages · $time';
  }

  @override
  String get ehLibraryRemoveHistory => 'Remove from history';

  @override
  String ehLibraryTodayTime(String time) {
    return 'Today $time';
  }

  @override
  String get ehDownloadTitle => 'Downloads';

  @override
  String ehDownloadSummary(int total, int completed) {
    return '$total total · $completed completed';
  }

  @override
  String get ehDownloadEmpty => 'No download tasks yet';

  @override
  String get ehDownloadEmptyHint =>
      'Tap the download button on a gallery\'s details page to save the whole gallery locally for offline reading.';

  @override
  String get ehDownloadDelete => 'Delete download';

  @override
  String ehDownloadDeleteConfirm(String title) {
    return 'Delete the local files for \'$title\'?';
  }

  @override
  String get ehDownloadDownloaded => 'Downloaded';

  @override
  String get ehDownloadNoPages => 'This gallery has no readable pages yet';

  @override
  String get ehDownloadNoDownloadedPages => 'No pages downloaded yet';

  @override
  String ehDownloadPagesProgress(int downloaded, int total) {
    return '$downloaded/$total pages';
  }

  @override
  String ehDownloadStatusQueued(String progress) {
    return 'Queued · $progress';
  }

  @override
  String ehDownloadStatusDownloading(String progress) {
    return 'Downloading · $progress';
  }

  @override
  String ehDownloadStatusPaused(String progress) {
    return 'Paused · $progress';
  }

  @override
  String ehDownloadStatusPausedError(String error) {
    return 'Paused · $error';
  }

  @override
  String ehDownloadStatusCompleted(String progress) {
    return 'Completed · $progress';
  }

  @override
  String ehDownloadStatusFailed(String error) {
    return 'Failed · $error';
  }

  @override
  String get ehDownloadUnknownError => 'Unknown error';

  @override
  String get ehStatusQueued => 'Queued';

  @override
  String get ehStatusDownloading => 'Downloading';

  @override
  String get ehStatusPaused => 'Paused';

  @override
  String get ehStatusCompleted => 'Completed';

  @override
  String get ehStatusFailed => 'Failed';

  @override
  String get ehDownloadPagesUnknown =>
      'Unable to get the gallery\'s page count';

  @override
  String ehDownloadFailedWith(String error) {
    return 'Download failed: $error';
  }

  @override
  String get ehDownloadPartial =>
      'Some pages were not downloaded. You can retry.';

  @override
  String get ehDownloadEmptyPage => 'The page is empty';

  @override
  String get ehDownloadDirUninitialized => 'Download directory not initialized';

  @override
  String get ehDownloadPausedInManager =>
      'Paused. You can resume it in Downloads.';

  @override
  String get ehAuthEmptyExPage =>
      'ExHentai returned an empty page: please log in again and tap \'Check EX\' on the login page to get access.';

  @override
  String get ehAuthEmptyList =>
      'ExHentai returned no list: make sure the login is valid, then tap \'Check EX\' on the login page to get access again.';

  @override
  String get ehAuthGetExExpired =>
      'The login has expired. Please log in again before fetching ExHentai access.';

  @override
  String get ehAuthIgneousMystery =>
      'This account does not have ExHentai access yet (igneous=mystery). Please confirm the account\'s eligibility and try again.';

  @override
  String get ehAuthIgneousNoContent =>
      'igneous was obtained, but ExHentai returned no content: the account may lack ExHentai access or the login has expired.';

  @override
  String get ehAuthLoginExpired =>
      'The login has expired. Please log in again.';

  @override
  String get ehAuthMissingCredential =>
      'The login is valid, but the site did not issue ExHentai credentials: please confirm the account has ExHentai access.';

  @override
  String get ehAuthSadPanda =>
      'ExHentai requires an igneous credential: tap \'Check EX\' on the login page to authorize again.';

  @override
  String get ehAuthSadPandaCookie =>
      'ExHentai requires an igneous Cookie: tap \'Check EX\' on the login page to complete authorization.';

  @override
  String ehBanLabelHoursMinutes(int hours, int minutes) {
    return '$hours hr $minutes min';
  }

  @override
  String ehBanLabelMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String ehBanRecoverAfter(String duration) {
    return 'Your IP is temporarily banned by the site. It should recover in about $duration.';
  }

  @override
  String get ehBanTemporary =>
      'Your IP is temporarily banned by the site. Please try again later.';

  @override
  String get ehBanWaitRecovery =>
      'Your IP is temporarily banned by the site. Please wait for the recovery time shown by the site.';

  @override
  String get ehErrorCloudflare =>
      'Blocked by Cloudflare. Please open the web page and complete the verification.';

  @override
  String get ehErrorRateLimited =>
      'Image server rate limit (509). Please try again later.';

  @override
  String ehNetConnectFailed(String error) {
    return 'Network connection failed: $error';
  }

  @override
  String get ehNetEmptyPage =>
      'The site returned an empty page. You may be temporarily banned or rate limited, so please try again later.';

  @override
  String ehNetImageStatusError(int status) {
    return 'Image request failed ($status)';
  }

  @override
  String ehNetRequestFailed(String error) {
    return 'Network request failed: $error';
  }

  @override
  String ehNetRequestStatusError(int status) {
    return 'Request failed ($status)';
  }

  @override
  String ehNetServerError(int status) {
    return 'Server error ($status)';
  }

  @override
  String get ehNetTimeout =>
      'Request timed out. Please check your network or proxy settings.';

  @override
  String get ehNetTooManyRedirects =>
      'Too many redirects. Please try again later.';

  @override
  String get ehParseApiInvalid =>
      'api.php returned content that could not be parsed';

  @override
  String get ehParseDetailStructure =>
      'Unexpected details page structure: the title could not be found';

  @override
  String get ehParseGalleryUnavailable =>
      'The gallery is unavailable or has been deleted';

  @override
  String get ehParseImageNotImage => 'The image URL returned non-image content';

  @override
  String get ehParseImageUrlFailed =>
      'Could not resolve the image URL for this page';

  @override
  String get ehParseOtherTagGroup => 'Other';

  @override
  String get ehParsePTokenMissing =>
      'Could not get the pToken for this page. Please start reading from the first page.';

  @override
  String get ehParseShowkeyMissing =>
      'The image page is missing showkey, so the image URL cannot be fetched again';
}
