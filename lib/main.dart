import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mini_game_app/firebase_options.dart';
import 'package:mini_game_app/screens/home_screen.dart';
import 'package:mini_game_app/screens/nickname_setup_screen.dart';
import 'package:mini_game_app/services/auth_service.dart';
import 'package:mini_game_app/services/user_service.dart';
import 'package:mini_game_app/theme/colors.dart';
import 'package:mini_game_app/theme/radius.dart';

void main() async {
  // Firestore 등 Firebase 기능을 쓰려면 위젯을 그리기 전에 초기화가 끝나 있어야 해서
  // main을 async로 바꾸고 runApp 전에 await로 기다린다.
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 회원가입 화면 없이 바로 쓸 수 있게, 로그인 안 돼 있으면 익명 계정을 만들고
  // 닉네임이 아직 없으면(최초 실행) 닉네임 입력 화면부터 보여준다.
  await AuthService().ensureSignedIn();
  final hasNickname = await UserService().hasNickname();

  runApp(MyApp(startWithNicknameSetup: !hasNickname));
}

class MyApp extends StatelessWidget {
  final bool startWithNicknameSetup;

  const MyApp({super.key, required this.startWithNicknameSetup});

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
      home: startWithNicknameSetup
          ? const NicknameSetupScreen()
          : const HomeScreen(),
    );
  }
}
