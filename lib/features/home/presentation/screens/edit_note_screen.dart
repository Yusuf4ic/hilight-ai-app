import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../data/models/note_card.dart';
import '../providers/notes_provider.dart';

class EditNoteScreen extends ConsumerStatefulWidget {
  const EditNoteScreen({super.key, required this.card});

  final NoteCard card;

  @override
  ConsumerState<EditNoteScreen> createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends ConsumerState<EditNoteScreen>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Pre-fill based on card type
    switch (widget.card.type) {
      case CardType.manualNote:
        _titleController =
            TextEditingController(text: widget.card.manualTitle ?? '');
        _bodyController =
            TextEditingController(text: widget.card.manualBody ?? '');
        break;
      case CardType.scannedQuote:
        _titleController =
            TextEditingController(text: widget.card.bookTitle ?? '');
        _bodyController =
            TextEditingController(text: widget.card.quote ?? '');
        break;
      case CardType.voiceNote:
        _titleController = TextEditingController(text: 'Voice Note');
        _bodyController =
            TextEditingController(text: widget.card.voiceTranscript ?? '');
        break;
      case CardType.aiInsight:
        _titleController = TextEditingController(text: 'AI Insight');
        _bodyController =
            TextEditingController(text: widget.card.aiSummary ?? '');
        break;
    }

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _onSave() {
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();

    if (body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.contentEmpty)),
      );
      return;
    }

    NoteCard updated;
    switch (widget.card.type) {
      case CardType.manualNote:
        updated = widget.card.copyWith(manualTitle: title, manualBody: body);
        break;
      case CardType.scannedQuote:
        updated = widget.card.copyWith(bookTitle: title, quote: body);
        break;
      case CardType.voiceNote:
        updated = widget.card.copyWith(voiceTranscript: body);
        break;
      case CardType.aiInsight:
        updated = widget.card.copyWith(aiSummary: body);
        break;
    }

    ref.read(notesProvider.notifier).updateNote(updated);
    Navigator.of(context).pop();
  }

  String get _titleHint {
    return switch (widget.card.type) {
      CardType.scannedQuote => S.bookTitle,
      CardType.manualNote => S.title,
      CardType.voiceNote => S.voiceNote,
      CardType.aiInsight => S.aiInsight,
    };
  }

  String get _bodyHint {
    return switch (widget.card.type) {
      CardType.scannedQuote => S.editQuote,
      CardType.manualNote => S.editNote,
      CardType.voiceNote => S.editTranscript,
      CardType.aiInsight => S.editSummary,
    };
  }

  Color get _accentColor {
    return switch (widget.card.type) {
      CardType.scannedQuote => AppColors.quoteAccent,
      CardType.voiceNote => AppColors.voiceAccent,
      CardType.aiInsight => AppColors.aiAccent,
      CardType.manualNote => const Color(0xFF64B5F6),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          S.editEntry,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _onSave,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _accentColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Save',
                style: TextStyle(
                  color: _accentColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Type badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.card.type.name
                        .replaceAllMapped(
                            RegExp(r'([A-Z])'), (m) => ' ${m[1]}')
                        .trim(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _accentColor,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Title field
                TextField(
                  controller: _titleController,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: _titleHint,
                    hintStyle: const TextStyle(color: AppColors.textHint),
                    border: InputBorder.none,
                  ),
                  readOnly: widget.card.type == CardType.voiceNote ||
                      widget.card.type == CardType.aiInsight,
                ),

                // Subtle divider
                Container(
                  height: 1,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _accentColor.withValues(alpha: 0.3),
                        _accentColor.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Body field
                TextField(
                  controller: _bodyController,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                  decoration: InputDecoration(
                    hintText: _bodyHint,
                    hintStyle: const TextStyle(color: AppColors.textHint),
                    border: InputBorder.none,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
