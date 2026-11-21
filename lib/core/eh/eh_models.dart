import '../../l10n/l10n.dart';

/// E-Hentai / ExHentai 站点。
enum EhSite {
  e('https://e-hentai.org'),
  ex('https://exhentai.org');

  const EhSite(this.baseUrl);

  String get label => switch (this) {
    EhSite.e => AppL10n.current.ehSiteEHentai,
    EhSite.ex => AppL10n.current.ehSiteExHentai,
  };

  final String baseUrl;

  static EhSite fromName(String? name) {
    return EhSite.values.firstWhere(
      (site) => site.name == name,
      orElse: () => EhSite.e,
    );
  }
}

/// 列表页可见的分类筛选项，bit 对应网站 `f_cats` 屏蔽位。
class EhCategoryFilter {
  const EhCategoryFilter(this.key, this.bit);

  final String key;
  final int bit;

  String get label => ehCategoryLabel(key);
}

const List<EhCategoryFilter> ehCategoryFilters = [
  EhCategoryFilter('misc', 1),
  EhCategoryFilter('doujinshi', 2),
  EhCategoryFilter('manga', 4),
  EhCategoryFilter('artist cg', 8),
  EhCategoryFilter('game cg', 16),
  EhCategoryFilter('image set', 32),
  EhCategoryFilter('cosplay', 64),
  EhCategoryFilter('asian porn', 128),
  EhCategoryFilter('non-h', 256),
  EhCategoryFilter('western', 512),
];

String ehCategoryLabel(String raw) {
  final key = raw.toLowerCase().trim();
  final l10n = AppL10n.current;
  switch (key) {
    case 'misc':
      return l10n.ehCategoryMisc;
    case 'doujinshi':
      return l10n.ehCategoryDoujinshi;
    case 'manga':
      return l10n.ehCategoryManga;
    case 'artist cg':
      return l10n.ehCategoryArtistCg;
    case 'game cg':
      return l10n.ehCategoryGameCg;
    case 'image set':
      return l10n.ehCategoryImageSet;
    case 'cosplay':
      return l10n.ehCategoryCosplay;
    case 'asian porn':
      return l10n.ehCategoryAsian;
    case 'non-h':
      return l10n.ehCategoryNonH;
    case 'western':
      return l10n.ehCategoryWestern;
  }
  return raw.trim().isEmpty ? l10n.commonUnknown : raw.trim();
}

/// 列表项。详情页会在此基础上补充更多字段。
class GalleryItem {
  const GalleryItem({
    required this.gid,
    required this.token,
    required this.title,
    required this.thumbUrl,
    this.category = '',
    this.rating = -1,
    this.pages = 0,
    this.uploader,
  });

  final int gid;
  final String token;
  final String title;
  final String thumbUrl;
  final String category;
  final double rating;
  final int pages;
  final String? uploader;

  String get detailPath => '/g/$gid/$token/';

  GalleryItem copyWith({
    String? title,
    String? thumbUrl,
    String? category,
    double? rating,
    int? pages,
    String? uploader,
  }) {
    return GalleryItem(
      gid: gid,
      token: token,
      title: title ?? this.title,
      thumbUrl: thumbUrl ?? this.thumbUrl,
      category: category ?? this.category,
      rating: rating ?? this.rating,
      pages: pages ?? this.pages,
      uploader: uploader ?? this.uploader,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is GalleryItem && other.gid == gid && other.token == token;

  @override
  int get hashCode => Object.hash(gid, token);
}

/// 详情页的单页预览，每页都有独立的 pToken。
class GalleryPreview {
  const GalleryPreview({
    required this.index,
    required this.pToken,
    required this.thumbUrl,
    required this.pageUrl,
    this.isSprite = false,
    this.thumbWidth = 0,
    this.thumbHeight = 0,
    this.thumbOffsetX = 0,
  });

  /// 0 基页号。
  final int index;
  final String pToken;
  final String thumbUrl;
  final String pageUrl;

  /// 详情页默认使用雪碧图缩略图，此时 thumbUrl 是整张图，
  /// 需要用 thumbOffsetX 裁出当前页。
  final bool isSprite;
  final double thumbWidth;
  final double thumbHeight;

  /// 雪碧图左边裁切偏移（正数）。
  final double thumbOffsetX;
}

class GalleryDetail extends GalleryItem {
  const GalleryDetail({
    required super.gid,
    required super.token,
    required super.title,
    required super.thumbUrl,
    super.category,
    super.rating,
    super.pages,
    super.uploader,
    this.titleJpn,
    this.ratingCount = 0,
    this.favoriteCount = 0,
    this.tags = const {},
    this.previews = const [],
    this.previewPerPage = 20,
  });

  final String? titleJpn;
  final int ratingCount;
  final int favoriteCount;
  final Map<String, List<String>> tags;
  final List<GalleryPreview> previews;
  final int previewPerPage;
}

/// 阅读器加载成功的一页。
class GalleryPage {
  const GalleryPage({
    required this.index,
    required this.pToken,
    required this.pageUrl,
    required this.imageUrl,
  });

  /// 0 基页号。
  final int index;
  final String pToken;
  final String pageUrl;
  final String imageUrl;
}

/// E-Hentai 登录 Cookie。
class EhCookie {
  const EhCookie(this.values);

  const EhCookie.empty() : values = const {};

  final Map<String, String> values;

  String? get memberId => _nonEmpty('ipb_member_id');

  String? get passHash => _nonEmpty('ipb_pass_hash');

  String? get igneous => _nonEmpty('igneous');

  bool get isLoggedIn => memberId != null && passHash != null;

  /// ExHentai 需要论坛登录后由站点下发的 igneous Cookie。
  /// 站点在账号没有里站权限时会下发 `igneous=mystery`，等同无效。
  bool get hasExAccess => igneous != null && igneous != 'mystery';

  bool get isEmpty => values.isEmpty;

  String get headerValue => values.entries
      .where((entry) => entry.value.trim().isNotEmpty)
      .map((entry) => '${entry.key}=${entry.value}')
      .join('; ');

  EhCookie merge(EhCookie other) => EhCookie({...values, ...other.values});

  String? _nonEmpty(String key) {
    final value = values[key]?.trim();
    return value == null || value.isEmpty ? null : value;
  }

  static EhCookie fromJson(Map<String, dynamic> json) {
    return EhCookie({
      for (final entry in json.entries)
        if (entry.value is String) entry.key: entry.value as String,
    });
  }

  Map<String, dynamic> toJson() => Map<String, dynamic>.from(values);

  /// 支持 `a=1; b=2`、`a: 1`、换行分隔，以及直接粘贴带 `Cookie:` 前缀的内容。
  static EhCookie parse(String raw) {
    var text = raw.trim();
    if (text.toLowerCase().startsWith('cookie:')) {
      text = text.substring('cookie:'.length).trim();
    }
    final values = <String, String>{};
    for (final part in text.split(RegExp(r'[;\n\r]+'))) {
      final token = part.trim();
      if (token.isEmpty) continue;
      var index = token.indexOf('=');
      if (index <= 0) index = token.indexOf(':');
      if (index <= 0) continue;
      final key = token.substring(0, index).trim();
      final value = token.substring(index + 1).trim();
      if (key.isEmpty || value.isEmpty) continue;
      values[key] = value;
    }
    return EhCookie(values);
  }
}

/// 阅读进度，MVP 阶段存 SharedPreferences。
class ReadingProgress {
  const ReadingProgress({
    required this.gid,
    required this.token,
    required this.title,
    required this.thumbUrl,
    required this.lastPage,
    required this.totalPages,
    required this.updatedAt,
  });

  final int gid;
  final String token;
  final String title;
  final String thumbUrl;

  /// 1 基页码。
  final int lastPage;
  final int totalPages;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => {
    'gid': gid,
    'token': token,
    'title': title,
    'thumbUrl': thumbUrl,
    'lastPage': lastPage,
    'totalPages': totalPages,
    'updatedAt': updatedAt.millisecondsSinceEpoch,
  };

  static ReadingProgress? fromJson(Map<String, dynamic> json) {
    final gid = json['gid'];
    final lastPage = json['lastPage'];
    if (gid is! int || lastPage is! int) return null;
    return ReadingProgress(
      gid: gid,
      token: json['token']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      thumbUrl: json['thumbUrl']?.toString() ?? '',
      lastPage: lastPage,
      totalPages: json['totalPages'] is int ? json['totalPages'] as int : 0,
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        json['updatedAt'] is int ? json['updatedAt'] as int : 0,
      ),
    );
  }
}
