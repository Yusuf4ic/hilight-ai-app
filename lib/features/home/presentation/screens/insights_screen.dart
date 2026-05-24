import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../data/models/note_card.dart';
import '../providers/notes_provider.dart';
import '../widgets/ai_insight_card.dart';
import '../widgets/scanned_quote_card.dart';
import '../widgets/voice_note_card.dart';
import '../widgets/manual_note_card.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  Widget _buildCard(NoteCard card) {
    return switch (card.type) {
      CardType.scannedQuote => ScannedQuoteCard(card: card),
      CardType.voiceNote => VoiceNoteCard(card: card),
      CardType.aiInsight => AiInsightCard(card: card),
      CardType.manualNote => ManualNoteCard(card: card),
    };
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, NoteCard card) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          S.deleteNote,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        content: Text(
          S.deleteNoteConfirm,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              S.cancel,
              style: TextStyle(
                color: AppColors.textHint,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              ref.read(notesProvider.notifier).deleteNote(card.id);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(S.noteDeleted),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Text(
              S.delete,
              style: TextStyle(
                color: Color(0xFFE74C3C),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(notesProvider);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTopBar(),
          _buildStatsRow(),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              S.timelineArchive,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            child: notesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (notes) {
                if (notes.isEmpty) {
                  return Center(
                    child: Text(
                      S.noInsightsYet,
                      style: TextStyle(color: AppColors.textHint),
                    ),
                  );
                }
                return ListView.separated(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: notes.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final card = notes[i];
                    return Dismissible(
                      key: ValueKey('insight_${card.id}'),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (_) async {
                        _showDeleteDialog(context, ref, card);
                        return false; // dialog handles deletion
                      },
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 24),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE74C3C).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Icon(Icons.delete_outline_rounded,
                                color: Color(0xFFE74C3C), size: 22),
                            const SizedBox(width: 6),
                            Text(
                              S.delete,
                              style: TextStyle(
                                color: Color(0xFFE74C3C),
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      child: _InsightCardWithDelete(
                        card: card,
                        cardWidget: _buildCard(card),
                        onDelete: () =>
                            _showDeleteDialog(context, ref, card),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Text(
        S.insights,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: -0.4,
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _StatChip(label: 'This week', value: '14', icon: Icons.bookmark),
          const SizedBox(width: 10),
          _StatChip(label: 'Books read', value: '8', icon: Icons.menu_book),
          const SizedBox(width: 10),
          _StatChip(
              label: 'Streak',
              value: '5d',
              icon: Icons.local_fire_department),
        ],
      ),
    );
  }
}

/// Wraps each card in the Insights list with a visible delete button.
class _InsightCardWithDelete extends StatefulWidget {
  const _InsightCardWithDelete({
    required this.card,
    required this.cardWidget,
    required this.onDelete,
  });

  final NoteCard card;
  final Widget cardWidget;
  final VoidCallback onDelete;

  @override
  State<_InsightCardWithDelete> createState() =>
      _InsightCardWithDeleteState();
}

class _InsightCardWithDeleteState extends State<_InsightCardWithDelete>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.cardWidget,
        // Delete button — top-right corner
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTapDown: (_) => _controller.forward(),
            onTapUp: (_) {
              _controller.reverse();
              widget.onDelete();
            },
            onTapCancel: () => _controller.reverse(),
            child: ScaleTransition(
              scale: _scaleAnim,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.background.withValues(alpha: 0.85),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: Color(0xFFE74C3C),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Insight {
  final String title;
  final String body;
  final IconData icon;
  final Color accentColor;
  final Color bgColor;

  const _Insight(
      this.title, this.body, this.icon, this.accentColor, this.bgColor);
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder, width: 0.5),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: AppColors.textSecondary),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ignore: unused_element
class _InsightTile extends StatelessWidget {
  const _InsightTile({required this.insight});

  final _Insight insight;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder, width: 0.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: insight.bgColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child:
                      Icon(insight.icon, size: 18, color: insight.accentColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        insight.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        insight.body,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 3.5,
              decoration: BoxDecoration(
                color: insight.accentColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
