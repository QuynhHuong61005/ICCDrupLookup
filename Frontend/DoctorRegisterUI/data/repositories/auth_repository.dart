import 'package:medprescribe_frontend/core/models/auth_response_model.dart';
import 'package:medprescribe_frontend/core/models/user_model.dart';
import 'package:medprescribe_frontend/core/network/token_manager.dart';
import 'package:medprescribe_frontend/services/api_service.dart';

/// Handles all authentication API calls against real backend.
class AuthRepository {
  final ApiService _api;

  AuthRepository({ApiService? apiService}) : _api = apiService ?? api;

  /// Login with email and password.
  /// Backend returns { accessToken, user } on success (no OTP flow for now).
  Future<AuthResponseModel> login(String email, String password) async {
    final response = await _api.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    final authResponse = AuthResponseModel.fromJson(response);
    if (authResponse.accessToken.isNotEmpty) {
      await TokenManager.saveAccessToken(authResponse.accessToken);
      if (authResponse.refreshToken.isNotEmpty) {
        await TokenManager.saveRefreshToken(authResponse.refreshToken);
      }
    }
    return authResponse;
  }

  /// Verify 2FA OTP code.
  Future<AuthResponseModel> verifyOtp(String email, String otpCode) async {
    final response = await _api.post<Map<String, dynamic>>(
      '/auth/verify-otp',
      data: {'email': email, 'code': otpCode},
    );
    final authResponse = AuthResponseModel.fromJson(response);
    await TokenManager.saveAccessToken(authResponse.accessToken);
    if (authResponse.refreshToken.isNotEmpty) {
      await TokenManager.saveRefreshToken(authResponse.refreshToken);
    }
    return authResponse;
  }

  /// Fetch the current logged-in user's profile.
  Future<UserModel> getProfile() async {
    final response = await _api.get<Map<String, dynamic>>('/auth/profile');
    return UserModel.fromJson(response);
  }

  /// Logout and clear all stored tokens.
  Future<void> logout() async {
    try {
      await _api.post<dynamic>('/auth/logout');
    } catch (_) {
      // Always clear tokens regardless of API outcome
    } finally {
      await TokenManager.clearAll();
    }
  }
}
