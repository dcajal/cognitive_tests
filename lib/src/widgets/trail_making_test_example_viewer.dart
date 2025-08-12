import 'package:flutter/material.dart';

enum TrailMakingTestType {
  testA,
  testB,
}

class TrailMakingTestExampleViewer extends StatelessWidget {
  final TrailMakingTestType testType;
  final double? height;
  final double? width;

  const TrailMakingTestExampleViewer({
    super.key,
    required this.testType,
    this.height,
    this.width,
  });

  String get _assetPath {
    switch (testType) {
      case TrailMakingTestType.testA:
        return 'assets/tmta_example.png';
      case TrailMakingTestType.testB:
        return 'assets/tmtb_example.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      _assetPath,
      fit: BoxFit.contain,
      package: 'cognitive_tests',
      height: height,
      width: width,
    );
  }
}
