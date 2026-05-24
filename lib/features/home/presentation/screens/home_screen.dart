import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../home/data/models/note_card.dart';
import '../providers/notes_provider.dart';
import '../widgets/ai_insight_card.dart';
import '../widgets/scanned_quote_card.dart';
import '../widgets/voice_note_card.dart';
import '../../../../BLoC/shared/widgets/bottom_nav_bar.dart';
import 'insights_screen.dart';
import 'library_screen.dart';
import 'profile_screen.dart';
import 'lumi_chat_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;
  int _selectedAiMode = -1; // -1 = no mode selected (general ask)
  final TextEditingController _askController = TextEditingController();
  final FocusNode _askFocus = FocusNode();
  final ScrollController _scrollController = ScrollController();

  static const _aiModes = [
    AiMode(Icons.document_scanner_outlined, 'OCR',       'Scan text from an image…'),
    AiMode(Icons.mic_none_rounded,          'Speech',    'Describe what you want to transcribe…'),
    AiMode(Icons.summarize_outlined,        'Summarize', 'Paste or select text to summarize…'),
    AiMode(Icons.quiz_outlined,             'Questions', 'Generate questions from this material…'),
    AiMode(Icons.school_outlined,           'Tutor',     'What would you like to learn?'),
    AiMode(Icons.account_tree_outlined,     'Organize',  'Describe how to organize your notes…'),
  ];

  @override
  void dispose() {
    _askController.dispose();
    _askFocus.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleScan() async {
    // Show scanning indicator
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 18, height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2, color: Colors.white,
              ),
            ),
            SizedBox(width: 12),
            Text('Scanning text from ESP32-CAM...'),
          ],
        ),
        duration: Duration(seconds: 30),
        backgroundColor: Color(0xFFF5A623),
      ),
    );

    final result = await ref.read(notesProvider.notifier).scanText();

    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    if (result.success) {
      // Switch to home tab and scroll to top
      setState(() => _selectedIndex = 0);
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.isMock
                ? 'Scan complete (mock mode — no API key)'
                : 'Text extracted successfully!',
          ),
          backgroundColor: const Color(0xFF5DCAA5),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Scan failed: ${result.error}'),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _handleSend() {
    final text = _askController.text.trim();
    if (text.isEmpty) return;

    final modeIndex = _selectedAiMode;

    _askController.clear();
    _askFocus.unfocus();

    // Open a dedicated chat screen with the initial message
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LumiChatScreen(
          initialMessage: text,
          initialModeIndex: modeIndex,
        ),
      ),
    );
  }

  void _onAiModeSelected(int index) {
    setState(() {
      _selectedAiMode = _selectedAiMode == index ? -1 : index;
    });
  }

  String get _currentHint {
    if (_selectedAiMode < 0) return 'Ask Lumi anything about this book…';
    return _aiModes[_selectedAiMode].hint;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomeTab(),
          const LibraryScreen(),
          const SizedBox.shrink(),
          const InsightsScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomSheet: _selectedIndex == 0
          ? _AskBar(
              controller: _askController,
              focusNode: _askFocus,
              hint: _currentHint,
              aiModes: _aiModes,
              selectedAiMode: _selectedAiMode,
              onAiModeSelected: _onAiModeSelected,
              onSend: _handleSend,
            )
          : null,
      bottomNavigationBar: AppBottomNavBar(
        selectedIndex: _selectedIndex,
        onTap: (i) {
          if (i == 2) {
            _handleScan();
            return;
          }
          setState(() => _selectedIndex = i);
        },
      ),
    );
  }

  Widget _buildHomeTab() {
    final notesAsync = ref.watch(notesProvider);
    return SafeArea(
      child: Column(
        children: [
          _TopBar(),
          Expanded(
            child: notesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (notes) => ListView(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                children: [
                  for (final card in notes) ...[
                    _buildCard(card),
                    const SizedBox(height: 12),
                  ],
                  const SizedBox(height: 140),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(NoteCard card) {
    return switch (card.type) {
      CardType.scannedQuote => ScannedQuoteCard(card: card),
      CardType.voiceNote => VoiceNoteCard(card: card),
      CardType.aiInsight => AiInsightCard(card: card),
    };
  }
}

// ── Top Bar ──────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome,
              size: 30, color: AppColors.textPrimary),
          const SizedBox(width: 10),
          const Text(
            'HiLight',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.add, color: AppColors.textPrimary, size: 32),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 25,
            backgroundColor: AppColors.divider,
            child: ClipOval(
              child: Container(
                  width: 45,
                  height: 45,
                  color: const Color(0xFFB4B2A9),
                  child: Image.network(
                    'https://cdn-icons-png.flaticon.com/512/1458/1458201.png',
                  )),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Ask Bar with AI Mode Chips ───────────────────────────────────────────────

class _AskBar extends StatelessWidget {
  const _AskBar({
    required this.controller,
    required this.focusNode,
    required this.hint,
    required this.aiModes,
    required this.selectedAiMode,
    required this.onAiModeSelected,
    required this.onSend,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;
  final List<AiMode> aiModes;
  final int selectedAiMode;
  final ValueChanged<int> onAiModeSelected;
  final VoidCallback onSend;

  static const modeColors = [
    Color(0xFFE67E22), // OCR — amber/orange
    Color(0xFF7F77DD), // Speech — purple
    Color(0xFF5DCAA5), // Summarize — green
    Color(0xFF3498DB), // Questions — blue
    Color(0xFFE74C8B), // Tutor — pink
    Color(0xFF2C2C2A), // Organize — dark
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.cardBorder, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── AI action chips row ──
          SizedBox(
            height: 50,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: aiModes.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (_, i) {
                final mode = aiModes[i];
                final isSelected = selectedAiMode == i;
                final color = modeColors[i];
                return GestureDetector(
                  onTap: () => onAiModeSelected(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? color.withOpacity(0.12)
                          : AppColors.background,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? color : AppColors.divider,
                        width: isSelected ? 1.2 : 0.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          mode.icon,
                          size: 16,
                          color: isSelected ? color : AppColors.textHint,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          mode.label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: isSelected ? color : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // ── Divider ──
          Container(
            height: 0.5,
            margin: const EdgeInsets.symmetric(horizontal: 14),
            color: AppColors.divider,
          ),

          // ── Text field + send button ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => onSend(),
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: const TextStyle(
                      color: AppColors.textHint,
                      fontSize: 15,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 10, bottom: 10),
                child: GestureDetector(
                  onTap: onSend,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: selectedAiMode >= 0
                          ? modeColors[selectedAiMode]
                          : AppColors.textPrimary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_upward,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
