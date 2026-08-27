import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/calculator_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const HanafiMirathApp());
}

class HanafiMirathApp extends StatelessWidget {
  const HanafiMirathApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ফারায়েজ ক্যালকুলেটর (হানাফি)',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF047857),
          primary: const Color(0xFF047857),
          secondary: const Color(0xFFD97706),
          surface: const Color(0xFFF8FAFC),
        ),
        textTheme: GoogleFonts.hindSiliguriTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: const CalculatorScreen(),
    );
  }
}