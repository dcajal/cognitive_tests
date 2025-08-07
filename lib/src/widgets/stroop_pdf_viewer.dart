import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

/// Widget that handles PDF viewing for cognitive tests
class StroopPdfViewer extends StatefulWidget {
  /// Path to the PDF asset
  final String assetPath = 'assets/stroop.pdf';

  /// Current page number to display
  final int currentPage;

  /// Callback when page changes are needed
  final VoidCallback? onPageChangeRequested;

  const StroopPdfViewer({
    super.key,
    required this.currentPage,
    this.onPageChangeRequested,
  });

  @override
  State<StroopPdfViewer> createState() => _StroopPdfViewerState();
}

class _StroopPdfViewerState extends State<StroopPdfViewer> {
  late final PdfViewerController _pdfController;

  @override
  void initState() {
    super.initState();
    _pdfController = PdfViewerController();
  }

  @override
  void didUpdateWidget(StroopPdfViewer oldWidget) {
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
    return SfPdfViewer.asset(
      widget.assetPath,
      controller: _pdfController,
      pageLayoutMode: PdfPageLayoutMode.single,
      canShowScrollHead: false,
      enableDoubleTapZooming: false,
      enableTextSelection: false,
      enableDocumentLinkAnnotation: false,
    );
  }

  /// Get the PDF controller for external access if needed
  PdfViewerController get controller => _pdfController;
}
