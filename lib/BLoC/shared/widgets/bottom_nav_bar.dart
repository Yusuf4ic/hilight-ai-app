import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/l10n/app_strings.dart';

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.home_outlined,      Icons.home,        S.navHome),
      (Icons.menu_book_outlined, Icons.menu_book,   S.navLibrary),
      (null,                     null,              ''),
      (Icons.lightbulb_outline,  Icons.lightbulb,   S.navInsights),
      (Icons.person_outline,     Icons.person,      S.navProfile),
    ];

    return Container(
      height: 84,
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(color: AppColors.divider, width: 0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          if (i == 2) {
            return _ScanButton(onTap: () => onTap(i));
          }
          final selected = selectedIndex == i;
          final (outline, filled, label) = items[i];
          return GestureDetector(
            onTap: () => onTap(i),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  selected ? filled : outline,
                  size: 30,
                  color: selected ? AppColors.textPrimary : AppColors.textHint,
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color:
                        selected ? AppColors.textPrimary : AppColors.textHint,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _ScanButton extends StatelessWidget {
  const _ScanButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Transform.translate(
        offset: const Offset(0, -6),
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.textPrimary, width: 2.5),
            color: AppColors.background,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.crop_free,
            size: 32,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
