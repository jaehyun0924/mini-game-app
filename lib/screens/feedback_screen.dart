import 'package:flutter/material.dart';
import 'package:mini_game_app/services/feedback_service.dart';
import 'package:mini_game_app/theme/spacing.dart';
import 'package:mini_game_app/theme/text_styles.dart';
import 'package:mini_game_app/widgets/primary_button.dart';

/// "새 게임 제안하기" 폼. 게임 이름/간단한 설명을 받아 Firestore에 저장한다.
class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController =
      TextEditingController();
  String? _nameErrorText;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      setState(() => _nameErrorText = '게임 이름을 입력해주세요');
      return;
    }

    setState(() {
      _nameErrorText = null;
      _isSubmitting = true;
    });

    try {
      await FeedbackService().submitGameSuggestion(
        gameName: name,
        description: _descriptionController.text.trim(),
      );
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제안해주셔서 감사해요!')),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('전송에 실패했어요. 다시 시도해주세요')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('새 게임 제안하기')),
      body: Padding(
        padding: const EdgeInsets.all(kSpacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('어떤 게임이 있으면 좋을지 알려주세요', style: kTextBody2),
            const SizedBox(height: kSpacingMd),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: '게임 이름',
                errorText: _nameErrorText,
              ),
            ),
            const SizedBox(height: kSpacingMd),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: '간단한 설명 (선택)'),
              maxLines: 4,
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
                    : const Text('제안하기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
