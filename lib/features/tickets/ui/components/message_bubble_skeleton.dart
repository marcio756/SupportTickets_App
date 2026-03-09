import 'package:flutter/material.dart';
import '../../../../core/widgets/skeleton_loader.dart';

/// A skeleton placeholder that mimics a chat message bubble.
/// Alternate alignments can be simulated by providing [isSender].
class MessageBubbleSkeleton extends StatelessWidget {
  /// Determines the alignment and border radius shape of the fake bubble.
  final bool isSender;

  /// Creates a MessageBubbleSkeleton.
  const MessageBubbleSkeleton({super.key, required this.isSender});

  @override
  Widget build(BuildContext context) {
    return SkeletonLoader(
      child: Align(
        alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          width: MediaQuery.of(context).size.width * 0.6,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16).copyWith(
              bottomRight: isSender ? const Radius.circular(0) : const Radius.circular(16),
              bottomLeft: isSender ? const Radius.circular(16) : const Radius.circular(0),
            ),
          ),
        ),
      ),
    );
  }
}