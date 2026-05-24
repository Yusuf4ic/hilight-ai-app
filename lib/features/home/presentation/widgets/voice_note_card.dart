import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../data/models/note_card.dart';
import 'card_shell.dart';
import 'waveform_bar.dart';

class VoiceNoteCard extends StatefulWidget {
  const VoiceNoteCard({super.key, required this.card});

  final NoteCard card;

  @override
  State<VoiceNoteCard> createState() => _VoiceNoteCardState();
}

class _VoiceNoteCardState extends State<VoiceNoteCard>
    with SingleTickerProviderStateMixin {
  bool _playing = false;
  late final AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CardShell(
      accentColor: AppColors.voiceAccent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                S.voiceNote,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                widget.card.voiceTime ?? '',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textHint,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _PlayButton(
                playing: _playing,
                onTap: () => setState(() => _playing = !_playing),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: WaveformBar(
                  controller: _waveController,
                  playing: _playing,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                widget.card.voiceDuration ?? '',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textHint,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            widget.card.voiceTranscript ?? '',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayButton extends StatelessWidget {
  const _PlayButton({required this.playing, required this.onTap});

  final bool playing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
          color: AppColors.textPrimary,
          shape: BoxShape.circle,
        ),
        child: Icon(
          playing ? Icons.pause : Icons.play_arrow,
          color: Colors.white,
          size: 18,
        ),
      ),
    );
  }
}
