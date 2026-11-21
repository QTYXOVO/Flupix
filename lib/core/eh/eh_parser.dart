import 'dart:math' as math;

import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;

import '../../l10n/l10n.dart';
import 'eh_exceptions.dart';
import 'eh_models.dart';

class GalleryListResult {
  const GalleryListResult({
    required this.items,
    required this.pages,
    required this.nextPage,
    this.nextCursor,
    this.totalResults = 0,
  });

  final List<GalleryItem> items;

  /// 总页数，0 表示站点采用游标分页或没有给出分页信息。
  final int pages;

  /// 下一页页码，-1 表示已到末尾。
  final int nextPage;

  /// 现代 E-Hentai 搜索/首页使用 `next=` 游标分页。
  final String? nextCursor;

  /// 站点给出的结果总数，0 表示未知。
  final int totalResults;
}

class ParsedImagePage {
  const ParsedImagePage({
    this.imageUrl,
    this.showKey,
    this.skipHathKey,
    this.nextIndex,
    this.prevIndex,
  });

  final String? imageUrl;
  final String? showKey;
  final String? skipHathKey;
  final int? nextIndex;
  final int? prevIndex;
}

/// 列表解析。所有选择器都保留兜底路径，页面结构变化时尽量不抛异常。
GalleryListResult parseGalleryList(String html, {required String baseUrl}) {
  _checkPage(html);
  final document = html_parser.parse(html);
  if (document.body?.text.contains('No hits found') ?? false) {
    return const GalleryListResult(items: [], pages: 0, nextPage: -1);
  }

  final items = <GalleryItem>[];
  final seen = <int>{};
  final container =
      document.querySelector('.itg') ?? document.querySelector('table.itg');
  if (container != null) {
    final rows = _listRows(container);
    for (final row in rows) {
      final item = _parseListItem(row, baseUrl);
      if (item == null || !seen.add(item.gid)) continue;
      items.add(item);
    }
  }

  final pagination = _parsePagination(document, html);
  final totalResults = _parseTotalResults(document);
  return GalleryListResult(
    items: items,
    pages: pagination.$1,
    nextPage: pagination.$2,
    nextCursor: pagination.$3,
    totalResults: totalResults,
  );
}

List<Element> _listRows(Element container) {
  if (container.localName == 'table') {
    final tbody = container.querySelector('tbody') ?? container;
    return tbody.children;
  }
  return container.children;
}

GalleryItem? _parseListItem(Element row, String baseUrl) {
  final anchor =
      row.querySelector('a.glink') ??
      row.querySelector('.glname a') ??
      row.querySelector('a[href*="/g/"]');
  if (anchor == null) return null;
  final href = anchor.attributes['href'] ?? '';
  final match = RegExp(r'/g/(\d+)/([0-9a-fA-F]+)').firstMatch(href);
  if (match == null) return null;

  final nameEl = row.querySelector('.glname');
  final titleEl = row.querySelector('.glink');
  var title = (titleEl?.text ?? nameEl?.text ?? anchor.text).trim();
  title = title.replaceAll(RegExp(r'\s+'), ' ');
  if (title.isEmpty) return null;

  final image = row.querySelector('img');
  final thumb = _normalizeUrl(
    image?.attributes['data-src'] ?? image?.attributes['src'],
    baseUrl,
  );

  final categoryEl = row.querySelector('.cn') ?? row.querySelector('.cs');
  final category = categoryEl?.text.trim() ?? '';

  final pages = _parsePageCount(row);

  final uploader = row.querySelector('a[href*="/uploader/"]')?.text.trim();

  return GalleryItem(
    gid: int.parse(match.group(1)!),
    token: match.group(2)!,
    title: title,
    thumbUrl: thumb,
    category: category,
    rating: _parseRating(row.querySelector('.ir')),
    pages: pages,
    uploader: uploader,
  );
}

int _parsePageCount(Element row) {
  for (final div in row.querySelectorAll('div')) {
    final match = RegExp(
      r'^([\d,]+)\s*pages?$',
      caseSensitive: false,
    ).firstMatch(div.text.trim());
    if (match != null) {
      return int.tryParse(match.group(1)!.replaceAll(',', '')) ?? 0;
    }
  }
  final fallback = RegExp(
    r'(\d[\d,]*)\s*pages?\b',
    caseSensitive: false,
  ).firstMatch(row.text);
  return int.tryParse(fallback?.group(1)?.replaceAll(',', '') ?? '') ?? 0;
}

double _parseRating(Element? element) {
  if (element == null) return -1;
  final title = element.attributes['title'] ?? '';
  final numeric = double.tryParse(
    RegExp(r'(\d+(?:\.\d+)?)').firstMatch(title)?.group(1) ??
        element.text.trim(),
  );
  return numeric ?? -1;
}

(int, int, String?) _parsePagination(Document document, String html) {
  final ptt = document.querySelector('.ptt');
  var pages = 0;
  var nextPage = -1;
  if (ptt != null) {
    for (final link in ptt.querySelectorAll('a')) {
      final href = link.attributes['href'] ?? '';
      final match = RegExp(r'[?&]page=(\d+)').firstMatch(href);
      if (match == null) continue;
      final value = int.parse(match.group(1)!);
      final label = link.text.trim();
      final numeric = int.tryParse(label);
      if (numeric != null) pages = math.max(pages, numeric);
      final alt = link.querySelector('img')?.attributes['alt']?.trim();
      if (_isNextLabel(label) || _isNextLabel(alt ?? '')) {
        nextPage = value;
      }
    }
  }

  var nextCursor = _nextCursorFromHref(
    document.querySelector('a#unext')?.attributes['href'],
  );
  if (nextCursor == null) {
    final scriptMatch = RegExp(r'var nexturl="([^"]*)"').firstMatch(html);
    final value = scriptMatch?.group(1) ?? '';
    if (value.isNotEmpty) nextCursor = _nextCursorFromHref(value);
  }

  return (pages, nextPage, nextCursor);
}

String? _nextCursorFromHref(String? href) {
  if (href == null || href.trim().isEmpty) return null;
  final uri = Uri.tryParse(_unescape(href.trim()));
  final value = uri?.queryParameters['next'];
  if (value == null || value.isEmpty) return null;
  return value;
}

int _parseTotalResults(Document document) {
  final text = document.querySelector('.searchtext')?.text ?? '';
  final match = RegExp(
    r'Found (?:about )?([\d,]+) results',
    caseSensitive: false,
  ).firstMatch(text);
  return int.tryParse(match?.group(1)?.replaceAll(',', '') ?? '') ?? 0;
}

bool _isNextLabel(String label) {
  final text = label.trim().toLowerCase();
  return text == '>' ||
      text == '›' ||
      text == '»' ||
      text == 'next' ||
      text == 'next page';
}

/// 详情解析。
GalleryDetail parseGalleryDetail(
  String html, {
  required GalleryItem item,
  required String baseUrl,
}) {
  _checkPage(html);
  final document = html_parser.parse(html);
  final titleEl = document.querySelector('#gn');
  if (titleEl == null) {
    if (document.body?.text.contains('Gallery Not Available') ?? false) {
      throw EhParseException(AppL10n.current.ehParseGalleryUnavailable);
    }
    throw EhParseException(AppL10n.current.ehParseDetailStructure);
  }

  final title = _cleanText(titleEl.text);

  final categoryEl =
      document.querySelector('#gdc .cn') ?? document.querySelector('#gdc .cs');
  final category = categoryEl?.text.trim();

  final uploader = document.querySelector('#gdn a')?.text.trim();

  final ratingText = document.querySelector('#rating_label')?.text ?? '';
  final rating = double.tryParse(
    RegExp(r'(\d+(?:\.\d+)?)').firstMatch(ratingText)?.group(1) ?? '',
  );

  final ratingCount = int.tryParse(
    RegExp(r'\d+')
            .firstMatch(document.querySelector('#rating_count')?.text ?? '')
            ?.group(0) ??
        '',
  );

  final pageText = document.querySelector('#gdd')?.text ?? '';
  final pageMatch = RegExp(
    r'(\d[\d,]*)\s*pages?',
    caseSensitive: false,
  ).firstMatch(pageText.isNotEmpty ? pageText : html);
  final pages = int.tryParse(pageMatch?.group(1)?.replaceAll(',', '') ?? '');

  final favoriteMatch = RegExp(
    r'Favorited:?\s*([\d,]+)',
    caseSensitive: false,
  ).firstMatch(html);
  final favoriteCount = int.tryParse(
    favoriteMatch?.group(1)?.replaceAll(',', '') ?? '',
  );

  final tags = <String, List<String>>{};
  for (final row in document.querySelectorAll('#taglist tr')) {
    final groupEl = row.querySelector('td.tc');
    if (groupEl == null) continue;
    var group = groupEl.text.replaceAll(':', '').trim();
    if (group.isEmpty) group = AppL10n.current.ehParseOtherTagGroup;
    final values = <String>[];
    for (final link in row.querySelectorAll('a')) {
      final href = link.attributes['href'] ?? '';
      if (!href.contains('/tag/')) continue;
      var tag = _cleanText(link.text);
      if (tag.endsWith('?')) {
        tag = tag.substring(0, tag.length - 1).trim();
      }
      if (tag.isNotEmpty) values.add(tag);
    }
    if (values.isNotEmpty) {
      tags.putIfAbsent(group, () => []).addAll(values);
    }
  }

  final previews = <GalleryPreview>[];
  final seen = <int>{};
  for (final link in document.querySelectorAll('#gdt a[href*="/s/"]')) {
    final href = link.attributes['href'] ?? '';
    final pTokenMatch = RegExp(r'/s/([^/]+)/').firstMatch(href);
    if (pTokenMatch == null) continue;

    final image = link.querySelector('img');
    final div = link.querySelector('div');
    final titleAttr =
        div?.attributes['title'] ?? image?.attributes['title'] ?? '';
    final alt = int.tryParse(image?.attributes['alt']?.trim() ?? '');
    final titlePage = int.tryParse(
      RegExp(r'Page\s+(\d+)').firstMatch(titleAttr)?.group(1) ?? '',
    );
    final tail = RegExp(r'-(\d+)(?:[/?#].*)?$').firstMatch(href);
    final index = titlePage != null && titlePage > 0
        ? titlePage - 1
        : (alt != null && alt > 0)
        ? alt - 1
        : int.tryParse(tail?.group(1) ?? '');
    if (index == null || index < 0 || !seen.add(index)) continue;

    var thumb = _normalizeUrl(
      image?.attributes['data-src'] ?? image?.attributes['src'],
      baseUrl,
    );
    var isSprite = false;
    var thumbWidth = 0.0;
    var thumbHeight = 0.0;
    var thumbOffsetX = 0.0;

    if (thumb.isEmpty && div != null) {
      final style = div.attributes['style'] ?? '';
      final urlMatch = RegExp(r'url\(([^)]+)\)').firstMatch(style);
      if (urlMatch != null) {
        thumb = _normalizeUrl(
          urlMatch.group(1)?.replaceAll(RegExp(r'''^["']|["']$'''), ''),
          baseUrl,
        );
        final offset = RegExp(r'(-?\d+)px\s+0').firstMatch(style);
        final width = RegExp(r'width:\s*([\d.]+)px').firstMatch(style);
        final height = RegExp(r'height:\s*([\d.]+)px').firstMatch(style);
        final offsetValue = double.tryParse(offset?.group(1) ?? '') ?? 0;
        thumbOffsetX = offsetValue < 0 ? -offsetValue : 0;
        thumbWidth = double.tryParse(width?.group(1) ?? '') ?? 200;
        thumbHeight = double.tryParse(height?.group(1) ?? '') ?? 291;
        isSprite = true;
      }
    }
    if (thumb.isEmpty) continue;

    previews.add(
      GalleryPreview(
        index: index,
        pToken: pTokenMatch.group(1)!,
        thumbUrl: thumb,
        pageUrl: _normalizeUrl(href, baseUrl),
        isSprite: isSprite,
        thumbWidth: thumbWidth,
        thumbHeight: thumbHeight,
        thumbOffsetX: thumbOffsetX,
      ),
    );
  }
  previews.sort((a, b) => a.index.compareTo(b.index));

  return GalleryDetail(
    gid: item.gid,
    token: item.token,
    title: title.isNotEmpty ? title : item.title,
    titleJpn: _cleanText(document.querySelector('#gj')?.text ?? ''),
    thumbUrl: item.thumbUrl,
    category: category?.isNotEmpty == true ? category! : item.category,
    rating: rating ?? item.rating,
    pages: pages ?? item.pages,
    uploader: uploader?.isNotEmpty == true ? uploader : item.uploader,
    ratingCount: ratingCount ?? 0,
    favoriteCount: favoriteCount ?? 0,
    tags: tags,
    previews: previews,
    previewPerPage: 20,
  );
}

/// 图片展示页解析。
ParsedImagePage parseImagePage(String html) {
  _checkPage(html);
  final imageUrl = _firstMatch(html, const [
    r'<img[^>]+id="img"[^>]+src="([^"]+)"',
    r'<img[^>]+src="([^"]+)"[^>]+id="img"',
    r'id="img"[^>]*?src="([^"]+)"',
    r'<img[^>]+src="([^"]+)"[^>]*style=',
  ]);

  final showKey = _firstMatch(html, const [
    r'var showkey\s*=\s*"([^"]+)"',
    r"var showkey\s*=\s*'([^']+)'",
    r'showkey="([^"]+)"',
  ]);

  final skipHath = RegExp(r"return nl\('([^)]+)'\)").firstMatch(html)?.group(1);

  int? nextIndex;
  int? prevIndex;
  final document = html_parser.parse(html);
  final nextHref = document.querySelector('#next')?.attributes['href'];
  final prevHref = document.querySelector('#prev')?.attributes['href'];
  nextIndex = _pageIndexFromHref(nextHref);
  prevIndex = _pageIndexFromHref(prevHref);

  return ParsedImagePage(
    imageUrl: _normalizeImageUrl(imageUrl),
    showKey: showKey.isEmpty ? null : showKey,
    skipHathKey: skipHath,
    nextIndex: nextIndex,
    prevIndex: prevIndex,
  );
}

int? _pageIndexFromHref(String? href) {
  if (href == null) return null;
  final match = RegExp(r'/(\d+)-(\d+)').firstMatch(href);
  if (match == null) return null;
  final page = int.tryParse(match.group(2) ?? '');
  return page == null ? null : page - 1;
}

GalleryItem? parseGdataItem(Map<String, dynamic> json) {
  final gid = json['gid'];
  final token = json['token'];
  if (gid is! int || token is! String) return null;
  final thumb = json['thumb']?.toString() ?? '';
  return GalleryItem(
    gid: gid,
    token: token,
    title: json['title']?.toString() ?? '',
    thumbUrl: thumb.startsWith('//') ? 'https:$thumb' : thumb,
    category: json['category']?.toString() ?? '',
    rating: _toDouble(json['rating']) ?? -1,
    pages: _toInt(json['filecount']) ?? 0,
    uploader: json['uploader']?.toString(),
  );
}

int? _toInt(Object? value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '');
}

double? _toDouble(Object? value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '');
}

void _checkPage(String html) {
  if (html.contains('Sad Panda') || html.toLowerCase().contains('sadpanda')) {
    throw EhAuthRequired(AppL10n.current.ehAuthSadPandaCookie);
  }
  if (html.contains('Just a moment') ||
      html.contains('cf-browser-verification')) {
    throw EhCloudflare();
  }
  if (html.contains('has been temporarily banned') ||
      html.contains('excessive request rate')) {
    throw EhNetworkException(AppL10n.current.ehBanWaitRecovery);
  }
}

String _firstMatch(String input, List<String> patterns) {
  for (final pattern in patterns) {
    final match = RegExp(pattern).firstMatch(input);
    if (match != null) {
      final value = _unescape(match.group(1) ?? '');
      if (value.isNotEmpty) return value;
    }
  }
  return '';
}

String _normalizeImageUrl(String raw) {
  if (raw.isEmpty) return '';
  final value = _unescape(raw);
  if (value.startsWith('//')) return 'https:$value';
  return value;
}

String _normalizeUrl(String? raw, String baseUrl) {
  if (raw == null) return '';
  final value = _unescape(raw.trim());
  if (value.isEmpty) return '';
  if (value.startsWith('//')) return 'https:$value';
  if (value.startsWith('http://') || value.startsWith('https://')) {
    return value;
  }
  return Uri.parse(baseUrl).resolve(value).toString();
}

String _cleanText(String raw) => raw.replaceAll(RegExp(r'\s+'), ' ').trim();

String _unescape(String input) => input
    .replaceAll('&amp;', '&')
    .replaceAll('&#39;', "'")
    .replaceAll('&quot;', '"')
    .replaceAll('&lt;', '<')
    .replaceAll('&gt;', '>');
