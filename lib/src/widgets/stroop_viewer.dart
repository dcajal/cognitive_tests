import 'package:flutter/material.dart';
import '../tests/stroop_test.dart';

/// Displays the Stroop test stimuli for the current page.
/// Scroll position resets to top whenever the page changes.
class StroopViewer extends StatefulWidget {
  final StroopTest test;
  final int currentPage;

  const StroopViewer({
    super.key,
    required this.test,
    required this.currentPage,
  });

  static int get totalPages => StroopTest.totalPages;

  @override
  State<StroopViewer> createState() => _StroopViewerState();
}

class _StroopViewerState extends State<StroopViewer> {
  late final ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
  }

  @override
  void didUpdateWidget(covariant StroopViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentPage != widget.currentPage) {
      // Jump to top instantly on page change
      if (_controller.hasClients) {
        _controller.jumpTo(0);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.currentPage) {
      case 0:
        return _buildWordList(widget.test.page0Words, context);
      case 1:
        return _buildColorPatchList(widget.test.page1Colors, context);
      case 2:
        return _buildWordList(widget.test.page2Words, context);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildWordList(List<dynamic> stimuli, BuildContext context) {
    return Scrollbar(
      thumbVisibility: true,
      controller: _controller,
      child: ListView.builder(
        controller: _controller,
        itemCount: stimuli.length,
        itemBuilder: (context, index) {
          final s = stimuli[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Center(
              child: Text(
                s.text,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: s.color,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildColorPatchList(List<dynamic> stimuli, BuildContext context) {
    return Scrollbar(
      thumbVisibility: true,
      controller: _controller,
      child: ListView.builder(
        controller: _controller,
        itemCount: stimuli.length,
        itemBuilder: (context, index) {
          final s = stimuli[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Center(
              child: Container(
                width: 120,
                height: 32,
                decoration: BoxDecoration(
                  color: s.color,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.black12),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
