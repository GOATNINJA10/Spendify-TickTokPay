import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:spendify/routes/app_pages.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as dotenv;
import 'package:flutter/services.dart' show rootBundle;
import 'package:spendify/services/background_service.dart';

late final SupabaseClient supabaseClient;
late final SupabaseClient supabaseServiceClient;

Future<void> main() async {
  // debugRepaintRainbowEnabled = true;

  try {
    // Initialize Flutter bindings
    WidgetsFlutterBinding.ensureInitialized();

    // Load environment variables
    await dotenv.dotenv.load(fileName: '.env');
    
    // Debug print to check if .env is loaded
    debugPrint('Environment variables loaded:');
    debugPrint('SUPABASE_URL: ${dotenv.dotenv.env['SUPABASE_URL']}');
    debugPrint('SUPABASE_ANON_KEY: ${dotenv.dotenv.env['SUPABASE_ANON_KEY']}');
    debugPrint('SUPABASE_SERVICE_KEY: ${dotenv.dotenv.env['SUPABASE_SERVICE_KEY']}');
    debugPrint('RESEND_API_KEY: ${dotenv.dotenv.env['RESEND_API_KEY']}');
    
    // Initialize Supabase with regular client
    await Supabase.initialize(
      url: dotenv.dotenv.env['SUPABASE_URL'] ?? 'https://bqlghhkmuctiqwpytpgg.supabase.co',
      anonKey: dotenv.dotenv.env['SUPABASE_ANON_KEY'] ?? '',
    );
    
    // Initialize clients
    supabaseClient = Supabase.instance.client;
    supabaseServiceClient = SupabaseClient(
      dotenv.dotenv.env['SUPABASE_URL'] ?? 'https://bqlghhkmuctiqwpytpgg.supabase.co',
      dotenv.dotenv.env['SUPABASE_SERVICE_KEY'] ?? '',
    );
    
    // Initialize background service
    await BackgroundService.initialize();
    await BackgroundService.startPeriodicTask();
    
    runApp(const MyApp());
  } catch (e) {
    debugPrint('Error initializing app: $e');
    debugPrint('Stack trace: ${StackTrace.current}');
    // Show an error dialog instead of crashing
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text(
              'Error initializing app: $e\nPlease restart the app.',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TickTockPay',
      initialRoute: Routes.SPLASH,
      getPages: AppPages.routes,
    );
  }
}
