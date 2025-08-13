import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'Weather_info_page/weather_info_screen.dart';
import 'airquality_page/air_quality_screen.dart';
import 'bookmarks_page/book_marks_screen.dart';



final selectedIndexProvider = StateProvider<int>((ref) => 0);

class MainHomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedIndexProvider);
    final screens = [
      AirQualityScreen(),
      WeatherInfoScreen(),
      BookMarksScreen(),
      Center(child: Text('설정 및 로그인')),
    ];

    return Scaffold(
      body: screens[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) {
          ref.read(selectedIndexProvider.notifier).state = index;
        },
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.cloud),
            label: '대기질',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.wb_sunny),
            label: '날씨',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: '즐겨찾기',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '설정',
          ),
        ],
      ),
    );
  }
}

