import 'package:flutter/material.dart';
import 'package:cognitive_tests/cognitive_tests.dart';
import 'test_result_handler.dart';

class TrailMakingTestWidget extends StatefulWidget {
  const TrailMakingTestWidget({super.key});

  @override
  _TrailMakingTestWidgetState createState() => _TrailMakingTestWidgetState();
}

class _TrailMakingTestWidgetState extends State<TrailMakingTestWidget> {
  late TrailMakingTest trailTest;
  final GlobalKey sheetKey = GlobalKey();
  bool _testStarted = false;

  @override
  void initState() {
    super.initState();
    trailTest = TrailMakingTest(resultHandler: MyTestResultHandler());
  }

  void _startTest() {
    setState(() {
      _testStarted = true;
    });
  }

  Future<void> _finishCurrentTest() async {
    await trailTest.finishTest(context, sheetKey);

    if (trailTest.isFirstTest) {
      // Move to Part B
      trailTest.moveToNextTest();
      trailTest.clearGestureData();
      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Part A completed! Now starting Part B...'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      // Test completed, go back
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TMT ${trailTest.isFirstTest ? "Part A" : "Part B"}'),
        backgroundColor: Colors.purple,
      ),
      body: !_testStarted ? _buildInstructions() : _buildTestArea(),
      floatingActionButton: _testStarted
          ? FloatingActionButton(
              onPressed: _finishCurrentTest,
              backgroundColor: Colors.green,
              tooltip: 'Finish ${trailTest.isFirstTest ? "Part A" : "Part B"}',
              child: const Icon(Icons.check),
            )
          : null,
    );
  }

  Widget _buildInstructions() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Trail Making Test ${trailTest.isFirstTest ? "Part A" : "Part B"}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            Text(
              trailTest.isFirstTest
                  ? 'In Part A, you would connect numbers in sequence (1-2-3-4...).\n\n'
                      'For this demo, simply draw on the screen to simulate the trail.'
                  : 'In Part B, you would alternate between numbers and letters (1-A-2-B-3-C...).\n\n'
                      'Continue drawing to simulate the trail for Part B.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _startTest,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child:
                  Text('Start ${trailTest.isFirstTest ? "Part A" : "Part B"}'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestArea() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey[100],
          width: double.infinity,
          child: Text(
            'Draw on the screen below. Tap the green button when finished.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Expanded(
          child: GestureDetector(
            onPanUpdate: (details) {
              trailTest.recordGesture(
                details.localPosition,
                details.globalPosition,
              );
              setState(() {}); // Trigger repaint
            },
            onPanStart: (details) {
              trailTest.recordGesture(
                details.localPosition,
                details.globalPosition,
              );
              setState(() {});
            },
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.white,
              child: CustomPaint(
                key: sheetKey,
                painter: TrailPainter(trailTest.paintingOffsets),
                size: Size.infinite,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class TrailPainter extends CustomPainter {
  final List<Offset?> offsets;

  TrailPainter(this.offsets);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // Draw the trail
    for (int i = 0; i < offsets.length - 1; i++) {
      if (offsets[i] != null && offsets[i + 1] != null) {
        canvas.drawLine(offsets[i]!, offsets[i + 1]!, paint);
      }
    }

    // Draw dots for each point
    final dotPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    for (var offset in offsets) {
      if (offset != null) {
        canvas.drawCircle(offset, 3.0, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
