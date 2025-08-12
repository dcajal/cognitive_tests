import 'package:flutter/material.dart';
import '../tests/stroop_test.dart';

/// Displays the Stroop test items for the current page.
/// Scroll position resets to top whenever the page changes.
class StroopViewer extends StatefulWidget {
  final StroopTest test;
  final int currentPage;
  final TextStyle? textStyle;
  final double itemHeight;

  const StroopViewer({
    super.key,
    required this.test,
    required this.currentPage,
    this.textStyle,
    this.itemHeight = 60,
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
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _controller.hasClients) {
          _controller.jumpTo(0);
        }
      });
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

  Widget _buildWordList(List<dynamic> items, BuildContext context) {
    return Scrollbar(
      thumbVisibility: true,
      controller: _controller,
      child: ListView.builder(
        controller: _controller,
        itemCount: items.length,
        itemBuilder: (context, index) {
          final s = items[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Center(
              child: Container(
                width: widget.itemHeight * 5,
                height: widget.itemHeight,
                alignment: Alignment.center,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Text(
                    s.text,
                    style: (widget.textStyle ??
                            const TextStyle(
                                fontFamily: 'OpenSans',
                                fontWeight: FontWeight.bold,
                                fontSize: 36))
                        .copyWith(
                      color: s.color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildColorPatchList(List<dynamic> items, BuildContext context) {
    return Scrollbar(
      thumbVisibility: true,
      controller: _controller,
      child: ListView.builder(
        controller: _controller,
        itemCount: items.length,
        itemBuilder: (context, index) {
          final s = items[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Center(
              child: Container(
                width: widget.itemHeight * 5,
                height: widget.itemHeight,
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
