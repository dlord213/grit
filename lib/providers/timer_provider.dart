import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/notification_service.dart';

class RestTimerState {
  final bool isActive;
  final int duration;
  final int remainingSeconds;
  final DateTime? targetTime;

  RestTimerState({
    this.isActive = false,
    this.duration = 0,
    this.remainingSeconds = 0,
    this.targetTime,
  });

  RestTimerState copyWith({
    bool? isActive,
    int? duration,
    int? remainingSeconds,
    DateTime? targetTime,
  }) {
    return RestTimerState(
      isActive: isActive ?? this.isActive,
      duration: duration ?? this.duration,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      targetTime: targetTime ?? this.targetTime,
    );
  }
}

class RestTimerNotifier extends StateNotifier<RestTimerState> {
  Timer? _timer;

  RestTimerNotifier() : super(RestTimerState());

  void startTimer(int seconds) {
    _timer?.cancel();
    if (seconds <= 0) return;

    final targetTime = DateTime.now().add(Duration(seconds: seconds));
    state = RestTimerState(
      isActive: true,
      duration: seconds,
      remainingSeconds: seconds,
      targetTime: targetTime,
    );

    // Schedule background local notification
    NotificationService().scheduleRestTimerNotification(seconds);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      if (now.isAfter(targetTime)) {
        stopTimer();
      } else {
        final remaining = targetTime.difference(now).inSeconds;
        state = state.copyWith(remainingSeconds: remaining);
      }
    });
  }

  void stopTimer() {
    _timer?.cancel();
    _timer = null;
    state = RestTimerState();
    NotificationService().cancelRestTimerNotification();
  }

  void adjustTime(int secondsDelta) {
    if (!state.isActive || state.targetTime == null) return;

    final newTarget = state.targetTime!.add(Duration(seconds: secondsDelta));
    final now = DateTime.now();
    final newRemaining = newTarget.difference(now).inSeconds;

    if (newRemaining <= 0) {
      stopTimer();
    } else {
      final newDuration = state.duration + secondsDelta;
      state = state.copyWith(
        duration: newDuration > 0 ? newDuration : 0,
        remainingSeconds: newRemaining,
        targetTime: newTarget,
      );
      // Reschedule background local notification with updated time
      NotificationService().scheduleRestTimerNotification(newRemaining);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final restTimerProvider = StateNotifierProvider<RestTimerNotifier, RestTimerState>((ref) {
  return RestTimerNotifier();
});
