import 'package:flutter/material.dart';
import 'package:smartschool/utils/app_constants.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final IconData? prefixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final int? maxLines;
  final String? Function(String?)? validator;
  final bool enabled;
  final void Function(String)? onChanged; // <<<--- Tambahkan baris ini

  const CustomTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.hintText = '',
    this.prefixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.validator,
    this.enabled = true,
    this.onChanged, // <<<--- Tambahkan ini juga
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon:
            prefixIcon != null
                ? Icon(prefixIcon, color: AppConstants.primaryBlue[700])
                : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: AppConstants.primaryBlue.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(
            color: AppConstants.accentBlue,
            width: 2.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: AppConstants.primaryBlue.shade200),
        ),
        filled: true,
        fillColor: Colors.blue.shade50,
      ),
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      enabled: enabled,
      onChanged: onChanged, // <<<--- Tambahkan ini
    );
  }
}
