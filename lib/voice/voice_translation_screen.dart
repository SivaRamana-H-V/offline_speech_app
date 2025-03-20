import 'package:flutter/material.dart';
import 'package:offline_speech_app/Text/flutter_tts.dart';
import 'package:offline_speech_app/voice/speech_to_text.dart';
import 'package:offline_speech_app/utils/responsive_helper.dart';
import 'package:translator/translator.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

class VoiceTranslationScreen extends StatefulWidget {
  const VoiceTranslationScreen({super.key});

  @override
  VoiceTranslationScreenState createState() => VoiceTranslationScreenState();
}

class VoiceTranslationScreenState extends State<VoiceTranslationScreen> {
  final SpeechService _speechService = SpeechService();
  final TextToSpeechService _ttsService = TextToSpeechService();
  late OnDeviceTranslator _translator;

  List<Map<String, String>> _languages = [];
  bool _isLoading = true;
  bool _isTranslating = false;

  Map<String, String> _sourceLanguage = {"name": "English", "code": "en"};
  Map<String, String> _targetLanguage = {"name": "Hindi", "code": "hi"};
  String _recognizedText = "";
  String _translatedText = "";
  bool _isListening = false;

  final Map<String, TranslateLanguage> _mlKitLanguages = {
    'en-IN': TranslateLanguage.english,
    'en-US': TranslateLanguage.english,
    'en': TranslateLanguage.english,
    'hi-IN': TranslateLanguage.hindi,
    'hi': TranslateLanguage.hindi,
    'ta-IN': TranslateLanguage.tamil,
    'ta': TranslateLanguage.tamil,
    'te-IN': TranslateLanguage.telugu,
    'te': TranslateLanguage.telugu,
  };

  @override
  void initState() {
    super.initState();
    _initializeTranslator();
    _initializeSpeech();
  }

  Future<void> _initializeTranslator() async {
    _translator = OnDeviceTranslator(
      sourceLanguage: TranslateLanguage.english,
      targetLanguage: TranslateLanguage.hindi,
    );
  }

  Future<void> _translateText() async {
    if (_recognizedText.isEmpty) return;

    setState(() => _isTranslating = true);

    try {
      final sourceCode = _sourceLanguage["code"]!;
      final targetCode = _targetLanguage["code"]!;

      final mlKitSourceLang = _mlKitLanguages[sourceCode];
      final mlKitTargetLang = _mlKitLanguages[targetCode];

      if (mlKitSourceLang == null || mlKitTargetLang == null) {
        throw Exception(
          'Selected language is not supported for offline translation',
        );
      }

      _translator = OnDeviceTranslator(
        sourceLanguage: mlKitSourceLang,
        targetLanguage: mlKitTargetLang,
      );

      final modelManager = OnDeviceTranslatorModelManager();
      if (!await modelManager.isModelDownloaded(mlKitTargetLang.name)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Downloading language model...')),
          );
        }
        await modelManager.downloadModel(mlKitTargetLang.name);
      }

      final result = await _translator.translateText(_recognizedText);
      setState(() => _translatedText = result);
    } catch (e) {
      if (mounted) {
        print('Translation error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Translation error: $e\nPlease ensure language models are downloaded.',
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      setState(() => _isTranslating = false);
    }
  }

  Future<void> _initializeSpeech() async {
    await _speechService.initialize();

    final availableLanguages = await _speechService.getAvailableLanguages();
    if (mounted) {
      setState(() {
        _languages =
            availableLanguages.where((lang) {
              return _mlKitLanguages.containsKey(lang["code"]) ||
                  _mlKitLanguages.containsKey(lang["code"]!.split('-')[0]);
            }).toList();

        if (_languages.isEmpty) {
          _languages = [
            {"name": "English (US)", "code": "en-US"},
          ];
        }

        _languages.sort((a, b) => a["name"]!.compareTo(b["name"]!));

        _sourceLanguage = _languages.firstWhere(
          (lang) => lang["code"]!.startsWith('en'),
          orElse: () => _languages.first,
        );
        _targetLanguage = _languages.firstWhere(
          (lang) => lang["code"]!.startsWith('hi'),
          orElse: () => _languages.first,
        );
        _isLoading = false;
      });
    }

    _speechService.onListeningStateChanged = (bool isListening) {
      if (mounted) {
        setState(() {
          _isListening = isListening;
        });
      }
    };

    _speechService.onError = (String error) {
      if (mounted) {
        print(error);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error)));
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Voice Translation')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLanguageDropdown(
                  'From',
                  _sourceLanguage,
                  (value) => setState(() {
                    _sourceLanguage = value;
                    _recognizedText = "";
                    _translatedText = "";
                  }),
                ),
                IconButton(
                  icon: const Icon(Icons.swap_horiz),
                  onPressed: () {
                    setState(() {
                      final temp = _sourceLanguage;
                      _sourceLanguage = _targetLanguage;
                      _targetLanguage = temp;
                      _translatedText = "";
                    });
                  },
                ),
                _buildLanguageDropdown(
                  'To',
                  _targetLanguage,
                  (value) => setState(() {
                    _targetLanguage = value;
                    if (_recognizedText.isNotEmpty) _translateText();
                  }),
                ),
              ],
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                if (_isListening) {
                  _speechService.stopListening();
                } else {
                  await _speechService.startListening((text) {
                    setState(() {
                      _recognizedText = text;
                      _translatedText = "";
                    });
                    _translateText();
                  }, _sourceLanguage["code"]!);
                }
              },
              child: Text(_isListening ? 'Stop' : 'Start Recording'),
            ),
            if (_translatedText.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  'Translation: $_translatedText',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
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
        DropdownButton<String>(
          value: selectedLanguage["name"],
          items:
              _languages.map((lang) {
                return DropdownMenuItem(
                  value: lang["name"],
                  child: Text(lang["name"]!),
                );
              }).toList(),
          onChanged: (value) {
            final newLang = _languages.firstWhere(
              (lang) => lang["name"] == value,
            );
            onChanged(newLang);
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _translator.close();
    _speechService.onListeningStateChanged = null;
    super.dispose();
  }
}
