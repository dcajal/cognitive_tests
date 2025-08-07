import 'package:cognitive_tests/cognitive_tests.dart';
import 'package:flutter/material.dart';

class TrailMakingTestInstructions extends StatelessWidget {
  const TrailMakingTestInstructions({super.key});

  @override
  Widget build(BuildContext context) {
    double displayWidth = MediaQuery.of(context).size.width;
    double displayHeight = MediaQuery.of(context).size.height;

    return Scaffold(
        appBar: AppBar(
          title: const Text('Trail Making Test'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
              padding: EdgeInsets.symmetric(
                  horizontal: 0.05 * displayWidth,
                  vertical: 0.01 * displayHeight),
              children: [
                Column(
                  children: [
                    const Text(
                      'Draw a line connecting all the numbers in ascending order without lifting your finger. The numbers will be displayed similarly to the following example:',
                    ),
                    SizedBox(
                      height: 0.02 * displayHeight,
                    ),
                    SizedBox(
                      height: 0.6 * displayWidth,
                      width: 0.9 * displayWidth,
                      child: const TrailMakingTestExampleViewer(
                        testType: TrailMakingTestType.testA,
                      ),
                    ),
                    SizedBox(
                      height: 0.02 * displayHeight,
                    ),
                    const Text(
                        'Second part of the test will be done similarly, this time alternating numbers and letters (1-A-2-B-3-C, etc.).'),
                    SizedBox(
                      height: 0.02 * displayHeight,
                    ),
                    SizedBox(
                      height: 0.6 * displayWidth,
                      width: 0.9 * displayWidth,
                      child: const TrailMakingTestExampleViewer(
                        testType: TrailMakingTestType.testB,
                      ),
                    ),
                    SizedBox(
                      height: 0.02 * displayHeight,
                    ),
                    TextButton(
                      child: const Text('Close'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                ),
              ]),
        ));
  }
}
