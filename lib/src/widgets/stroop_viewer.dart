import 'package:flutter/material.dart';

class StroopViewer extends StatelessWidget {
  final int currentPage;
  final VoidCallback? onPageChangeRequested;

  const StroopViewer({
    super.key,
    required this.currentPage,
    this.onPageChangeRequested,
  });

  static const List<String> _pageAssets = [
    'assets/stroop-0.png',
    'assets/stroop-1.png',
    'assets/stroop-2.png',
  ];

  static int get totalPages => _pageAssets.length;

  @override
  Widget build(BuildContext context) {
    final safeIndex = currentPage.clamp(0, _pageAssets.length - 1);
    return Image.asset(
      _pageAssets[safeIndex],
      fit: BoxFit.contain,
      package: 'cognitive_tests',
    );
  }
}
