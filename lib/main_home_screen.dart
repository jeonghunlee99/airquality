import 'package:flutter/material.dart';

import 'airquality/air_quality_screen.dart';

class MainHomeScreen extends StatefulWidget {
  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    CurrentLocationAirQualityScreen(),
    Center(child: Text('날씨 정보 탭')),       // 2번 탭
    Center(child: Text('3번 탭 - 추후 선택')), // 3번 탭
    Center(child: Text('설정 및 로그인')),     // 4번 탭
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<BottomNavigationBarItem> _navBarItems = [
    BottomNavigationBarItem(
      icon: Icon(Icons.cloud),
      label: '대기질',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.wb_sunny),
      label: '날씨',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.bar_chart),
      label: '3번',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.settings),
      label: '설정',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: _navBarItems,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}