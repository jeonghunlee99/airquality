import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../login_page/login_page.dart';
import '../utils/auth_service.dart';

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      backgroundColor:
      Theme.of(context).brightness == Brightness.light
          ? Colors.white
          : Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("설정"),
        elevation: 0,
        centerTitle: true,
        forceMaterialTransparency: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          authState.when(
            data: (user) {
              if (user != null) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors:
                      Theme.of(context).brightness == Brightness.dark
                          ? [Colors.grey.shade900, Colors.blueGrey.shade800]
                          : [Colors.white, const Color(0xFFB3E5FC)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(color: Colors.grey, width: 1.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundImage:
                      user.photoURL != null ? NetworkImage(user.photoURL!) : null,
                      child: user.photoURL == null
                          ? const Icon(Icons.person, size: 30)
                          : null,
                    ),
                    title: Text(
                      user.displayName ?? '이름 없음',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Text(
                      user.email ?? '이메일 없음',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              } else {
                return const SizedBox.shrink();
              }
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text("오류 발생: $e")),
          ),
          const SizedBox(height: 25),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors:
                Theme.of(context).brightness == Brightness.dark
                    ? [Colors.grey.shade900, Colors.blueGrey.shade800]
                    : [Colors.white, const Color(0xFFB3E5FC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: Colors.grey, width: 1.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _buildSwitchTile(
                  imagePath: "assets/bell_icon.png",
                  title: "알림 받기",
                  value: true,
                  onChanged: (val) {},
                ),
                _buildSwitchTile(
                  imagePath: ref.watch(themeModeProvider) == ThemeMode.dark
                      ? "assets/light_mod_icon.png"
                      : "assets/dark_mod_icon.png",
                  title: "다크 모드",
                  value: ref.watch(themeModeProvider) == ThemeMode.dark,
                  onChanged: (val) {
                    ref.read(themeModeProvider.notifier).state =
                    val ? ThemeMode.dark : ThemeMode.light;
                  },
                ),
                const SizedBox(height: 2),
                _buildSettingTile(
                  imagePath: "assets/privacy_policy_icon.png",
                  title: "개인정보 처리방침",
                  onTap: () {},
                ),
                _buildSettingTile(
                  imagePath: "assets/tc_icon.png",
                  title: "이용약관",
                  onTap: () {},
                ),
                _buildSettingTile(
                  imagePath: "assets/app_info_icon.png",
                  title: "앱 버전",
                  trailing: const Text(
                    "v1.0.0",
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          authState.when(
            data: (user) {
              if (user != null) {
                return GestureDetector(
                  onTap: () async {
                    await AuthService().signOut();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("로그아웃 되었습니다.")),
                    );
                  },
                  child: _buildButton(context, "로그아웃", Colors.redAccent),
                );
              } else {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                  },
                  child: _buildButton(context, "로그인", Colors.black),
                );
              }
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text("오류 발생: $e")),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(BuildContext context, String text, Color textColor) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
          Theme.of(context).brightness == Brightness.dark
              ? [Colors.grey.shade900, Colors.blueGrey.shade800]
              : [Colors.white, const Color(0xFFB3E5FC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey, width: 1),
      ),
      padding: const EdgeInsets.symmetric(vertical: 14),
      alignment: Alignment.center,
      child: Text(
        text,
        style: GoogleFonts.notoSansKr(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String imagePath,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: ListTile(
        leading: SizedBox(
          width: 40,
          height: 40,
          child: Image.asset(imagePath),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.white,
          activeTrackColor: Colors.grey,
          inactiveThumbColor: Colors.white,
          inactiveTrackColor: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required String imagePath,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: ListTile(
        leading: SizedBox(
          width: 40,
          height: 40,
          child: Image.asset(imagePath),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: trailing ?? const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}