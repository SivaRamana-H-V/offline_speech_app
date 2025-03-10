import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:offline_speech_app/flutter_tts.dart';
import 'package:offline_speech_app/speech_to_text.dart';
import 'package:lottie/lottie.dart';

void main() {
  runApp(VoiceAssistantApp());
}

class VoiceAssistantApp extends StatelessWidget {
  const VoiceAssistantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Offline Voice Assistant',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        brightness: Brightness.dark,
      ),
      home: VoiceAssistantHomePage(),
    );
  }
}

class VoiceAssistantHomePage extends StatefulWidget {
  const VoiceAssistantHomePage({super.key});

  @override
  VoiceAssistantHomePageState createState() => VoiceAssistantHomePageState();
}

class VoiceAssistantHomePageState extends State<VoiceAssistantHomePage> {
  final SpeechService _speechService = SpeechService();
  final TextToSpeechService _ttsService = TextToSpeechService();
  String _recognizedText = 'Press the button and start speaking';
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _speechService.initialize();
  }

  void _onListen() {
    if (_isListening) {
      _speechService.stopListening();
      setState(() => _isListening = false);
    } else {
      _speechService.startListening((text) {
        setState(() => _recognizedText = text);
      });
      setState(() => _isListening = true);

      // Set a timeout to reset listening state
      Future.delayed(Duration(seconds: 5), () {
        if (_isListening) {
          setState(() => _isListening = false);
          _speechService.stopListening();
        }
      });
    }
  }

  void _onSpeak() {
    _ttsService.speak(_recognizedText);
    setState(() => _isListening = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Offline Voice Assistant',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            children: [
              Column(
                children: [
                  Center(
                    child: Lottie.asset(
                      _isListening
                          ? 'assets/listening.json'
                          : 'assets/idle.json',
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: 20),
                  AnimatedSwitcher(
                    duration: Duration(milliseconds: 500),
                    child: Text(
                      _recognizedText,
                      key: ValueKey<String>(_recognizedText),
                      style: TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              OpenContainer(
                closedElevation: 8.0,
                closedShape: CircleBorder(),
                transitionDuration: Duration(milliseconds: 500),
                closedColor:
                    _isListening ? Colors.redAccent : Colors.greenAccent,
                closedBuilder:
                    (context, action) => FloatingActionButton(
                      onPressed: _onListen,
                      backgroundColor: _isListening ? Colors.red : Colors.green,
                      child: Icon(
                        _isListening ? Icons.mic_off : Icons.mic,
                        size: 30,
                      ),
                    ),
                openBuilder: (context, action) => Container(),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _onSpeak,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.volume_up, size: 28),
                    SizedBox(width: 10),
                    Text(
                      'Read Text',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
