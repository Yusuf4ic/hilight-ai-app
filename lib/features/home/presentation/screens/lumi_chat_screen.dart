import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../data/models/note_card.dart';
import '../providers/notes_provider.dart';

// ── Models ───────────────────────────────────────────────────────────────────

class AiMode {
  final IconData icon;
  final String label;
  final String hint;
  const AiMode(this.icon, this.label, this.hint);
}

class ChatMessage {
  final String text;
  final bool isUser;
  final String? modeLabel;
  final Color? modeColor;
  final DateTime timestamp;
  final bool isTyping;

  const ChatMessage({
    required this.text,
    required this.isUser,
    this.modeLabel,
    this.modeColor,
    required this.timestamp,
    this.isTyping = false,
  });
}

// ── Lumi Chat Screen ─────────────────────────────────────────────────────────

class LumiChatScreen extends ConsumerStatefulWidget {
  const LumiChatScreen({
    super.key,
    this.initialMessage,
    this.initialModeIndex = -1,
    this.existingNote,
  });

  /// The first user message that triggered the chat.
  final String? initialMessage;

  /// AI mode index at the moment the chat was opened (‑1 = general).
  final int initialModeIndex;

  /// The existing NoteCard if we are resuming an old chat.
  final NoteCard? existingNote;

  @override
  ConsumerState<LumiChatScreen> createState() => _LumiChatScreenState();
}

class _LumiChatScreenState extends ConsumerState<LumiChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  int _selectedAiMode = -1;
  String? _chatNoteId;

  static List<AiMode> get _aiModes => [
    AiMode(Icons.document_scanner_outlined, S.modeOcr,       S.hintOcr),
    AiMode(Icons.mic_none_rounded,          S.modeSpeech,    S.hintSpeech),
    AiMode(Icons.summarize_outlined,        S.modeSummarize, S.hintSummarize),
    AiMode(Icons.quiz_outlined,             S.modeQuestions, S.hintQuestions),
    AiMode(Icons.school_outlined,           S.modeTutor,     S.hintTutor),
    AiMode(Icons.account_tree_outlined,     S.modeOrganize,  S.hintOrganize),
  ];

  static const modeColors = [
    Color(0xFFE67E22), // OCR
    Color(0xFF7F77DD), // Speech
    Color(0xFF5DCAA5), // Summarize
    Color(0xFF3498DB), // Questions
    Color(0xFFE74C8B), // Tutor
    Color(0xFF2C2C2A), // Organize
  ];

  @override
  void initState() {
    super.initState();
    _selectedAiMode = widget.initialModeIndex;

    if (widget.existingNote != null) {
      _chatNoteId = widget.existingNote!.id;
      final historyRaw = widget.existingNote!.aiSummary ?? '';
      if (historyRaw.isNotEmpty) {
        final lines = historyRaw.split('\n');
        for (final line in lines) {
          final parts = line.split('|||');
          if (parts.length >= 3) {
            final isUser = parts[0] == 'You';
            final text = parts[1];
            final time = DateTime.tryParse(parts[2]) ?? DateTime.now();
            _messages.add(ChatMessage(
              text: text,
              isUser: isUser,
              timestamp: time,
            ));
          }
        }
      }
    } else if (widget.initialMessage != null && widget.initialMessage!.isNotEmpty) {
      // Seed the conversation with the initial user message + process it
      final modeLabel =
          widget.initialModeIndex >= 0 ? _aiModes[widget.initialModeIndex].label : null;
      final modeColor =
          widget.initialModeIndex >= 0 ? modeColors[widget.initialModeIndex] : null;

      _messages.add(ChatMessage(
        text: widget.initialMessage!,
        isUser: true,
        modeLabel: modeLabel,
        modeColor: modeColor,
        timestamp: DateTime.now(),
      ));
      
      // Immediately start processing the first message
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _processMessage(widget.initialMessage!);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ── Helpers ──

  String get _currentHint {
    if (_selectedAiMode < 0) return S.askLumiAnything;
    return _aiModes[_selectedAiMode].hint;
  }

  bool _isProcessing = false;

  Future<void> _handleSend() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isProcessing) return;

    final modeLabel = _selectedAiMode >= 0 ? _aiModes[_selectedAiMode].label : null;
    final modeColor = _selectedAiMode >= 0 ? modeColors[_selectedAiMode] : null;

    setState(() {
      _isProcessing = true;
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
        modeLabel: modeLabel,
        modeColor: modeColor,
        timestamp: DateTime.now(),
      ));
    });

    _controller.clear();
    _focusNode.unfocus();
    _scrollToBottom();
    
    await _processMessage(text);
  }

  Future<void> _processMessage(String prompt) async {
    if (!mounted) return;
    
    setState(() {
      _isProcessing = true;
      _messages.add(ChatMessage(
        text: '',
        isUser: false,
        timestamp: DateTime.now(),
        isTyping: true,
      ));
    });
    
    _scrollToBottom();

    try {
      // Build history for backend
      final history = _messages
          .where((m) => !m.isTyping) // exclude the typing placeholder
          .map((m) => {
                'role': m.isUser ? 'user' : 'model',
                'text': m.text,
              })
          .toList();

      final scanService = ref.read(scanServiceProvider);
      final responseText = await scanService.sendChatMessage(history);

      if (!mounted) return;

      setState(() {
        _messages.removeLast(); // remove typing indicator
        _messages.add(ChatMessage(
          text: responseText,
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isProcessing = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.removeLast();
        _messages.add(ChatMessage(
          text: 'Error connecting to Gemini: $e',
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isProcessing = false;
      });
    }

    _updateChatNote();

    _controller.clear();
    _focusNode.unfocus();
    _scrollToBottom();
  }

  void _updateChatNote() {
    // Build the full dialogue (all messages including the first pair)
    final fullBuffer = StringBuffer();
    for (final m in _messages) {
      if (m.isUser) {
        fullBuffer.writeln('You|||${m.text}|||${m.timestamp.toIso8601String()}');
      } else {
        fullBuffer.writeln('Lumi|||${m.text}|||${m.timestamp.toIso8601String()}');
      }
    }

    final fullLog = fullBuffer.toString().trim();
    if (fullLog.isEmpty) return;

    // Title = first user message (truncated to 60 chars)
    final firstUserMsg = _messages.firstWhere(
      (m) => m.isUser,
      orElse: () => _messages.first,
    );
    final title = firstUserMsg.text.length > 60
        ? '${firstUserMsg.text.substring(0, 60)}\u2026'
        : firstUserMsg.text;

    if (_chatNoteId == null) {
      _chatNoteId = const Uuid().v4();
      final card = NoteCard(
        id: _chatNoteId!,
        type: CardType.aiInsight,
        manualTitle: title,
        aiSummary: fullLog,
      );
      ref.read(notesProvider.notifier).addNote(card);
    } else {
      final card = NoteCard(
        id: _chatNoteId!,
        type: CardType.aiInsight,
        manualTitle: title,
        aiSummary: fullLog,
      );
      ref.read(notesProvider.notifier).updateNote(card);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ── Build ──

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: _messages.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) => _ChatBubble(message: _messages[i]),
              ),
            ),
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  // ── Header ──

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(color: AppColors.divider, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                size: 20, color: AppColors.textPrimary),
          ),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.aiBadgeBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.auto_awesome,
                size: 18, color: AppColors.aiAccent),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lumi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'AI Assistant',
                  style: TextStyle(fontSize: 11, color: AppColors.textHint),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _messages.clear();
                _chatNoteId = null;
              });
            },
            icon: const Icon(Icons.delete_outline_rounded,
                size: 22, color: AppColors.textHint),
            tooltip: S.clearChat,
          ),
        ],
      ),
    );
  }

  // ── Input bar ──

  Widget _buildInputBar() {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.cardBorder, width: 0.5),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── AI mode chips ──
          SizedBox(
            height: 50,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _aiModes.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (_, i) {
                final mode = _aiModes[i];
                final isSelected = _selectedAiMode == i;
                final color = modeColors[i];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedAiMode = _selectedAiMode == i ? -1 : i;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          // ignore: deprecated_member_use
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
                        Icon(mode.icon,
                            size: 16,
                            color: isSelected ? color : AppColors.textHint),
                        const SizedBox(width: 5),
                        Text(
                          mode.label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                            color:
                                isSelected ? color : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          Container(
            height: 0.5,
            margin: const EdgeInsets.symmetric(horizontal: 14),
            color: AppColors.divider,
          ),

          // ── Text field + send ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _handleSend(),
                  style: const TextStyle(
                      fontSize: 16, color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: _currentHint,
                    hintStyle: const TextStyle(
                        color: AppColors.textHint, fontSize: 15),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 10, bottom: 10),
                child: GestureDetector(
                  onTap: _handleSend,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: _selectedAiMode >= 0
                          ? modeColors[_selectedAiMode]
                          : AppColors.textPrimary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_upward,
                        color: Colors.white, size: 20),
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

// ── Chat Bubble ──────────────────────────────────────────────────────────────

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final time =
        '${message.timestamp.hour.toString().padLeft(2, '0')}:'
        '${message.timestamp.minute.toString().padLeft(2, '0')}';

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isUser ? AppColors.textPrimary : AppColors.surface,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isUser ? 16 : 4),
              bottomRight: Radius.circular(isUser ? 4 : 16),
            ),
            border: isUser
                ? null
                : Border.all(color: AppColors.cardBorder, width: 0.5),
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: Colors.black.withOpacity(0.04),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment:
                isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              // Mode tag for user messages
              if (isUser && message.modeLabel != null) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  margin: const EdgeInsets.only(bottom: 6),
                  decoration: BoxDecoration(
                    color: (message.modeColor ?? AppColors.textHint)
                        // ignore: deprecated_member_use
                        .withOpacity(0.25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    message.modeLabel!,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ],
              // AI avatar for bot messages
              if (!isUser) ...[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: AppColors.aiBadgeBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.auto_awesome,
                          size: 12, color: AppColors.aiAccent),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Lumi',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.aiAccent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
              ],
              // Message text
              if (message.isTyping)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.aiAccent,
                    ),
                  ),
                )
              else
                Text(
                  message.text,
                  style: TextStyle(
                    fontSize: 14,
                    color: isUser ? Colors.white : AppColors.textPrimary,
                    height: 1.45,
                  ),
                ),
              const SizedBox(height: 4),
              // Timestamp
              Text(
                time,
                style: TextStyle(
                  fontSize: 10,
                  color: isUser
                      // ignore: deprecated_member_use
                      ? Colors.white.withOpacity(0.5)
                      : AppColors.textHint,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
