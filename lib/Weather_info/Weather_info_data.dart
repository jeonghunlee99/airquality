import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'dart:convert';

final weatherProvider = FutureProvider<List<HourlyWeather>>((ref) async {
  ref.keepAlive();

  final DateTime now = DateTime.now();
  final String baseDate = _getBaseDate(now);
  final String baseTime = _getBaseTime(now);
  final String serviceKey = 'Hmyyh9ZiYNt4vOZZdasLtsfACBE+bL/+2PevBXn00OmYRdYQUZsHzJt+Lup4p4MK3m4HnRlV8Sy043CoDzm7Lg==';
  final int nx = 55, ny = 127;

  final dio = Dio();
  final response = await dio.get(
    'https://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getVilageFcst',
    queryParameters: {
      'serviceKey': serviceKey,
      'pageNo': 1,
      'numOfRows': 1000,
      'dataType': 'JSON',
      'base_date': baseDate,
      'base_time': baseTime,
      'nx': nx,
      'ny': ny,
    },
  );

  final Map<String, dynamic> data = response.data is String
      ? jsonDecode(response.data)
      : response.data;

  final items = data['response']['body']['items']['item'] as List;
  final neededCategories = ['TMP', 'WSD', 'VEC', 'SKY', 'PTY', 'POP', 'PCP', 'REH'];
  final today = _formatDate(now);

  Map<String, Map<String, String>> timeGrouped = {};
  for (var item in items) {
    if (item['fcstDate'] != today) continue;
    if (!neededCategories.contains(item['category'])) continue;

    final time = item['fcstTime'];
    timeGrouped[time] ??= {};
    timeGrouped[time]![item['category']] = item['fcstValue'].toString();
  }

  final weatherList = timeGrouped.entries.map((entry) {
    return HourlyWeather.fromMap(entry.key, entry.value);
  }).toList()
    ..sort((a, b) => a.time.compareTo(b.time));

  return weatherList;
});


String _getBaseDate(DateTime now) {
  if (now.hour < 2) {
    final yesterday = now.subtract(Duration(days: 1));
    return _formatDate(yesterday);
  }
  return _formatDate(now);
}

String _formatDate(DateTime date) {
  return '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
}

String _getBaseTime(DateTime now) {
  List<int> baseHours = [2, 5, 8, 11, 14, 17, 20, 23];
  int hour = now.hour;

  int selectedHour = baseHours.lastWhere((h) => h <= hour, orElse: () => 23);

  return selectedHour.toString().padLeft(2, '0') + '00';
}

class HourlyWeather {
  final String time;
  final String temp; // TMP
  final String windSpeed; // WSD
  final String windDir; // VEC
  final String sky; // SKY
  final String pty; // PTY
  final String pop; // POP
  final String humidity; // REH
  final String pcp; // PCP

  HourlyWeather({
    required this.time,
    required this.temp,
    required this.windSpeed,
    required this.windDir,
    required this.sky,
    required this.pty,
    required this.pop,
    required this.humidity,
    required this.pcp,
  });

  factory HourlyWeather.fromMap(String time, Map<String, String> data) {
    return HourlyWeather(
      time: '${time.substring(0, 2)}:00',
      temp: data['TMP'] ?? '-',
      windSpeed: data['WSD'] ?? '-',
      windDir: data['VEC'] ?? '-',
      sky: data['SKY'] ?? '-',
      pty: data['PTY'] ?? '-',
      pop: data['POP'] ?? '-',
      humidity: data['REH'] ?? '-',
      pcp: data['PCP'] ?? '-',
    );
  }
}
