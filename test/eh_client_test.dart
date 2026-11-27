import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flupix/core/eh/eh_client.dart';
import 'package:flupix/core/eh/eh_exceptions.dart';
import 'package:flupix/core/eh/eh_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EhClient 重试策略', () {
    test('连续连接失败重试 3 次后抛出网络异常', () async {
      final http = _FakeHttpClient((_, _, _) async {
        throw SocketException('offline');
      });
      final client = EhClient(
        site: EhSite.e,
        cookie: const EhCookie.empty(),
        httpClient: http,
        retryDelay: Duration.zero,
      );

      await expectLater(
        client.getHtml(Uri.parse('https://e-hentai.org/')),
        throwsA(isA<EhNetworkException>()),
      );
      expect(http.calls, 3);
      client.dispose();
    });

    test('超时同样重试，前两次失败后第三次成功', () async {
      final http = _FakeHttpClient((_, url, call) async {
        if (call < 3) throw TimeoutException('slow');
        return _FakeRequest(url, () => _FakeResponse(body: '<html>ok</html>'));
      });
      final client = EhClient(
        site: EhSite.e,
        cookie: const EhCookie.empty(),
        httpClient: http,
        retryDelay: Duration.zero,
      );

      expect(await client.getHtml(Uri.parse('https://e-hentai.org/')), '<html>ok</html>');
      expect(http.calls, 3);
      client.dispose();
    });

    test('业务异常不重试', () async {
      final http = _FakeHttpClient((_, url, _) async {
        return _FakeRequest(
          url,
          () => _FakeResponse(
            statusCode: 509,
            body: 'Exceeded allowed hits',
          ),
        );
      });
      final client = EhClient(
        site: EhSite.e,
        cookie: const EhCookie.empty(),
        httpClient: http,
        retryDelay: Duration.zero,
      );

      await expectLater(
        client.getHtml(Uri.parse('https://e-hentai.org/')),
        throwsA(isA<EhRateLimited>()),
      );
      expect(http.calls, 1);
      client.dispose();
    });
  });

  group('EhClient Cookie 分域', () {
    test('按目标站点发送 Cookie，并在站点下发后回调', () async {
      final sent = <String, String?>{};
      var updated = const EhCookie.empty();
      final http = _FakeHttpClient((_, url, call) async {
        return _FakeRequest(
          url,
          () {
            final response = _FakeResponse(body: '<html>ok</html>');
            if (call == 2) {
              response.headers.set(
                HttpHeaders.setCookieHeader,
                'ipb_session_id=abc; Path=/',
              );
            }
            return response;
          },
          onClose: (request) {
            sent[url.host] = request.headers.value(HttpHeaders.cookieHeader);
          },
        );
      });
      final client = EhClient(
        site: EhSite.e,
        cookie: const EhCookie({
          'ipb_member_id': '1',
          'igneous': 'ex-token',
          'cf_clearance': 'cf-token',
        }),
        httpClient: http,
        retryDelay: Duration.zero,
        onCookiesChanged: (cookie) => updated = cookie,
      );

      await client.getHtml(Uri.parse('https://e-hentai.org/g/1/'));
      expect(sent['e-hentai.org'], contains('ipb_member_id=1'));
      expect(sent['e-hentai.org'], contains('cf_clearance=cf-token'));
      expect(sent['e-hentai.org'], isNot(contains('igneous')));

      await client.getHtml(Uri.parse('https://exhentai.org/'));
      expect(sent['exhentai.org'], contains('igneous=ex-token'));
      expect(sent['exhentai.org'], isNot(contains('cf_clearance')));
      expect(updated.values['ipb_session_id'], 'abc');

      client.dispose();
    });
  });
}

typedef _HttpHandler =
    Future<HttpClientRequest> Function(String method, Uri url, int call);

class _FakeHttpClient implements HttpClient {
  _FakeHttpClient(this._handler);

  final _HttpHandler _handler;
  int calls = 0;

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) {
    calls++;
    return _handler(method, url, calls);
  }

  @override
  void close({bool force = false}) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeHeaders implements HttpHeaders {
  final Map<String, List<String>> _values = {};

  ContentType? _contentType = ContentType('text', 'html', charset: 'utf-8');

  @override
  ContentType? get contentType => _contentType;

  @override
  set contentType(ContentType? value) => _contentType = value;

  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {
    _values[name.toLowerCase()] = [value.toString()];
  }

  @override
  String? value(String name) => _values[name.toLowerCase()]?.first;

  @override
  void forEach(void Function(String name, List<String> values) action) {
    _values.forEach(action);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeRequest implements HttpClientRequest {
  _FakeRequest(this.uri, this._respond, {this.onClose});

  @override
  final Uri uri;

  final HttpClientResponse Function() _respond;
  final void Function(_FakeRequest request)? onClose;

  @override
  final HttpHeaders headers = _FakeHeaders();

  @override
  bool followRedirects = true;

  final BytesBuilder body = BytesBuilder();

  @override
  void add(List<int> data) => body.add(data);

  @override
  Future<HttpClientResponse> close() async {
    onClose?.call(this);
    return _respond();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeResponse extends Stream<List<int>> implements HttpClientResponse {
  _FakeResponse({this.statusCode = 200, this.body = ''});

  @override
  final int statusCode;

  final String body;

  @override
  final HttpHeaders headers = _FakeHeaders();

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.fromIterable([
      utf8.encode(body),
    ]).listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
