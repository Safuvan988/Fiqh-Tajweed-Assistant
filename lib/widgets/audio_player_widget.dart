import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quranfiqh/services/audio_service.dart';

class AudioPlayerWidget extends StatefulWidget {
  final VoidCallback onTap;
  final bool isPlaying;
  final double progress;
  final String audioUrl;
  final ValueChanged<double> onProgressChanged;

  const AudioPlayerWidget({
    super.key,
    required this.isPlaying,
    required this.progress,
    required this.audioUrl,
    required this.onTap,
    required this.onProgressChanged,
  });

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  final AudioService _audioService = AudioService();
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _durationSubscription;

  @override
  void initState() {
    super.initState();
    _positionSubscription = _audioService.onPositionChanged.listen((p) {
      if (mounted && _audioService.currentlyPlayingUrl == widget.audioUrl) {
        setState(() => _position = p);
      }
    });
    _durationSubscription = _audioService.onDurationChanged.listen((d) {
      if (mounted && _audioService.currentlyPlayingUrl == widget.audioUrl) {
        setState(() => _duration = d);
      }
    });
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    double progress = 0.0;
    if (_duration.inMilliseconds > 0) {
      progress = (_position.inMilliseconds / _duration.inMilliseconds).clamp(
        0.0,
        1.0,
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 16, 16),
      child: Row(
        children: [
          // Play / Pause Button / Loading
          _buildPlayButton(colorScheme),
          // Slider
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                trackHeight: 4,
                activeTrackColor: colorScheme.primary,
                inactiveTrackColor: colorScheme.primary.withValues(alpha: 0.15),
                thumbColor: colorScheme.primary,
                overlayColor: colorScheme.primary.withValues(alpha: 0.2),
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
              ),
              child: Slider(
                value: progress,
                onChanged: (val) {
                  final newPos = Duration(
                    milliseconds: (_duration.inMilliseconds * val).toInt(),
                  );
                  _audioService.seek(newPos);
                },
              ),
            ),
          ),
          // Timer
          Text(
            '${_formatDuration(_position)} / ${_formatDuration(_duration)}',
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.5),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayButton(ColorScheme colorScheme) {
    // Show spinner if playing but no duration (buffering)
    if (widget.isPlaying && _duration == Duration.zero) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: colorScheme.primary,
          ),
        ),
      );
    }

    return IconButton(
      onPressed: widget.onTap,
      icon: SizedBox(
        width: 42,
        height: 42,
        child: SvgPicture.asset(
          widget.isPlaying
              ? 'assets/icons/pause-stroke-rounded.svg'
              : 'assets/icons/play-stroke-rounded.svg',
          semanticsLabel: widget.isPlaying ? 'Pause' : 'Play',
          colorFilter: ColorFilter.mode(colorScheme.primary, BlendMode.srcIn),
        ),
      ),
    );
  }
}
