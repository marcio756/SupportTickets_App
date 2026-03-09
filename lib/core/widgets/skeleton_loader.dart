import 'package:flutter/material.dart';

/// Provides a shimmer animation effect to its child widget.
/// Used to create Skeleton Screens during data loading states.
class SkeletonLoader extends StatefulWidget {
  /// The widget layout to apply the shimmer effect to.
  final Widget child;

  /// Creates a new SkeletonLoader.
  const SkeletonLoader({
    super.key,
    required this.child,
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                Theme.of(context).colorScheme.surfaceContainerHighest,
                Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              ],
              stops: const [0.1, 0.5, 0.9],
              begin: const Alignment(-1.0, -0.5),
              end: const Alignment(2.0, 0.5),
              transform: _SlidingGradientTransform(slidePercent: _controller.value),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

/// Helper class to animate the linear gradient across the child bounds.
class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;

  /// Initializes the transform with the current animation percentage.
  const _SlidingGradientTransform({required this.slidePercent});

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0.0, 0.0);
  }
}