import 'package:flutter/material.dart';
import 'package:medprescribe_frontend/shared/constants/app_constants.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final double? borderRadius;
  final bool hasBorder;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.onTap,
    this.backgroundColor,
    this.borderRadius,
    this.hasBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor =
        backgroundColor ?? theme.cardTheme.color ?? theme.colorScheme.surface;
    final radius = borderRadius != null
        ? BorderRadius.circular(borderRadius!)
        : AppRadius.lgBorderRadius;

    Widget cardWidget = Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: radius,
        border: hasBorder
            ? Border.all(
                color: theme.brightness == Brightness.light
                    ? Colors.grey.withValues(alpha: 0.12)
                    : Colors.white.withValues(alpha: 0.08),
                width: 1,
              )
            : null,
        boxShadow: AppShadows.cardShadow,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );

    return cardWidget;
  }
}
