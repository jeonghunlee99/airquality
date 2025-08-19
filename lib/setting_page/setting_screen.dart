import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/auth_service.dart';

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.light
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
              border: Border.all(color: Colors.grey, width: 1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _buildSwitchTile(
                  icon: Icons.notifications,
                  iconColor: Colors.blue.shade600,
                  title: "알림 받기",
                  value: true,
                  onChanged: (val) {},
                ),
                _buildSwitchTile(
                  icon: Icons.dark_mode,
                  iconColor: Colors.deepPurple.shade400,
                  title: "다크 모드",
                  value: ref.watch(themeModeProvider) == ThemeMode.dark,
                  onChanged: (val) {
                    ref.read(themeModeProvider.notifier).state =
                        val ? ThemeMode.dark : ThemeMode.light;
                  },
                ),
                const SizedBox(height: 2),
                _buildSettingTile(
                  icon: Icons.privacy_tip,
                  iconColor: Colors.teal,
                  title: "개인정보 처리방침",
                  onTap: () {},
                ),
                _buildSettingTile(
                  icon: Icons.description,
                  iconColor: Colors.orange,
                  title: "이용약관",
                  onTap: () {},
                ),
                _buildSettingTile(
                  icon: Icons.info,
                  iconColor: Colors.blueGrey,
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
                  onTap: () async {
                    final user = await AuthService().signInWithGoogle();
                    if (user != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("환영합니다, ${user.displayName}!")),
                      );
                    } else {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(const SnackBar(content: Text("로그인 취소됨")));
                    }
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
    required IconData icon,
    required Color iconColor,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    Color activeColor = Colors.white,
    Color activeTrackColor = Colors.grey,
    Color inactiveThumbColor = Colors.white,
    Color inactiveTrackColor = Colors.grey,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: SwitchListTile(
        secondary: Icon(icon, color: iconColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        value: value,
        onChanged: onChanged,
        activeColor: activeColor,
        activeTrackColor: activeTrackColor,
        inactiveThumbColor: inactiveThumbColor,
        inactiveTrackColor: inactiveTrackColor,
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: trailing ?? const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
