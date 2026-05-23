import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/note_card.dart';
import 'card_shell.dart';

class ScannedQuoteCard extends StatelessWidget {
  const ScannedQuoteCard({super.key, required this.card});

  final NoteCard card;

  @override
  Widget build(BuildContext context) {
    return CardShell(
      accentColor: AppColors.quoteAccent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Badge(),
              const Spacer(),
              const Icon(Icons.more_horiz, size: 20, color: AppColors.textHint),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            card.quote ?? '',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card.bookTitle ?? '',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '${card.author} — ${card.page}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              const Icon(
                Icons.bookmark_border,
                size: 20,
                color: AppColors.textHint,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.quoteBadgeBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'Scanned Quote',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.quoteBadgeFg,
        ),
      ),
    );
  }
}
