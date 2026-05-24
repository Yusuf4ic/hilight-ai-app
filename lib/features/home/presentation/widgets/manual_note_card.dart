import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../data/models/note_card.dart';
import 'card_shell.dart';

class ManualNoteCard extends StatelessWidget {
  const ManualNoteCard({super.key, required this.card});

  final NoteCard card;

  @override
  Widget build(BuildContext context) {
    return CardShell(
      accentColor: const Color(0xFF64B5F6), // Light blue accent for manual notes
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _NoteBadge(),
              const Spacer(),
              const Icon(Icons.more_horiz, size: 20, color: AppColors.textHint),
            ],
          ),
          const SizedBox(height: 12),
          if (card.manualTitle != null && card.manualTitle!.isNotEmpty) ...[
            Text(
              card.manualTitle!,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
          ],
          Text(
            card.manualBody ?? '',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _NoteBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.edit_note, size: 14, color: Color(0xFF1976D2)),
          const SizedBox(width: 4),
          Text(
            S.manualNote,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1976D2),
            ),
          ),
        ],
      ),
    );
  }
}
