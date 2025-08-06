import 'package:flutter/material.dart';
import '../widgets/app_notification.dart';

class NotificationService {
  static final List<OverlayEntry> _activeNotifications = [];

  static void show({
    required BuildContext context,
    required String message,
    required NotificationType type,
    Duration duration = const Duration(seconds: 4),
  }) {
    // Remover notificaciones existentes para evitar solapamiento
    _clearNotifications();

    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => AppNotification(
        message: message,
        type: type,
        duration: duration,
        onDismiss: () {
          _removeNotification(overlayEntry);
        },
      ),
    );

    _activeNotifications.add(overlayEntry);
    overlay.insert(overlayEntry);
  }

  static void showSuccess(BuildContext context, String message) {
    show(
      context: context,
      message: message,
      type: NotificationType.success,
    );
  }

  static void showError(BuildContext context, String message) {
    show(
      context: context,
      message: message,
      type: NotificationType.error,
    );
  }

  static void showInfo(BuildContext context, String message) {
    show(
      context: context,
      message: message,
      type: NotificationType.info,
    );
  }

  static void showWarning(BuildContext context, String message) {
    show(
      context: context,
      message: message,
      type: NotificationType.warning,
    );
  }

  static void _removeNotification(OverlayEntry entry) {
    if (_activeNotifications.contains(entry)) {
      entry.remove();
      _activeNotifications.remove(entry);
    }
  }

  static void _clearNotifications() {
    for (final entry in _activeNotifications) {
      entry.remove();
    }
    _activeNotifications.clear();
  }

  static void clearAll() {
    _clearNotifications();
  }
}