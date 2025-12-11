import 'package:flutter/material.dart';

class RoundedInputField extends StatelessWidget {
  final String hint;
  final String? initialValue;
  final Widget? suffix;
  final VoidCallback? onTap;
  final TextInputType? keyboardType;
  final Function(String)? onChanged;

  const RoundedInputField({
    super.key,
    required this.hint,
    this.keyboardType,
    this.suffix,
    this.initialValue,
    this.onTap,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: initialValue,
                onChanged: onChanged,
                readOnly: onTap != null,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                keyboardType: keyboardType ?? TextInputType.text,
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: const TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                ),
              ),
            ),
            if (suffix != null) suffix!,
          ],
        ),
      ),
    );
  }
}
