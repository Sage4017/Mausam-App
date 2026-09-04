import 'package:flutter/material.dart';
import '../core/app_theme.dart';

class PillButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onPressed;
  final bool isPrimary;
  final double height;

  const PillButton({
    super.key,
    required this.label,
    this.icon,
    required this.onPressed,
    this.isPrimary = true,
    this.height = 50,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? MausamColors.primary : MausamColors.surfaceContainerHigh,
          foregroundColor: isPrimary ? MausamColors.onPrimary : MausamColors.primary,
          elevation: isPrimary ? 3 : 0,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: isPrimary ? MausamColors.onPrimary : MausamColors.primary,
              fontWeight: FontWeight.bold,
            )),
            if (icon != null) ...[
              const SizedBox(width: 8),
              Icon(icon, size: 18, color: isPrimary ? MausamColors.onPrimary : MausamColors.primary),
            ],
          ],
        ),
      ),
    );
  }
}