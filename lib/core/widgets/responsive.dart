import 'package:flutter/material.dart';

class Responsive {
  static double pagePadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 900) return 40;
    if (width >= 600) return 28;
    return 20;
  }

  static double contentWidth(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 900) return 720;
    if (width >= 600) return 560;
    return width;
  }

  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= 600;
}

class ResponsiveScaffoldBody extends StatelessWidget {
  const ResponsiveScaffoldBody({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: Responsive.contentWidth(context)),
        child: child,
      ),
    );
  }
}
