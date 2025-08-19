import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<User?> signInWithGoogle() async {
    // 1. 구글 로그인 다이얼로그 표시
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null; // 사용자가 취소한 경우

    // 2. 인증 정보 가져오기
    final GoogleSignInAuthentication googleAuth =
    await googleUser.authentication;

    // 3. Firebase Auth 자격 증명 생성
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // 4. Firebase에 로그인
    final userCredential = await _auth.signInWithCredential(credential);
    return userCredential.user;
  }
}
