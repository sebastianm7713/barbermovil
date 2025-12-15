import 'package:flutter/material.dart';
import '../core/app_theme.dart';

class CustomInput extends StatelessWidget {
  final TextEditingController controller;
  final IconData icon;
  final String label;
  final bool isPassword;

  const CustomInput({
    super.key,
    required this.controller,
    required this.icon,
    required this.label,
    this.isPassword = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(
        fontSize: 15,
        color: AppTheme.darkText,
      ),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: AppTheme.primary),
        labelText: label,
        labelStyle: const TextStyle(
          color: AppTheme.lightText,
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppTheme.primary,
            width: 2,
          ),
        ),
      ),
    );
  }
}
