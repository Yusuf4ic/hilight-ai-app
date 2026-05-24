import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  NotesNotifier(this._ref) : super(const AsyncValue.loading()) {
    _loadInitialNotes();
    _startPolling();
  }

  Future<void> _loadInitialNotes() async {
    try {
      final repo = NotesRepositoryImpl();
      final notes = await repo.getNotes();
      state = AsyncValue.data(notes);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
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
        state = AsyncValue.data([pollResult.card!, ...currentNotes]);
      }
    } else if (!pollResult.hasNew) {
      // Update scan_id to stay in sync even with no new results
      _lastScanId = pollResult.scanId;
    }
  }

  /// Trigger a scan: ESP32 capture → Gemini OCR → add card to top of list.
  Future<ScanResult> scanText() async {
    final scanService = _ref.read(scanServiceProvider);

    _ref.read(isScanningProvider.notifier).state = true;
    _ref.read(scanErrorProvider.notifier).state = null;

    try {
      final result = await scanService.scanText();

      if (result.success && result.card != null) {
        // Update _lastScanId so polling won't re-add this result
        if (result.rawJson != null && result.rawJson!['scan_id'] != null) {
          _lastScanId = result.rawJson!['scan_id'] as int;
        }

        // Prepend the new card to the top of the list
        final currentNotes = state.valueOrNull ?? [];
        state = AsyncValue.data([result.card!, ...currentNotes]);
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
}
