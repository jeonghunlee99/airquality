import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../utils/auth_service.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text("로그인"), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                print("네이버 로그인 버튼 클릭");
              },
              child: const CircleAvatar(
                radius: 40,
                backgroundColor: Color(0xFF03C75A),
                child: Text(
                  "N",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text("네이버로 로그인"),

            const SizedBox(height: 40),

            GestureDetector(
              onTap: () async {
                final user = await AuthService().signInWithGoogle();
                if (user != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("환영합니다, ${user.displayName}!")),
                  );
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text("로그인 취소됨")));
                }
              },
              child: const CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white,
                child: Icon(
                  FontAwesomeIcons.google,
                  color: Colors.black54,
                  size: 40.0, // 아이콘 크기를 원형에 맞게 키움
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text("Google 로그인"),
          ],
        ),
      ),
    );
  }
}
