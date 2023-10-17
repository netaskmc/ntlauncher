import 'package:flutter/material.dart';

class NtTextField extends StatelessWidget {
  final String? value;
  final ValueChanged<String>? onChanged;
  final String? labelText;
  final String? hintText;
  final bool obscureText;

  const NtTextField({
    super.key,
    this.value,
    this.onChanged,
    this.labelText,
    this.hintText,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: obscureText,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 3,
        ),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(6)),
          gapPadding: 8,
        ),
        labelText: labelText,
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(6)),
          borderSide: BorderSide(
            width: 1,
            color: Color.fromRGBO(255, 255, 255, 0.1),
          ),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(6)),
          borderSide: BorderSide(
            width: 1,
            color: Color.fromRGBO(255, 255, 255, 0.3),
          ),
        ),
        labelStyle: const TextStyle(
          color: Color.fromRGBO(255, 255, 255, 0.5),
        ),
      ),
    );
  }
}
