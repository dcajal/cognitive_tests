import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:cognitive_tests/cognitive_tests.dart';

/// Widget that combines PDF viewing and gesture detection for Trail Making Test
class TrailMakingTestViewer extends StatefulWidget {
  /// Test logic handler
  final TrailMakingTest testLogic;

  /// Whether this is the first test (TMT-A) or second test (TMT-B)
  final bool isFirstTest;

  /// Global key for the sheet widget (needed for test completion)
  final GlobalKey sheetKey;

  const TrailMakingTestViewer({
    super.key,
    required this.testLogic,
    required this.isFirstTest,
    required this.sheetKey,
  });

  @override
  State<TrailMakingTestViewer> createState() => _TrailMakingTestViewerState();
}

class _TrailMakingTestViewerState extends State<TrailMakingTestViewer> {
  final GlobalKey<TrailGestureDetectorState> _gestureDetectorKey =
      GlobalKey<TrailGestureDetectorState>();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: TmtSheet(
            key: widget.sheetKey,
            firstTest: widget.isFirstTest,
          ),
        ),
        TrailGestureDetector(
          key: _gestureDetectorKey,
          testLogic: widget.testLogic,
        ),
      ],
    );
  }

  /// Clear gesture data (called from parent)
  void clearGestureData() {
    setState(() {
      widget.testLogic.clearGestureData();
    });
  }
}

/// PDF sheet widget for Trail Making Test
class TmtSheet extends StatelessWidget {
  final List<String> testPath = [
    'packages/cognitive_tests/assets/tmta.pdf',
    'packages/cognitive_tests/assets/tmtb.pdf'
  ];
  final bool firstTest;

  TmtSheet({
    super.key,
    required this.firstTest,
  });

  @override
  Widget build(BuildContext context) {
    return PdfView(
      controller: PdfController(
        document: PdfDocument.openAsset(firstTest ? testPath[0] : testPath[1]),
      ),
    );
  }
}

/// Gesture detector for Trail Making Test
class TrailGestureDetector extends StatefulWidget {
  final TrailMakingTest testLogic;

  const TrailGestureDetector({
    super.key,
    required this.testLogic,
  });

  @override
  TrailGestureDetectorState createState() => TrailGestureDetectorState();
}

class TrailGestureDetectorState extends State<TrailGestureDetector> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) {
        setState(() {
          final renderBox = context.findRenderObject() as RenderBox;
          final localPosition = renderBox.globalToLocal(details.globalPosition);
          widget.testLogic.recordGesture(localPosition, details.globalPosition);
        });
      },
      onPanUpdate: (details) {
        setState(() {
          final renderBox = context.findRenderObject() as RenderBox;
          final localPosition = renderBox.globalToLocal(details.globalPosition);
          widget.testLogic.recordGesture(localPosition, details.globalPosition);
        });
      },
      onPanEnd: (details) {
        setState(() {
          widget.testLogic.recordGesture(null, null);
        });
      },
      child: CustomPaint(
          painter: TrailPainter(widget.testLogic.paintingOffsets),
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
          )),
    );
  }
}

/// Custom painter for drawing trail lines
class TrailPainter extends CustomPainter {
  final List<Offset?> offsets;

  TrailPainter(this.offsets) : super();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..isAntiAlias = true
      ..strokeWidth = 3;

    for (var i = 0; i < offsets.length - 1; i++) {
      if (offsets[i] != null && offsets[i + 1] != null) {
        canvas.drawLine(offsets[i]!, offsets[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
