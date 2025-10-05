import 'package:workmanager/workmanager.dart';
import 'package:spendify/services/bill_notification_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:async';

class BackgroundService {
  static const String checkDueBillsTask = 'checkDueBillsTask';
  static Timer? _webTimer;

  static Future<void> initialize() async {
    if (!kIsWeb) {
      await Workmanager().initialize(
        callbackDispatcher,
        isInDebugMode: false,
      );
    }
  }

  static Future<void> startPeriodicTask() async {
    if (!kIsWeb) {
      await Workmanager().registerPeriodicTask(
        checkDueBillsTask,
        checkDueBillsTask,
        frequency: const Duration(hours: 1),
        initialDelay: const Duration(minutes: 1),
        constraints: Constraints(
          networkType: NetworkType.connected,
        ),
      );
    } else {
      // Web implementation using Timer
      _webTimer?.cancel();
      _webTimer = Timer.periodic(
        const Duration(hours: 1),
        (_) async {
          final notificationService = BillNotificationService();
          await notificationService.checkDueBillsAndSendNotifications();
        },
      );
    }
  }

  static Future<void> stopPeriodicTask() async {
    if (!kIsWeb) {
      await Workmanager().cancelByUniqueName(checkDueBillsTask);
    } else {
      _webTimer?.cancel();
      _webTimer = null;
    }
  }
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  if (!kIsWeb) {
    Workmanager().executeTask((taskName, inputData) async {
      if (taskName == BackgroundService.checkDueBillsTask) {
        final notificationService = BillNotificationService();
        await notificationService.checkDueBillsAndSendNotifications();
        return true;
      }
      return false;
    });
  }
} 