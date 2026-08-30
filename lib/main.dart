import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mini_game_app/firebase_options.dart';
import 'package:mini_game_app/screens/home_screen.dart';
import 'package:mini_game_app/theme/colors.dart';
import 'package:mini_game_app/theme/radius.dart';

void main() async {
  // Firestore 등 Firebase 기능을 쓰려면 위젯을 그리기 전에 초기화가 끝나 있어야 해서
  // main을 async로 바꾸고 runApp 전에 await로 기다린다.
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
