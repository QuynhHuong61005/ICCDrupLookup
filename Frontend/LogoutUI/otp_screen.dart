import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import 'package:medprescribe_frontend/shared/constants/app_constants.dart';
import 'package:medprescribe_frontend/shared/themes/app_theme.dart';
import 'package:medprescribe_frontend/shared/widgets/app_button.dart';
import 'package:medprescribe_frontend/shared/widgets/app_card.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _pinController = TextEditingController();
  final _focusNode = FocusNode();
  int _counter = 60;
  Timer? _timer;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pinController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startTimer() {
    _counter = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_counter > 0) {
        setState(() => _counter--);
      } else {
        _timer?.cancel();
      }
    });
  }

  void _verifyOtp() {
    final code = _pinController.text;
    if (code.length < 6) return;

    setState(() => _isLoading = true);

    // Simulate API delay
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() => _isLoading = false);
        // For testing, mock code is 123456
        if (code == '123456' || code == '654321') {
          context.go('/dashboard');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Invalid code. Try entering "123456" for demo authentication.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Styling configuration for Pinput
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: theme.textTheme.titleMedium?.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.onSurface,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppRadius.mdBorderRadius,
        border: Border.all(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.12)),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: theme.colorScheme.primary, width: 2),
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: AppCard(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl, vertical: AppSpacing.xxl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Shield security icon
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.shield_outlined,
                      size: 56,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  AppSpacing.gapH24,
                  Text(
                    '2FA Verification',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  AppSpacing.gapH8,
                  Text(
                    'Enter the 6-digit code sent to your authenticator app or email.',
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  AppSpacing.gapH32,

                  // Pinput input field
                  Pinput(
                    length: 6,
                    controller: _pinController,
                    focusNode: _focusNode,
                    defaultPinTheme: defaultPinTheme,
                    focusedPinTheme: focusedPinTheme,
                    onCompleted: (_) => _verifyOtp(),
                    androidSmsAutofillMethod: AndroidSmsAutofillMethod.none,
                    hapticFeedbackType: HapticFeedbackType.lightImpact,
                  ),
                  AppSpacing.gapH24,

                  // Countdown text
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.timer_outlined,
                          size: 16,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6)),
                      AppSpacing.gapW4,
                      Text(
                        _counter > 0
                            ? 'Code expires in ${_counter}s'
                            : 'Code expired',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: _counter > 0
                              ? theme.colorScheme.onSurface
                                  .withValues(alpha: 0.6)
                              : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.gapH24,

                  // Verification Buttons
                  AppButton(
                    text: 'Confirm Code',
                    onPressed:
                        _pinController.text.length == 6 ? _verifyOtp : null,
                    isLoading: _isLoading,
                  ),
                  AppSpacing.gapH8,
                  AppButton(
                    text: 'Resend Code',
                    onPressed: _counter == 0
                        ? () {
                            _startTimer();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Mock 2FA OTP code re-sent!')),
                            );
                          }
                        : null,
                    style: AppButtonStyle.text,
                  ),

                  AppSpacing.gapH8,
                  Text(
                    'Demo Bypass: Enter "123456"',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
