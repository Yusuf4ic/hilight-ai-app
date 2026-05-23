import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  final int selectedIndex;
  final ValueChanged<int> onTap;

  static const _items = [
    (Icons.home_outlined,      Icons.home,        'Home'),
    (Icons.menu_book_outlined, Icons.menu_book,   'Library'),
    (null,                     null,              ''),
    (Icons.lightbulb_outline,  Icons.lightbulb,   'Insights'),
    (Icons.person_outline,     Icons.person,      'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
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
        children: List.generate(_items.length, (i) {
          if (i == 2) {
            return _ScanButton(onTap: () => onTap(i));
          }
          final selected = selectedIndex == i;
          final (outline, filled, label) = _items[i];
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
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.textHint, width: 1),
        ),
        child: const Icon(
          Icons.crop_free,
          size: 20,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
