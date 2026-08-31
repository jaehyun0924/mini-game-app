import 'package:flutter/material.dart';
import 'package:mini_game_app/screens/home_screen.dart';
import 'package:mini_game_app/services/user_service.dart';
import 'package:mini_game_app/theme/spacing.dart';
import 'package:mini_game_app/theme/text_styles.dart';
import 'package:mini_game_app/widgets/primary_button.dart';

/// 앱 최초 실행 시(익명 로그인 직후) 딱 한 번 보여주는 닉네임 입력 화면.
/// 그룹 멤버 목록/랭킹에 표시할 이름을 정하는 용도라 이메일/비번 없이 이것만 받는다.
class NicknameSetupScreen extends StatefulWidget {
  const NicknameSetupScreen({super.key});

  @override
  State<NicknameSetupScreen> createState() => _NicknameSetupScreenState();
}

class _NicknameSetupScreenState extends State<NicknameSetupScreen> {
  final TextEditingController _nicknameController = TextEditingController();
  String? _errorText;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final nickname = _nicknameController.text.trim();

    if (nickname.isEmpty) {
      setState(() => _errorText = '닉네임을 입력해주세요');
      return;
    }

    setState(() {
      _errorText = null;
      _isSubmitting = true;
    });

    try {
      await UserService().saveNickname(nickname);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('저장에 실패했어요. 다시 시도해주세요')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(kSpacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('닉네임을 알려주세요', style: kTextHeading2),
              const SizedBox(height: kSpacingXs),
              const Text('그룹 멤버 목록과 랭킹에 이 이름으로 표시돼요', style: kTextBody2),
              const SizedBox(height: kSpacingLg),
              TextField(
                controller: _nicknameController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: '닉네임',
                  errorText: _errorText,
                ),
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: kSpacingLg),
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('시작하기'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
