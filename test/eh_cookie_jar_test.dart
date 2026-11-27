import 'package:flupix/core/eh/eh_cookie_jar.dart';
import 'package:flupix/core/eh/eh_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EhCookieJar 初始分域', () {
    test('igneous 只发给 ExHentai，cf_* 只发给 E-Hentai', () {
      final jar = EhCookieJar.fromCookie(
        const EhCookie({
          'ipb_member_id': '1',
          'ipb_pass_hash': 'hash',
          'igneous': 'ex-token',
          'cf_clearance': 'cf-token',
        }),
      );

      final exHeader = jar.headerFor('exhentai.org');
      expect(exHeader, contains('igneous=ex-token'));
      expect(exHeader, contains('ipb_member_id=1'));
      expect(exHeader, isNot(contains('cf_clearance')));

      final ehHeader = jar.headerFor('e-hentai.org');
      expect(ehHeader, contains('ipb_member_id=1'));
      expect(ehHeader, contains('cf_clearance=cf-token'));
      expect(ehHeader, isNot(contains('igneous')));
    });

    test('普通偏好只留在论坛域名，nw/sp 同步到里站', () {
      final jar = EhCookieJar.fromCookie(
        const EhCookie({'sk': 'xyz', 'nw': '1', 'sp': '0'}),
      );

      final ehHeader = jar.headerFor('e-hentai.org');
      expect(ehHeader, contains('sk=xyz'));
      expect(ehHeader, contains('nw=1'));
      expect(ehHeader, contains('sp=0'));

      final exHeader = jar.headerFor('exhentai.org');
      expect(exHeader, contains('nw=1'));
      expect(exHeader, contains('sp=0'));
      expect(exHeader, isNot(contains('sk=xyz')));
    });

    test('论坛子域可匹配非 hostOnly Cookie', () {
      final jar = EhCookieJar.fromCookie(
        const EhCookie({'ipb_member_id': '1'}),
      );
      expect(jar.headerFor('forums.e-hentai.org'), 'ipb_member_id=1');
    });
  });

  group('EhCookieJar Set-Cookie', () {
    test('无 Domain 时仅对当前主机生效', () {
      final jar = EhCookieJar([]);
      jar.applySetCookie(
        'session=abc; Path=/',
        Uri.parse('https://e-hentai.org/g/1/'),
      );

      expect(jar.valueOf('session', 'e-hentai.org'), 'abc');
      expect(jar.valueOf('session', 'forums.e-hentai.org'), isNull);
      expect(jar.headerFor('exhentai.org'), isNot(contains('session')));
    });

    test('Domain 带点时可匹配子域但不匹配其它站点', () {
      final jar = EhCookieJar([]);
      jar.applySetCookie(
        'sid=1; Domain=.e-hentai.org; Path=/',
        Uri.parse('https://e-hentai.org/g/1/'),
      );

      expect(jar.headerFor('forums.e-hentai.org'), 'sid=1');
      expect(jar.headerFor('exhentai.org'), isNot(contains('sid')));
    });

    test('同名 Cookie 后写入覆盖且只保留一份', () {
      final jar = EhCookieJar([]);
      final url = Uri.parse('https://e-hentai.org/g/1/');
      jar.applySetCookie('a=1', url);
      expect(jar.valueOf('a', 'e-hentai.org'), '1');

      jar.applySetCookie('a=2', url);
      expect(jar.valueOf('a', 'e-hentai.org'), '2');
      expect('a='.allMatches(jar.headerFor('e-hentai.org')).length, 1);
      expect(jar.headerFor('e-hentai.org'), 'a=2');
    });

    test('空值、Max-Age 过期与 Expires 过期都会删除', () {
      final jar = EhCookieJar.fromCookie(
        const EhCookie({'a': '1', 'b': '2', 'c': '3'}),
      );
      final url = Uri.parse('https://e-hentai.org/g/1/');

      jar.applySetCookie('a=; Max-Age=0', url);
      jar.applySetCookie('b=2; Expires=Wed, 09 Jun 2021 10:18:14 GMT', url);
      jar.applySetCookie('c=3; Max-Age=-10', url);

      expect(jar.toCookie().values, isEmpty);
      expect(jar.dirty, isTrue);
    });

    test('无法解析的属性不会丢弃 Cookie', () {
      final jar = EhCookieJar([]);
      jar.applySetCookie(
        'a=1; Max-Age=abc; Expires=not-a-date',
        Uri.parse('https://e-hentai.org/'),
      );
      expect(jar.valueOf('a', 'e-hentai.org'), '1');
    });
  });

  group('EhCookieJar 变更标记', () {
    test('写入、清空与 markClean 正确切换 dirty', () {
      final jar = EhCookieJar([]);
      expect(jar.dirty, isFalse);

      jar.applySetCookie('a=1', Uri.parse('https://e-hentai.org/'));
      expect(jar.dirty, isTrue);

      jar.markClean();
      expect(jar.dirty, isFalse);

      jar.remove('missing');
      expect(jar.dirty, isFalse);

      jar.remove('a');
      expect(jar.dirty, isTrue);
    });

    test('remove 清除所有域名下的同名 Cookie', () {
      final jar = EhCookieJar.fromCookie(
        const EhCookie({'igneous': 'x', 'ipb_member_id': '1'}),
      );
      expect(jar.headerFor('exhentai.org'), contains('igneous=x'));

      jar.remove('igneous');
      expect(jar.valueOf('igneous', 'exhentai.org'), isNull);
      expect(jar.headerFor('exhentai.org'), isNot(contains('igneous')));
    });
  });

  group('EhCookieJar 过期处理', () {
    test('过期 Cookie 不参与匹配也不导出', () {
      final jar = EhCookieJar([
        JarCookie(
          name: 'old',
          value: '1',
          domain: 'e-hentai.org',
          hostOnly: false,
          expires: DateTime.now().subtract(const Duration(minutes: 1)),
        ),
        const JarCookie(
          name: 'fresh',
          value: '2',
          domain: 'e-hentai.org',
          hostOnly: false,
        ),
      ]);

      expect(jar.headerFor('e-hentai.org'), 'fresh=2');
      expect(jar.toCookie().values, {'fresh': '2'});
    });

    test('同名 Cookie 取值优先最新一条', () {
      final jar = EhCookieJar([
        const JarCookie(
          name: 'a',
          value: '1',
          domain: 'e-hentai.org',
          hostOnly: false,
        ),
        const JarCookie(
          name: 'a',
          value: '2',
          domain: 'e-hentai.org',
          hostOnly: false,
        ),
      ]);

      expect(jar.valueOf('a', 'e-hentai.org'), '2');
      expect('a='.allMatches(jar.headerFor('e-hentai.org')).length, 1);
    });
  });
}
