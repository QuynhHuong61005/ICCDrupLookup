import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  /// Utility helper to check if current display is desktop size
  static bool isDesktop(BuildContext context) {
    return ResponsiveBreakpoints.of(context).isDesktop;
  }

  /// Utility helper to check if current display is tablet size
  static bool isTablet(BuildContext context) {
    return ResponsiveBreakpoints.of(context).isTablet;
  }

  /// Utility helper to check if current display is mobile size
  static bool isMobile(BuildContext context) {
    return ResponsiveBreakpoints.of(context).isMobile ||
        (!ResponsiveBreakpoints.of(context).isTablet && !ResponsiveBreakpoints.of(context).isDesktop);
  }

  @override
  Widget build(BuildContext context) {
    if (ResponsiveBreakpoints.of(context).isDesktop) {
      return desktop;
    } else if (ResponsiveBreakpoints.of(context).isTablet) {
      return tablet ?? desktop;
    } else {
      return mobile;
    }
  }
}
