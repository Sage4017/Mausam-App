import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import '../core/app_theme.dart';

class ImdLogoWidget extends StatelessWidget {
  final double size;
  final bool showSubtitle;

  const ImdLogoWidget({
    super.key,
    this.size = 76,
    this.showSubtitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const RadialGradient(
              colors: [
                Color(0xFF1E3A5F),
                Color(0xFF0F2537),
              ],
            ),
            border: Border.all(
              color: const Color(0xFFD4AF37), // Official Gold Border
              width: 2.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F2537).withValues(alpha: 0.25),
                blurRadius: 18,
                offset: const Offset(0, 6),
              )
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer gold ring accent
              Container(
                width: size * 0.82,
                height: size * 0.82,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.45),
                    width: 1,
                  ),
                ),
              ),
              // Weather Symbols & Indian Tricolor Accent
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.wb_sunny_rounded, size: size * 0.28, color: const Color(0xFFFFB300)),
                      SizedBox(width: size * 0.04),
                      Icon(Icons.cloud_outlined, size: size * 0.32, color: const Color(0xFFE0F7FA)),
                    ],
                  ),
                  SizedBox(height: size * 0.04),
                  Container(
                    width: size * 0.5,
                    height: 2.5,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFFF9933), // Saffron
                          Color(0xFFFFFFFF), // White
                          Color(0xFF138808), // Green
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (showSubtitle) ...[
          const SizedBox(height: 12),
          Text(
            'αñ¡αñ╛αñ░αññ αñ«αÑîαñ╕αñ« αñ╡αñ┐αñ£αÑìαñ₧αñ╛αñ¿ αñ╡αñ┐αñ¡αñ╛αñù',
            style: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
              color: MausamColors.primary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'INDIA METEOROLOGICAL DEPARTMENT',
            style: GoogleFonts.hankenGrotesk(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
              color: const Color(0xFF1E3A5F),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Ministry of Earth Sciences ┬╖ Govt. of India',
            style: GoogleFonts.hankenGrotesk(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: MausamColors.secondary,
            ),
          ),
        ],
      ],
    );
  }
}



class ImdBadge extends StatelessWidget {
  final bool isDark;
  const ImdBadge({super.key, this.isDark = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.12) : MausamColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFD4AF37).withValues(alpha: 0.6),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFFF9933),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'IMD OFFICIAL TELEMETRY',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
              color: isDark ? Colors.white : MausamColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

