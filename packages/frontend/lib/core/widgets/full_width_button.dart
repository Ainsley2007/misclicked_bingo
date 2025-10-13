import 'package:flutter/material.dart';

class FullWidthButton extends StatelessWidget {
  const FullWidthButton({required this.onPressed, required this.icon, required this.label, super.key});

  final VoidCallback? onPressed;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(onPressed: onPressed, icon: Icon(icon), label: Text(label)),
    );
  }
}
