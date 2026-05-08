import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/constants/timer_constants.dart';
import '../../../../core/services/audio_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../widgets/ring_timer_widget.dart';

class GeneralWarmupWidget extends StatefulWidget {
  final VoidCallback onComplete;

  const GeneralWarmupWidget({super.key, required this.onComplete});

  @override
  State<GeneralWarmupWidget> createState() => _GeneralWarmupWidgetState();
}

class _GeneralWarmupWidgetState extends State<GeneralWarmupWidget> {
  static const _totalRounds = TimerConstants.generalWarmupRounds;
  static const _workSeconds = TimerConstants.generalWarmupWorkSeconds;
  static const _restSeconds = TimerConstants.generalWarmupRestSeconds;

  final _audio = AudioService();
  int _round = 1;
  bool _isWorking = true;
  int _remaining = _workSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTick();
  }

  void _startTick() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _remaining--;
        if (_remaining == TimerConstants.timerWarningSeconds && _isWorking) {
          _audio.playTenSeconds();
        }
        if (_remaining <= 0) {
          _advance();
        }
      });
    });
  }

  void _advance() {
    _timer?.cancel();
    _audio.playStart();
    if (_isWorking) {
      if (_round == _totalRounds) {
        widget.onComplete();
        return;
      }
      _isWorking = false;
      _remaining = _restSeconds;
    } else {
      _round++;
      _isWorking = true;
      _remaining = _workSeconds;
    }
    _startTick();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = _isWorking ? _workSeconds : _restSeconds;
    final progress = _remaining / total;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Allgemeines Aufwärmen', style: AppTypography.label),
          const SizedBox(height: 8),
          Text(
            _isWorking ? 'Runde $_round / $_totalRounds' : 'Pause',
            style: AppTypography.headingMedium,
          ),
          const SizedBox(height: 40),
          RingTimerWidget(
            remainingSeconds: _remaining,
            progress: progress,
          ),
          const SizedBox(height: 16),
          Text(
            _isWorking ? 'AMRAP' : 'Erhol dich',
            style: AppTypography.bodyLarge
                .copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}
