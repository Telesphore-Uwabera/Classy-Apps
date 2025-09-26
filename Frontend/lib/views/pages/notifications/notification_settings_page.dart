import 'package:flutter/material.dart';
import 'package:Classy/services/notification.service.dart';
import 'package:Classy/models/app_notification.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({Key? key}) : super(key: key);

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  final NotificationService _notificationService = NotificationService();
  
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _smsNotifications = false;
  bool _orderUpdates = true;
  bool _promotionalNotifications = true;
  bool _systemNotifications = true;
  bool _quietHoursEnabled = false;
  TimeOfDay _quietHoursStart = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _quietHoursEnd = const TimeOfDay(hour: 8, minute: 0);

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final response = await _notificationService.getNotificationSettings();
      if (response.code == 200 && response.body != null) {
        final settings = response.body['settings'];
        setState(() {
          _pushNotifications = settings['push_notifications'] ?? true;
          _emailNotifications = settings['email_notifications'] ?? true;
          _smsNotifications = settings['sms_notifications'] ?? false;
          _orderUpdates = settings['order_updates'] ?? true;
          _promotionalNotifications = settings['promotional_notifications'] ?? true;
          _systemNotifications = settings['system_notifications'] ?? true;
          _quietHoursEnabled = settings['quiet_hours_enabled'] ?? false;
          
          if (settings['quiet_hours_start'] != null) {
            final startParts = settings['quiet_hours_start'].split(':');
            _quietHoursStart = TimeOfDay(
              hour: int.parse(startParts[0]),
              minute: int.parse(startParts[1]),
            );
          }
          
          if (settings['quiet_hours_end'] != null) {
            final endParts = settings['quiet_hours_end'].split(':');
            _quietHoursEnd = TimeOfDay(
              hour: int.parse(endParts[0]),
              minute: int.parse(endParts[1]),
            );
          }
        });
      }
    } catch (e) {
      _showSnackBar('Failed to load settings: $e');
    }
  }

  Future<void> _saveSettings() async {
    try {
      final settings = {
        'push_notifications': _pushNotifications,
        'email_notifications': _emailNotifications,
        'sms_notifications': _smsNotifications,
        'order_updates': _orderUpdates,
        'promotional_notifications': _promotionalNotifications,
        'system_notifications': _systemNotifications,
        'quiet_hours_enabled': _quietHoursEnabled,
        'quiet_hours_start': '${_quietHoursStart.hour.toString().padLeft(2, '0')}:${_quietHoursStart.minute.toString().padLeft(2, '0')}',
        'quiet_hours_end': '${_quietHoursEnd.hour.toString().padLeft(2, '0')}:${_quietHoursEnd.minute.toString().padLeft(2, '0')}',
      };

      final response = await _notificationService.updateNotificationSettings(settings);
      if (response.code == 200) {
        _showSnackBar('Settings saved successfully');
      } else {
        _showSnackBar('Failed to save settings: ${response.message}');
      }
    } catch (e) {
      _showSnackBar('Failed to save settings: $e');
    }
  }

  Future<void> _testNotification() async {
    try {
      final response = await _notificationService.testNotification();
      if (response.code == 200) {
        _showSnackBar('Test notification sent successfully');
      } else {
        _showSnackBar('Failed to send test notification: ${response.message}');
      }
    } catch (e) {
      _showSnackBar('Failed to send test notification: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
        actions: [
          IconButton(
            onPressed: _testNotification,
            icon: const Icon(Icons.notifications_active),
            tooltip: 'Test Notification',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Notification Channels'),
            _buildSwitchTile(
              'Push Notifications',
              'Receive notifications on your device',
              Icons.notifications,
              _pushNotifications,
              (value) => setState(() => _pushNotifications = value),
            ),
            _buildSwitchTile(
              'Email Notifications',
              'Receive notifications via email',
              Icons.email,
              _emailNotifications,
              (value) => setState(() => _emailNotifications = value),
            ),
            _buildSwitchTile(
              'SMS Notifications',
              'Receive notifications via SMS',
              Icons.sms,
              _smsNotifications,
              (value) => setState(() => _smsNotifications = value),
            ),
            
            const SizedBox(height: 24),
            _buildSectionHeader('Notification Types'),
            _buildSwitchTile(
              'Order Updates',
              'Get notified about order status changes',
              Icons.shopping_cart,
              _orderUpdates,
              (value) => setState(() => _orderUpdates = value),
            ),
            _buildSwitchTile(
              'Promotional Notifications',
              'Receive offers and discounts',
              Icons.local_offer,
              _promotionalNotifications,
              (value) => setState(() => _promotionalNotifications = value),
            ),
            _buildSwitchTile(
              'System Notifications',
              'Receive app updates and maintenance alerts',
              Icons.system_update,
              _systemNotifications,
              (value) => setState(() => _systemNotifications = value),
            ),
            
            const SizedBox(height: 24),
            _buildSectionHeader('Quiet Hours'),
            _buildSwitchTile(
              'Enable Quiet Hours',
              'Mute notifications during specific hours',
              Icons.bedtime,
              _quietHoursEnabled,
              (value) => setState(() => _quietHoursEnabled = value),
            ),
            if (_quietHoursEnabled) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTimePickerTile(
                      'Start Time',
                      _quietHoursStart,
                      (time) => setState(() => _quietHoursStart = time),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTimePickerTile(
                      'End Time',
                      _quietHoursEnd,
                      (time) => setState(() => _quietHoursEnd = time),
                    ),
                  ),
                ],
              ),
            ],
            
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveSettings,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save Settings',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        secondary: Icon(icon, color: Colors.grey[600]),
        value: value,
        onChanged: onChanged,
        activeColor: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildTimePickerTile(
    String label,
    TimeOfDay time,
    ValueChanged<TimeOfDay> onChanged,
  ) {
    return InkWell(
      onTap: () async {
        final newTime = await showTimePicker(
          context: context,
          initialTime: time,
        );
        if (newTime != null) {
          onChanged(newTime);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  time.format(context),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
