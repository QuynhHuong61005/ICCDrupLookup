import 'package:flutter/material.dart';
import 'package:medprescribe_frontend/shared/constants/app_constants.dart';

enum AppButtonStyle { elevated, outlined, text }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final AppButtonStyle style;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.style = AppButtonStyle.elevated,
    this.backgroundColor,
    this.textColor,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonWidth = width ?? double.infinity;

    Widget childWidget;
    if (isLoading) {
      childWidget = SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            style == AppButtonStyle.elevated ? Colors.white : theme.primaryColor,
          ),
        ),
      );
    } else {
      childWidget = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18),
            AppSpacing.gapW8,
          ],
          Text(text),
        ],
      );
    }

    switch (style) {
      case AppButtonStyle.outlined:
        return SizedBox(
          width: buttonWidth,
          height: 48,
          child: OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: backgroundColor ?? theme.primaryColor),
              foregroundColor: textColor ?? theme.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.mdBorderRadius,
              ),
            ),
            child: childWidget,
          ),
        );
      case AppButtonStyle.text:
        return SizedBox(
          width: buttonWidth,
          height: 48,
          child: TextButton(
            onPressed: isLoading ? null : onPressed,
            style: TextButton.styleFrom(
              foregroundColor: textColor ?? theme.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.mdBorderRadius,
              ),
            ),
            child: childWidget,
          ),
        );
      case AppButtonStyle.elevated:
        return SizedBox(
          width: buttonWidth,
          height: 48,
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: backgroundColor ?? theme.primaryColor,
              foregroundColor: textColor ?? Colors.white,
              elevation: 0,
            ),
            child: childWidget,
          ),
        );
    }
  }
}
