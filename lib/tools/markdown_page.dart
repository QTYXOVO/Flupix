import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
        SharedPreferences.getInstance()
            .then((prefs) => prefs.setString(_draftKey, pending)),
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
    final newText =
        text.replaceRange(selection.start, selection.end, '$before$content$after');
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
    final allPrefixed =
        lines.every((line) => line.isEmpty || line.startsWith(prefix));
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
    _insertBlock('| 列一 | 列二 |\n| --- | --- |\n| 内容 | 内容 |');
  }

  Future<void> _confirmClear() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清空内容？'),
        content: const Text('当前草稿会被删除，且无法恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('清空'),
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
    copyText(context, href, message: '已复制链接');
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
        dialogTitle: '打开 Markdown 文件',
        type: FileType.custom,
        allowedExtensions: const ['md', 'markdown', 'txt'],
      );
      if (file == null) return;
      final content = utf8.decode(await file.readAsBytes(), allowMalformed: true);
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
      _notify('已打开 ${file.name}');
    } catch (error) {
      if (!mounted) return;
      _notify('打开失败：$error', error: true);
    }
  }

  Future<void> _exportFile() async {
    final text = _controller.text;
    final base = _fileName ?? '未命名.md';
    final target = base.toLowerCase().endsWith('.md') ? base : '$base.md';
    try {
      final uri = await FilePicker.saveFile(
        fileName: target,
        bytes: Uint8List.fromList(utf8.encode(text)),
        mimeType: 'text/markdown',
        dialogTitle: '导出 Markdown',
      );
      if (uri == null || !mounted) return;
      // 桌面端返回文件路径，可取得实际另存的文件名；移动端返回 content:// 标识，沿用默认名。
      final segments = uri.pathSegments;
      final savedName = Platform.isWindows && segments.isNotEmpty
          ? Uri.decodeComponent(segments.last)
          : target;
      setState(() => _fileName = savedName);
      _notify('已导出 $savedName');
    } catch (error) {
      if (!mounted) return;
      _notify('导出失败：$error', error: true);
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
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final text = _controller.text;
    final lineCount = text.isEmpty ? 0 : '\n'.allMatches(text).length + 1;

    return ToolPage(
      title: 'Markdown 编辑',
      subtitle: 'GFM 预览 · .md 导入导出',
      actions: [
        IconButton(
          tooltip: '打开 .md 文件',
          onPressed: _openFile,
          icon: const Icon(Icons.folder_open_outlined),
        ),
        IconButton(
          tooltip: '导出为 .md 文件',
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
                        segments: const [
                          ButtonSegment(
                            value: false,
                            icon: Icon(Icons.edit_outlined, size: 18),
                            label: Text('编辑'),
                          ),
                          ButtonSegment(
                            value: true,
                            icon: Icon(Icons.visibility_outlined, size: 18),
                            label: Text('预览'),
                          ),
                        ],
                        selected: {_previewOnly},
                        showSelectedIcon: false,
                        onSelectionChanged: (selection) =>
                            setState(() => _previewOnly = selection.first),
                      ),
                    const Spacer(),
                    Text(
                      '$lineCount 行 · ${text.length} 字符',
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
                _toolButton(Icons.title, '一级标题', () => _toggleLinePrefix('# ')),
                _toolButton(Icons.text_fields, '二级标题', () => _toggleLinePrefix('## ')),
                _toolButton(
                  Icons.format_bold,
                  '粗体',
                  () => _wrapSelection('**', '**', '粗体'),
                ),
                _toolButton(
                  Icons.format_italic,
                  '斜体',
                  () => _wrapSelection('*', '*', '斜体'),
                ),
                _toolButton(
                  Icons.code,
                  '行内代码',
                  () => _wrapSelection('`', '`', 'code'),
                ),
                _toolButton(
                  Icons.format_list_bulleted,
                  '无序列表',
                  () => _toggleLinePrefix('- '),
                ),
                _toolButton(
                  Icons.format_list_numbered,
                  '有序列表',
                  () => _toggleLinePrefix('1. '),
                ),
                _toolButton(
                  Icons.check_box_outlined,
                  '任务列表',
                  () => _toggleLinePrefix('- [ ] '),
                ),
                _toolButton(
                  Icons.format_quote,
                  '引用',
                  () => _toggleLinePrefix('> '),
                ),
                _toolButton(
                  Icons.link,
                  '链接',
                  () => _wrapSelection('[', '](https://)', '链接文字'),
                ),
                _toolButton(Icons.data_array, '代码块', _insertCodeBlock),
                _toolButton(Icons.table_chart_outlined, '表格', _insertTable),
                _toolButton(
                  Icons.horizontal_rule,
                  '分隔线',
                  () => _insertBlock('---'),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: scheme.outlineVariant.withValues(alpha: 0.4)),
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
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: '# 在这里开始写 Markdown…',
                contentPadding: EdgeInsets.all(16),
              ),
              onChanged: (_) => _onTextChanged(),
            ),
          ),
          Divider(height: 1, color: scheme.outlineVariant.withValues(alpha: 0.4)),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 2, 6, 2),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _fileName == null
                        ? '草稿自动保存在本机'
                        : '$_fileName · 草稿自动保存',
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
                            message: '已复制 Markdown 源码',
                          ),
                  icon: const Icon(Icons.copy_all_outlined, size: 18),
                  label: const Text('复制'),
                ),
                TextButton.icon(
                  onPressed: _controller.text.isEmpty ? null : _confirmClear,
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('清空'),
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
            child: Text('预览', style: textTheme.labelLarge),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
              child: text.isEmpty
                  ? Text(
                      '左侧输入的 Markdown 会实时渲染在这里',
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
