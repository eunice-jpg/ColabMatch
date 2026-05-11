import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class SkillTag extends StatelessWidget {
  final String label;
  final bool removable;
  final VoidCallback? onRemove;
  final Color? backgroundColor;
  final Color? textColor;

  const SkillTag({
    super.key,
    required this.label,
    this.removable = false,
    this.onRemove,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.tagBlue,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              color: textColor ?? AppColors.tagBluText,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (removable) ...[
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onRemove,
              child: Icon(
                Icons.close,
                size: 14,
                color: textColor ?? AppColors.tagBluText,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
