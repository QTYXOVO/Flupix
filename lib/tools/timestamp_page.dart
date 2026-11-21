import 'dart:async';

import 'package:flutter/material.dart';

import '../core/formatters.dart';
import '../l10n/l10n.dart';
import '../widgets/ui_kit.dart';

class TimestampPage extends StatefulWidget {
  const TimestampPage({super.key});

  @override
  State<TimestampPage> createState() => _TimestampPageState();
}

class _TimestampPageState extends State<TimestampPage> {
  final TextEditingController _timestampInput = TextEditingController();
  Timer? _ticker;
  DateTime _now = DateTime.now();
  DateTime? _parsedTime;
  String? _parseError;
  DateTime _pickedTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _timestampInput.dispose();
    super.dispose();
  }

  int _milliseconds(DateTime time) => time.millisecondsSinceEpoch;

  void _parseTimestamp(String raw) {
    final source = raw.trim();
    if (source.isEmpty) {
      setState(() {
        _parsedTime = null;
        _parseError = null;
      });
      return;
    }
    final value = int.tryParse(source);
    if (value == null) {
      setState(() {
        _parsedTime = null;
        _parseError = AppL10n.current.timestampErrorNotInteger;
      });
      return;
    }
    final milliseconds = value.abs() >= 100000000000 ? value : value * 1000;
    try {
      final time = DateTime.fromMillisecondsSinceEpoch(milliseconds);
      setState(() {
        _parsedTime = time;
        _parseError = null;
      });
    } catch (_) {
      setState(() {
        _parsedTime = null;
        _parseError = AppL10n.current.timestampErrorOutOfRange;
      });
    }
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _pickedTime,
      firstDate: DateTime(1970),
      lastDate: DateTime(2100),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_pickedTime),
    );
    if (time == null) return;
    setState(() {
      _pickedTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final seconds = _now.millisecondsSinceEpoch ~/ 1000;
    final parsed = _parsedTime;

    return ToolPage(
      title: l10n.timestampPageTitle,
      subtitle: l10n.timestampPageSubtitle,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          SectionCard(
            color: scheme.primaryContainer,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.timestampCurrentTime,
                  style: textTheme.labelLarge?.copyWith(
                    color: scheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  formatDateTime(_now),
                  style: textTheme.headlineSmall?.copyWith(
                    color: scheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  weekdayLabel(_now),
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onPrimaryContainer.withValues(alpha: 0.8),
                  ),
                ),
                const Divider(height: 28),
                CopyableValue(label: l10n.timestampSeconds, value: '$seconds'),
                CopyableValue(
                  label: l10n.timestampMilliseconds,
                  value: '${_now.millisecondsSinceEpoch}',
                ),
                CopyableValue(
                  label: l10n.timestampUtcIso,
                  value: _now.toUtc().toIso8601String(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.timestampToDateTime, style: textTheme.titleSmall),
                const SizedBox(height: 12),
                TextField(
                  controller: _timestampInput,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: l10n.timestampLabel,
                    hintText: l10n.timestampHint,
                    suffixIcon: TextButton(
                      onPressed: () {
                        final now = DateTime.now().millisecondsSinceEpoch;
                        _timestampInput.text = '$now';
                        _parseTimestamp('$now');
                      },
                      child: Text(l10n.timestampNow),
                    ),
                  ),
                  onChanged: _parseTimestamp,
                ),
                const SizedBox(height: 12),
                if (_parseError != null)
                  Text(
                    _parseError!,
                    style: textTheme.bodySmall?.copyWith(color: scheme.error),
                  )
                else if (parsed != null)
                  Column(
                    children: [
                      CopyableValue(
                        label: l10n.timestampLocalTime,
                        value: formatDateTime(parsed),
                      ),
                      CopyableValue(
                        label: l10n.timestampUtcTime,
                        value: formatDateTime(parsed.toUtc()),
                        monospace: false,
                      ),
                      CopyableValue(
                        label: l10n.timestampIso8601,
                        value: parsed.toUtc().toIso8601String(),
                      ),
                    ],
                  )
                else
                  Text(
                    l10n.timestampEmptyHint,
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.timestampFromDateTime, style: textTheme.titleSmall),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        formatDateTime(_pickedTime),
                        style: textTheme.titleMedium,
                      ),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: _pickDateTime,
                      icon: const Icon(Icons.event),
                      label: Text(l10n.timestampPick),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                CopyableValue(
                  label: l10n.timestampSeconds,
                  value: '${_pickedTime.millisecondsSinceEpoch ~/ 1000}',
                ),
                CopyableValue(
                  label: l10n.timestampMilliseconds,
                  value: '${_milliseconds(_pickedTime)}',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
