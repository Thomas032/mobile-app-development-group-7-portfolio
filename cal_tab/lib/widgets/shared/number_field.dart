import 'package:cal_tab/utils/validators.dart';
import 'package:flutter/material.dart';

class NumberField extends StatelessWidget {
  const NumberField({
    super.key,
    required this.fieldKey,
    required this.controller,
    required this.label,
    required this.suffix,
  });

  final Key fieldKey;
  final TextEditingController controller;
  final String label;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: fieldKey,
      controller: controller,
      decoration: InputDecoration(labelText: label, suffixText: suffix),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (value) => validatePositiveNumber(value, label),
    );
  }
}
