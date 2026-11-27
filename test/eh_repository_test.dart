import 'dart:io';

import 'package:flupix/core/eh/eh_client.dart';
import 'package:flupix/core/eh/eh_exceptions.dart';
import 'package:flupix/core/eh/eh_models.dart';
import 'package:flupix/core/eh/eh_repository.dart';
import 'package:flutter_test/flutter_test.dart';

const _item = GalleryItem(
  gid: 123,
  token: 'abcdef1234',
  title: 'Fallback',
  thumbUrl: 'https://ehgt.org/t.jpg',
);

String _detailHtml(List<int> pageIndexes) {
  final previews = pageIndexes
      .map(
        (index) =>
            '<div class="gdtm"><a href="/s/ptok$index/123-${index + 1}">'
            '<img data-src="//ehgt.org/p$index.jpg" alt="${index + 1}"></a></div>',
      )
      .join();
  return '''
    <div id="gn">Test Gallery</div>
    <div id="gdd">Length: 42 pages</div>
    <div id="gdt">$previews</div>
  ''';
}

void main() {
  group('EhRepository 详情缓存', () {
    test('重复请求命中缓存，force 可绕过', () async {
      final client = _FakeEhClient();
      final repo = EhRepository(client);
      client.pages[repo.urls.detail(123, 'abcdef1234').toString()] =
          _detailHtml([0, 1]);

      await repo.fetchDetail(_item);
      await repo.fetchDetail(_item);
      expect(client.requests, hasLength(1));

      await repo.fetchDetail(_item, force: true);
      expect(client.requests, hasLength(2));
    });
  });

  group('EhRepository pToken 补全', () {
    test('详情页解析出的 pToken 可直接复用，不额外请求', () async {
      final client = _FakeEhClient();
      final repo = EhRepository(client);
      client.pages[repo.urls.detail(123, 'abcdef1234').toString()] =
          _detailHtml([0, 1]);

      await repo.fetchDetail(_item);
      final before = client.requests.length;

      expect(await repo.ensurePToken(_item, 1), 'ptok1');
      expect(client.requests, hasLength(before));
    });

    test('缓存缺失时按 index ~/ 20 拉取对应预览页', () async {
      final client = _FakeEhClient();
      final repo = EhRepository(client);
      final previewPage = repo.urls.detail(123, 'abcdef1234', previewPage: 2);
      client.pages[previewPage.toString()] = _detailHtml([41]);

      expect(await repo.ensurePToken(_item, 41), 'ptok41');
      expect(client.requests.single, previewPage);
      expect(client.requests.single.queryParameters['p'], '2');
    });

    test('预览页没有目标 pToken 时抛出解析异常', () async {
      final client = _FakeEhClient();
      final repo = EhRepository(client);
      final previewPage = repo.urls.detail(123, 'abcdef1234', previewPage: 1);
      client.pages[previewPage.toString()] = _detailHtml([0]);

      await expectLater(
        repo.ensurePToken(_item, 20),
        throwsA(isA<EhParseException>()),
      );
    });
  });

  group('EhRepository fetchPage', () {
    test('用 pToken 构造图片页地址并解析图片', () async {
      final client = _FakeEhClient();
      final repo = EhRepository(client);
      client.pages[repo.urls.detail(123, 'abcdef1234').toString()] =
          _detailHtml([0]);
      client.pages[repo.urls.imagePage('ptok0', 123, 0).toString()] =
          '<img id="img" src="https://img.ehgt.org/page-1.jpg">';

      await repo.fetchDetail(_item);
      final page = await repo.fetchPage(_item, 0);

      expect(page.pToken, 'ptok0');
      expect(page.pageUrl, 'https://e-hentai.org/s/ptok0/123-1');
      expect(page.imageUrl, 'https://img.ehgt.org/page-1.jpg');
    });

    test('缺少图片地址时通过 showpage API 拼接', () async {
      final client = _FakeEhClient();
      final repo = EhRepository(client);
      client.pages[repo.urls.detail(123, 'abcdef1234').toString()] =
          _detailHtml([0]);
      client.pages[repo.urls.imagePage('ptok0', 123, 0).toString()] =
          '<script>var showkey="sk1";</script>';
      client.apiHandler = (body) {
        expect(body['method'], 'showpage');
        expect(body['imgkey'], 'ptok0');
        expect(body['showkey'], 'sk1');
        return {
          'i3': '<img id="img" src="https://img.ehgt.org/from-api.jpg">',
        };
      };

      await repo.fetchDetail(_item);
      final page = await repo.fetchPage(_item, 0);
      expect(page.imageUrl, 'https://img.ehgt.org/from-api.jpg');
    });

    test('缺少 showkey 时抛出解析异常', () async {
      final client = _FakeEhClient();
      final repo = EhRepository(client);
      client.pages[repo.urls.detail(123, 'abcdef1234').toString()] =
          _detailHtml([0]);
      client.pages[repo.urls.imagePage('ptok0', 123, 0).toString()] =
          '<html>plain</html>';

      await repo.fetchDetail(_item);
      await expectLater(
        repo.fetchPage(_item, 0),
        throwsA(isA<EhParseException>()),
      );
    });
  });
}

class _FakeEhClient extends EhClient {
  _FakeEhClient()
    : super(
        site: EhSite.e,
        cookie: const EhCookie.empty(),
        httpClient: _UnusedHttpClient(),
      );

  final List<Uri> requests = [];
  final Map<String, String> pages = {};
  Map<String, dynamic> Function(Map<String, Object?> body)? apiHandler;

  @override
  Future<String> getHtml(Uri url, {String? referer}) async {
    requests.add(url);
    final html = pages[url.toString()];
    if (html == null) throw StateError('未准备页面：$url');
    return html;
  }

  @override
  Future<Map<String, dynamic>> apiJson(Map<String, Object?> body) async {
    final handler = apiHandler;
    if (handler == null) throw StateError('未准备 API 响应：$body');
    return handler(body);
  }
}

class _UnusedHttpClient implements HttpClient {
  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async {
    throw UnsupportedError('测试不应发起真实网络请求');
  }

  @override
  void close({bool force = false}) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
