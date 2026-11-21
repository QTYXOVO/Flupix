import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// E-Hentai 标签命名空间的中文名。
const Map<String, String> ehTagNamespaceLabels = {
  'artist': '画师',
  'character': '角色',
  'parody': '原作',
  'group': '社团',
  'cosplayer': 'Coser',
  'language': '语言',
  'male': '男性',
  'female': '女性',
  'mixed': '混合',
  'other': '其他',
  'reclass': '重新分类',
  'location': '地点',
  'temp': '临时',
};

/// 常见通用标签的内置翻译，用户导入的翻译会覆盖这里。
const Map<String, String> ehBuiltinTagTranslations = {
  'other:full color': '全彩',
  'other:webtoon': '条漫',
  'other:artbook': '画集',
  'other:novel': '小说',
  'other:oneshot': '单篇',
  'other:sample': '样本',
  'other:anthology': '选集',
  'other:multi-work series': '多作品系列',
  'other:ongoing': '连载中',
  'other:complete': '已完结',
  'other:annual': '年刊',
  'other:fanbook': '粉丝书',
  'other:official': '官方',
  'other:rewrite': '重绘',
  'other:text cleaned': '文字已清理',
  'language:chinese': '中文',
  'language:english': '英文',
  'language:japanese': '日文',
  'language:korean': '韩文',
};

String _tagKey(String namespace, String tag) =>
    '${namespace.trim().toLowerCase()}:${tag.trim().toLowerCase()}';

String ehTagNamespaceLabel(String namespace) {
  final raw = namespace.trim();
  if (raw.isEmpty) return '其他';
  return ehTagNamespaceLabels[raw.toLowerCase()] ?? raw;
}

/// 优先使用用户导入的翻译，其次内置翻译，最后回退原文。
String ehTagDisplay(
  String namespace,
  String tag,
  Map<String, String> translations,
) {
  final key = _tagKey(namespace, tag);
  return translations[key] ?? ehBuiltinTagTranslations[key] ?? tag.trim();
}

/// 生成 E-Hentai 搜索语法；带空格的值加引号，末尾 `$` 表示精确匹配。
String ehTagQuery(String namespace, String tag) {
  final ns = namespace.trim().toLowerCase();
  final value = tag.trim();
  if (value.isEmpty) return ns;
  final exact = value.endsWith(r'$') ? value : '$value\$';
  final quoted = exact.contains(' ') ? '"$exact"' : exact;
  return ns.isEmpty ? quoted : '$ns:$quoted';
}

class EhTagEntry {
  const EhTagEntry({
    required this.namespace,
    required this.tag,
    required this.lastUsed,
  });

  final String namespace;
  final String tag;
  final DateTime lastUsed;

  String get key => _tagKey(namespace, tag);

  Map<String, Object> toJson() => {
    'n': namespace,
    't': tag,
    'u': lastUsed.millisecondsSinceEpoch,
  };

  static EhTagEntry? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final tag = raw['t']?.toString().trim() ?? '';
    if (tag.isEmpty) return null;
    return EhTagEntry(
      namespace: raw['n']?.toString() ?? '',
      tag: tag,
      lastUsed: DateTime.fromMillisecondsSinceEpoch(
        raw['u'] is int ? raw['u'] as int : 0,
      ),
    );
  }
}

/// 标签历史与翻译库，均存放在 SharedPreferences。
class EhTagStore {
  static const _historyKey = 'eh_tag_history';
  static const _translationKey = 'eh_tag_translations';
  static const _historyLimit = 400;

  static Future<List<EhTagEntry>> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_historyKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        final entries = decoded
            .map(EhTagEntry.fromJson)
            .whereType<EhTagEntry>()
            .toList();
        entries.sort((a, b) => b.lastUsed.compareTo(a.lastUsed));
        return entries;
      }
    } catch (_) {
      // 损坏的历史按空处理。
    }
    return [];
  }

  static Future<void> record(Map<String, List<String>> tags) async {
    final now = DateTime.now();
    final entries = await loadHistory();
    final map = {for (final entry in entries) entry.key: entry};
    for (final group in tags.entries) {
      for (final tag in group.value) {
        final trimmed = tag.trim();
        if (trimmed.isEmpty) continue;
        final entry = EhTagEntry(
          namespace: group.key.trim(),
          tag: trimmed,
          lastUsed: now,
        );
        map[entry.key] = entry;
      }
    }
    await _saveHistory(map.values.toList());
  }

  static Future<void> recordEntry(EhTagEntry entry) async {
    final entries = await loadHistory();
    final map = {for (final item in entries) item.key: item};
    map[entry.key] = entry;
    await _saveHistory(map.values.toList());
  }

  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }

  static Future<Map<String, String>> loadTranslations() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_translationKey);
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        return {
          for (final entry in decoded.entries)
            if (entry.value is String && entry.value.toString().trim().isNotEmpty)
              entry.key.toString().toLowerCase(): entry.value.toString().trim(),
        };
      }
    } catch (_) {
      // 损坏的翻译库按空处理。
    }
    return {};
  }

  /// 支持 `{"artist:tag": "翻译"}` 与 `{"artist": {"tag": "翻译"}}` 两种格式。
  /// 返回新增或覆盖的条目数；没有有效条目时抛出 [FormatException]。
  static Future<int> importTranslations(String raw) async {
    final decoded = jsonDecode(raw.trim());
    final incoming = <String, String>{};

    void add(String key, Object? value) {
      final normalized = key.trim().toLowerCase();
      if (!normalized.contains(':') || value is! String) return;
      final text = value.trim();
      if (text.isEmpty) return;
      incoming[normalized] = text;
    }

    if (decoded is Map) {
      for (final entry in decoded.entries) {
        final key = entry.key.toString();
        final value = entry.value;
        if (value is Map) {
          for (final nested in value.entries) {
            add('$key:${nested.key}', nested.value);
          }
        } else {
          add(key, value);
        }
      }
    }
    if (incoming.isEmpty) {
      throw const FormatException('没有找到可用的翻译条目');
    }

    final current = await loadTranslations();
    current.addAll(incoming);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_translationKey, jsonEncode(current));
    return incoming.length;
  }

  static Future<void> clearTranslations() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_translationKey);
  }

  static Future<void> _saveHistory(List<EhTagEntry> entries) async {
    entries.sort((a, b) => b.lastUsed.compareTo(a.lastUsed));
    if (entries.length > _historyLimit) {
      entries.removeRange(_historyLimit, entries.length);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _historyKey,
      jsonEncode([for (final entry in entries) entry.toJson()]),
    );
  }
}
