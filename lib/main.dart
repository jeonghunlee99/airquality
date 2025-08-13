import 'package:airquality/setting_page/setting_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'airquality_page/air_quality_controller.dart';
import 'main_home_screen.dart';

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    initLocation(ref);
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Air Quality App',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        progressIndicatorTheme: const ProgressIndicatorThemeData(color: Colors.black),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        progressIndicatorTheme: const ProgressIndicatorThemeData(color: Colors.white),
      ),
      themeMode: themeMode,
      home: MainHomeScreen(),
    );
  }
}


