import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/utils/page_transitions.dart';
import '../../data/models/note_card.dart';
import '../screens/lumi_chat_screen.dart';
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
              Text(
                '${card.createdAt.day.toString().padLeft(2, '0')}.${card.createdAt.month.toString().padLeft(2, '0')}.${card.createdAt.year} ${card.createdAt.hour.toString().padLeft(2, '0')}:${card.createdAt.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(fontSize: 11, color: AppColors.textHint),
              ),
              const SizedBox(width: 8),
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
          const SizedBox(height: 16),
          // ── "Discuss with Lumi" button ─────────────────────────────────
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                SlideRightRoute(
                  page: LumiChatScreen(
                    initialMessage: 'Обсуди со мной этот текст:\n\n"${card.quote}"',
                  ),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: AppColors.aiAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  // ignore: deprecated_member_use
                  color: AppColors.aiAccent.withOpacity(0.3),
                  width: 0.8,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.auto_awesome,
                    size: 14,
                    color: AppColors.aiAccent,
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Обсудить с ИИ',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.aiAccent,
                    ),
                  ),
                ],
              ),
            ),
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
      child: Text(
        S.scannedQuote,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.quoteBadgeFg,
        ),
      ),
    );
  }
}
