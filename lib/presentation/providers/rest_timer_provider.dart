import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/timer_constants.dart';
import '../../core/services/audio_service.dart';

class RestTimerState {
  final int totalSeconds;
  final int remainingSeconds;
  final bool isRunning;
  final bool isComplete;

  const RestTimerState({
    required this.totalSeconds,
    required this.remainingSeconds,
    this.isRunning = false,
    this.isComplete = false,
  });

  double get progress =>
      totalSeconds == 0 ? 1.0 : remainingSeconds / totalSeconds;
}

class RestTimerNotifier extends StateNotifier<RestTimerState> {
  Timer? _timer;
  final AudioService _audio;
  void Function()? _onComplete;

  RestTimerNotifier(this._audio)
      : super(const RestTimerState(totalSeconds: 180, remainingSeconds: 180));

  void start(int seconds, {void Function()? onComplete}) {
    _timer?.cancel();
    _onComplete = onComplete;
    state = RestTimerState(
        totalSeconds: seconds, remainingSeconds: seconds, isRunning: true);
    _timer = Timer.periodic(const Duration(seconds: 1), _tick);
  }

  void _tick(Timer t) {
    final remaining = state.remainingSeconds - 1;
    if (remaining == TimerConstants.timerWarningSeconds) {
      _audio.playTenSeconds();
    }
    if (remaining <= 0) {
      _timer?.cancel();
      _audio.playStart();
      state = RestTimerState(
        totalSeconds: state.totalSeconds,
        remainingSeconds: 0,
        isRunning: false,
        isComplete: true,
      );
      _onComplete?.call();
    } else {
      state = RestTimerState(
        totalSeconds: state.totalSeconds,
        remainingSeconds: remaining,
        isRunning: true,
      );
    }
  }

  void cancel() {
    _timer?.cancel();
    state = RestTimerState(
      totalSeconds: state.totalSeconds,
      remainingSeconds: state.remainingSeconds,
      isRunning: false,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final restTimerProvider =
    StateNotifierProvider<RestTimerNotifier, RestTimerState>((ref) {
  return RestTimerNotifier(AudioService());
});
