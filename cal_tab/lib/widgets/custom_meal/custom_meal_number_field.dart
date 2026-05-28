import 'package:flutter/material.dart';

class CustomMealNumberField extends StatelessWidget {
  const CustomMealNumberField({
    super.key,
    required this.controller,
    required this.label,
    required this.suffix,
    required this.validator,
    this.allowDecimal = true,
  });

  final TextEditingController controller;
  final String label;
  final String suffix;
  final String? Function(String?) validator;
  final bool allowDecimal;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label, suffixText: suffix),
      keyboardType: TextInputType.numberWithOptions(decimal: allowDecimal),
      validator: validator,
    );
  }
}
