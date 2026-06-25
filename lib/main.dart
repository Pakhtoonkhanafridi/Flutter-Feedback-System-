import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'config/supabase_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Color(0x00000000),
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Color(0xFFF3F2F7),
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  try {
    if (SupabaseConfig.isConfigured) {
      await Supabase.initialize(
        url: SupabaseConfig.url,
        publishableKey: SupabaseConfig.publishableKey,
      );
    }
  } catch (e) {
    // Supabase init failed - app will still run but backend features disabled
    debugPrint('Supabase initialization failed: $e');
  }

  runApp(const FeedbackApp());
}
