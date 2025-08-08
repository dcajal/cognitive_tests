import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';

/// Widget that handles PDF viewing for cognitive tests
class StroopViewer extends StatefulWidget {
  /// Path to the PDF asset
  final String assetPath = 'packages/cognitive_tests/assets/stroop.pdf';

  /// Current page number to display
  final int currentPage;

  /// Callback when page changes are needed
  final VoidCallback? onPageChangeRequested;

  const StroopViewer({
    super.key,
    required this.currentPage,
    this.onPageChangeRequested,
  });

  @override
  State<StroopViewer> createState() => _StroopViewerState();
}

class _StroopViewerState extends State<StroopViewer> {
  late final PdfController _pdfController;

  @override
  void initState() {
    super.initState();
    _pdfController = PdfController(
      document: PdfDocument.openAsset(widget.assetPath),
    );
  }

  @override
  void didUpdateWidget(StroopViewer oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update PDF page when currentPage changes
    if (oldWidget.currentPage != widget.currentPage) {
      _pdfController.jumpToPage(widget.currentPage);
    }
  }

  @override
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PdfView(
      controller: _pdfController,
    );
  }

  /// Get the PDF controller for external access if needed
  PdfController get controller => _pdfController;
}
