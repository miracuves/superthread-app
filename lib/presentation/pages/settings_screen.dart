import 'package:flutter/material.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_text_styles.dart';
import '../../../core/router/app_router.dart';
import 'notifications/notifications_settings_screen.dart';

class SettingsScreen extends StatelessWidget {
  final String? initialSection;

  const SettingsScreen({
    super.key,
    this.initialSection,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: AppTextStyles.headline3.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSettingsSection(
              context,
              'Account Settings',
              [
                _buildSettingsTile(
                  context,
                  'Profile Information',
                  'Update your personal details',
                  Icons.person_outlined,
                  () {},
                ),
                _buildSettingsTile(
                  context,
                  'Email Preferences',
                  'Manage email notifications',
                  Icons.email_outlined,
                  () {},
                ),
                _buildSettingsTile(
                  context,
                  'Security',
                  'Password and authentication',
                  Icons.security_outlined,
                  () {},
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSettingsSection(
              context,
              'App Preferences',
              [
                _buildSettingsTile(
                  context,
                  'Appearance',
                  'Theme and display settings',
                  Icons.palette_outlined,
                  () {},
                ),
                _buildSettingsTile(
                  context,
                  'Language',
                  'Choose app language',
                  Icons.language_outlined,
                  () {},
                ),
                _buildSettingsTile(
                  context,
                  'Notifications',
                  'Push and in-app notifications',
                  Icons.notifications_outlined,
                  () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const NotificationsSettingsScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSettingsSection(
              context,
              'Data & Storage',
              [
                _buildSettingsTile(
                  context,
                  'Storage Usage',
                  'Manage your data storage',
                  Icons.storage_outlined,
                  () {},
                ),
                _buildSettingsTile(
                  context,
                  'Export Data',
                  'Download your data',
                  Icons.download_outlined,
                  () {},
                ),
                _buildSettingsTile(
                  context,
                  'Clear Cache',
                  'Free up storage space',
                  Icons.clear_all_outlined,
                  () {},
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSettingsSection(
              context,
              'Support',
              [
                _buildSettingsTile(
                  context,
                  'Help Center',
                  'Get help and support',
                  Icons.help_outline,
                  () {},
                ),
                _buildSettingsTile(
                  context,
                  'Privacy Policy',
                  'Read our privacy policy',
                  Icons.privacy_tip_outlined,
                  () {},
                ),
                _buildSettingsTile(
                  context,
                  'Terms of Service',
                  'Read our terms of service',
                  Icons.description_outlined,
                  () {},
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildAppInfo(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
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
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(
        icon,
        color: Theme.of(context).colorScheme.onSurface,
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyMedium.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodySmall.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }

  Widget _buildAppInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.dashboard,
              size: 30,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Superthread',
            style: AppTextStyles.headline3.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Version 1.0.0',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'A powerful productivity app for managing your work and life.',
            style: AppTextStyles.bodySmall.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Made with ❤️ using Flutter',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}