import 'package:flutter/material.dart';
import 'widgets/intro_slide.dart';
import '../../app/router.dart';

/// Onboarding screen with introduction slides
class OnboardingScreen extends StatefulWidget {  
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingSlide> _slides = [
    OnboardingSlide(
      title: 'ברוכים הבאים לטינה',
      description: 'העוזרת הדיגיטלית החכמה שתעזור לכם עם כל השירותים',
      icon: Icons.assistant,
      color: Colors.blue,
    ),
    OnboardingSlide(
      title: 'שיחות קוליות חכמות',
      description: 'דברו ישירות עם טינה או עם נציגי השירות שלנו',
      icon: Icons.phone,
      color: Colors.green,
    ),
    OnboardingSlide(
      title: 'מעקב ותיעוד',
      description: 'כל השיחות נשמרות ומתועדות עבורכם',
      icon: Icons.history,
      color: Colors.orange,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: AlignmentDirectional.topEnd,
              child: TextButton(
                onPressed: _skipOnboarding,
                child: const Text('דלג'),
              ),
            ),
            
            // Slides
            Expanded(
              flex: 4,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _slides.length,
                itemBuilder: (context, index) {
                  return IntroSlide(slide: _slides[index]);
                },
              ),
            ),
            
            // Page indicators
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _slides.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 20 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? Theme.of(context).primaryColor
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Navigation buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        if (_currentPage > 0)
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _previousPage,
                              child: const Text('הקודם'),
                            ),
                          ),
                        
                        if (_currentPage > 0) const SizedBox(width: 16),
                        
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _currentPage == _slides.length - 1
                                ? _completeOnboarding
                                : _nextPage,
                            child: Text(
                              _currentPage == _slides.length - 1
                                  ? 'בואו נתחיל'
                                  : 'הבא',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _skipOnboarding() {
    Navigator.pushReplacementNamed(context, AppRouter.home);
  }

  void _completeOnboarding() {
    Navigator.pushReplacementNamed(context, AppRouter.home);
  }
} 