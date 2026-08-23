import 'package:flutter/material.dart';
import 'package:mini_game_app/screens/home_screen.dart';
import 'package:mini_game_app/theme/colors.dart';
import 'package:mini_game_app/theme/radius.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '미니게임',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: kColorBackground,
        colorScheme: ColorScheme.fromSeed(
          seedColor: kColorPrimary,
          primary: kColorPrimary,
          error: kColorError,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: kColorSurface,
          foregroundColor: kColorTextPrimary,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kColorPrimary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: kColorTextDisabled,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(kRadiusMd),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: kColorSurface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(kRadiusMd),
            borderSide: const BorderSide(color: kColorBorder),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
