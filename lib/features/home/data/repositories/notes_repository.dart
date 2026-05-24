import '../models/note_card.dart';

abstract class NotesRepository {
  Future<List<NoteCard>> getNotes();
}

class NotesRepositoryImpl implements NotesRepository {
  @override
  Future<List<NoteCard>> getNotes() async {
    // В будущем: запрос к API или локальной БД (Hive / Isar)
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      NoteCard(
        id: '1',
        type: CardType.scannedQuote,
        quote:
            '"The whole point of abundance is to subtract the obvious '
            'and add the meaningful."',
        bookTitle: 'Steal Like An Artist',
        author: 'Austin Kleon',
        page: 'Page 28',
      ),
      NoteCard(
        id: '2',
        type: CardType.voiceNote,
        voiceTime: 'Today, 9:30 AM',
        voiceDuration: '00:45',
        voiceTranscript:
            'Idea: Use this in the context of creative constraints.',
      ),
      NoteCard(
        id: '3',
        type: CardType.aiInsight,
        aiSummary:
            'This chapter is about focusing on what truly matters and '
            'removing distractions to create space for creativity.',
      ),
      NoteCard(
        id: '4',
        type: CardType.scannedQuote,
        quote:
            '"You do not rise to the level of your goals. '
            'You fall to the level of your systems."',
        bookTitle: 'Atomic Habits',
        author: 'James Clear',
        page: 'Page 54',
      ),
      NoteCard(
        id: '5',
        type: CardType.voiceNote,
        voiceTime: 'Yesterday, 6:15 PM',
        voiceDuration: '01:12',
        voiceTranscript:
            'Reflection: Build systems, not goals. '
            'Connect this to the chapter on habit loops and identity change.',
      ),
    ];
  }
}
