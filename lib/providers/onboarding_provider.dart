import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/storage/local_storage.dart';

class OnboardingNotifier extends StateNotifier<bool> {
  OnboardingNotifier(this._localStorage) : super(false) {
    _checkOnboardingStatus();
  }

  final LocalStorage _localStorage;
  static const String _onboardingKey = 'onboarding_completed';

  Future<void> _checkOnboardingStatus() async {
    try {
      // Ensure storage is initialized before reading
      await _localStorage.init();
      final isCompleted = await _localStorage.getAppSetting<bool>(_onboardingKey) ?? false;
      state = isCompleted;
    } catch (e) {
      // If there's an error, assume onboarding is not completed
      state = false;
    }
  }

  Future<void> completeOnboarding() async {
    try {
      // Ensure storage is initialized before saving
      await _localStorage.init();
      await _localStorage.saveAppSetting(_onboardingKey, true);
      state = true;
    } catch (e) {
      // If storage fails, still mark onboarding as completed in memory
      state = true;
    }
  }

  Future<void> resetOnboarding() async {
    try {
      await _localStorage.init();
      await _localStorage.removeAppSetting(_onboardingKey);
      state = false;
    } catch (e) {
      // If storage fails, still reset state
      state = false;
    }
  }
}

final onboardingProvider = StateNotifierProvider<OnboardingNotifier, bool>((ref) {
  final localStorage = ref.watch(localStorageProvider);
  return OnboardingNotifier(localStorage);
});
