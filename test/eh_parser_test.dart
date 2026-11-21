import 'package:flupix/core/eh/eh_exceptions.dart';
import 'package:flupix/core/eh/eh_library.dart';
import 'package:flupix/core/eh/eh_models.dart';
import 'package:flupix/core/eh/eh_parser.dart';
import 'package:flupix/core/eh/eh_repository.dart';
import 'package:flupix/core/eh/eh_tags.dart';
import 'package:flupix/core/eh/eh_url.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('parseGalleryList', () {
    test('解析条目、分类、评分与分页', () {
      const html = '''
        <table class="itg">
          <tbody>
            <tr><td>header</td></tr>
            <tr>
              <td class="gl2c">
                <a href="/g/123/abcdef1234/">
                  <img data-src="//ehgt.org/t/1.jpg" src="https://ehgt.org/placeholder.gif">
                </a>
              </td>
              <td class="gl3c">
                <div class="gl1t">
                  <div class="glname"><a class="glink" href="/g/123/abcdef1234/">Test Gallery</a></div>
                </div>
                <div class="cn">Doujinshi</div>
                <div class="ir" title="Rating: 4.5">4.5</div>
                <div class="glhide">
                  <div><a href="/uploader/someone">someone</a></div>
                  <div>12 pages</div>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
        <table class="ptt">
          <tbody><tr>
            <td><a href="?page=0">1</a></td>
            <td><a href="?page=1">2</a></td>
            <td><a href="?page=1">&gt;</a></td>
          </tr></tbody>
        </table>
      ''';

      final result = parseGalleryList(html, baseUrl: 'https://e-hentai.org');

      expect(result.items, hasLength(1));
      final item = result.items.first;
      expect(item.gid, 123);
      expect(item.token, 'abcdef1234');
      expect(item.title, 'Test Gallery');
      expect(item.thumbUrl, 'https://ehgt.org/t/1.jpg');
      expect(item.category, 'Doujinshi');
      expect(item.rating, 4.5);
      expect(item.pages, 12);
      expect(item.uploader, 'someone');
      expect(result.pages, 2);
      expect(result.nextPage, 1);
    });

    test('无结果时返回空列表', () {
      const html = '<html><body>No hits found</body></html>';
      final result = parseGalleryList(html, baseUrl: 'https://e-hentai.org');
      expect(result.items, isEmpty);
      expect(result.nextPage, -1);
    });

    test('Sad Panda 页面抛出登录异常', () {
      const html =
          '<html><body><img src="/img/sadpanda.png" alt="Sad Panda"></body></html>';
      expect(
        () => parseGalleryList(html, baseUrl: 'https://exhentai.org'),
        throwsA(isA<EhAuthRequired>()),
      );
    });

    test('IP 临时封禁页面抛出网络异常', () {
      const html =
          '<html><body>This IP address has been temporarily banned due to '
          'an excessive request rate. The ban expires in 3 hours and 55 '
          'minutes.</body></html>';
      expect(
        () => parseGalleryList(html, baseUrl: 'https://e-hentai.org'),
        throwsA(isA<EhNetworkException>()),
      );
    });

    test('解析 next 游标分页与结果总数', () {
      const html = '''
        <div class="searchtext"><p>Found about 3,308 results. </p></div>
        <a id="unext" href="https://e-hentai.org/?f_search=test&amp;next=4299842">Next &gt;</a>
      ''';
      final result = parseGalleryList(html, baseUrl: 'https://e-hentai.org');
      expect(result.nextCursor, '4299842');
      expect(result.totalResults, 3308);
    });
  });

  group('parseGalleryDetail', () {
    test('解析标题、标签、页数与预览 pToken', () {
      const html = '''
        <div id="gn">Test Gallery</div>
        <div id="gj">テストギャラリー</div>
        <div id="gdc"><div class="cn">Manga</div></div>
        <div id="gdn">Uploader: <a href="/uploader/someone">someone</a></div>
        <div id="gdd">Length: 42 pages</div>
        <div id="rating_label">Rating: 4.75</div>
        <div id="rating_count">(123)</div>
        <table id="taglist">
          <tr>
            <td class="tc">artist:</td>
            <td>
              <div class="gt"><a href="/tag/abc">foo</a></div>
              <div class="gt"><a href="/tag/def">bar ?</a></div>
            </td>
          </tr>
        </table>
        <div id="gdt">
          <div class="gdtm"><a href="https://e-hentai.org/s/ptok1/123-1"><img src="//ehgt.org/p1.jpg" alt="1"></a></div>
          <div class="gdtm"><a href="/s/ptok2/123-2"><img data-src="//ehgt.org/p2.jpg" alt="2"></a></div>
        </div>
      ''';

      final detail = parseGalleryDetail(
        html,
        item: const GalleryItem(
          gid: 123,
          token: 'abcdef1234',
          title: 'Fallback',
          thumbUrl: 'https://ehgt.org/t.jpg',
        ),
        baseUrl: 'https://e-hentai.org',
      );

      expect(detail.title, 'Test Gallery');
      expect(detail.titleJpn, 'テストギャラリー');
      expect(detail.category, 'Manga');
      expect(detail.uploader, 'someone');
      expect(detail.pages, 42);
      expect(detail.rating, 4.75);
      expect(detail.ratingCount, 123);
      expect(detail.tags['artist'], ['foo', 'bar']);
      expect(detail.previews, hasLength(2));
      expect(detail.previews.first.index, 0);
      expect(detail.previews.first.pToken, 'ptok1');
      expect(detail.previews[1].index, 1);
      expect(detail.previews[1].pToken, 'ptok2');
      expect(detail.previews[1].thumbUrl, 'https://ehgt.org/p2.jpg');
    });

    test('解析雪碧图预览的偏移与尺寸', () {
      const html = '''
        <div id="gn">Sprite Gallery</div>
        <div id="gdd">Length: 3 pages</div>
        <div id="gdt">
          <a href="https://e-hentai.org/s/tok1/1-1">
            <div title="Page 1: 001.jpg" style="width:200px;height:291px;background:transparent url(https://hath.network/1.webp) -0px 0 no-repeat"></div>
          </a>
          <a href="https://e-hentai.org/s/tok2/1-2">
            <div title="Page 2: 002.jpg" style="width:200px;height:291px;background:transparent url(https://hath.network/1.webp) -200px 0 no-repeat"></div>
          </a>
        </div>
      ''';
      final detail = parseGalleryDetail(
        html,
        item: const GalleryItem(
          gid: 1,
          token: 'tok',
          title: 'Fallback',
          thumbUrl: '',
        ),
        baseUrl: 'https://e-hentai.org',
      );
      expect(detail.previews, hasLength(2));
      expect(detail.previews.first.isSprite, isTrue);
      expect(detail.previews.first.thumbOffsetX, 0);
      expect(detail.previews[1].thumbOffsetX, 200);
      expect(detail.previews[1].thumbWidth, 200);
      expect(detail.previews[1].thumbHeight, 291);
      expect(detail.previews[1].thumbUrl, 'https://hath.network/1.webp');
    });
  });

  group('parseGdataItem', () {
    test('兼容字符串形式的 filecount 与 rating', () {
      final item = parseGdataItem({
        'gid': 1,
        'token': 'abc',
        'title': 'Title',
        'thumb': '//ehgt.org/t.jpg',
        'category': 'Manga',
        'rating': '4.44',
        'filecount': '26',
        'uploader': 'someone',
      });
      expect(item, isNotNull);
      expect(item!.gid, 1);
      expect(item.rating, 4.44);
      expect(item.pages, 26);
      expect(item.uploader, 'someone');
      expect(item.thumbUrl, 'https://ehgt.org/t.jpg');
    });
  });

  group('parseImagePage', () {
    test('解析图片地址、showkey、skipHath 与相邻页', () {
      const html = '''
        <img id="img" src="https://img.ehgt.org/page-3.jpg" style="height:1000px">
        <script>var showkey="abc123";</script>
        <a id="next" href="/s/nexttoken/123-4">Next</a>
        <a id="prev" href="/s/prevtoken/123-2">Prev</a>
        <a href="#" onclick="return nl('skipkey')">Download original</a>
      ''';

      final page = parseImagePage(html);
      expect(page.imageUrl, 'https://img.ehgt.org/page-3.jpg');
      expect(page.showKey, 'abc123');
      expect(page.skipHathKey, 'skipkey');
      expect(page.nextIndex, 3);
      expect(page.prevIndex, 1);
    });
  });

  group('EhCookie', () {
    test('解析分号分隔的 Cookie', () {
      final cookie = EhCookie.parse(
        'Cookie: ipb_member_id=1; ipb_pass_hash=abc; sk=xyz; igneous=ex',
      );
      expect(cookie.memberId, '1');
      expect(cookie.passHash, 'abc');
      expect(cookie.hasExAccess, isTrue);
      expect(cookie.headerValue, contains('ipb_member_id=1'));
    });

    test('解析换行分隔的 Cookie，并忽略空值', () {
      final cookie = EhCookie.parse('''
        ipb_member_id=2
        ipb_pass_hash=def
        sk=
      ''');
      expect(cookie.memberId, '2');
      expect(cookie.isLoggedIn, isTrue);
      expect(cookie.values.containsKey('sk'), isFalse);
    });

    test('解析冒号分隔的换行 Cookie', () {
      final cookie = EhCookie.parse('''
        ipb_member_id: 3
        ipb_pass_hash: ghi
        igneous: ex
      ''');
      expect(cookie.memberId, '3');
      expect(cookie.passHash, 'ghi');
      expect(cookie.hasExAccess, isTrue);
    });

    test('合并 Cookie 时后者覆盖同名键', () {
      final cookie = const EhCookie({'a': '1', 'b': '2'})
          .merge(const EhCookie({'b': '3', 'c': '4'}));
      expect(cookie.values, {'a': '1', 'b': '3', 'c': '4'});
      expect(cookie.hasExAccess, isFalse);
    });
  });

  group('EhUrls', () {
    test('搜索、页码与分类屏蔽位写入查询参数', () {
      final url = const EhUrls(EhSite.e).list(
        page: 2,
        keyword: 'test tag',
        excludedCategories: 6,
      );
      expect(url.host, 'e-hentai.org');
      expect(url.queryParameters['f_search'], 'test tag');
      expect(url.queryParameters['page'], '2');
      expect(url.queryParameters['f_cats'], '6');
    });

    test('游标分页优先于页码', () {
      final url = const EhUrls(EhSite.e).list(
        page: 3,
        next: '4299842',
        keyword: 'test',
      );
      expect(url.queryParameters['next'], '4299842');
      expect(url.queryParameters.containsKey('page'), isFalse);
    });

    test('首页不生成多余参数', () {
      final url = const EhUrls(EhSite.ex).list();
      expect(url.toString(), 'https://exhentai.org/');
    });

    test('详情第二组预览与图片页编号', () {
      const urls = EhUrls(EhSite.e);
      expect(
        urls.detail(123, 'tok', previewPage: 2).toString(),
        'https://e-hentai.org/g/123/tok/?p=2',
      );
      expect(urls.detail(123, 'tok').toString(), 'https://e-hentai.org/g/123/tok/');
      expect(
        urls.imagePage('ptok', 123, 0).toString(),
        'https://e-hentai.org/s/ptok/123-1',
      );
    });
  });

  group('parseImagePage API 片段', () {
    test('解析 i3 与 i6 拼接后的片段', () {
      const fragments =
          '<div id="i3"><img id="img" src="https://img.ehgt.org/api-1.jpg"></div>'
          '<div id="i6"><a href="#" onclick="return nl(\'skip-abc\')">Original</a></div>';
      final page = parseImagePage(fragments);
      expect(page.imageUrl, 'https://img.ehgt.org/api-1.jpg');
      expect(page.skipHathKey, 'skip-abc');
      expect(page.showKey, isNull);
    });
  });

  group('ehTagQuery', () {
    test('生成精确匹配搜索词', () {
      expect(ehTagQuery('artist', 'foo'), r'artist:foo$');
    });

    test('带空格的值加引号', () {
      expect(ehTagQuery('female', 'sole female'), r'female:"sole female$"');
    });

    test('空命名空间只返回标签', () {
      expect(ehTagQuery('', 'full color'), r'"full color$"');
    });
  });

  group('ehTagDisplay', () {
    test('导入翻译优先于内置翻译', () {
      expect(ehTagDisplay('language', 'Chinese', const {}), '中文');
      expect(
        ehTagDisplay('language', 'chinese', const {
          'language:chinese': '汉语',
        }),
        '汉语',
      );
    });
  });

  group('EhTagStore', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('导入扁平与嵌套格式的翻译', () async {
      final count = await EhTagStore.importTranslations(
        '{"artist:someone": "某画师", "language": {"chinese": "汉语"}}',
      );
      expect(count, 2);
      final translations = await EhTagStore.loadTranslations();
      expect(translations['artist:someone'], '某画师');
      expect(translations['language:chinese'], '汉语');
    });

    test('没有有效条目时抛出格式错误', () async {
      await expectLater(
        EhTagStore.importTranslations('{"invalid": "value"}'),
        throwsFormatException,
      );
    });

    test('记录与去重标签历史', () async {
      await EhTagStore.record({
        'artist': ['foo'],
        'language': ['chinese'],
      });
      var history = await EhTagStore.loadHistory();
      expect(history, hasLength(2));
      expect(history.map((entry) => entry.tag), containsAll(['foo', 'chinese']));

      await EhTagStore.record({
        'artist': ['foo'],
      });
      history = await EhTagStore.loadHistory();
      expect(history, hasLength(2));
    });
  });

  test('igneous 为 mystery 时视为没有 ExHentai 权限', () {
    const cookie = EhCookie({
      'ipb_member_id': '1',
      'ipb_pass_hash': 'hash',
      'igneous': 'mystery',
    });
    expect(cookie.isLoggedIn, isTrue);
    expect(cookie.hasExAccess, isFalse);
    expect(cookie.igneous, 'mystery');
  });

  group('EhFavoriteStore', () {    setUp(() => SharedPreferences.setMockInitialValues({}));

    const item = GalleryItem(
      gid: 7,
      token: 'token7',
      title: 'Test Gallery',
      thumbUrl: 'https://ehgt.org/t.jpg',
      category: 'Manga',
      rating: 4.5,
      pages: 12,
    );

    test('收藏、还原字段与取消', () async {
      expect(await EhFavoriteStore.contains(7), isFalse);
      expect(await EhFavoriteStore.toggle(item), isTrue);
      expect(await EhFavoriteStore.contains(7), isTrue);

      final loaded = (await EhFavoriteStore.load()).single;
      expect(loaded.title, 'Test Gallery');
      expect(loaded.category, 'Manga');
      expect(loaded.rating, 4.5);
      expect(loaded.pages, 12);

      expect(await EhFavoriteStore.toggle(item), isFalse);
      expect(await EhFavoriteStore.load(), isEmpty);
    });
  });

  group('EhProgressStore', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('汇总阅读进度并按最近阅读倒序', () async {
      const first = GalleryItem(
        gid: 1,
        token: 'a',
        title: 'First',
        thumbUrl: '',
      );
      const second = GalleryItem(
        gid: 2,
        token: 'b',
        title: 'Second',
        thumbUrl: '',
      );
      await EhProgressStore.save(item: first, lastPage: 3, totalPages: 10);
      await Future<void>.delayed(const Duration(milliseconds: 5));
      await EhProgressStore.save(item: second, lastPage: 1, totalPages: 5);

      final all = await EhProgressStore.loadAll();
      expect(all, hasLength(2));
      expect(all.first.gid, 2);
      expect(all.first.lastPage, 1);
      expect(all.last.gid, 1);
    });
  });
}
