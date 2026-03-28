import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';

class AppInput extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? prefix;
  final Widget? suffix;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLines;
  final bool readOnly;
  final VoidCallback? onTap;
  final void Function(String)? onChanged;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;

  const AppInput({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.prefix,
    this.suffix,
    this.inputFormatters,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
    this.onChanged,
    this.focusNode,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscureText,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      readOnly: readOnly,
      onTap: onTap,
      onChanged: onChanged,
      focusNode: focusNode,
      textInputAction: textInputAction,
      style: AppTextStyles.body,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefix,
        suffixIcon: suffix,
      ),
    );
  }
}

class AppSearchInput extends StatelessWidget {
  final String hint;
  final TextEditingController? controller;
  final void Function(String)? onChanged;

  const AppSearchInput({
    super.key,
    this.hint = 'Поиск...',
    this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      style: AppTextStyles.body,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.body.copyWith(color: AppColors.muted),
        prefixIcon: const Icon(Icons.search, color: AppColors.muted, size: 20),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
