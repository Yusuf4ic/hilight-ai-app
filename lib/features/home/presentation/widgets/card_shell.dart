import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class CardShell extends StatelessWidget {
  const CardShell({
    super.key,
    required this.child,
    required this.accentColor,
  });

  final Widget child;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left:   BorderSide(color: accentColor, width: 3),
          top:    const BorderSide(color: AppColors.cardBorder, width: 0.5),
          right:  const BorderSide(color: AppColors.cardBorder, width: 0.5),
          bottom: const BorderSide(color: AppColors.cardBorder, width: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}
