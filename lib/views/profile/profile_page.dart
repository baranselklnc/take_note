import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/notes_viewmodel.dart';
import '../../providers/theme_provider.dart';
import '../../models/note.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {

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
    final notesState = ref.watch(notesViewModelProvider);

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
              child: Text('Giriş yapılmamış'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Profile Header
                _buildProfileHeader(context, user),
                
                const SizedBox(height: 24),
                
                // Statistics Section
                _buildStatisticsSection(context, notesState),
                
                const SizedBox(height: 24),
                
                // Theme Section
                _buildThemeSection(context),
                
                const SizedBox(height: 24),
                
                // Account Actions
                _buildAccountActions(context),
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
                'Bir hata oluştu',
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

  Widget _buildProfileHeader(BuildContext context, user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            child: Text(
              user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user.name.isNotEmpty ? user.name : 'Kullanıcı',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user.email,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'TakeNoters',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection(BuildContext context, AsyncValue<List<Note>> notesState) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(
                  Icons.analytics_outlined,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'İstatistikler',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          notesState.when(
            data: (notes) {
              final totalNotes = notes.length;
              final pinnedNotes = notes.where((note) => note.isPinned).length;
              final totalCharacters = notes.fold<int>(0, (sum, note) => sum + note.content.length);
              final avgNoteLength = totalNotes > 0 ? (totalCharacters / totalNotes).round() : 0;
              
              return Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            context,
                            'Toplam Not',
                            totalNotes.toString(),
                            Icons.note_outlined,
                            Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            context,
                            'Sabitlenen',
                            pinnedNotes.toString(),
                            Icons.push_pin_outlined,
                            Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            context,
                            'Toplam Karakter',
                            totalCharacters.toString(),
                            Icons.text_fields_outlined,
                            Colors.green,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            context,
                            'Ort. Uzunluk',
                            avgNoteLength.toString(),
                            Icons.analytics_outlined,
                            Colors.purple,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stack) => Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'İstatistikler yüklenemedi',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSection(BuildContext context) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(
                  Icons.palette_outlined,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Tema Ayarları',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          _buildThemeSettingsItem(context),
        ],
      ),
    );
  }

  Widget _buildAccountActions(BuildContext context) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(
                  Icons.account_circle_outlined,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Hesap İşlemleri',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.edit_outlined,
                color: Colors.blue,
                size: 20,
              ),
            ),
            title: const Text('Profil Düzenle'),
            subtitle: const Text('Adınızı ve e-posta adresinizi güncelleyin'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              _showSnackBar('Profil düzenleme özelliği yakında eklenecek');
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.security_outlined,
                color: Colors.orange,
                size: 20,
              ),
            ),
            title: const Text('Güvenlik'),
            subtitle: const Text('Şifre değiştir ve güvenlik ayarları'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              _showSnackBar('Güvenlik ayarları yakında eklenecek');
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.logout,
                color: Colors.red,
                size: 20,
              ),
            ),
            title: const Text('Çıkış Yap'),
            subtitle: const Text('Hesabınızdan güvenli şekilde çıkış yapın'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () async {
              await ref.read(authViewModelProvider.notifier).logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
        ],
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
