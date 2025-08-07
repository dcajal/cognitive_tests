import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';

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
        return 'packages/cognitive_tests/assets/tmta_example.pdf';
      case TrailMakingTestType.testB:
        return 'packages/cognitive_tests/assets/tmtb_example.pdf';
    }
  }

  @override
  Widget build(BuildContext context) {
    return PdfView(
      controller: PdfController(
        document: PdfDocument.openAsset(_assetPath),
      ),
    );
  }
}
