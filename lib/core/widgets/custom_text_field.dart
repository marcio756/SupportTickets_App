// Ficheiro: lib/core/widgets/custom_text_field.dart
import 'package:flutter/material.dart';

/// Um componente de campo de texto reutilizável para manter consistência na UI.
class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  
  // Novas propriedades adicionadas para suportar interfaces mais ricas
  final Widget? prefixIcon;
  final bool enabled;
  final void Function(String)? onSubmitted;
  final int maxLines;

  const CustomTextField({
    super.key,
    this.controller,
    required this.hintText,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.prefixIcon,
    this.enabled = true,
    this.onSubmitted,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      enabled: enabled,
      onFieldSubmitted: onSubmitted,
      maxLines: obscureText ? 1 : maxLines, // Inputs com password não podem ter mais de 1 linha
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: prefixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        filled: true,
        // ignore: deprecated_member_use
        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
      ),
    );
  }
}