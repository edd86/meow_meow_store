import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final String? prefixText;
  final int maxLines;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final bool _isSearch;
  final TextCapitalization? capitalization;
  final Color? color;

  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.validator,
    this.keyboardType,
    this.prefixText,
    this.maxLines = 1,
    this.enabled = true,
    this.onChanged,
    this.capitalization,
    this.color,
  }) : _isSearch = false;

  const AppTextField.search({
    super.key,
    required String hintText,
    required TextEditingController this.controller,
    this.color,
    this.onChanged,
  }) : label = hintText,
       validator = null,
       keyboardType = null,
       prefixText = null,
       maxLines = 1,
       enabled = true,
       capitalization = TextCapitalization.none,
       _isSearch = true;

  @override
  Widget build(BuildContext context) {
    final inputColor = color ?? Theme.of(context).colorScheme.onSurface;
    return TextFormField(
      style: TextStyle(color: inputColor),
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      enabled: enabled,
      onChanged: onChanged,
      textCapitalization: capitalization ?? TextCapitalization.none,
      decoration: InputDecoration(
        labelText: label,
        prefixText: _isSearch ? null : prefixText,
        prefixIcon: _isSearch ? const Icon(Icons.search) : null,
      ),
    );
  }
}
