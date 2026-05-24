import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../data/models/note_card.dart';
import '../providers/notes_provider.dart';
import 'package:uuid/uuid.dart';

class CreateContentScreen extends ConsumerStatefulWidget {
  const CreateContentScreen({super.key});

  @override
  ConsumerState<CreateContentScreen> createState() => _CreateContentScreenState();
}

class _CreateContentScreenState extends ConsumerState<CreateContentScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  
  // Default to manualNote
  CardType _selectedType = CardType.manualNote;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _onSave() {
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();

    if (body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.emptyContentWarning)),
      );
      return;
    }

    final newCard = NoteCard(
      id: const Uuid().v4(),
      type: _selectedType,
      // If it's a manualNote, put data in manual fields
      manualTitle: _selectedType == CardType.manualNote ? title : null,
      manualBody: _selectedType == CardType.manualNote ? body : null,
      // If the user chooses Quote, put data in quote fields
      quote: _selectedType == CardType.scannedQuote ? body : null,
      bookTitle: _selectedType == CardType.scannedQuote ? title : null,
      author: _selectedType == CardType.scannedQuote ? 'Manual Entry' : null,
      // By default it's not hidden from home
      isHiddenFromHome: false,
    );

    ref.read(notesProvider.notifier).addNote(newCard);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          S.newEntry,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _onSave,
            child: Text(
              S.save,
              style: TextStyle(
                color: AppColors.quoteAccent,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type Selector
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<CardType>(
                    value: _selectedType,
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                    items: [
                      DropdownMenuItem(
                        value: CardType.manualNote,
                        child: Text(S.note),
                      ),
                      DropdownMenuItem(
                        value: CardType.scannedQuote,
                        child: Text(S.quote),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedType = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Title Field
              TextField(
                controller: _titleController,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: _selectedType == CardType.scannedQuote ? S.bookTitleOptional : S.titleOptional,
                  hintStyle: const TextStyle(color: AppColors.textHint),
                  border: InputBorder.none,
                ),
              ),
              const SizedBox(height: 12),

              // Body Field
              TextField(
                controller: _bodyController,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                decoration: InputDecoration(
                  hintText: _selectedType == CardType.scannedQuote 
                      ? S.typeQuoteHere 
                      : S.startWritingNote,
                  hintStyle: const TextStyle(color: AppColors.textHint),
                  border: InputBorder.none,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
