import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'airquality/air_quality_screen.dart';

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Air Quality App',
      theme: ThemeData(primarySwatch: Colors.blue,
        progressIndicatorTheme: const ProgressIndicatorThemeData(color: Colors.black, )),
      home: CurrentLocationAirQualityScreen(),
    );
  }
}


