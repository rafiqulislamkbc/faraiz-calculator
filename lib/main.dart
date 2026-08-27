import 'package:flutter/material.dart';
import 'screens/calculator_screen.dart';

void main() {
  runApp(const HanafiMirathApp());
}

class HanafiMirathApp extends StatelessWidget {
  const HanafiMirathApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'হানাফি মিরাছ ও ফারায়েজ ক্যালকুলেটর',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Kalpurush', // পুরো অ্যাপে কালপুরুষ ফন্ট
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF047857),
          primary: const Color(0xFF047857),
          secondary: const Color(0xFFF59E0B),
          background: const Color(0xFFF8FAF9),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF047857),
          foregroundColor: Colors.white,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontFamily: 'Kalpurush',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontFamily: 'Kalpurush'),
          bodyMedium: TextStyle(fontFamily: 'Kalpurush'),
          titleLarge: TextStyle(fontFamily: 'Kalpurush', fontWeight: FontWeight.bold),
          titleMedium: TextStyle(fontFamily: 'Kalpurush', fontWeight: FontWeight.bold),
          labelLarge: TextStyle(fontFamily: 'Kalpurush', fontWeight: FontWeight.bold),
        ),
      ),
      home: const CalculatorScreen(),
    );
  }
}