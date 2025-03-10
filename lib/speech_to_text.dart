import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isAvailable = false;
  bool _isListening = false;

  Future<void> initialize() async {
    _isAvailable = await _speech.initialize();
  }

  void startListening(Function(String) onResult) {
    if (_isAvailable && !_isListening) {
      _speech.listen(onResult: (result) {
        onResult(result.recognizedWords);
      });
      _isListening = true;
    }
  }

  void stopListening() {
    if (_isListening) {
      _speech.stop();
      _isListening = false;
    }
  }
}
