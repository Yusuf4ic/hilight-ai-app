import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/note_card.dart';
import '../../data/repositories/notes_repository.dart';
import '../../data/services/scan_service.dart';

// ── Services ──
final scanServiceProvider = Provider<ScanService>((_) => ScanService());

// ── Notes state ──
final notesProvider =
    StateNotifierProvider<NotesNotifier, AsyncValue<List<NoteCard>>>((ref) {
  final notifier = NotesNotifier(ref);
  ref.onDispose(() => notifier.stopPolling());
  return notifier;
});

/// Tracks whether a scan is currently in progress.
final isScanningProvider = StateProvider<bool>((_) => false);

/// Holds the last scan error message (null if no error).
final scanErrorProvider = StateProvider<String?>((_) => null);

class NotesNotifier extends StateNotifier<AsyncValue<List<NoteCard>>> {
  final Ref _ref;
  Timer? _pollTimer;
  int _lastScanId = 0;
  static const _prefsKey = 'saved_notes';

  NotesNotifier(this._ref) : super(const AsyncValue.loading()) {
    _loadInitialNotes();
    _startPolling();
  }

  Future<void> _loadInitialNotes() async {
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
        final repo = NotesRepositoryImpl();
        final notes = await repo.getNotes();
        state = AsyncValue.data(notes);
        _saveToPrefs(notes);
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

  /// Start polling for device-triggered scans every 3 seconds.
  void _startPolling() {
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      await _checkForDeviceScans();
    });
  }

  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  Future<void> _checkForDeviceScans() async {
    final scanService = _ref.read(scanServiceProvider);
    final pollResult = await scanService.checkLatest(_lastScanId);

    if (pollResult.hasNew && pollResult.card != null) {
      _lastScanId = pollResult.scanId;

      // Don't add duplicate — check if we already have this scan_id
      final currentNotes = state.valueOrNull ?? [];
      final alreadyExists = currentNotes.any((n) => n.id == pollResult.card!.id);

      if (!alreadyExists) {
        final updatedList = [pollResult.card!, ...currentNotes];
        state = AsyncValue.data(updatedList);
        _saveToPrefs(updatedList);
      }
    } else if (!pollResult.hasNew) {
      // Update scan_id to stay in sync even with no new results
      _lastScanId = pollResult.scanId;
    }
  }

  /// Trigger a scan: optionally upload a device image, else trigger ESP32.
  Future<ScanResult> scanText({String? imagePath}) async {
    final scanService = _ref.read(scanServiceProvider);

    _ref.read(isScanningProvider.notifier).state = true;
    _ref.read(scanErrorProvider.notifier).state = null;

    try {
      final result = imagePath != null
          ? await scanService.scanImageUpload(imagePath)
          : await scanService.scanText();

      if (result.success && result.card != null) {
        // Update _lastScanId so polling won't re-add this result
        if (result.rawJson != null && result.rawJson!['scan_id'] != null) {
          _lastScanId = result.rawJson!['scan_id'] as int;
        }

        // Prepend the new card to the top of the list
        final currentNotes = state.valueOrNull ?? [];
        final updatedList = [result.card!, ...currentNotes];
        state = AsyncValue.data(updatedList);
        _saveToPrefs(updatedList);
      } else {
        _ref.read(scanErrorProvider.notifier).state =
            result.error ?? 'Scan failed';
      }

      return result;
    } catch (e) {
      _ref.read(scanErrorProvider.notifier).state = e.toString();
      return ScanResult(success: false, error: e.toString());
    } finally {
      _ref.read(isScanningProvider.notifier).state = false;
    }
  }

  // ── CRUD operations (our local additions) ─────────────────────────────────

  void addNote(NoteCard note) {
    final currentList = state.valueOrNull ?? [];
    final updatedList = [note, ...currentList];
    state = AsyncValue.data(updatedList);
    _saveToPrefs(updatedList);
  }

  void hideFromHome(String id) {
    final currentList = state.valueOrNull ?? [];
    final updatedList = currentList.map((note) {
      if (note.id == id) {
        return note.copyWith(isHiddenFromHome: true);
      }
      return note;
    }).toList();
    state = AsyncValue.data(updatedList);
    _saveToPrefs(updatedList);
  }

  void deleteNote(String id) {
    final currentList = state.valueOrNull ?? [];
    final updatedList = currentList.where((note) => note.id != id).toList();
    state = AsyncValue.data(updatedList);
    _saveToPrefs(updatedList);
  }

  void updateNote(NoteCard updatedNote) {
    final currentList = state.valueOrNull ?? [];
    final updatedList = currentList.map((note) {
      if (note.id == updatedNote.id) return updatedNote;
      return note;
    }).toList();
    state = AsyncValue.data(updatedList);
    _saveToPrefs(updatedList);
  }
}
