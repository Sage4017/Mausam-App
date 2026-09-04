import 'package:flutter/material.dart';
import '../core/app_theme.dart';

class FrostedGlassCard extends StatelessWidget {
  final Widget child;
  final Color? accentColor;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  const FrostedGlassCard({
    super.key,
    required this.child,
    this.accentColor,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: MausamColors.surfaceContainerLowest.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MausamColors.surfaceVariant),
        boxShadow: [
          BoxShadow(
            color: MausamColors.primary.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Stack(
            children: [
              if (accentColor != null)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 4,
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: padding,
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}