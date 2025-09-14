import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../providers/theme_provider.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  // Mock data for settings
  bool _notificationsEnabled = true;
  bool _dataSharingEnabled = false;
  bool _analyticsEnabled = true;
  bool _crashReportingEnabled = false;
  bool _marketingEmailsEnabled = false;

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        centerTitle: true,
        elevation: 0,
      ),
      body: authState.when(
        data: (user) {
          if (user == null) {
            return const Center(
              child: Text('Not logged in'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Profile Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Theme.of(context).primaryColor,
                        child: Text(
                          user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.name.isNotEmpty ? user.name : 'User',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Theme Section
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildThemeSettingsItem(context),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Notifications Section
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildSettingsItem(
                        context,
                        icon: Icons.notifications_outlined,
                        title: 'Bildirimler',
                        subtitle: 'Uygulama bildirimlerini al',
                        trailing: Switch(
                          value: _notificationsEnabled,
                          onChanged: (value) {
                            setState(() {
                              _notificationsEnabled = value;
                            });
                            _showSnackBar(
                              value 
                                ? 'Bildirim tercihiniz aktif olarak güncellendi'
                                : 'Bildirim tercihiniz pasif olarak güncellendi'
                            );
                          },
                        ),
                        onTap: () {
                          setState(() {
                            _notificationsEnabled = !_notificationsEnabled;
                          });
                          _showSnackBar(
                            _notificationsEnabled 
                              ? 'Bildirim tercihiniz aktif olarak güncellendi'
                              : 'Bildirim tercihiniz pasif olarak güncellendi'
                          );
                        },
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Privacy & Security Section
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildSettingsItem(
                        context,
                        icon: Icons.dark_mode_outlined,
                        title: 'Karanlık Mod',
                        subtitle: 'Açık ve karanlık temalar arasında geçiş yap',
                        trailing: Switch(
                          value: Theme.of(context).brightness == Brightness.dark,
                          onChanged: (value) {
                            // TODO: Implement theme switching
                          },
                        ),
                        onTap: () {
                          // TODO: Implement theme switching
                        },
                      ),
                      const Divider(height: 1),
                      _buildSettingsItem(
                        context,
                        icon: Icons.analytics_outlined,
                        title: 'Veri Paylaşımı',
                        subtitle: 'Güvenlik ve gizlilik için verilerimi geliştirmek için paylaşıyorum',
                        trailing: Switch(
                          value: _dataSharingEnabled,
                          onChanged: (value) {
                            setState(() {
                              _dataSharingEnabled = value;
                            });
                            _showSnackBar(
                              value 
                                ? 'Veri paylaşımı aktif olarak güncellendi'
                                : 'Veri paylaşımı pasif olarak güncellendi'
                            );
                          },
                        ),
                        onTap: () {
                          setState(() {
                            _dataSharingEnabled = !_dataSharingEnabled;
                          });
                          _showSnackBar(
                            _dataSharingEnabled 
                              ? 'Veri paylaşımı aktif olarak güncellendi'
                              : 'Veri paylaşımı pasif olarak güncellendi'
                          );
                        },
                      ),
                      const Divider(height: 1),
                      _buildSettingsItem(
                        context,
                        icon: Icons.analytics_outlined,
                        title: 'Analitik Veriler',
                        subtitle: 'Uygulama performansını iyileştirmek için analitik verileri paylaş',
                        trailing: Switch(
                          value: _analyticsEnabled,
                          onChanged: (value) {
                            setState(() {
                              _analyticsEnabled = value;
                            });
                            _showSnackBar(
                              value 
                                ? 'Analitik veriler aktif olarak güncellendi'
                                : 'Analitik veriler pasif olarak güncellendi'
                            );
                          },
                        ),
                        onTap: () {
                          setState(() {
                            _analyticsEnabled = !_analyticsEnabled;
                          });
                          _showSnackBar(
                            _analyticsEnabled 
                              ? 'Analitik veriler aktif olarak güncellendi'
                              : 'Analitik veriler pasif olarak güncellendi'
                          );
                        },
                      ),
                      const Divider(height: 1),
                      _buildSettingsItem(
                        context,
                        icon: Icons.bug_report_outlined,
                        title: 'Hata Raporlama',
                        subtitle: 'Uygulama hatalarını otomatik olarak raporla',
                        trailing: Switch(
                          value: _crashReportingEnabled,
                          onChanged: (value) {
                            setState(() {
                              _crashReportingEnabled = value;
                            });
                            _showSnackBar(
                              value 
                                ? 'Hata raporlama aktif olarak güncellendi'
                                : 'Hata raporlama pasif olarak güncellendi'
                            );
                          },
                        ),
                        onTap: () {
                          setState(() {
                            _crashReportingEnabled = !_crashReportingEnabled;
                          });
                          _showSnackBar(
                            _crashReportingEnabled 
                              ? 'Hata raporlama aktif olarak güncellendi'
                              : 'Hata raporlama pasif olarak güncellendi'
                          );
                        },
                      ),
                      const Divider(height: 1),
                      _buildSettingsItem(
                        context,
                        icon: Icons.email_outlined,
                        title: 'Pazarlama E-postaları',
                        subtitle: 'Yeni özellikler ve güncellemeler hakkında e-posta al',
                        trailing: Switch(
                          value: _marketingEmailsEnabled,
                          onChanged: (value) {
                            setState(() {
                              _marketingEmailsEnabled = value;
                            });
                            _showSnackBar(
                              value 
                                ? 'Pazarlama e-postaları aktif olarak güncellendi'
                                : 'Pazarlama e-postaları pasif olarak güncellendi'
                            );
                          },
                        ),
                        onTap: () {
                          setState(() {
                            _marketingEmailsEnabled = !_marketingEmailsEnabled;
                          });
                          _showSnackBar(
                            _marketingEmailsEnabled 
                              ? 'Pazarlama e-postaları aktif olarak güncellendi'
                              : 'Pazarlama e-postaları pasif olarak güncellendi'
                          );
                        },
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Logout Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await ref.read(authViewModelProvider.notifier).logout();
                      if (context.mounted) {
                        context.go('/login');
                      }
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Çıkış Yap'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Something went wrong',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSettingsItem(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          themeMode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode,
          color: Theme.of(context).primaryColor,
          size: 20,
        ),
      ),
      title: const Text('Tema'),
      subtitle: Text(_getThemeModeText(themeMode)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              Icons.light_mode,
              color: themeMode == ThemeMode.light 
                  ? Theme.of(context).primaryColor 
                  : Theme.of(context).textTheme.bodySmall?.color,
            ),
            onPressed: () {
              ref.read(themeProvider.notifier).setThemeMode(ThemeMode.light);
            },
          ),
          IconButton(
            icon: Icon(
              Icons.dark_mode,
              color: themeMode == ThemeMode.dark 
                  ? Theme.of(context).primaryColor 
                  : Theme.of(context).textTheme.bodySmall?.color,
            ),
            onPressed: () {
              ref.read(themeProvider.notifier).setThemeMode(ThemeMode.dark);
            },
          ),
          IconButton(
            icon: Icon(
              Icons.settings_system_daydream,
              color: themeMode == ThemeMode.system 
                  ? Theme.of(context).primaryColor 
                  : Theme.of(context).textTheme.bodySmall?.color,
            ),
            onPressed: () {
              ref.read(themeProvider.notifier).setThemeMode(ThemeMode.system);
            },
          ),
        ],
      ),
    );
  }

  String _getThemeModeText(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Açık tema';
      case ThemeMode.dark:
        return 'Karanlık tema';
      case ThemeMode.system:
        return 'Sistem teması';
    }
  }
}
