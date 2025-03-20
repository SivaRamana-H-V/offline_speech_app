import 'package:flutter/material.dart';
import 'package:offline_speech_app/Text/text_translation_screen.dart';
import 'package:offline_speech_app/voice/voice_translation_screen.dart';
import 'package:offline_speech_app/utils/responsive_helper.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = ResponsiveHelper.getScreenWidth(context);
    final screenHeight = ResponsiveHelper.getScreenHeight(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'SpeakEasy',
          style: TextStyle(
            fontSize: ResponsiveHelper.getFontSize(context, 24),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.orangeAccent,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Choose Translation Mode',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getFontSize(context, 24),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: screenHeight * 0.04),
              Wrap(
                spacing: screenWidth * 0.04,
                runSpacing: screenHeight * 0.02,
                alignment: WrapAlignment.center,
                children: [
                  _buildOptionCard(
                    context,
                    'Voice Translation',
                    Icons.mic,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const VoiceTranslationScreen(),
                      ),
                    ),
                    screenWidth,
                    screenHeight,
                  ),
                  _buildOptionCard(
                    context,
                    'Text Translation',
                    Icons.text_fields,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TextTranslationScreen(),
                      ),
                    ),
                    screenWidth,
                    screenHeight,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
    double screenWidth,
    double screenHeight,
  ) {
    final cardWidth = ResponsiveHelper.isMobile(context)
        ? screenWidth * 0.8
        : screenWidth * 0.35;
    final cardHeight = ResponsiveHelper.isMobile(context)
        ? screenHeight * 0.25
        : screenHeight * 0.3;

    return InkWell(
      onTap: onTap,
      child: Container(
        width: cardWidth,
        height: cardHeight,
        padding: EdgeInsets.all(screenWidth * 0.04),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: ResponsiveHelper.getIconSize(context, 50),
              color: Colors.orangeAccent,
            ),
            SizedBox(height: screenHeight * 0.02),
            Text(
              title,
              style: TextStyle(
                fontSize: ResponsiveHelper.getFontSize(context, 20),
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
