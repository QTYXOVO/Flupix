import 'package:flutter/material.dart';

import '../../core/eh/eh_tags.dart';
import '../../l10n/l10n.dart';
import '../../widgets/ui_kit.dart';

/// 本地标签检索：从浏览过的图库收集标签，支持翻译显示与导入翻译库。
class EhTagSearchPage extends StatefulWidget {
  const EhTagSearchPage({super.key});

  @override
  State<EhTagSearchPage> createState() => _EhTagSearchPageState();
}

class _EhTagSearchPageState extends State<EhTagSearchPage> {
  final _searchController = TextEditingController();
  final _importController = TextEditingController();
  List<EhTagEntry> _entries = const [];
  Map<String, String> _translations = const {};
  bool _loading = true;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _importController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final entries = await EhTagStore.loadHistory();
    final translations = await EhTagStore.loadTranslations();
    if (!mounted) return;
    setState(() {
      _entries = entries;
      _translations = translations;
      _loading = false;
    });
  }

  List<EhTagEntry> get _filtered {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return _entries;
    return _entries.where((entry) {
      final translation = ehTagDisplay(
        entry.namespace,
        entry.tag,
        _translations,
      ).toLowerCase();
      return entry.tag.toLowerCase().contains(query) ||
          translation.contains(query) ||
          entry.namespace.toLowerCase().contains(query) ||
          ehTagNamespaceLabel(entry.namespace).contains(query);
    }).toList();
  }

  Future<void> _select(EhTagEntry entry) async {
    await EhTagStore.recordEntry(
      EhTagEntry(
        namespace: entry.namespace,
        tag: entry.tag,
        lastUsed: DateTime.now(),
      ),
    );
    if (!mounted) return;
    Navigator.of(context).pop(ehTagQuery(entry.namespace, entry.tag));
  }

  Future<void> _importTranslations() async {
    _importController.clear();
    final l10n = context.l10n;
    final raw = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.ehTagImportTitle),
          content: SizedBox(
            width: 480,
            child: TextField(
              controller: _importController,
              maxLines: 8,
              minLines: 6,
              style: Theme.of(context).textTheme.bodySmall,
              decoration: const InputDecoration(
                hintText:
                    '{"artist:someone": "某画师"}\n'
                    '或 {"language": {"chinese": "中文"}}',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.commonCancel),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(context).pop(_importController.text),
              child: Text(l10n.ehTagImportAction),
            ),
          ],
        );
      },
    );
    if (raw == null || raw.trim().isEmpty) return;
    try {
      final count = await EhTagStore.importTranslations(raw);
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.ehTagImported(count))));
    } on FormatException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(l10n.ehTagImportFailed(error.message))),
        );
    }
  }

  Future<void> _clearHistory() async {
    final l10n = context.l10n;
    final confirmed = await _confirm(
      l10n.ehTagClearHistoryTitle,
      l10n.ehTagClearHistoryMessage,
    );
    if (!confirmed) return;
    await EhTagStore.clearHistory();
    await _load();
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l10n.ehTagHistoryCleared)));
  }

  Future<void> _clearTranslations() async {
    final l10n = context.l10n;
    final confirmed = await _confirm(
      l10n.ehTagClearTranslationsTitle,
      l10n.ehTagClearTranslationsMessage,
    );
    if (!confirmed) return;
    await EhTagStore.clearTranslations();
    await _load();
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l10n.ehTagTranslationsCleared)));
  }

  Future<bool> _confirm(String title, String message) async {
    final l10n = context.l10n;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.commonConfirm),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ToolPage(
      title: l10n.ehTagTitle,
      subtitle: l10n.ehTagLocalCount(_entries.length),
      actions: [
        IconButton(
          tooltip: l10n.ehTagImportTooltip,
          onPressed: _importTranslations,
          icon: const Icon(Icons.translate),
        ),
        PopupMenuButton<String>(
          tooltip: l10n.commonMore,
          onSelected: (value) {
            if (value == 'history') _clearHistory();
            if (value == 'translations') _clearTranslations();
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'history',
              child: Text(l10n.ehTagClearHistoryTitle),
            ),
            PopupMenuItem(
              value: 'translations',
              child: Text(l10n.ehTagClearTranslationsTitle),
            ),
          ],
        ),
      ],
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                hintText: l10n.ehTagSearchHint,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        tooltip: l10n.commonClear,
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                        icon: const Icon(Icons.close),
                      ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerLow,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    final entries = _filtered;
    if (entries.isEmpty) return _buildEmpty();

    final groups = <String, List<EhTagEntry>>{};
    for (final entry in entries) {
      groups.putIfAbsent(entry.namespace, () => []).add(entry);
    }
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final children = <Widget>[];
    for (final group in groups.entries) {
      children.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
          child: Row(
            children: [
              Text(
                ehTagNamespaceLabel(group.key),
                style: textTheme.labelLarge?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                group.key,
                style: textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
      for (final entry in group.value) {
        final display = ehTagDisplay(entry.namespace, entry.tag, _translations);
        children.add(
          ListTile(
            dense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            title: Text(display),
            subtitle: display == entry.tag ? null : Text(entry.tag),
            trailing: const Icon(Icons.arrow_forward, size: 18),
            onTap: () => _select(entry),
          ),
        );
      }
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: children,
    );
  }

  Widget _buildEmpty() {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final searching = _query.trim().isNotEmpty;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              searching ? Icons.search_off : Icons.sell_outlined,
              size: 42,
              color: scheme.outline,
            ),
            const SizedBox(height: 12),
            Text(
              searching ? l10n.ehTagNoMatch : l10n.ehTagNoRecords,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 6),
            Text(
              searching ? l10n.ehTagNoMatchHint : l10n.ehTagNoRecordsHint,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
            if (!searching) ...[
              const SizedBox(height: 16),
              FilledButton.tonal(
                onPressed: _importTranslations,
                child: Text(l10n.ehTagImportLibrary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
