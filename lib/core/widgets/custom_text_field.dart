import 'package:flutter/material.dart';

/// A reusable, styled text input field conforming to the application's design system.
class CustomTextField extends StatelessWidget {
  /// Controls the text being edited.
  final TextEditingController controller;
  
  /// The placeholder text shown when the field is empty.
  final String hintText;
  
  /// Determines if the field should hide its content (useful for passwords).
  final bool obscureText;
  
  /// Identifies the type of keyboard to display.
  final TextInputType keyboardType;
  
  /// Optional validation logic for the input.
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
        ),
      ),
    );
  }
}