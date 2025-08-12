import 'package:flutter/material.dart';
import 'package:cognitive_tests/cognitive_tests.dart';

/// StroopTestPage widget - A stateful widget that implements the Stroop cognitive test
///
/// The Stroop test is a psychological test that measures cognitive flexibility
/// and selective attention by presenting color words printed in different colors
class StroopTestPage extends StatefulWidget {
  const StroopTestPage({super.key});

  @override
  StroopTestPageState createState() => StroopTestPageState();
}

class StroopTestPageState extends State<StroopTestPage> {
  /// Business logic handler for the Stroop test
  late final StroopTest _test;

  @override
  void initState() {
    super.initState();

    _test = StroopTest(
      enableAudioRecording: true,
    );

    _test.initialize();
  }

  @override
  void deactivate() {
    _test.dispose();
    super.deactivate();
  }

  @override
  void dispose() {
    _test.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stroop Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // PDF viewer section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: StroopViewer(
                  currentPage: _test.testPage,
                ),
              ),
            ),

            // Navigation button section
            Center(
              child: _buildNavigationButton(),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the appropriate navigation button based on current page
  Widget _buildNavigationButton() {
    if (_test.isLastPage) {
      // Show finish button on last page
      return TextButton(
        child: const Text('Finish'),
        onPressed: () => Navigator.of(context).pop(),
      );
    } else {
      // Show next button for other pages
      return TextButton(
        child: const Text('Next'),
        onPressed: () => _goToNextPage(),
      );
    }
  }

  /// Handles navigation to the next page
  void _goToNextPage() {
    setState(() {
      _test.goToNextPage();
      // The PDF viewer will automatically update via the currentPage parameter
    });
  }
}
