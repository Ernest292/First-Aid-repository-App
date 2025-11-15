import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',      // Replace with your Supabase project URL
    anonKey: 'YOUR_SUPABASE_ANON_KEY', // Replace with your Supabase anon key
  );

  runApp(const FirstAidApp());
}

class FirstAidApp extends StatelessWidget {
  const FirstAidApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'First Aid Quick Guide',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
