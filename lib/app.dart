import 'package:flutter/material.dart';

import 'screens/feedback_screen.dart';
import 'screens/home_screen.dart';
import 'services/feedback_service.dart';
import 'theme/app_theme.dart';

class FeedbackApp extends StatelessWidget {
  const FeedbackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Feedback App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: HomeScreen.routeName,
      routes: {
        HomeScreen.routeName: (_) => const HomeScreen(),
        FeedbackScreen.routeName: (_) =>
            FeedbackScreen(feedbackService: FeedbackService()),
      },
    );
  }
}
