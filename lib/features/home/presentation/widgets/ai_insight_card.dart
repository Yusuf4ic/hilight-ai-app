import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/utils/page_transitions.dart';
import '../../data/models/note_card.dart';
import '../screens/lumi_chat_screen.dart';

class AiInsightCard extends StatelessWidget {
  const AiInsightCard({super.key, required this.card});

  final NoteCard card;

  @override
  Widget build(BuildContext context) {
    final title = card.manualTitle?.isNotEmpty == true
        ? card.manualTitle!
        : S.aiInsight;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
          bottomLeft: Radius.circular(4),
          bottomRight: Radius.circular(20),
        ),
        border: Border.all(
          // ignore: deprecated_member_use
          color: AppColors.aiAccent.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: AppColors.aiAccent.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Badge row ──────────────────────────────────────────────────
          Row(
            children: [
              const _AiBadge(),
              const Spacer(),
              Text(
                '${card.createdAt.day.toString().padLeft(2, '0')}.${card.createdAt.month.toString().padLeft(2, '0')}.${card.createdAt.year} ${card.createdAt.hour.toString().padLeft(2, '0')}:${card.createdAt.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(fontSize: 11, color: AppColors.textHint),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // ── Title (first user question) ────────────────────────────────
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),

          // ── "Read more" button ─────────────────────────────────────────
          GestureDetector(
            onTap: () => Navigator.of(context).push(
              SlideRightRoute(page: LumiChatScreen(existingNote: card)),
            ),
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
                  Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 14,
                    color: AppColors.aiAccent,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    S.readMore,
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

class _AiBadge extends StatelessWidget {
  const _AiBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.aiBadgeBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.auto_awesome, size: 12, color: AppColors.aiBadgeFg),
          const SizedBox(width: 4),
          Text(
            S.aiInsight,
            style: const TextStyle(
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
