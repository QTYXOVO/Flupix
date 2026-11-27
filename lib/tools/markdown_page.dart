import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/platform_capabilities.dart';
import '../l10n/l10n.dart';
import '../widgets/ui_kit.dart';

class MarkdownPage extends StatefulWidget {
  const MarkdownPage({super.key});

  @override
  State<MarkdownPage> createState() => _MarkdownPageState();
}

class _MarkdownPageState extends State<MarkdownPage> {
  static const String _draftKey = 'markdown_draft';

  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _saveTimer;
  bool _previewOnly = false;
  String? _fileName;

  @override
  void initState() {
    super.initState();
    _restoreDraft();
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    final pending = _controller.text;
    if (pending.trim().isNotEmpty) {
      unawaited(
        SharedPreferences.getInstance().then(
          (prefs) => prefs.setString(_draftKey, pending),
        ),
      );
    }
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _restoreDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final draft = prefs.getString(_draftKey);
    if (!mounted || draft == null || draft.isEmpty) return;
    _controller.text = draft;
    setState(() {});
  }

  void _onTextChanged() {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 600), _saveDraft);
    setState(() {});
  }

  Future<void> _saveDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final text = _controller.text;
    if (text.isEmpty) {
      await prefs.remove(_draftKey);
    } else {
      await prefs.setString(_draftKey, text);
    }
  }

  void _applyEdit(TextEditingValue value) {
    _controller.value = value;
    _focusNode.requestFocus();
    _onTextChanged();
  }

  /// 用标记包裹选区，未选中时插入占位文字并选中它。
  void _wrapSelection(String before, String after, String placeholder) {
    final text = _controller.text;
    var selection = _controller.selection;
    if (!selection.isValid) {
      selection = TextSelection.collapsed(offset: text.length);
    }
    final selected = selection.textInside(text);
    final content = selected.isEmpty ? placeholder : selected;
    final newText = text.replaceRange(
      selection.start,
      selection.end,
      '$before$content$after',
    );
    final start = selection.start + before.length;
    _applyEdit(
      TextEditingValue(
        text: newText,
        selection: TextSelection(
          baseOffset: start,
          extentOffset: start + content.length,
        ),
      ),
    );
  }

  /// 给选中行批量加/去前缀。
  void _toggleLinePrefix(String prefix) {
    final text = _controller.text;
    var selection = _controller.selection;
    if (!selection.isValid) {
      selection = TextSelection.collapsed(offset: text.length);
    }

    final lineStart = text.lastIndexOf('\n', selection.start - 1) + 1;
    var lineEnd = text.indexOf('\n', selection.end);
    if (lineEnd == -1) lineEnd = text.length;

    final lines = text.substring(lineStart, lineEnd).split('\n');
    final allPrefixed = lines.every(
      (line) => line.isEmpty || line.startsWith(prefix),
    );
    final updated = lines
        .map((line) {
          if (line.isEmpty) return line;
          if (allPrefixed) return line.substring(prefix.length);
          return '$prefix$line';
        })
        .join('\n');

    final newText = text.replaceRange(lineStart, lineEnd, updated);
    final caret = lineStart + updated.length;
    _applyEdit(
      TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(
          offset: caret > newText.length ? newText.length : caret,
        ),
      ),
    );
  }

  /// 在光标处插入独立块，自动补齐前后换行。
  void _insertBlock(String block, {int caretFromEnd = 0}) {
    final text = _controller.text;
    var selection = _controller.selection;
    if (!selection.isValid) {
      selection = TextSelection.collapsed(offset: text.length);
    }
    final offset = selection.start;
    final needsLeading = offset > 0 && text[offset - 1] != '\n';
    final needsTrailing =
        offset < text.length && text[offset] != '\n' && !block.endsWith('\n');
    final insert =
        '${needsLeading ? '\n' : ''}$block${needsTrailing ? '\n' : ''}';
    final newText = text.replaceRange(offset, offset, insert);
    final caret = (offset + insert.length - caretFromEnd)
        .clamp(0, newText.length)
        .toInt();
    _applyEdit(
      TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: caret),
      ),
    );
  }

  void _insertCodeBlock() {
    _insertBlock('```\n\n```', caretFromEnd: 4);
  }

  void _insertTable() {
    _insertBlock(context.l10n.markdownTableTemplate);
  }

  Future<void> _confirmClear() async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.markdownClearTitle),
        content: Text(l10n.markdownClearMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.commonClear),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    _controller.clear();
    _fileName = null;
    _onTextChanged();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_draftKey);
  }

  void _copyLink(String? href) {
    if (href == null || href.isEmpty) return;
    copyText(context, href, message: context.l10n.markdownLinkCopied);
  }

  void _notify(String message, {bool error = false}) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: error
            ? Theme.of(context).colorScheme.errorContainer
            : null,
      ),
    );
  }

  Future<void> _openFile() async {
    try {
      final file = await FilePicker.pickFile(
        dialogTitle: context.l10n.markdownOpenDialogTitle,
        type: FileType.custom,
        allowedExtensions: const ['md', 'markdown', 'txt'],
      );
      if (file == null) return;
      final content = utf8.decode(
        await file.readAsBytes(),
        allowMalformed: true,
      );
      if (!mounted) return;
      _saveTimer?.cancel();
      _controller.value = TextEditingValue(
        text: content,
        selection: const TextSelection.collapsed(offset: 0),
      );
      setState(() {
        _fileName = file.name;
        _previewOnly = false;
      });
      await _saveDraft();
      if (!mounted) return;
      _notify(context.l10n.markdownOpened(file.name));
    } catch (error) {
      if (!mounted) return;
      _notify(context.l10n.markdownOpenFailed('$error'), error: true);
    }
  }

  Future<void> _exportFile() async {
    final text = _controller.text;
    final base = _fileName ?? context.l10n.markdownUntitledFileName;
    final target = base.toLowerCase().endsWith('.md') ? base : '$base.md';
    try {
      final uri = await FilePicker.saveFile(
        fileName: target,
        bytes: Uint8List.fromList(utf8.encode(text)),
        mimeType: 'text/markdown',
        dialogTitle: context.l10n.markdownExportDialogTitle,
      );
      if (uri == null || !mounted) return;
      // 桌面端返回文件路径，可取得实际另存的文件名；移动端返回 content:// 标识，沿用默认名。
      final segments = uri.pathSegments;
      final savedName = AppCapabilities.isDesktop && segments.isNotEmpty
          ? Uri.decodeComponent(segments.last)
          : target;
      setState(() => _fileName = savedName);
      _notify(context.l10n.markdownExported(savedName));
    } catch (error) {
      if (!mounted) return;
      _notify(context.l10n.markdownExportFailed('$error'), error: true);
    }
  }

  MarkdownStyleSheet _styleSheet(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    return MarkdownStyleSheet.fromTheme(theme).copyWith(
      p: textTheme.bodyMedium?.copyWith(height: 1.7),
      h1: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
      h2: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      h3: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      a: TextStyle(
        color: scheme.primary,
        decoration: TextDecoration.underline,
        decorationColor: scheme.primary,
      ),
      code: textTheme.bodySmall?.copyWith(
        fontFamily: 'monospace',
        backgroundColor: scheme.surfaceContainerHighest,
      ),
      codeblockDecoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      blockquoteDecoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      blockquotePadding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      horizontalRuleDecoration: BoxDecoration(
        border: Border(top: BorderSide(color: scheme.outlineVariant)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final text = _controller.text;
    final lineCount = text.isEmpty ? 0 : '\n'.allMatches(text).length + 1;

    return ToolPage(
      title: l10n.markdownTitle,
      subtitle: l10n.markdownSubtitle,
      actions: [
        IconButton(
          tooltip: l10n.markdownOpenFileTooltip,
          onPressed: _openFile,
          icon: const Icon(Icons.folder_open_outlined),
        ),
        IconButton(
          tooltip: l10n.markdownExportTooltip,
          onPressed: text.isEmpty ? null : _exportFile,
          icon: const Icon(Icons.save_alt_outlined),
        ),
      ],
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 900;
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Column(
              children: [
                Row(
                  children: [
                    if (!wide)
                      SegmentedButton<bool>(
                        segments: [
                          ButtonSegment(
                            value: false,
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            label: Text(l10n.commonEdit),
                          ),
                          ButtonSegment(
                            value: true,
                            icon: const Icon(
                              Icons.visibility_outlined,
                              size: 18,
                            ),
                            label: Text(l10n.commonPreview),
                          ),
                        ],
                        selected: {_previewOnly},
                        showSelectedIcon: false,
                        onSelectionChanged: (selection) =>
                            setState(() => _previewOnly = selection.first),
                      ),
                    const Spacer(),
                    Text(
                      l10n.markdownStats(lineCount, text.length),
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: wide
                      ? Row(
                          children: [
                            Expanded(child: _buildEditor(context)),
                            const SizedBox(width: 16),
                            Expanded(child: _buildPreview(context)),
                          ],
                        )
                      : _previewOnly
                      ? _buildPreview(context)
                      : _buildEditor(context),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEditor(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return SectionCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 6, 6, 2),
            child: Wrap(
              children: [
                _toolButton(
                  Icons.title,
                  l10n.markdownHeading1,
                  () => _toggleLinePrefix('# '),
                ),
                _toolButton(
                  Icons.text_fields,
                  l10n.markdownHeading2,
                  () => _toggleLinePrefix('## '),
                ),
                _toolButton(
                  Icons.format_bold,
                  l10n.markdownBold,
                  () => _wrapSelection('**', '**', l10n.markdownBold),
                ),
                _toolButton(
                  Icons.format_italic,
                  l10n.markdownItalic,
                  () => _wrapSelection('*', '*', l10n.markdownItalic),
                ),
                _toolButton(
                  Icons.code,
                  l10n.markdownInlineCode,
                  () => _wrapSelection('`', '`', 'code'),
                ),
                _toolButton(
                  Icons.format_list_bulleted,
                  l10n.markdownBulletList,
                  () => _toggleLinePrefix('- '),
                ),
                _toolButton(
                  Icons.format_list_numbered,
                  l10n.markdownOrderedList,
                  () => _toggleLinePrefix('1. '),
                ),
                _toolButton(
                  Icons.check_box_outlined,
                  l10n.markdownTaskList,
                  () => _toggleLinePrefix('- [ ] '),
                ),
                _toolButton(
                  Icons.format_quote,
                  l10n.markdownQuote,
                  () => _toggleLinePrefix('> '),
                ),
                _toolButton(
                  Icons.link,
                  l10n.markdownLink,
                  () => _wrapSelection(
                    '[',
                    '](https://)',
                    l10n.markdownLinkPlaceholder,
                  ),
                ),
                _toolButton(
                  Icons.data_array,
                  l10n.markdownCodeBlock,
                  _insertCodeBlock,
                ),
                _toolButton(
                  Icons.table_chart_outlined,
                  l10n.markdownTable,
                  _insertTable,
                ),
                _toolButton(
                  Icons.horizontal_rule,
                  l10n.markdownDivider,
                  () => _insertBlock('---'),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: scheme.outlineVariant.withValues(alpha: 0.4),
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              expands: true,
              maxLines: null,
              minLines: null,
              textAlignVertical: TextAlignVertical.top,
              keyboardType: TextInputType.multiline,
              style: textTheme.bodyMedium?.copyWith(
                fontFamily: 'monospace',
                height: 1.7,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: l10n.markdownEditorHint,
                contentPadding: const EdgeInsets.all(16),
              ),
              onChanged: (_) => _onTextChanged(),
            ),
          ),
          Divider(
            height: 1,
            color: scheme.outlineVariant.withValues(alpha: 0.4),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 2, 6, 2),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _fileName == null
                        ? l10n.markdownDraftSavedLocally
                        : l10n.markdownDraftAutoSaved(_fileName!),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: _controller.text.isEmpty
                      ? null
                      : () => copyText(
                          context,
                          _controller.text,
                          message: l10n.markdownSourceCopied,
                        ),
                  icon: const Icon(Icons.copy_all_outlined, size: 18),
                  label: Text(l10n.commonCopy),
                ),
                TextButton.icon(
                  onPressed: _controller.text.isEmpty ? null : _confirmClear,
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: Text(l10n.commonClear),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _toolButton(IconData icon, String tooltip, VoidCallback onPressed) {
    return IconButton(
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      iconSize: 20,
      onPressed: onPressed,
      icon: Icon(icon),
    );
  }

  Widget _buildPreview(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final text = _controller.text.trim();

    return SectionCard(
      color: scheme.surfaceContainerHigh,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
            child: Text(l10n.commonPreview, style: textTheme.labelLarge),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
              child: text.isEmpty
                  ? Text(
                      l10n.markdownPreviewPlaceholder,
                      style: textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    )
                  : MarkdownBody(
                      data: _controller.text,
                      selectable: true,
                      styleSheet: _styleSheet(context),
                      onTapLink: (text, href, title) => _copyLink(href),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
