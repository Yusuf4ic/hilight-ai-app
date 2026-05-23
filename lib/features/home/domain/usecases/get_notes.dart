import '../../data/models/note_card.dart';
import '../../data/repositories/notes_repository.dart';

class GetNotes {
  final NotesRepository _repository;

  const GetNotes(this._repository);

  Future<List<NoteCard>> call() => _repository.getNotes();
}
