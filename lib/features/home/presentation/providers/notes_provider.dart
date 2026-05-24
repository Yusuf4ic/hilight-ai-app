import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/note_card.dart';
import '../../data/repositories/notes_repository.dart';
import '../../domain/usecases/get_notes.dart';

final notesRepositoryProvider = Provider<NotesRepository>(
  (_) => NotesRepositoryImpl(),
);

final getNotesProvider = Provider<GetNotes>(
  (ref) => GetNotes(ref.read(notesRepositoryProvider)),
);

class NotesNotifier extends Notifier<AsyncValue<List<NoteCard>>> {
  static const _prefsKey = 'saved_notes';

  @override
  AsyncValue<List<NoteCard>> build() {
    // Initial load
    _loadNotes();
    return const AsyncValue.loading();
  }

  Future<void> _loadNotes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notesJsonList = prefs.getStringList(_prefsKey);

      if (notesJsonList != null && notesJsonList.isNotEmpty) {
        // Load from local storage
        final loadedNotes = notesJsonList
            .map((jsonStr) => NoteCard.fromJson(jsonDecode(jsonStr)))
            .toList();
        state = AsyncValue.data(loadedNotes);
      } else {
        // Fallback to initial mock data if empty
        final initialNotes = await ref.read(getNotesProvider)();
        state = AsyncValue.data(initialNotes);
        _saveToPrefs(initialNotes);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> _saveToPrefs(List<NoteCard> notes) async {
    final prefs = await SharedPreferences.getInstance();
    final notesJsonList = notes.map((n) => jsonEncode(n.toJson())).toList();
    await prefs.setStringList(_prefsKey, notesJsonList);
  }

  void addNote(NoteCard note) {
    if (state is AsyncData) {
      final currentList = state.value!;
      final updatedList = [note, ...currentList];
      state = AsyncValue.data(updatedList);
      _saveToPrefs(updatedList);
    }
  }

  void hideFromHome(String id) {
    if (state is AsyncData) {
      final currentList = state.value!;
      final updatedList = currentList.map((note) {
        if (note.id == id) {
          return note.copyWith(isHiddenFromHome: true);
        }
        return note;
      }).toList();
      state = AsyncValue.data(updatedList);
      _saveToPrefs(updatedList);
    }
  }

  void deleteNote(String id) {
    if (state is AsyncData) {
      final currentList = state.value!;
      final updatedList = currentList.where((note) => note.id != id).toList();
      state = AsyncValue.data(updatedList);
      _saveToPrefs(updatedList);
    }
  }

  void updateNote(NoteCard updatedNote) {
    if (state is AsyncData) {
      final currentList = state.value!;
      final updatedList = currentList.map((note) {
        if (note.id == updatedNote.id) return updatedNote;
        return note;
      }).toList();
      state = AsyncValue.data(updatedList);
      _saveToPrefs(updatedList);
    }
  }
}

final notesProvider = NotifierProvider<NotesNotifier, AsyncValue<List<NoteCard>>>(() {
  return NotesNotifier();
});
