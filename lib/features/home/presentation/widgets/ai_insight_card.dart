import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/note_card.dart';
import 'card_shell.dart';

class AiInsightCard extends StatelessWidget {
  const AiInsightCard({super.key, required this.card});

  final NoteCard card;

  @override
  Widget build(BuildContext context) {
    return CardShell(
      accentColor: AppColors.aiAccent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _AiBadge(),
              const Spacer(),
              const Icon(Icons.more_horiz, size: 20, color: AppColors.textHint),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Summary',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            card.aiSummary ?? '',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _AiBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.aiBadgeBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome, size: 12, color: AppColors.aiBadgeFg),
          SizedBox(width: 4),
          Text(
            'AI Insight',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.aiBadgeFg,
            ),
          ),
        ],
      ),
    );
  }
}
