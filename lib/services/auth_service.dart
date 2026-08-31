import 'package:firebase_auth/firebase_auth.dart';

/// 회원가입 부담 없이 앱을 바로 쓸 수 있도록, 로그인 상태가 아니면 자동으로
/// 익명 계정을 만들어 로그인한다. 카카오 로그인 등 실명 계정은 나중에
/// "계정 연결" 기능으로 이 익명 계정에 이어붙일 예정이라 지금은 스킵.
class AuthService {
  Future<User> ensureSignedIn() async {
    final auth = FirebaseAuth.instance;
    final currentUser = auth.currentUser;
    if (currentUser != null) return currentUser;

    final credential = await auth.signInAnonymously();
    return credential.user!;
  }
}
