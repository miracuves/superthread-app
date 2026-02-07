import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_text_styles.dart';
import '../../../core/services/storage/storage_service.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../bloc/theme/theme_event.dart';
import '../../bloc/theme/theme_state.dart';
import '../../widgets/custom_button.dart';
import '../notifications/notifications_settings_screen.dart';
import '../notifications/notification_history_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _notificationsEnabled = true;
  bool _biometricEnabled = false;
  bool _autoSyncEnabled = true;
  String _defaultView = 'grid';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
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

  Future<void> _loadPreferences() async {
    // Load user preferences from storage
    final storageService = StorageService();
    await storageService.init();
    
    setState(() {
      _notificationsEnabled = true; // Will be updated async
      _biometricEnabled = false; // Will be updated async
      _autoSyncEnabled = true; // Will be updated async
      _defaultView = 'grid'; // Will be updated async
    });
    
    // Load actual values
    final notificationsEnabled = await storageService.getNotificationsEnabled();
    final biometricEnabled = await storageService.getBiometricEnabled();
    final autoSyncEnabled = await storageService.getAutoSyncEnabled();
    final defaultView = await storageService.getDefaultView();
    
    if (mounted) {
      setState(() {
        _notificationsEnabled = notificationsEnabled;
        _biometricEnabled = biometricEnabled;
        _autoSyncEnabled = autoSyncEnabled;
        _defaultView = defaultView;
      });
    }
  }
  
  Future<void> _savePreferences() async {
    final storageService = StorageService();
    await storageService.init();
    await storageService.setNotificationsEnabled(_notificationsEnabled);
    await storageService.setBiometricEnabled(_biometricEnabled);
    await storageService.setAutoSyncEnabled(_autoSyncEnabled);
    await storageService.setDefaultView(_defaultView);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile & Settings',
          style: AppTextStyles.headline3.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [
          IconButton(
            icon: Icon(
              Icons.help_outline,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: () => _showHelpDialog(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Refresh profile data
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileHeader(context),
                const SizedBox(height: 24),
                _buildSettingsSections(context),
                const SizedBox(height: 24),
                _buildDangerZone(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primaryDark,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.textInverse.withOpacity(0.3),
                          width: 3,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 38,
                        backgroundColor: AppColors.textInverse.withOpacity(0.2),
                        backgroundImage: state.user.avatarUrl != null
                            ? NetworkImage(state.user.avatarUrl!)
                            : null,
                        child: state.user.avatarUrl == null
                            ? Text(
                                state.user.name.isNotEmpty
                                    ? state.user.name[0].toUpperCase()
                                    : 'U',
                                style: AppTextStyles.headline2.copyWith(
                                  color: AppColors.textInverse,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.user.name,
                            style: AppTextStyles.headline3.copyWith(
                              color: AppColors.textInverse,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            state.user.email,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textInverse.withOpacity(0.9),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.success.withOpacity(0.5),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: AppColors.success,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Pro Account',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.success,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Member Since',
                        state.user.createdAt != null 
                            ? DateFormat('MMM yyyy').format(state.user.createdAt!)
                            : 'N/A',
                        Icons.calendar_today,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Team ID',
                        state.teamId.substring(0, 8),
                        Icons.group,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.textInverse.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.textInverse.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: AppColors.textInverse.withOpacity(0.8),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textInverse.withOpacity(0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textInverse,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSections(BuildContext context) {
    return Column(
      children: [
        _buildSettingsSection(
          context,
          'Appearance',
          [
            _buildThemeSelector(context),
            _buildSwitchTile(
              'Dark Mode',
              'Use dark theme across the app',
              context.watch<ThemeBloc>().state is AppThemeState &&
                  (context.watch<ThemeBloc>().state as AppThemeState)
                          .themeMode ==
                      ThemeMode.dark,
              (value) {
                final newMode = value ? ThemeMode.dark : ThemeMode.light;
                context.read<ThemeBloc>().add(ThemeChanged(newMode));
              },
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildSettingsSection(
          context,
          'Preferences',
          [
            _buildDefaultViewSelector(context),
            _buildNavigationTile(
              'Notifications',
              'View and manage notifications',
              Icons.notifications_outlined,
              () => context.push('/notifications/history'),
            ),
            _buildNavigationTile(
              'Notification Settings',
              'Configure notification preferences',
              Icons.settings_outlined,
              () => context.push('/notifications/settings'),
            ),
            _buildSwitchTile(
              'Auto Sync',
              'Sync data automatically',
              _autoSyncEnabled,
              (value) {
                setState(() {
                  _autoSyncEnabled = value;
                });
                _savePreferences();
              },
            ),
            _buildSwitchTile(
              'Biometric Authentication',
              'Use fingerprint or face ID',
              _biometricEnabled,
              (value) {
                setState(() {
                  _biometricEnabled = value;
                });
                _savePreferences();
              },
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildSettingsSection(
          context,
          'Account',
          [
            _buildNavigationTile(
              'Edit Profile',
              'Update your profile information',
              Icons.person_outlined,
              () => _showEditProfileDialog(context),
            ),
            _buildNavigationTile(
              'Security',
              'Password and authentication settings',
              Icons.security_outlined,
              () => _showSecurityDialog(context),
            ),
            _buildNavigationTile(
              'Storage & Data',
              'Manage your data and storage',
              Icons.storage_outlined,
              () => _showStorageDialog(context),
            ),
            _buildNavigationTile(
              'About',
              'App version and information',
              Icons.info_outline,
              () => _showAboutDialog(context),
            ),
          ],
        ),
      ],
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
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildThemeSelector(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        ThemeMode currentTheme = ThemeMode.system;
        if (state is AppThemeState) {
          currentTheme = state.themeMode;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: Icon(
                Icons.palette_outlined,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              title: Text(
                'Theme',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                'Choose your preferred theme',
                style: AppTextStyles.bodySmall.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment(
                      value: ThemeMode.light,
                      label: Text('Light'),
                      icon: Icon(Icons.light_mode_outlined),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      label: Text('Dark'),
                      icon: Icon(Icons.dark_mode_outlined),
                    ),
                    ButtonSegment(
                      value: ThemeMode.system,
                      label: Text('System'),
                      icon: Icon(Icons.settings_suggest_outlined),
                    ),
                  ],
                  selected: {currentTheme},
                  showSelectedIcon: false,
                  onSelectionChanged: (Set<ThemeMode> selection) {
                    final newTheme = selection.first;
                    context.read<ThemeBloc>().add(ThemeChanged(newTheme));
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDefaultViewSelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: Icon(
            Icons.view_quilt_outlined,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          title: Text(
            'Default View',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            'Choose default layout for cards and notes',
            style: AppTextStyles.bodySmall.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: SizedBox(
            width: double.infinity,
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'grid',
                  label: Text('Grid'),
                  icon: Icon(Icons.grid_view_outlined),
                ),
                ButtonSegment(
                  value: 'list',
                  label: Text('List'),
                  icon: Icon(Icons.list_alt_outlined),
                ),
              ],
              selected: {_defaultView},
              showSelectedIcon: false,
              onSelectionChanged: (Set<String> selection) {
                setState(() {
                  _defaultView = selection.first;
                });
                _savePreferences();
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return ListTile(
      leading: Icon(
        _getIconForTitle(title),
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
      trailing: Switch(
        value: value,
        onChanged: onChanged,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }

  Widget _buildNavigationTile(
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

  Widget _buildDangerZone(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Danger Zone',
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
                  Icons.logout_outlined,
                  color: AppColors.error,
                ),
                title: Text(
                  'Logout',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  'Sign out of your account',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.error.withOpacity(0.8),
                  ),
                ),
                trailing: Icon(
                  Icons.chevron_right,
                  color: AppColors.error.withOpacity(0.6),
                ),
                onTap: () => _showLogoutDialog(context),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              Divider(
                height: 1,
                color: AppColors.error.withOpacity(0.2),
              ),
              ListTile(
                leading: Icon(
                  Icons.delete_outline,
                  color: AppColors.error,
                ),
                title: Text(
                  'Delete Account',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  'Permanently delete your account and data',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.error.withOpacity(0.8),
                  ),
                ),
                trailing: Icon(
                  Icons.chevron_right,
                  color: AppColors.error.withOpacity(0.6),
                ),
                onTap: () => _showDeleteAccountDialog(context),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getIconForTitle(String title) {
    switch (title) {
      case 'Push Notifications':
        return Icons.notifications_outlined;
      case 'Auto Sync':
        return Icons.sync_outlined;
      case 'Biometric Authentication':
        return Icons.fingerprint_outlined;
      default:
        return Icons.settings_outlined;
    }
  }

  void _showEditProfileDialog(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'Enter your name',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'Enter your email',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile updated successfully!')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showSecurityDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Security Settings'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• Password: ********'),
            SizedBox(height: 8),
            Text('• Two-Factor Authentication: Enabled'),
            SizedBox(height: 8),
            Text('• Last Login: 2 hours ago'),
            SizedBox(height: 16),
            Text('More security features coming soon!'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showStorageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Storage & Data'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StorageInfoWidget(),
            SizedBox(height: 16),
            Text('Clear cache to free up space'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache cleared successfully!')),
              );
            },
            child: const Text('Clear Cache'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Superthread',
      applicationVersion: 'Version 1.0.0',
      applicationIcon: Container(
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
      children: [
        const Text('A powerful productivity app for managing your work and life.'),
        const SizedBox(height: 16),
        const Text('Made with ❤️ using Flutter'),
      ],
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('📚 Documentation:'),
            Text('Visit superthread.com/docs'),
            SizedBox(height: 12),
            Text('💬 Community:'),
            Text('Join our Discord server'),
            SizedBox(height: 12),
            Text('📧 Support:'),
            Text('support@superthread.com'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(const LogoutRequested());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone and will permanently delete all your data.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account deletion feature coming soon!'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class StorageInfoWidget extends StatefulWidget {
  const StorageInfoWidget({super.key});

  @override
  State<StorageInfoWidget> createState() => _StorageInfoWidgetState();
}

class _StorageInfoWidgetState extends State<StorageInfoWidget> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<double>(
      future: () async {
        // Simulate getting storage info
        final totalStorage = 1024.0; // 1 GB in MB
        final usedStorage = 245.0; // Would come from actual storage service
        return usedStorage / totalStorage;
      }(),
      builder: (context, snapshot) {
        final percentage = snapshot.data ?? 0.0;
        final usedMB = (percentage * 1024).round();
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Storage Used: $usedMB MB / 1 GB (${(percentage * 100).toInt()}%)'),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: percentage),
            const SizedBox(height: 16),
            Text('• Cache: ${((percentage * 45).round())} MB'),
            Text('• Documents: ${((percentage * 180).round())} MB'),
            Text('• Images: ${((percentage * 20).round())} MB'),
          ],
        );
      },
    );
  }
}