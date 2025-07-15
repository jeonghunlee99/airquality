import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'Weather_info_data.dart';


class WeatherInfoScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsync = ref.watch(weatherProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('날씨 정보'),
      ),
      body: Center(
        child: weatherAsync.when(
          data: (temperature) => Text(
            '현재 기온: $temperature°C',
            style: TextStyle(fontSize: 24),
          ),
          loading: () => CircularProgressIndicator(),
          error: (err, stack) => Text('오류 발생: $err'),
        ),
      ),
    );
  }
}
