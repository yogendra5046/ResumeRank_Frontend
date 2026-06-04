import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

class LoadingScreen extends StatelessWidget {
  final String message;

  const LoadingScreen({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // AI Scanning Animation
              SizedBox(
                height: 200,
                child: Lottie.asset('assets/lottie/ai_scan.json', repeat: true),
              ).animate().fadeIn(duration: 800.ms).scale(),

              SizedBox(height: 40),

              // Rotating Funny Messages
              SizedBox(
                height: 40,
                child: DefaultTextStyle(
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                  child: AnimatedTextKit(
                    animatedTexts: [
                      RotateAnimatedText('Teaching AI to read your resume...'),
                      RotateAnimatedText('Bribing the ATS bots for you...'),
                      RotateAnimatedText(
                        'Converting buzzwords to offer letters...',
                      ),
                      RotateAnimatedText(
                        'Asking HR what they actually want...',
                      ),
                      RotateAnimatedText(
                        "Removing 'hardworking' from 10M resumes...",
                      ),
                      RotateAnimatedText(
                        'Calculating interview probability...',
                      ),
                    ],
                    repeatForever: true,
                  ),
                ),
              ),

              SizedBox(height: 32),

              // Gradient Progress Indicator
              Stack(
                children: [
                  Container(
                    height: 8,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  Container(
                        height: 8,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      )
                      .animate(onPlay: (controller) => controller.repeat())
                      .shimmer(
                        duration: 2.seconds,
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                ],
              ),

              SizedBox(height: 16),

              Text(
                message,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B),
                  fontSize: 13,
                  letterSpacing: 1.2,
                ),
              ).animate().fadeIn(delay: 500.ms),
            ],
          ),
        ),
      ),
    );
  }
}
