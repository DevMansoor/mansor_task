import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final AutovalidateMode autovalidateMode;
  final String hintText;
  final String? Function(String?)? validator;
  final bool obscureText;

  const CustomTextField({
    Key? key,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    required this.hintText,
    this.validator,
    this.obscureText = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        hintText: hintText,
      ),
      validator: validator,
    );
  }
}
