import 'package:flutter/material.dart';
import 'package:cognitive_tests/cognitive_tests.dart';
import 'test_result_handler.dart';

class StroopTestWidget extends StatefulWidget {
  const StroopTestWidget({super.key});

  @override
  _StroopTestWidgetState createState() => _StroopTestWidgetState();
}

class _StroopTestWidgetState extends State<StroopTestWidget> {
  late StroopTest stroopTest;
  bool _isInitialized = false;
  bool _testStarted = false;

  @override
  void initState() {
    super.initState();
    stroopTest = StroopTest(
      resultHandler: MyTestResultHandler(),
      enableAudioRecording: true, // Set to false to disable audio
    );
    _initializeTest();
  }

  Future<void> _initializeTest() async {
    final hasPermission = await stroopTest.initialize();
    setState(() {
      _isInitialized = hasPermission;
    });

    if (!hasPermission) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Audio recording permission denied. Test will run without audio.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _startTest() async {
    if (_isInitialized) {
      await stroopTest.startTest();
      setState(() {
        _testStarted = true;
      });
    }
  }

  Future<void> _finishTest() async {
    if (_testStarted) {
      await stroopTest.finishTest(context);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stroop Test - Page ${stroopTest.testPage}'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!_isInitialized)
                const CircularProgressIndicator()
              else if (!_testStarted) ...[
                Text(
                  'Stroop Test',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 20),
                Text(
                  'This is a demo of the Stroop cognitive test. '
                  'Click "Start Test" to begin, then use "Next Page" to simulate '
                  'page transitions during the test.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _startTest,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  child: const Text('Start Test'),
                ),
              ] else ...[
                Text(
                  'Test in Progress',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 20),
                Text(
                  'Current Page: ${stroopTest.testPage}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 40),
                Text(
                  'This would be your Stroop test content.\n'
                  'Show colored words and ask participants to name the color.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        stroopTest.goToNextPage();
                        setState(() {});
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Text('Next Page'),
                    ),
                    ElevatedButton(
                      onPressed: _finishTest,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('Finish Test'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    stroopTest.dispose();
    super.dispose();
  }
}
