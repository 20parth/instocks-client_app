import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';

import '../../core/formatters.dart';
import '../../core/models/client_notification_item.dart';
import '../../core/models/notification_preference.dart';
import '../../shared/widgets/app_card.dart';
import '../client/client_api.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _localNotifications = FlutterLocalNotificationsPlugin();
  late Future<_NotificationsBundle> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
    _localNotifications.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );
  }

  Future<_NotificationsBundle> _load() async {
    final api = context.read<ClientApi>();
    final notifications = await api.getNotifications();
    final preferences = await api.getNotificationPreferences();

    return _NotificationsBundle(notifications: notifications, preferences: preferences);
  }

  Future<void> _showLocalPreview() async {
    await _localNotifications.show(
      1,
      'Instocks Client',
      'Local notification preview is enabled for this app.',
      const NotificationDetails(
        android: AndroidNotificationDetails('instocks_client', 'Instocks Client Notifications'),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  Future<void> _markRead(int notificationId) async {
    await context.read<ClientApi>().markNotificationRead(notificationId);
    setState(() => _future = _load());
  }

  Future<void> _togglePreference(NotificationPreference preference, NotificationPreference updated) async {
    final bundle = await _future;
    final next = bundle.preferences.map((item) => item.id == preference.id ? updated : item).toList();
    await context.read<ClientApi>().updateNotificationPreferences(next);
    setState(() => _future = _load());
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<_NotificationsBundle>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text('Notifications', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              const Text('Review in-app alerts and control how Instocks contacts your client account.'),
              const SizedBox(height: 20),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Local App Alerts', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    const Text('This Flutter app can preview local notifications now. Full background push still needs FCM/APNS setup.'),
                    const SizedBox(height: 16),
                    FilledButton(onPressed: _showLocalPreview, child: const Text('Preview Local Notification')),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Preferences', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    ...data.preferences.map((preference) => SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(preference.notificationType.replaceAll('_', ' ')),
                          subtitle: Text('In-app ${preference.allowInApp ? 'on' : 'off'} • Email ${preference.allowEmail ? 'on' : 'off'} • Push ${preference.allowPush ? 'on' : 'off'}'),
                          value: preference.allowPush,
                          onChanged: (value) => _togglePreference(preference, preference.copyWith(allowPush: value)),
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Notification Center', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    ...data.notifications.map((notification) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(notification.title),
                          subtitle: Text('${notification.message}\n${AppFormatters.dateTime(notification.createdAt)}'),
                          isThreeLine: true,
                          trailing: notification.isRead
                              ? const Icon(Icons.done_all_rounded)
                              : TextButton(onPressed: () => _markRead(notification.id), child: const Text('Read')),
                        )),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _NotificationsBundle {
  _NotificationsBundle({required this.notifications, required this.preferences});

  final List<ClientNotificationItem> notifications;
  final List<NotificationPreference> preferences;
}
