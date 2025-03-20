import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isAvailable = false;
  bool _isListening = false;
  List<stt.LocaleName> _availableLocales = [];

  // Add callback for status changes
  Function? onListeningStateChanged;
  Function(String)? onError;

  Future<void> initialize() async {
    try {
      _isAvailable = await _speech.initialize(
        onStatus: (status) {
          // Handle status changes
          if (status == 'done' || status == 'notListening') {
            _isListening = false;
            // Notify UI about state change
            onListeningStateChanged?.call(false);
          } else if (status == 'listening') {
            _isListening = true;
            // Notify UI about state change
            onListeningStateChanged?.call(true);
          }
        },
        onError: (error) {
          stopListening();
          onError?.call("Error: $error");
        },
      );

      if (_isAvailable) {
        _availableLocales = await _speech.locales();
      }
    } catch (e) {
      onError?.call("Initialization error: $e");
    }
  }

  Future<void> startListening(
    Function(String) onResult,
    String localeId,
  ) async {
    if (!_isAvailable || _isListening) return;

    try {
      var selectedLocale = _availableLocales.firstWhere(
        (locale) => locale.localeId.toLowerCase() == localeId.toLowerCase(),
        orElse:
            () => _availableLocales.firstWhere(
              (locale) => locale.localeId.startsWith(localeId.split('-')[0]),
              orElse: () => _availableLocales.first,
            ),
      );

      await _speech.listen(
        onResult: (result) {
          onResult(result.recognizedWords);
        },
        localeId: selectedLocale.localeId,
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
      );

      _isListening = true;
      onListeningStateChanged?.call(true);
    } catch (e) {
      onError?.call("Failed to start listening: $e");
      _isListening = false;
      onListeningStateChanged?.call(false);
    }
  }

  // Get available languages
  Future<List<Map<String, String>>> getAvailableLanguages() async {
    if (!_isAvailable) return [];

    return _availableLocales.map((locale) {
      return {"name": locale.name, "code": locale.localeId};
    }).toList();
  }

  void stopListening() {
    if (_isListening) {
      _speech.stop();
      _isListening = false;
      onListeningStateChanged?.call(false);
    }
  }

  bool get isListening => _isListening;
}
