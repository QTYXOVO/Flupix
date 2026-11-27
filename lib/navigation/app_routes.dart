import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../core/app_settings.dart';
import '../core/eh/eh_download.dart';
import '../core/eh/eh_models.dart';
import '../core/eh/eh_repository.dart';
import '../core/eh/eh_session.dart';
import '../screens/settings_page.dart';
import '../tools/eh/eh_browse_page.dart';
import '../tools/eh/eh_detail_page.dart';
import '../tools/eh/eh_download_page.dart';
import '../tools/eh/eh_library_page.dart';
import '../tools/eh/eh_login_page.dart';
import '../tools/eh/eh_reader_page.dart';
import '../tools/eh/eh_tag_search_page.dart';
import '../tools/pixiv_login_page.dart';
import '../tools/puzzle/puzzle_crop_page.dart';

/// 应用内的页面跳转表。
///
/// 所有页面跳转集中在此声明，保留各页面原有的泛型返回值；
/// 页面代码只描述「去哪里」，不关心 Route 的构造细节。
abstract final class AppRoutes {
  /// 工具页：由调用方提供的 builder 现成构建。
  static Route<void> tool(WidgetBuilder builder) {
    return MaterialPageRoute<void>(builder: builder);
  }

  static Route<void> settings(AppSettings settings) {
    return MaterialPageRoute<void>(
      builder: (_) => SettingsPage(settings: settings),
    );
  }

  static Route<String> pixivOAuth(String challenge) {
    return MaterialPageRoute<String>(
      builder: (_) => PixivOAuthPage(challenge: challenge),
    );
  }

  static Route<String> pixivCookie() {
    return MaterialPageRoute<String>(builder: (_) => const PixivCookiePage());
  }

  static Route<bool> ehLogin(EhSession session) {
    return MaterialPageRoute<bool>(
      builder: (_) => EhLoginPage(session: session),
    );
  }

  static Route<String> ehTagSearch() {
    return MaterialPageRoute<String>(builder: (_) => const EhTagSearchPage());
  }

  static Route<void> ehBrowse({String? initialKeyword}) {
    return MaterialPageRoute<void>(
      builder: (_) => EhBrowsePage(initialKeyword: initialKeyword ?? ''),
    );
  }

  static Route<void> ehLibrary({
    required EhSession session,
    required EhRepository repository,
    EhDownloadManager? downloadManager,
  }) {
    return MaterialPageRoute<void>(
      builder: (_) => EhLibraryPage(
        session: session,
        repository: repository,
        downloadManager: downloadManager,
      ),
    );
  }

  static Route<void> ehDownloads({
    required EhSession session,
    required EhDownloadManager manager,
  }) {
    return MaterialPageRoute<void>(
      builder: (_) => EhDownloadPage(session: session, manager: manager),
    );
  }

  static Route<void> ehDetail({
    required EhSession session,
    required EhRepository repository,
    required GalleryItem item,
    EhDownloadManager? downloadManager,
  }) {
    return MaterialPageRoute<void>(
      builder: (_) => EhDetailPage(
        session: session,
        repository: repository,
        item: item,
        downloadManager: downloadManager,
      ),
    );
  }

  static Route<void> ehReader({
    required EhRepository repository,
    required GalleryItem item,
    required GalleryDetail detail,
    required int totalPages,
    required int initialIndex,
    String? Function(int index)? localPagePath,
  }) {
    return MaterialPageRoute<void>(
      builder: (_) => EhReaderPage(
        repository: repository,
        item: item,
        detail: detail,
        totalPages: totalPages,
        initialIndex: initialIndex,
        localPagePath: localPagePath,
      ),
    );
  }

  static Route<Rect> puzzleCrop({
    required ui.Image image,
    required String sourceName,
  }) {
    return MaterialPageRoute<Rect>(
      builder: (_) => PuzzleCropPage(image: image, sourceName: sourceName),
    );
  }
}
