import 'package:flutter/material.dart';
import 'package:mini_game_app/screens/group_detail_screen.dart';
import 'package:mini_game_app/services/group_service.dart';
import 'package:mini_game_app/theme/spacing.dart';
import 'package:mini_game_app/theme/text_styles.dart';
import 'package:mini_game_app/widgets/primary_button.dart';

/// 그룹 이름을 입력받아 그룹 + 초대 코드를 만든다.
class GroupCreateScreen extends StatefulWidget {
  const GroupCreateScreen({super.key});

  @override
  State<GroupCreateScreen> createState() => _GroupCreateScreenState();
}

class _GroupCreateScreenState extends State<GroupCreateScreen> {
  final TextEditingController _nameController = TextEditingController();
  String? _errorText;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _errorText = '그룹 이름을 입력해주세요');
      return;
    }

    setState(() {
      _errorText = null;
      _isSubmitting = true;
    });

    try {
      final group = await GroupService().createGroup(name);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => GroupDetailScreen(groupId: group.id),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('그룹 생성에 실패했어요. 다시 시도해주세요')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('그룹 만들기')),
      body: Padding(
        padding: const EdgeInsets.all(kSpacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('그룹 이름을 정해주세요', style: kTextBody2),
            const SizedBox(height: kSpacingMd),
            TextField(
              controller: _nameController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: '그룹 이름',
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
                    : const Text('만들기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
