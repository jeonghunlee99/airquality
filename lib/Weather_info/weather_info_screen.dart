import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'Weather_info_data.dart';

class WeatherInfoScreen extends ConsumerWidget {
  const WeatherInfoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsync = ref.watch(weatherProvider);

    return Scaffold(
      appBar: AppBar(title: Text('오늘의 시간별 기온'), centerTitle: true),
      body: weatherAsync.when(
        data: (weatherData) {
          final baseTime = weatherData['baseTime'] as String;
          final weatherList = weatherData['data'] as List;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  '📢 ${baseTime.substring(0, 2)}시 발표 기준 예보입니다.',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: weatherList.length,
                  separatorBuilder: (context, index) => Divider(),
                  itemBuilder: (context, index) {
                    final item = weatherList[index];
                    final time = item['time'];
                    final temp = item['temp'];
                    return ListTile(
                      leading: Icon(Icons.access_time),
                      title: Text('$time'),
                      trailing: Text('$temp°C', style: TextStyle(fontSize: 18)),
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('오류 발생: $err')),
      ),
    );
  }
}
