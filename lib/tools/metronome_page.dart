import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../widgets/ui_kit.dart';

class MetronomePage extends StatefulWidget {
  const MetronomePage({super.key});

  @override
  State<MetronomePage> createState() => _MetronomePageState();
}

class _MetronomePageState extends State<MetronomePage>
    with SingleTickerProviderStateMixin {
  static const int _minBpm = 30;
  static const int _maxBpm = 240;

  final AudioPlayer _accentPlayer = AudioPlayer();
  final AudioPlayer _beatPlayer = AudioPlayer();

  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 160),
    value: 1,
  );

  Timer? _timer;
  int _bpm = 120;
  int _beatsPerBar = 4;

  /// 刚刚发声、当前在界面上高亮的拍（0 起）。
  int _currentBeat = 0;

  /// 下一次定时器触发时要播放的拍（0 起）。
  int _nextBeat = 0;
  bool _running = false;
  bool _accentEnabled = true;
  bool _soundEnabled = true;
  double _volume = 0.8;
  final List<DateTime> _tapTimes = <DateTime>[];

  @override
  void initState() {
    super.initState();
    _preparePlayers();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulse.dispose();
    _accentPlayer.dispose();
    _beatPlayer.dispose();
    super.dispose();
  }

  Future<void> _preparePlayers() async {
    for (final player in [_accentPlayer, _beatPlayer]) {
      try {
        await player.setPlayerMode(PlayerMode.lowLatency);
        await player.setReleaseMode(ReleaseMode.stop);
        await player.setVolume(_volume);
      } catch (_) {
        // 音频初始化失败时仍保留可视节拍功能。
      }
    }
  }

  Future<void> _playClick(bool accent) async {
    if (!_soundEnabled) return;
    final player = accent ? _accentPlayer : _beatPlayer;
    final source = AssetSource(accent ? 'sounds/tick.wav' : 'sounds/tock.wav');
    try {
      await player.stop();
    } catch (_) {
      // 首次播放前没有可停止的音源，忽略异常。
    }
    try {
      await player.play(source);
    } catch (_) {
      // 音频播放失败时保持可视节拍继续运行。
    }
  }

  Duration get _beatInterval =>
      Duration(microseconds: (60000000 / _bpm).round());

  void _start() {
    _timer?.cancel();
    _nextBeat = 0;
    setState(() {
      _running = true;
      _currentBeat = 0;
    });
    _emitBeat();
    _timer = Timer.periodic(_beatInterval, (_) => _emitBeat());
  }

  void _stop() {
    _timer?.cancel();
    _timer = null;
    setState(() {
      _running = false;
      _currentBeat = 0;
    });
    _pulse.stop();
    _pulse.value = 1;
  }

  void _emitBeat() {
    if (!mounted) return;
    // 发声与界面高亮必须使用同一拍号，setState 后界面在下一帧才重建，
    // 因此先取出本拍、再推进 _nextBeat，避免显示比声音快一拍。
    final beat = _nextBeat;
    _nextBeat = (beat + 1) % _beatsPerBar;
    final accent = _accentEnabled && beat == 0;
    _playClick(accent);
    _pulse.forward(from: 0);
    setState(() => _currentBeat = beat);
  }

  void _updateBpm(int value, {bool fromTap = false}) {
    final next = value.clamp(_minBpm, _maxBpm).toInt();
    if (next == _bpm) return;
    setState(() => _bpm = next);
    if (_running) {
      _timer?.cancel();
      _timer = Timer.periodic(_beatInterval, (_) => _emitBeat());
    }
    if (!fromTap) _tapTimes.clear();
  }

  void _onTapTempo() {
    final now = DateTime.now();
    if (_tapTimes.isNotEmpty &&
        now.difference(_tapTimes.last) > const Duration(seconds: 2)) {
      _tapTimes.clear();
    }
    _tapTimes.add(now);
    if (_tapTimes.length > 6) {
      _tapTimes.removeAt(0);
    }
    if (_tapTimes.length < 2) return;
    final total = _tapTimes.last.difference(_tapTimes.first).inMilliseconds;
    final average = total / (_tapTimes.length - 1);
    if (average <= 0) return;
    _updateBpm((60000 / average).round(), fromTap: true);
  }

  void _setBeatsPerBar(int beats) {
    setState(() {
      _beatsPerBar = beats;
      if (_currentBeat >= beats) _currentBeat = 0;
      if (_nextBeat >= beats) _nextBeat = 0;
    });
  }

  void _setVolume(double value) {
    setState(() => _volume = value);
    _accentPlayer.setVolume(value).ignore();
    _beatPlayer.setVolume(value).ignore();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ToolPage(
      title: context.l10n.metronomeTitle,
      subtitle: context.l10n.metronomeSubtitle,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          SectionCard(
            child: Column(
              children: [
                AnimatedBuilder(
                  animation: _pulse,
                  builder: (context, child) {
                    final scale = 1 + (1 - _pulse.value) * 0.12;
                    return Transform.scale(scale: scale, child: child);
                  },
                  child: Container(
                    width: 132,
                    height: 132,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _running
                          ? (_currentBeat == 0 && _accentEnabled
                                ? scheme.primary
                                : scheme.primaryContainer)
                          : scheme.surfaceContainerHighest,
                    ),
                    child: Text(
                      _running ? '${_currentBeat + 1}' : '—',
                      style: textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: _running
                            ? (_currentBeat == 0 && _accentEnabled
                                  ? scheme.onPrimary
                                  : scheme.onPrimaryContainer)
                            : scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '$_bpm',
                      style: textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'BPM',
                      style: textTheme.titleMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    for (var beat = 0; beat < _beatsPerBar; beat++)
                      _BeatDot(
                        active: _running && _currentBeat == beat,
                        accent: _accentEnabled && beat == 0,
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton.filledTonal(
                      tooltip: context.l10n.metronomeDecreaseBpm,
                      onPressed: _bpm > _minBpm
                          ? () => _updateBpm(_bpm - 1)
                          : null,
                      icon: const Icon(Icons.remove),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      width: 96,
                      height: 96,
                      child: FilledButton(
                        onPressed: _running ? _stop : _start,
                        style: FilledButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: EdgeInsets.zero,
                        ),
                        child: Icon(
                          _running
                              ? Icons.stop_rounded
                              : Icons.play_arrow_rounded,
                          size: 44,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    IconButton.filledTonal(
                      tooltip: context.l10n.metronomeIncreaseBpm,
                      onPressed: _bpm < _maxBpm
                          ? () => _updateBpm(_bpm + 1)
                          : null,
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _onTapTempo,
                  icon: const Icon(Icons.touch_app_outlined, size: 18),
                  label: Text(context.l10n.metronomeTapTempo),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      context.l10n.metronomeTempo,
                      style: textTheme.titleSmall,
                    ),
                    const Spacer(),
                    Text(
                      context.l10n.metronomeBpmValue(_bpm),
                      style: textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: _bpm.toDouble(),
                  min: _minBpm.toDouble(),
                  max: _maxBpm.toDouble(),
                  divisions: _maxBpm - _minBpm,
                  label: '$_bpm',
                  onChanged: (value) => _updateBpm(value.round()),
                ),
                const Divider(height: 20),
                Text(
                  context.l10n.metronomeBeatsPerBar,
                  style: textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (var beats = 1; beats <= 12; beats++)
                      ChoiceChip(
                        label: Text('$beats'),
                        selected: _beatsPerBar == beats,
                        showCheckmark: false,
                        onSelected: (_) => _setBeatsPerBar(beats),
                      ),
                  ],
                ),
                const Divider(height: 24),
                Material(
                  color: Colors.transparent,
                  child: Column(
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(context.l10n.metronomeAccent),
                        subtitle: Text(context.l10n.metronomeAccentHint),
                        value: _accentEnabled,
                        onChanged: (value) =>
                            setState(() => _accentEnabled = value),
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(context.l10n.metronomeSound),
                        subtitle: Text(context.l10n.metronomeSoundHint),
                        value: _soundEnabled,
                        onChanged: (value) =>
                            setState(() => _soundEnabled = value),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Text(
                      context.l10n.metronomeVolume,
                      style: textTheme.titleSmall,
                    ),
                    Expanded(
                      child: Slider(value: _volume, onChanged: _setVolume),
                    ),
                    SizedBox(
                      width: 44,
                      child: Text(
                        '${(_volume * 100).round()}%',
                        textAlign: TextAlign.end,
                        style: textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BeatDot extends StatelessWidget {
  const _BeatDot({required this.active, required this.accent});

  final bool active;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final Color color;
    if (active) {
      color = accent ? scheme.primary : scheme.primaryContainer;
    } else {
      color = scheme.surfaceContainerHighest;
    }
    return AnimatedContainer(
      duration: const Duration(milliseconds: 80),
      width: accent ? 14 : 10,
      height: accent ? 14 : 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(color: scheme.outlineVariant, width: 0.5),
      ),
    );
  }
}
