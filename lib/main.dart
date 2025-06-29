import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'app/router.dart';
import 'app/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tina - עוזרת דיגיטלית',
      theme: AppTheme.lightTheme,
      
      // RTL Configuration
      locale: const Locale('he', 'IL'), // Hebrew Israel
      supportedLocales: const [
        Locale('he', 'IL'), // Hebrew
        Locale('en', 'US'), // English (fallback)
      ],
      
      // Localization delegates
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      
      // Force RTL text direction
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
      
      initialRoute: AppRouter.home,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
