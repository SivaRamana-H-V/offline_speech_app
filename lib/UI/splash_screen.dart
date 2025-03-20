import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:offline_speech_app/UI/home_page.dart';
import 'package:offline_speech_app/utils/responsive_helper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = ResponsiveHelper.getScreenWidth(context);
    final screenHeight = ResponsiveHelper.getScreenHeight(context);

    return Scaffold(
      backgroundColor: Colors.orangeAccent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: screenWidth * 0.4,
              height: screenHeight * 0.2,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(100),
                  bottomRight: Radius.circular(100),
                ),
              ),
              child: Lottie.asset(
                'assets/listening.json',
                width:
                    ResponsiveHelper.isMobile(context)
                        ? screenWidth * 0.4
                        : screenWidth * 0.25,
                height:
                    ResponsiveHelper.isMobile(context)
                        ? screenHeight * 0.2
                        : screenHeight * 0.25,
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            Text(
              'SpeakEasy',
              style: TextStyle(
                fontSize: ResponsiveHelper.getFontSize(context, 32),
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
