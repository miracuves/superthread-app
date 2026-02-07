import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_text_styles.dart';
import '../../widgets/custom_button.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../../data/models/notification_model.dart';
import '../../../core/services/notifications/superthread_notification_service.dart';
import '../../../core/services/storage/storage_service.dart';
import '../../../core/service_locator.dart';

class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  State<NotificationsSettingsScreen> createState() => _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState extends State<NotificationsSettingsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  NotificationPreferences _preferences = const NotificationPreferences();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
    _loadPreferences();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadPreferences() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final notificationService = getService<SuperthreadNotificationService>();
      final prefs = notificationService.preferences;
      setState(() {
        _preferences = prefs;
      });
    } catch (e) {
      // Keep default preferences if loading fails
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _savePreferences() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final notificationService = getService<SuperthreadNotificationService>();
      await notificationService.savePreferences(_preferences);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Settings saved successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to save settings'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: AppTextStyles.headline3.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildNotificationToggle(context),
              const SizedBox(height: 24),
              _buildNotificationTypes(context),
              const SizedBox(height: 24),
              _buildPollingSettings(context),
              const SizedBox(height: 24),
              _buildSoundAndVibration(context),
              const SizedBox(height: 24),
              _buildQuietHours(context),
              const SizedBox(height: 24),
              _buildDangerZone(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationToggle(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.notifications_active,
            color: _preferences.enabled ? AppColors.primary : Colors.grey,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enable Notifications',
                  style: AppTextStyles.headline4.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Get updates for your Superthread activity',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _preferences.enabled,
            onChanged: (value) async {
              setState(() {
                _preferences = _preferences.copyWith(enabled: value);
              });
              await _savePreferences();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationTypes(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notification Types',
          style: AppTextStyles.headline4.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Column(
            children: [
              _buildNotificationType(
                context,
                'Cards',
                'Notifications for new and updated cards',
                Icons.style,
                _preferences.cardNotifications,
                (value) => _preferences = _preferences.copyWith(cardNotifications: value),
              ),
              _buildNotificationType(
                context,
                'Notes',
                'Notifications for new and updated notes',
                Icons.note_alt,
                _preferences.noteNotifications,
                (value) => _preferences = _preferences.copyWith(noteNotifications: value),
              ),
              _buildNotificationType(
                context,
                'Projects',
                'Notifications for project updates',
                Icons.dashboard,
                _preferences.projectNotifications,
                (value) => _preferences = _preferences.copyWith(projectNotifications: value),
              ),
              _buildNotificationType(
                context,
                'Comments',
                'Notifications for comments and mentions',
                Icons.comment,
                _preferences.commentNotifications,
                (value) => _preferences = _preferences.copyWith(commentNotifications: value),
              ),
              _buildNotificationType(
                context,
                'Assignments',
                'Notifications when assigned to cards',
                Icons.assignment,
                _preferences.assignmentNotifications,
                (value) => _preferences = _preferences.copyWith(assignmentNotifications: value),
              ),
              _buildNotificationType(
                context,
                'Deadlines',
                'Important deadline and reminder notifications',
                Icons.alarm,
                _preferences.deadlineNotifications,
                (value) => _preferences = _preferences.copyWith(deadlineNotifications: value),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationType(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return ListTile(
      leading: Icon(
        icon,
        color: value ? AppColors.primary : Colors.grey,
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyMedium.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        description,
        style: AppTextStyles.bodySmall.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: (value) {
          setState(() {
            onChanged(value);
          });
          _savePreferences();
        },
      ),
    );
  }

  Widget _buildPollingSettings(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Polling Settings',
          style: AppTextStyles.headline4.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Polling Interval',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'How often to check for new updates (minutes)',
                style: AppTextStyles.bodySmall.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _preferences.pollingInterval,
                    onChanged: (value) async {
                      setState(() {
                        _preferences = _preferences.copyWith(pollingInterval: value);
                      });
                      await _savePreferences();
                    },
                    items: [1, 2, 5, 10, 15, 30, 60].map((interval) {
                      return DropdownMenuItem<int>(
                        value: interval,
                        child: Text('$interval minute${interval == 1 ? '' : 's'}'),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Current interval: ${_preferences.pollingInterval} minute${_preferences.pollingInterval == 1 ? '' : 's'}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.info.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.info,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Shorter intervals use more battery. Recommended: 5-10 minutes.',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.info,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSoundAndVibration(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Alerts & Feedback',
          style: AppTextStyles.headline4.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Column(
            children: [
              _buildNotificationType(
                context,
                'Sound',
                'Play notification sound',
                Icons.volume_up,
                _preferences.soundEnabled,
                (value) => _preferences = _preferences.copyWith(soundEnabled: value),
              ),
              _buildNotificationType(
                context,
                'Vibration',
                'Vibrate on notifications',
                Icons.vibration,
                _preferences.vibrationEnabled,
                (value) => _preferences = _preferences.copyWith(vibrationEnabled: value),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuietHours(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quiet Hours',
          style: AppTextStyles.headline4.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Disable notifications during these hours',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Hours when notifications will not make sound or vibrate',
                style: AppTextStyles.bodySmall.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(24, (hour) {
                  final hourStr = hour.toString();
                  final isSelected = _preferences.quietHours.contains(hourStr);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _preferences = _preferences.copyWith(
                            quietHours: _preferences.quietHours.where((h) => h != hourStr).toList(),
                          );
                        } else {
                          _preferences = _preferences.copyWith(
                            quietHours: [..._preferences.quietHours, hourStr]..sort(),
                          );
                        }
                      });
                      _savePreferences();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        '${hour.toString().padLeft(2, '0')}:00',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isSelected ? AppColors.textInverse : Theme.of(context).colorScheme.onSurface,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 8),
              Text(
                'Selected: ${_preferences.quietHours.map((h) => '${h.toString().padLeft(2, '0')}:00').join(', ')}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDangerZone(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notification Management',
          style: AppTextStyles.headline4.copyWith(
            color: AppColors.error,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: AppColors.error.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.error.withOpacity(0.3),
            ),
          ),
          child: Column(
            children: [
              ListTile(
                leading: Icon(
                  Icons.delete_sweep,
                  color: AppColors.error,
                ),
                title: Text(
                  'Clear All Notifications',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  'Remove all stored notifications',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.error.withOpacity(0.8),
                  ),
                ),
                onTap: () => _showClearNotificationsDialog(context),
              ),
              ListTile(
                leading: Icon(
                  Icons.history,
                  color: AppColors.warning,
                ),
                title: Text(
                  'Reset to Default Settings',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  'Restore default notification preferences',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.warning.withOpacity(0.8),
                  ),
                ),
                onTap: () => _showResetSettingsDialog(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showClearNotificationsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Notifications'),
        content: const Text(
          'Are you sure you want to clear all stored notifications? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Show snackbar BEFORE popping the context
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All notifications cleared'),
                  backgroundColor: AppColors.success,
                ),
              );
              Navigator.pop(context);
              // Clear notifications from storage
              final storageService = getService<StorageService>();
              await storageService.clearNotifications();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showResetSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text(
          'Are you sure you want to reset all notification settings to their default values?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Show snackbar BEFORE popping the context
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Settings reset to defaults'),
                  backgroundColor: AppColors.success,
                ),
              );
              Navigator.pop(context);
              setState(() {
                _preferences = const NotificationPreferences();
              });
              await _savePreferences();
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}