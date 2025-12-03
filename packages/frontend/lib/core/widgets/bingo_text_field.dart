import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BingoTextField extends StatelessWidget {
  const BingoTextField({
    super.key,
    this.controller,
    this.decoration,
    this.onChanged,
    this.keyboardType,
    this.inputFormatters,
    this.maxLength,
    this.maxLines = 1,
    this.enabled,
    this.style,
    this.textInputAction,
    this.focusNode,
    this.autofocus = false,
    this.obscureText = false,
    this.readOnly = false,
  });

  final TextEditingController? controller;
  final InputDecoration? decoration;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final int? maxLines;
  final bool? enabled;
  final TextStyle? style;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool obscureText;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: decoration,
      onChanged: onChanged,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLength: maxLength,
      maxLines: maxLines,
      enabled: enabled,
      style: style,
      textInputAction: textInputAction,
      focusNode: focusNode,
      autofocus: autofocus,
      obscureText: obscureText,
      readOnly: readOnly,
      autofillHints: const [],
    );
  }
}
