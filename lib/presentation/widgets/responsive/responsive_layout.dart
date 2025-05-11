import 'package:firebase_parking/presentation/widgets/responsive/desktop_scaffold.dart';
import 'package:firebase_parking/presentation/widgets/responsive/mobile_scaffold.dart';
import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1100) {
          return const DesktopScaffold();
        } else {
          return const MobileScaffold();
        }
      },
    );
  }
}
