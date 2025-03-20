import 'package:flutter/material.dart';
import 'package:offline_speech_app/utils/responsive_helper.dart';
import 'package:offline_speech_app/Text/flutter_tts.dart';
import 'package:translator/translator.dart';

class TextTranslationScreen extends StatefulWidget {
  const TextTranslationScreen({super.key});

  @override
  TextTranslationScreenState createState() => TextTranslationScreenState();
}

class TextTranslationScreenState extends State<TextTranslationScreen> {
  final TextEditingController _textController = TextEditingController();
  final TextToSpeechService _ttsService = TextToSpeechService();
  final translator = GoogleTranslator();

  bool _isLoading = false;
  String _translatedText = '';

  // Predefined supported languages
  final List<Map<String, String>> _languages = [
    {"name": "English", "code": "en"},
    {"name": "Hindi", "code": "hi"},
    {"name": "Tamil", "code": "ta"},
    {"name": "Telugu", "code": "te"},
    {"name": "Malayalam", "code": "ml"},
    {"name": "Kannada", "code": "kn"},
    {"name": "Chinese", "code": "zh-cn"},
    {"name": "Japanese", "code": "ja"},
    {"name": "Korean", "code": "ko"},
    {"name": "Vietnamese", "code": "vi"},
    {"name": "Thai", "code": "th"},
  ];

  late Map<String, String> _sourceLanguage;
  late Map<String, String> _targetLanguage;

  @override
  void initState() {
    super.initState();
    _sourceLanguage = _languages[0]; // English
    _targetLanguage = _languages[1]; // Hindi
    _initializeTTS();
  }

  Future<void> _initializeTTS() async {
    try {
      await _ttsService.initialize();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error initializing TTS: $e')));
      }
    }
  }

  Future<void> _translateText() async {
    if (_textController.text.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final result = await translator.translate(
        _textController.text,
        from: _sourceLanguage["code"]!,
        to: _targetLanguage["code"]!,
      );

      setState(() => _translatedText = result.text);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Translation error. Please check your internet connection or try again later.',
            ),
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = ResponsiveHelper.getScreenWidth(context);
    final screenHeight = ResponsiveHelper.getScreenHeight(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Text Translation',
          style: TextStyle(
            fontSize: ResponsiveHelper.getFontSize(context, 24),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.orangeAccent,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          children: [
            // Language Selection
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLanguageDropdown(
                  'From',
                  _sourceLanguage,
                  (value) => setState(() => _sourceLanguage = value),
                ),
                IconButton(
                  icon: const Icon(Icons.swap_horiz),
                  onPressed: () {
                    setState(() {
                      final temp = _sourceLanguage;
                      _sourceLanguage = _targetLanguage;
                      _targetLanguage = temp;
                      if (_translatedText.isNotEmpty) _translateText();
                    });
                  },
                ),
                _buildLanguageDropdown(
                  'To',
                  _targetLanguage,
                  (value) => setState(() => _targetLanguage = value),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.02),

            // Input Text Field
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                controller: _textController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Enter text to translate',
                  contentPadding: EdgeInsets.all(16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (_) => setState(() => _translatedText = ''),
              ),
            ),
            SizedBox(height: screenHeight * 0.02),

            // Translate Button
            ElevatedButton(
              onPressed: _isLoading ? null : _translateText,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.08,
                  vertical: screenHeight * 0.02,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child:
                  _isLoading
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                      : const Text(
                        'Translate',
                        style: TextStyle(color: Colors.white),
                      ),
            ),
            SizedBox(height: screenHeight * 0.02),

            // Translated Text
            if (_translatedText.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Translation:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: ResponsiveHelper.getFontSize(context, 16),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      _translatedText,
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getFontSize(context, 16),
                      ),
                    ),
                    SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed:
                          () => _ttsService.speak(
                            _translatedText,
                            _targetLanguage["code"]!,
                          ),
                      icon: const Icon(Icons.volume_up, color: Colors.white),
                      label: const Text(
                        'Listen',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orangeAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageDropdown(
    String label,
    Map<String, String> selectedLanguage,
    Function(Map<String, String>) onChanged,
  ) {
    return Column(
      children: [
        Text(label),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(20),
          ),
          child: DropdownButton<String>(
            value: selectedLanguage["code"],
            underline: Container(),
            items:
                _languages.map((lang) {
                  return DropdownMenuItem(
                    value: lang["code"],
                    child: Text(lang["name"]!),
                  );
                }).toList(),
            onChanged: (value) {
              final newLang = _languages.firstWhere(
                (lang) => lang["code"] == value,
              );
              onChanged(newLang);
              if (_translatedText.isNotEmpty) _translateText();
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
