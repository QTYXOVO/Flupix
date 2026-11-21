import 'package:flupix/core/eh/eh_download.dart';
import 'package:flupix/core/eh/eh_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const item = GalleryItem(
    gid: 1001,
    token: 'abcdef1234',
    title: 'Download Test',
    thumbUrl: 'https://ehgt.org/t/1.jpg',
    category: 'Doujinshi',
    rating: 4.5,
    pages: 12,
    uploader: 'someone',
  );

  group('EhDownload', () {
    test('进度按已下载页数计算', () {
      final download = EhDownload(
        item: item,
        totalPages: 12,
        done: {0, 1, 2},
      );

      expect(download.downloaded, 3);
      expect(download.progress, closeTo(0.25, 1e-9));
      expect(download.isCompleted, isFalse);
    });

    test('页数为 0 时进度为 0', () {
      final download = EhDownload(item: item, totalPages: 0);

      expect(download.progress, 0);
    });

    test('序列化后可还原全部字段', () {
      final download = EhDownload(
        item: item,
        totalPages: 12,
        done: {5, 0, 3},
        status: EhDownloadStatus.paused,
        error: '已暂停',
        updatedAt: DateTime.fromMillisecondsSinceEpoch(1700000000000),
      );

      final restored = EhDownload.fromJson(download.toJson());

      expect(restored, isNotNull);
      expect(restored!.gid, 1001);
      expect(restored.item.token, 'abcdef1234');
      expect(restored.item.title, 'Download Test');
      expect(restored.item.category, 'Doujinshi');
      expect(restored.item.rating, 4.5);
      expect(restored.item.pages, 12);
      expect(restored.item.uploader, 'someone');
      expect(restored.totalPages, 12);
      expect(restored.done, {0, 3, 5});
      expect(restored.status, EhDownloadStatus.paused);
      expect(restored.error, '已暂停');
      expect(restored.updatedAt.millisecondsSinceEpoch, 1700000000000);
    });

    test('下载中状态恢复为暂停，避免重启后卡住', () {
      final raw = {
        'gid': 1001,
        'token': 'abcdef1234',
        'title': 'Download Test',
        'total': 12,
        'done': [0, 1],
        'status': 'downloading',
      };

      final restored = EhDownload.fromJson(raw);

      expect(restored!.status, EhDownloadStatus.paused);
      expect(restored.done, {0, 1});
    });

    test('已完成页数达到总页数时标记为完成', () {
      final raw = {
        'gid': 1001,
        'token': 'abcdef1234',
        'title': 'Download Test',
        'total': 3,
        'done': [0, 1, 2],
        'status': 'paused',
      };

      final restored = EhDownload.fromJson(raw);

      expect(restored!.status, EhDownloadStatus.completed);
      expect(restored.isCompleted, isTrue);
    });

    test('缺少必要字段时返回 null', () {
      expect(EhDownload.fromJson({'gid': 1001}), isNull);
      expect(EhDownload.fromJson('broken'), isNull);
    });
  });
}
