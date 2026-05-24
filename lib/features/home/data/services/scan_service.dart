import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_config.dart';
import '../models/note_card.dart';

/// Service that communicates with the HiLight Python backend.
class ScanService {
  /// Triggers ESP32-CAM capture → Gemini text extraction and returns a NoteCard.
  Future<ScanResult> scanText() async {
    try {
      final response = await http
          .post(Uri.parse(ApiConfig.scanEndpoint))
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;

        if (data['success'] == true) {
          final extractedText = data['extracted_text'] as String? ?? '';
          final highlights = (data['highlights'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              [];
          final title = data['title'] as String?;
          final page = data['page_number'] as String?;
          final confidence = data['confidence'] as String? ?? 'low';
          final language = data['language'] as String?;
          final isMock = data['mock'] as bool? ?? false;
          final imageFilename = data['image_filename'] as String?;

          // Build the quote text — use highlighted text if available,
          // otherwise the full extracted text
          final quoteText = highlights.isNotEmpty
              ? highlights.join('\n')
              : extractedText;

          final card = NoteCard(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            type: CardType.scannedQuote,
            quote: quoteText.isNotEmpty ? '"$quoteText"' : 'No text detected',
            bookTitle: title ?? 'Scanned Document',
            author: confidence == 'high'
                ? 'High confidence'
                : confidence == 'medium'
                    ? 'Medium confidence'
                    : 'Low confidence',
            page: page != null ? 'Page $page' : (language ?? 'Scan'),
          );

          return ScanResult(
            success: true,
            card: card,
            rawJson: data,
            isMock: isMock,
            imageFilename: imageFilename,
          );
        } else {
          return ScanResult(
            success: false,
            error: data['error'] as String? ?? 'Unknown error',
          );
        }
      } else {
        return ScanResult(
          success: false,
          error: 'Server error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ScanResult(
        success: false,
        error: 'Cannot reach backend: $e',
      );
    }
  }

  /// Uploads a photo taken by the device camera to the backend for processing.
  Future<ScanResult> scanImageUpload(String imagePath) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConfig.scanUploadEndpoint),
      );
      
      request.files.add(
        await http.MultipartFile.fromPath('image', imagePath),
      );

      final responseStream = await request.send().timeout(const Duration(seconds: 40));
      final response = await http.Response.fromStream(responseStream);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;

        if (data['success'] == true) {
          final extractedText = data['extracted_text'] as String? ?? '';
          final highlights = (data['highlights'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              [];
          final title = data['title'] as String?;
          final page = data['page_number'] as String?;
          final confidence = data['confidence'] as String? ?? 'low';
          final language = data['language'] as String?;
          final isMock = data['mock'] as bool? ?? false;
          final imageFilename = data['image_filename'] as String?;

          final quoteText = highlights.isNotEmpty
              ? highlights.join('\n')
              : extractedText;

          final card = NoteCard(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            type: CardType.scannedQuote,
            quote: quoteText.isNotEmpty ? '"$quoteText"' : 'No text detected',
            bookTitle: title ?? 'Scanned Document',
            author: confidence == 'high'
                ? 'High confidence'
                : confidence == 'medium'
                    ? 'Medium confidence'
                    : 'Low confidence',
            page: page != null ? 'Page $page' : (language ?? 'Scan'),
          );

          return ScanResult(
            success: true,
            card: card,
            rawJson: data,
            isMock: isMock,
            imageFilename: imageFilename,
          );
        } else {
          return ScanResult(
            success: false,
            error: data['error'] as String? ?? 'Unknown error',
          );
        }
      } else {
        return ScanResult(
          success: false,
          error: 'Server error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ScanResult(
        success: false,
        error: 'Upload failed: $e',
      );
    }
  }

  /// Check if the backend and ESP32-CAM are reachable.
  Future<HealthStatus> checkHealth() async {
    try {
      final response = await http
          .get(Uri.parse(ApiConfig.healthEndpoint))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return HealthStatus(
          backendOk: true,
          esp32Reachable: data['esp32_cam'] == 'reachable',
          geminiConfigured: data['gemini_configured'] as bool? ?? false,
        );
      }
      return const HealthStatus(backendOk: false);
    } catch (_) {
      return const HealthStatus(backendOk: false);
    }
  }

  /// Poll for new scan results (triggered by ESP32 hardware button).
  /// Returns a ScanResult if there's a new scan after [afterScanId].
  Future<PollResult> checkLatest(int afterScanId) async {
    try {
      final uri = Uri.parse('${ApiConfig.latestEndpoint}?after=$afterScanId');
      final response =
          await http.get(uri).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final hasNew = data['has_new'] as bool? ?? false;
        final scanId = data['scan_id'] as int? ?? 0;

        if (hasNew && data['result'] != null) {
          final result = data['result'] as Map<String, dynamic>;
          final extractedText = result['extracted_text'] as String? ?? '';
          final highlights = (result['highlights'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              [];
          final title = result['title'] as String?;
          final page = result['page_number'] as String?;
          final confidence = result['confidence'] as String? ?? 'low';
          final language = result['language'] as String?;

          final quoteText = highlights.isNotEmpty
              ? highlights.join('\n')
              : extractedText;

          final card = NoteCard(
            id: 'device_$scanId',
            type: CardType.scannedQuote,
            quote: quoteText.isNotEmpty ? '"$quoteText"' : 'No text detected',
            bookTitle: title ?? 'Scanned Document',
            author: confidence == 'high'
                ? 'High confidence'
                : confidence == 'medium'
                    ? 'Medium confidence'
                    : 'Low confidence',
            page: page != null ? 'Page $page' : (language ?? 'Scan'),
          );

          return PollResult(hasNew: true, scanId: scanId, card: card);
        }

        return PollResult(hasNew: false, scanId: scanId);
      }
      return PollResult(hasNew: false, scanId: afterScanId);
    } catch (_) {
      return PollResult(hasNew: false, scanId: afterScanId);
    }
  }

  /// Sends a conversation history to the backend for Gemini chat processing.
  Future<String> sendChatMessage(List<Map<String, dynamic>> messages) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.chatEndpoint),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'messages': messages}),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        if (data['success'] == true) {
          return data['response'] as String? ?? 'Empty response from AI';
        } else {
          throw Exception(data['error'] ?? 'Unknown error from AI');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to communicate with AI: $e');
    }
  }
}

/// Result of a scan operation.
class ScanResult {
  final bool success;
  final NoteCard? card;
  final Map<String, dynamic>? rawJson;
  final String? error;
  final bool isMock;
  final String? imageFilename;

  const ScanResult({
    required this.success,
    this.card,
    this.rawJson,
    this.error,
    this.isMock = false,
    this.imageFilename,
  });
}

/// Health status of the backend.
class HealthStatus {
  final bool backendOk;
  final bool esp32Reachable;
  final bool geminiConfigured;

  const HealthStatus({
    required this.backendOk,
    this.esp32Reachable = false,
    this.geminiConfigured = false,
  });
}

/// Result of polling for new device-triggered scans.
class PollResult {
  final bool hasNew;
  final int scanId;
  final NoteCard? card;

  const PollResult({
    required this.hasNew,
    required this.scanId,
    this.card,
  });
}
