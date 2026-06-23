import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medprescribe_frontend/core/models/user_model.dart';
import 'package:medprescribe_frontend/core/network/token_manager.dart';
import 'package:medprescribe_frontend/features/auth/data/repositories/auth_repository.dart';

// ─── Auth State ─────────────────────────────────────────────────

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? error;
  final bool requires2FA;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.error,
    this.requires2FA = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? error,
    bool? requires2FA,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error,
      requires2FA: requires2FA ?? this.requires2FA,
    );
  }

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.loading;
}

// ─── Auth Notifier ───────────────────────────────────────────────

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo;

  AuthNotifier(this._repo) : super(const AuthState()) {
    _checkInitialAuthState();
  }

  Future<void> _checkInitialAuthState() async {
    final loggedIn = await TokenManager.isLoggedIn();
    if (loggedIn) {
      try {
        final user = await _repo.getProfile();
        state = AuthState(status: AuthStatus.authenticated, user: user);
      } catch (_) {
        await TokenManager.clearAll();
        state = const AuthState(status: AuthStatus.unauthenticated);
      }
    } else {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      final response = await _repo.login(email, password);
      if (response.user.otpEnabled) {
        // Requires OTP verification — don't authenticate yet
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          requires2FA: true,
          user: response.user,
        );
        return false;
      }
      state = AuthState(
        status: AuthStatus.authenticated,
        user: response.user,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> verifyOtp(String email, String otpCode) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      final response = await _repo.verifyOtp(email, otpCode);
      state = AuthState(
        status: AuthStatus.authenticated,
        user: response.user,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  void clearError() {
    state = state.copyWith(error: null, status: AuthStatus.unauthenticated);
  }
}

// ─── Providers ───────────────────────────────────────────────────

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

/// Convenience provider to get the current user or null.
final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authProvider).user;
});
