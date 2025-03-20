import 'package:flutter/material.dart';
import 'package:offline_speech_app/Text/flutter_tts.dart';
import 'package:offline_speech_app/voice/speech_to_text.dart';
import 'package:offline_speech_app/utils/responsive_helper.dart';

class VoiceTranslationScreen extends StatefulWidget {
  const VoiceTranslationScreen({super.key});

  @override
  VoiceTranslationScreenState createState() => VoiceTranslationScreenState();
}

class VoiceTranslationScreenState extends State<VoiceTranslationScreen> {
  final SpeechService _speechService = SpeechService();
  final TextToSpeechService _ttsService = TextToSpeechService();

  List<Map<String, String>> _languages = [];
  bool _isLoading = true;

  Map<String, String> _selectedLanguage = {"name": "English", "code": "en-US"};
  String _recognizedText = "";
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
  }

  Future<void> _initializeSpeech() async {
    await _speechService.initialize();

    // Get available languages
    final availableLanguages = await _speechService.getAvailableLanguages();
    if (mounted) {
      setState(() {
        _languages =
            availableLanguages.where((lang) {
              String name = lang["name"]!.toLowerCase();
              return name.contains('english (india)') ||
                  name.contains('hindi (india)') ||
                  name.contains('tamil (india)') ||
                  name.contains('telugu (india)') ||
                  name.contains('malayalam (india)');
            }).toList();

        if (_languages.isEmpty) {
          // Add at least English if no languages are available
          _languages = [
            {"name": "English", "code": "en-US"},
          ];
        }

        // Sort languages alphabetically
        _languages.sort((a, b) => a["name"]!.compareTo(b["name"]!));

        // Set default language
        _selectedLanguage = _languages.firstWhere(
          (lang) => lang["code"]!.startsWith('en'),
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error)));
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = ResponsiveHelper.getScreenWidth(context);
    final screenHeight = ResponsiveHelper.getScreenHeight(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Voice Translation',
          style: TextStyle(
            fontSize: ResponsiveHelper.getFontSize(context, 24),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.orangeAccent,
      ),
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width:
                  ResponsiveHelper.isMobile(context)
                      ? screenWidth * 0.8
                      : screenWidth * 0.5,
              height:
                  ResponsiveHelper.isMobile(context)
                      ? screenHeight * 0.4
                      : screenHeight * 0.5,
              padding: EdgeInsets.all(screenWidth * 0.04),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(96, 158, 158, 158),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.mic,
                    size: ResponsiveHelper.getIconSize(context, 50),
                    color: _isListening ? Colors.red : Colors.grey,
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Text(
                    _isListening ? 'Listening...' : 'Tap to record',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getFontSize(context, 18),
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.04),
                  // Language selection dropdown
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.03,
                                vertical: screenHeight * 0.01,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: DropdownButton<String>(
                                value: _selectedLanguage["name"],
                                underline: Container(),
                                isDense: true,
                                isExpanded: false,
                                items:
                                    _languages.map((language) {
                                      return DropdownMenuItem<String>(
                                        value: language["name"],
                                        child: Container(
                                          constraints: BoxConstraints(
                                            maxWidth:
                                                screenWidth *
                                                0.5, // Limit width of dropdown items
                                          ),
                                          child: Text(
                                            language["name"]!,
                                            style: TextStyle(
                                              fontSize:
                                                  ResponsiveHelper.getFontSize(
                                                    context,
                                                    16,
                                                  ),
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedLanguage =
                                        Map<String, String>.from(
                                          _languages.firstWhere(
                                            (lang) => lang["name"] == value,
                                          ),
                                        );
                                    _recognizedText = "";
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            // Display recognized text
            if (_recognizedText.isNotEmpty)
              Container(
                width:
                    ResponsiveHelper.isMobile(context)
                        ? screenWidth * 0.8
                        : screenWidth * 0.5,
                padding: EdgeInsets.all(screenWidth * 0.04),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(96, 158, 158, 158),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Recognized Text (${_selectedLanguage["name"]}):',
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getFontSize(context, 16),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Text(
                      _recognizedText,
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getFontSize(context, 16),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            SizedBox(height: screenHeight * 0.03),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    if (_isListening) {
                      _speechService.stopListening();
                    } else {
                      await _speechService.startListening((text) {
                        setState(() {
                          _recognizedText = text;
                        });
                      }, _selectedLanguage["code"]!);
                    }
                  },
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
                  child: Text(
                    _isListening ? 'Stop' : 'Start Recording',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getFontSize(context, 18),
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: screenWidth * 0.04),
                if (_isLoading)
                  CircularProgressIndicator()
                else if (_recognizedText.isNotEmpty)
                  ElevatedButton(
                    onPressed: () {
                      _ttsService.speak(
                        _recognizedText,
                        _selectedLanguage["code"]!,
                      );
                    },
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
                    child: Text(
                      'Play',
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getFontSize(context, 18),
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _speechService.onListeningStateChanged = null;
    super.dispose();
  }
}
