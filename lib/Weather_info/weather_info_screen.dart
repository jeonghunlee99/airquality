import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'Weather_info_data.dart';

class WeatherInfoScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsync = ref.watch(weatherProvider);

    return Scaffold(
      appBar: AppBar(title: Text('시간별 예보'), centerTitle: true),
      body: weatherAsync.when(
        data: (weatherList) {
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: weatherList.length,
            itemBuilder: (context, index) {
              final item = weatherList[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${item.time} 예보', style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 6),
                      Text('🌡️ 기온: ${item.temp}°C'),
                      Text('💨 풍속: ${item.windSpeed} m/s'),
                      Text('🧭 풍향: ${item.windDir}°'),
                      Text('☁️ 하늘상태: ${_getSky(item.sky)}'),
                      Text('🌧️ 강수형태: ${_getPty(item.pty)}'),
                      Text('📈 강수확률: ${item.pop}%'),
                      Text('💧 습도: ${item.humidity}%'),
                      Text('🌂 강수량: ${item.pcp}'),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('오류 발생: $err')),
      ),
    );
  }

  String _getSky(String code) {
    switch (code) {
      case '1': return '맑음';
      case '3': return '구름많음';
      case '4': return '흐림';
      default: return '-';
    }
  }

  String _getPty(String code) {
    switch (code) {
      case '0': return '없음';
      case '1': return '비';
      case '2': return '비/눈';
      case '3': return '눈';
      case '4': return '소나기';
      default: return '-';
    }
  }
}
