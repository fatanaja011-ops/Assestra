import 'package:flutter/material.dart';
import 'features/home/pages/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AssestraApp());
}

class AssestraApp extends StatelessWidget {
  const AssestraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Assestra',
      debugShowCheckedModeBanner: false,

      // ===== THEME =====
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4DB6AC),
        ),
        scaffoldBackgroundColor: const Color(0xFFF1F8F4),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: Color(0xFFF1F8F4),
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),

      // ===== FIRST PAGE =====
      home: const HomePage(),
    );
  }
}
