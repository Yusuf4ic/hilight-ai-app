import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/note_card.dart';
import '../../data/repositories/notes_repository.dart';
import '../../domain/usecases/get_notes.dart';

final notesRepositoryProvider = Provider<NotesRepository>(
  (_) => NotesRepositoryImpl(),
);

final getNotesProvider = Provider<GetNotes>(
  (ref) => GetNotes(ref.read(notesRepositoryProvider)),
);

final notesProvider = FutureProvider<List<NoteCard>>((ref) {
  return ref.read(getNotesProvider)();
});
