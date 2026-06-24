import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:medprescribe_frontend/features/admin/presentation/role_management_screen.dart';
import 'package:medprescribe_frontend/features/auth/presentation/login_screen.dart';
import 'package:medprescribe_frontend/features/auth/presentation/otp_screen.dart';
import 'package:medprescribe_frontend/features/auth/presentation/providers/auth_provider.dart';
import 'package:medprescribe_frontend/features/dashboard/presentation/dashboard_screen.dart';
import 'package:medprescribe_frontend/features/drugs/presentation/drug_detail_screen.dart';
import 'package:medprescribe_frontend/features/drugs/presentation/drug_lookup_screen.dart';
import 'package:medprescribe_frontend/features/icd/presentation/disease_detail_screen.dart';
import 'package:medprescribe_frontend/features/icd/presentation/icd_lookup_screen.dart';
import 'package:medprescribe_frontend/features/interactions/presentation/interaction_checker_screen.dart';
import 'package:medprescribe_frontend/features/prescriptions/presentation/prescription_builder_screen.dart';
import 'package:medprescribe_frontend/shared/layouts/navigation_shell.dart';

class AppRoutes {
  static const String login = '/login';
  static const String otp = '/otp';
  static const String dashboard = '/dashboard';
  static const String icd = '/icd';
  static const String icdDetail = '/icd/detail/:id';
  static const String drugs = '/drugs';
  static const String drugDetail = '/drugs/detail/:id';
  static const String interactions = '/interactions';
  static const String prescriptions = '/prescriptions';
  static const String admin = '/admin';

  // GoRouter is created with a ProviderContainer reference so the
  // redirect function can access the auth state.
  static GoRouter createRouter(ProviderContainer container) {
    return GoRouter(
      initialLocation: login,
      refreshListenable: _AuthStateListenable(container),
      redirect: (context, state) {
        final authState = container.read(authProvider);
        final isAuth = authState.isAuthenticated;
        final isLoading = authState.status == AuthStatus.initial;
        final isOnLoginPage = state.matchedLocation == login;
        final isOnOtpPage = state.matchedLocation == otp;

        // Still initializing — don't redirect yet
        if (isLoading) return null;

        // Not authenticated → send to login (unless already there or on OTP)
        if (!isAuth && !isOnLoginPage && !isOnOtpPage) {
          return login;
        }

        // Already authenticated → don't stay on login/otp
        if (isAuth && (isOnLoginPage || isOnOtpPage)) {
          return dashboard;
        }

        return null;
      },
      routes: [
        // ─── Auth Routes (Outside shell) ─────────────────────────
        GoRoute(
          path: login,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: otp,
          builder: (context, state) => const OtpScreen(),
        ),

        // ─── App Core Shell (with sidebar navigation) ─────────────
        ShellRoute(
          builder: (context, state, child) {
            return NavigationShell(child: child);
          },
          routes: [
            GoRoute(
              path: dashboard,
              builder: (context, state) => const DashboardScreen(),
            ),
            GoRoute(
              path: icd,
              builder: (context, state) => const IcdLookupScreen(),
              routes: [
                GoRoute(
                  path: 'detail/:id',
                  builder: (context, state) {
                    final id = state.pathParameters['id'] ?? '';
                    return DiseaseDetailScreen(icdId: id);
                  },
                ),
              ],
            ),
            GoRoute(
              path: drugs,
              builder: (context, state) => const DrugLookupScreen(),
              routes: [
                GoRoute(
                  path: 'detail/:id',
                  builder: (context, state) {
                    final id = state.pathParameters['id'] ?? '';
                    return DrugDetailScreen(drugId: id);
                  },
                ),
              ],
            ),
            GoRoute(
              path: interactions,
              builder: (context, state) => const InteractionCheckerScreen(),
            ),
            GoRoute(
              path: prescriptions,
              builder: (context, state) => const PrescriptionBuilderScreen(),
            ),
            GoRoute(
              path: admin,
              builder: (context, state) => const RoleManagementScreen(),
            ),
          ],
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                '404 — Page Not Found',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => context.go(login),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Makes GoRouter react to auth state changes via Riverpod.
class _AuthStateListenable extends ChangeNotifier {
  final ProviderContainer _container;

  _AuthStateListenable(this._container) {
    _container.listen<AuthState>(
      authProvider,
      (_, __) => notifyListeners(),
    );
  }
}
