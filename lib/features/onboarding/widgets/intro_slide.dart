import 'package:flutter/material.dart';

/// Data model for onboarding slide
class OnboardingSlide {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const OnboardingSlide({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

/// Widget for displaying intro slide content
class IntroSlide extends StatelessWidget {
  final OnboardingSlide slide;

  const IntroSlide({
    super.key,
    required this.slide,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: slide.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              slide.icon,
              size: 60,
              color: slide.color,
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Title
          Text(
            slide.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 20),
          
          // Description
          Text(
            slide.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey.shade600,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
} 