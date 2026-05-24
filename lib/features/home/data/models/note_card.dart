enum CardType { scannedQuote, voiceNote, aiInsight, manualNote }

class NoteCard {
  final String id;
  final CardType type;
  final bool isHiddenFromHome;

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

  // manualNote
  final String? manualTitle;
  final String? manualBody;

  const NoteCard({
    required this.id,
    required this.type,
    this.isHiddenFromHome = false,
    this.quote,
    this.bookTitle,
    this.author,
    this.page,
    this.voiceTranscript,
    this.voiceDuration,
    this.voiceTime,
    this.aiSummary,
    this.manualTitle,
    this.manualBody,
  });

  NoteCard copyWith({
    String? id,
    CardType? type,
    bool? isHiddenFromHome,
    String? quote,
    String? bookTitle,
    String? author,
    String? page,
    String? voiceTranscript,
    String? voiceDuration,
    String? voiceTime,
    String? aiSummary,
    String? manualTitle,
    String? manualBody,
  }) {
    return NoteCard(
      id: id ?? this.id,
      type: type ?? this.type,
      isHiddenFromHome: isHiddenFromHome ?? this.isHiddenFromHome,
      quote: quote ?? this.quote,
      bookTitle: bookTitle ?? this.bookTitle,
      author: author ?? this.author,
      page: page ?? this.page,
      voiceTranscript: voiceTranscript ?? this.voiceTranscript,
      voiceDuration: voiceDuration ?? this.voiceDuration,
      voiceTime: voiceTime ?? this.voiceTime,
      aiSummary: aiSummary ?? this.aiSummary,
      manualTitle: manualTitle ?? this.manualTitle,
      manualBody: manualBody ?? this.manualBody,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'isHiddenFromHome': isHiddenFromHome,
      'quote': quote,
      'bookTitle': bookTitle,
      'author': author,
      'page': page,
      'voiceTranscript': voiceTranscript,
      'voiceDuration': voiceDuration,
      'voiceTime': voiceTime,
      'aiSummary': aiSummary,
      'manualTitle': manualTitle,
      'manualBody': manualBody,
    };
  }

  factory NoteCard.fromJson(Map<String, dynamic> json) {
    return NoteCard(
      id: json['id'] as String,
      type: CardType.values.firstWhere((e) => e.name == json['type'], orElse: () => CardType.manualNote),
      isHiddenFromHome: json['isHiddenFromHome'] as bool? ?? false,
      quote: json['quote'] as String?,
      bookTitle: json['bookTitle'] as String?,
      author: json['author'] as String?,
      page: json['page'] as String?,
      voiceTranscript: json['voiceTranscript'] as String?,
      voiceDuration: json['voiceDuration'] as String?,
      voiceTime: json['voiceTime'] as String?,
      aiSummary: json['aiSummary'] as String?,
      manualTitle: json['manualTitle'] as String?,
      manualBody: json['manualBody'] as String?,
    );
  }
}
