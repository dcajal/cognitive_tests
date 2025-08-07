import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

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
        return 'assets/tmta_example.pdf';
      case TrailMakingTestType.testB:
        return 'assets/tmtb_example.pdf';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SfPdfViewer.asset(
      _assetPath,
      canShowScrollHead: false,
      enableDoubleTapZooming: false,
      enableTextSelection: false,
      enableDocumentLinkAnnotation: false,
    );
  }
}
