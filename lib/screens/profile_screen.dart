import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mini_game_app/services/user_service.dart';
import 'package:mini_game_app/theme/colors.dart';
import 'package:mini_game_app/theme/radius.dart';
import 'package:mini_game_app/theme/spacing.dart';
import 'package:mini_game_app/theme/text_styles.dart';
import 'package:mini_game_app/widgets/primary_button.dart';
import 'package:mini_game_app/widgets/shrink_button.dart';

/// 내 닉네임과 ID를 보여주고, 닉네임을 바꿀 수 있는 화면.
/// 이메일/비번 없는 익명 계정만 쓰는 앱이라 ID(uid)가 "나"를 가리키는 유일한
/// 값이다 — 그룹원에게 문제를 알려주거나 디버깅할 때 등, 닉네임만으로
/// 특정하기 애매할 때 이 ID로 정확히 구분할 수 있게 복사 기능을 같이 둔다.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nicknameController = TextEditingController();
  String? _nickname;
  String? _errorText;
  bool _isEditing = false;
  bool _isSubmitting = false;

  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _loadNickname();
  }

  Future<void> _loadNickname() async {
    final nicknames = await UserService().getNicknames([_uid]);
    if (!mounted) return;
    setState(() => _nickname = nicknames[_uid] ?? '');
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  void _startEditing() {
    _nicknameController.text = _nickname ?? '';
    setState(() {
      _isEditing = true;
      _errorText = null;
    });
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
      await UserService().updateNickname(nickname);
      if (!mounted) return;
      setState(() {
        _nickname = nickname;
        _isEditing = false;
        _isSubmitting = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('닉네임 변경에 실패했어요. 다시 시도해주세요')),
      );
    }
  }

  void _copyId() {
    Clipboard.setData(ClipboardData(text: _uid));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('ID를 복사했어요')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('내 정보')),
      body: Padding(
        padding: const EdgeInsets.all(kSpacingMd),
        child: _nickname == null
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('닉네임', style: kTextBody2),
                  const SizedBox(height: kSpacingXs),
                  if (_isEditing) ...[
                    TextField(
                      controller: _nicknameController,
                      autofocus: true,
                      decoration: InputDecoration(
                        labelText: '닉네임',
                        errorText: _errorText,
                      ),
                      onSubmitted: (_) => _submit(),
                    ),
                    const SizedBox(height: kSpacingSm),
                    Row(
                      children: [
                        Expanded(
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
                                : const Text('저장'),
                          ),
                        ),
                        const SizedBox(width: kSpacingSm),
                        TextButton(
                          onPressed: _isSubmitting
                              ? null
                              : () => setState(() => _isEditing = false),
                          child: const Text('취소'),
                        ),
                      ],
                    ),
                  ] else
                    Row(
                      children: [
                        Text(
                          _nickname!.isEmpty ? '(닉네임 없음)' : _nickname!,
                          style: kTextTitle,
                        ),
                        const SizedBox(width: kSpacingSm),
                        ShrinkButton(
                          onPressed: _startEditing,
                          child: const Padding(
                            padding: EdgeInsets.all(kSpacingXs),
                            child: Icon(
                              Icons.edit_outlined,
                              size: 18,
                              color: kColorPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: kSpacingLg),
                  const Text('ID', style: kTextBody2),
                  const SizedBox(height: kSpacingXs),
                  ShrinkButton(
                    onPressed: _copyId,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(kSpacingMd),
                      decoration: BoxDecoration(
                        color: kColorPrimaryLight,
                        borderRadius: BorderRadius.circular(kRadiusMd),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _uid,
                              style: kTextBody1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: kSpacingSm),
                          const Icon(
                            Icons.copy_outlined,
                            size: 18,
                            color: kColorPrimary,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: kSpacingXs),
                  const Text('탭하면 복사돼요 — 문의할 때 알려주세요', style: kTextCaption),
                ],
              ),
      ),
    );
  }
}
