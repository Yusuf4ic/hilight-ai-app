enum CardType { scannedQuote, voiceNote, aiInsight }

class NoteCard {
  final String id;
  final CardType type;

  // scannedQuote
  final String? quote;
  final String? bookTitle;
  final String? author;
  final String? page;

  // voiceNote
  final String? voiceTranscript;
  final String? voiceDuration;
  final String? voiceTime;

  // aiInsight
  final String? aiSummary;

  const NoteCard({
    required this.id,
    required this.type,
    this.quote,
    this.bookTitle,
    this.author,
    this.page,
    this.voiceTranscript,
    this.voiceDuration,
    this.voiceTime,
    this.aiSummary,
  });
}
