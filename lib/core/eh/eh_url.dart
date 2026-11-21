import 'eh_models.dart';

/// 统一构造 E-Hentai / ExHentai 的 URL，避免散落在页面里拼字符串。
class EhUrls {
  const EhUrls(this.site);

  final EhSite site;

  Uri get home => Uri.parse('${site.baseUrl}/');

  Uri list({
    int page = 0,
    String? next,
    String keyword = '',
    int excludedCategories = 0,
  }) {
    final params = <String, String>{};
    final query = keyword.trim();
    if (query.isNotEmpty) params['f_search'] = query;
    if (excludedCategories > 0) params['f_cats'] = '$excludedCategories';
    final cursor = next?.trim();
    if (cursor != null && cursor.isNotEmpty) {
      params['next'] = cursor;
    } else if (page > 0) {
      params['page'] = '$page';
    }
    final home = Uri.parse('${site.baseUrl}/');
    return params.isEmpty ? home : home.replace(queryParameters: params);
  }

  Uri detail(int gid, String token, {int previewPage = 0}) {
    final base = '${site.baseUrl}/g/$gid/$token/';
    if (previewPage <= 0) return Uri.parse(base);
    return Uri.parse(base).replace(queryParameters: {'p': '$previewPage'});
  }

  /// 第 index 页（0 基）的图片展示页。
  Uri imagePage(String pToken, int gid, int index) {
    return Uri.parse('${site.baseUrl}/s/$pToken/$gid-${index + 1}');
  }

  Uri get api => Uri.parse('${site.baseUrl}/api.php');

  /// 列表缩略图没有稳定的详情页 Referer，退回站点首页。
  Uri get thumbReferer => home;
}
