import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:medprescribe_frontend/features/auth/presentation/providers/auth_provider.dart';
import 'package:medprescribe_frontend/shared/constants/app_constants.dart';
import 'package:medprescribe_frontend/shared/widgets/app_button.dart';
import 'package:medprescribe_frontend/shared/widgets/app_card.dart';
import 'package:medprescribe_frontend/shared/widgets/app_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      final success = await ref.read(authProvider.notifier).login(
            _emailController.text.trim(),
            _passwordController.text,
          );

      if (!mounted) return;

      final authState = ref.read(authProvider);
      if (authState.requires2FA) {
        // Navigate to OTP screen with email
        context.push('/otp');
      } else if (success && authState.isAuthenticated) {
        context.go('/dashboard');
      }
      // If error, it will be shown by rebuilding from authProvider state
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _formKey,
              child: AppCard(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl, vertical: AppSpacing.xxl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // App Logo & Header
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color:
                            theme.colorScheme.primary.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.health_and_safety,
                        size: 56,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    AppSpacing.gapH24,
                    Text(
                      'MedPrescribe',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontSize: 26,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    AppSpacing.gapH8,
                    Text(
                      'AI Clinical Prescription & Drug Lookup',
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    AppSpacing.gapH32,

                    // Error display
                    if (authState.error != null) ...[
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.08),
                          borderRadius: AppRadius.smBorderRadius,
                          border: Border.all(
                              color: Colors.red.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline,
                                color: Colors.red, size: 16),
                            AppSpacing.gapW8,
                            Expanded(
                              child: Text(
                                authState.error!,
                                style: const TextStyle(
                                    color: Colors.red, fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                      AppSpacing.gapH16,
                    ],

                    // Input Fields
                    AppTextField(
                      controller: _emailController,
                      label: 'Email Address',
                      hint: 'doctor@medprescribe.com',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email_outlined,
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!val.contains('@')) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    AppSpacing.gapH24,
                    AppTextField(
                      controller: _passwordController,
                      label: 'Password',
                      hint: '••••••••',
                      isPassword: true,
                      prefixIcon: Icons.lock_outline,
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (val.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    AppSpacing.gapH16,

                    // Login Button
                    AppButton(
                      text: 'Login',
                      onPressed: _handleLogin,
                      isLoading: authState.isLoading,
                    ),
                    AppSpacing.gapH16,

                    // Sub-caption indicating accounts
                    Text(
                      'Accounts:\ndoctor@medprescribe.com / admin123',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
