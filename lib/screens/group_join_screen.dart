import 'package:flutter/material.dart';
import 'package:mini_game_app/screens/group_detail_screen.dart';
import 'package:mini_game_app/services/group_service.dart';
import 'package:mini_game_app/theme/spacing.dart';
import 'package:mini_game_app/theme/text_styles.dart';
import 'package:mini_game_app/widgets/primary_button.dart';

/// 초대 코드를 입력받아 그룹에 참여한다.
class GroupJoinScreen extends StatefulWidget {
  const GroupJoinScreen({super.key});

  @override
  State<GroupJoinScreen> createState() => _GroupJoinScreenState();
}

class _GroupJoinScreenState extends State<GroupJoinScreen> {
  final TextEditingController _codeController = TextEditingController();
  String? _errorText;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      setState(() => _errorText = '초대 코드를 입력해주세요');
      return;
    }

    setState(() {
      _errorText = null;
      _isSubmitting = true;
    });

    try {
      final group = await GroupService().joinByCode(code);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => GroupDetailScreen(groupId: group.id),
        ),
      );
    } on GroupJoinException catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorText = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('참여에 실패했어요. 다시 시도해주세요')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('코드로 참여하기')),
      body: Padding(
        padding: const EdgeInsets.all(kSpacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('전달받은 6자리 초대 코드를 입력해주세요', style: kTextBody2),
            const SizedBox(height: kSpacingMd),
            TextField(
              controller: _codeController,
              autofocus: true,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                labelText: '초대 코드',
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
                    : const Text('참여하기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
