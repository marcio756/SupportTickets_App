import 'package:flutter/material.dart';
import 'skeleton_loader.dart';

/// A skeleton placeholder mimicking a standard form input field.
/// Used during data fetching for dropdowns or locked inputs.
class FormFieldSkeleton extends StatelessWidget {
  /// Creates a FormFieldSkeleton.
  const FormFieldSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonLoader(
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}