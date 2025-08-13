import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("설정"), elevation: 0),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300, width: 1.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                // 네
                _buildSwitchTile(
                  icon: Icons.notifications,
                  iconColor: Colors.blue.shade600,
                  title: "알림 받기",
                  value: true,
                  onChanged: (val) {},
                ),
                const SizedBox(height: 12),

                _buildSwitchTile(
                  icon: Icons.dark_mode,
                  iconColor: Colors.deepPurple.shade400,
                  title: "다크 모드",
                  value: false,
                  onChanged: (val) {},
                ),
                const SizedBox(height: 12),

                _buildSettingTile(
                  icon: Icons.privacy_tip,
                  iconColor: Colors.teal,
                  title: "개인정보 처리방침",
                  onTap: () {},
                ),
                const SizedBox(height: 12),

                _buildSettingTile(
                  icon: Icons.description,
                  iconColor: Colors.orange,
                  title: "이용약관",
                  onTap: () {},
                ),
                const SizedBox(height: 12),

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
          SizedBox(height: 25),
          GestureDetector(
            onTap: () {
              // 로그인 함수 넣기
            },
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.white, Color(0xFFB3E5FC)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.grey, width: 1),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
              alignment: Alignment.center,
              child: Text(
                "로그인",
                style: GoogleFonts.notoSansKr(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: SwitchListTile(
        secondary: Icon(icon, color: iconColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        value: value,
        onChanged: onChanged,
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
