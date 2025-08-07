import 'package:flutter/material.dart';
import 'package:cognitive_tests/cognitive_tests.dart';

class TrailMakingTestPage extends StatefulWidget {
  const TrailMakingTestPage({super.key});

  @override
  TrailMakingTestPageState createState() => TrailMakingTestPageState();
}

class TrailMakingTestPageState extends State<TrailMakingTestPage> {
  /// Business logic handler for the Trail Making test
  late final TrailMakingTest _test;

  final GlobalKey _sheetKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Initialize the test with result handler
    _test = TrailMakingTest();
  }

  @override
  Widget build(BuildContext context) {
    double displayWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trail Making Test'),
      ),
      body: Column(
        children: [
          Expanded(
            child: TrailMakingTestViewer(
              testLogic: _test,
              isFirstTest: _test.isFirstTest,
              sheetKey: _sheetKey,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                width: 0.3 * displayWidth,
                child: TextButton(
                    child: const Text("Erase traces"),
                    onPressed: () {
                      setState(() {
                        _test.clearGestureData();
                      });
                    }),
              ),
              SizedBox(
                width: 0.3 * displayWidth,
                child: TextButton(
                  onPressed: _test.isFirstTest
                      ? () async {
                          await _finishCurrentTest();
                          setState(() {
                            _test.moveToNextTest();
                          });
                        }
                      : () async {
                          await _finishCurrentTest();
                          await _finishCompleteTest();
                        },
                  child: Text(_test.isFirstTest ? "Next" : "Finish"),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  /// Finish current test part and save data
  Future<void> _finishCurrentTest() async {
    try {
      await _test.finishTest(context, _sheetKey);
      _test.clearGestureData();
    } catch (e) {
      debugPrint('Error finishing test part: $e');
    }
  }

  /// Handle completion of entire test and navigation
  Future<void> _finishCompleteTest() async {
    try {
      // Close test after delay
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        Navigator.pop(context); // Instructions
        Navigator.pop(context); // Main menu
      }
    } catch (e) {
      debugPrint('Error completing test: $e');
    }
  }
}
