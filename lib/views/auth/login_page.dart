import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../shared/theme/app_theme.dart';
import 'signup_page.dart';
import '../notes/notes_list_page.dart';

/// Login page
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      ref.read(authViewModelProvider.notifier).login(
        _emailController.text.trim(),
        _passwordController.text,
      );
    }
  }

  void _navigateToSignup() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const SignupPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);

    // Navigate to notes list if authenticated
    ref.listen(authViewModelProvider, (previous, next) {
      next.whenData((user) {
        if (user != null) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const NotesListPage()),
          );
        }
      });
    });

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(
                    color: Theme.of(context).dividerColor.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo/Title
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            Icons.note_alt_rounded,
                            size: 60,
                            color: Theme.of(context).primaryColor,
                          ),
                        ).animate()
                            .scale(duration: 600.ms, curve: Curves.elasticOut)
                            .fadeIn(duration: 400.ms),
                        
                        const SizedBox(height: 24),
                        
                        Text(
                          'Tekrar Hoş Geldiniz',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ).animate(delay: 200.ms)
                            .slideY(begin: 0.3, end: 0, curve: Curves.easeOutCubic)
                            .fadeIn(),
                        
                        const SizedBox(height: 8),
                        
                        Text(
                          'Take Note\'a devam etmek için giriş yapın',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                          textAlign: TextAlign.center,
                        ).animate(delay: 300.ms)
                            .slideY(begin: 0.3, end: 0, curve: Curves.easeOutCubic)
                            .fadeIn(),
                        
                        const SizedBox(height: 32),

                        // Email field
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: 'E-posta',
                            prefixIcon: Icon(
                              Icons.email_outlined,
                              color: Theme.of(context).primaryColor,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: Theme.of(context).dividerColor.withOpacity(0.3),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: Theme.of(context).dividerColor.withOpacity(0.3),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: Theme.of(context).primaryColor,
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: Theme.of(context).cardColor,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Lütfen e-posta adresinizi girin';
                            }
                            if (!value.contains('@')) {
                              return 'Lütfen geçerli bir e-posta adresi girin';
                            }
                            return null;
                          },
                        ).animate(delay: 400.ms)
                            .slideY(begin: 0.3, end: 0, curve: Curves.easeOutCubic)
                            .fadeIn(),
                        
                        const SizedBox(height: 20),

                        // Password field
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _login(),
                          decoration: InputDecoration(
                            labelText: 'Şifre',
                            prefixIcon: Icon(
                              Icons.lock_outlined,
                              color: Theme.of(context).primaryColor,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                color: Theme.of(context).primaryColor,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: Theme.of(context).dividerColor.withOpacity(0.3),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: Theme.of(context).dividerColor.withOpacity(0.3),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: Theme.of(context).primaryColor,
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: Theme.of(context).cardColor,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Lütfen şifrenizi girin';
                            }
                            if (value.length < 6) {
                              return 'Şifre en az 6 karakter olmalıdır';
                            }
                            return null;
                          },
                        ).animate(delay: 500.ms)
                            .slideY(begin: 0.3, end: 0, curve: Curves.easeOutCubic)
                            .fadeIn(),
                        
                        const SizedBox(height: 32),

                        // Login button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: authState.isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: authState.isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Text(
                                    'Giriş Yap',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ).animate(delay: 600.ms)
                            .slideY(begin: 0.3, end: 0, curve: Curves.easeOutCubic)
                            .fadeIn(),
                        const SizedBox(height: 20),

                        // Error message
                        if (authState.hasError)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.errorColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppTheme.errorColor.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: AppTheme.errorColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    authState.error.toString(),
                                    style: TextStyle(
                                      color: AppTheme.errorColor,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ).animate(delay: 700.ms)
                              .slideY(begin: 0.3, end: 0, curve: Curves.easeOutCubic)
                              .fadeIn(),

                        const SizedBox(height: 24),

                        // Sign up link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Hesabınız yok mu? ",
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).textTheme.bodySmall?.color,
                              ),
                            ),
                            TextButton(
                              onPressed: _navigateToSignup,
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                'Kayıt Ol',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ).animate(delay: 800.ms)
                            .slideY(begin: 0.3, end: 0, curve: Curves.easeOutCubic)
                            .fadeIn(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
