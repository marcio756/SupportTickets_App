import 'package:flutter/material.dart';

/// A progress bar that provides the illusion of fast loading.
/// It moves quickly at the start, slows down asymptotically, 
/// and rushes to completion when the task is finished.
class ProgressIllusionBar extends StatefulWidget {
  /// Whether the background task has completed.
  final bool isComplete;

  /// Creates a new ProgressIllusionBar.
  const ProgressIllusionBar({
    super.key,
    required this.isComplete,
  });

  @override
  State<ProgressIllusionBar> createState() => _ProgressIllusionBarState();
}

class _ProgressIllusionBarState extends State<ProgressIllusionBar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10), // Long duration for the illusion
    );

    // Fast out, slow in curve to simulate quick initial progress that hangs at ~90%
    _animation = Tween<double>(begin: 0.0, end: 0.9).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.fastOutSlowIn,
      ),
    );

    _controller.forward();
  }

  @override
  void didUpdateWidget(ProgressIllusionBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isComplete && !oldWidget.isComplete) {
      // Rush to 100% when complete
      _controller.duration = const Duration(milliseconds: 300);
      _animation = Tween<double>(begin: _animation.value, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeOut,
        ),
      );
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return LinearProgressIndicator(
          value: _animation.value,
          backgroundColor: Colors.transparent,
          color: Theme.of(context).colorScheme.primary,
        );
      },
    );
  }
}