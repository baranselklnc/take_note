import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'shared/theme/app_theme.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'views/auth/login_page.dart';
import 'views/main/main_navigation_page.dart';
import 'views/onboarding/onboarding_page.dart';
import 'providers/onboarding_provider.dart';
import 'core/constants/supabase_constants.dart';
import 'services/server_discovery_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  // Initialize Supabase
  await Supabase.initialize(
    url: SupabaseConstants.supabaseUrl,
    anonKey: SupabaseConstants.supabaseAnonKey,
  );
  
  // Initialize server discovery
  await ServerDiscoveryService.initialize();
  
  // Initialize storage
  final container = ProviderContainer();
  await container.read(storageServiceProvider).init();
  
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MainApp(),
    ),
  );
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider);
    final isOnboardingCompleted = ref.watch(onboardingProvider);

    return MaterialApp(
      title: 'Take Note',
      theme: AppTheme.lightTheme,
      home: isOnboardingCompleted
          ? authState.when(
              data: (user) => user != null ? const MainNavigationPage() : const LoginPage(),
              loading: () => const ServerDiscoveryScreen(),
              error: (error, stack) => const LoginPage(),
            )
          : const OnboardingPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ServerDiscoveryScreen extends StatefulWidget {
  const ServerDiscoveryScreen({super.key});

  @override
  State<ServerDiscoveryScreen> createState() => _ServerDiscoveryScreenState();
}

class _ServerDiscoveryScreenState extends State<ServerDiscoveryScreen> {
  bool _isRetrying = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            const Text(
              'Sunucuya bağlanıyor...',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            const Text(
              'Bu işlem birkaç saniye sürebilir',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            if (_isRetrying) ...[
              const Text(
                'Bağlantı kurulamadı',
                style: TextStyle(fontSize: 16, color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _retryConnection,
                child: const Text('Tekrar Dene'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _retryConnection() async {
    setState(() {
      _isRetrying = true;
    });

    try {
      await ServerDiscoveryService.retryDiscovery();
    } catch (e) {
      // Hata gösterimi için
    }
  }
}
