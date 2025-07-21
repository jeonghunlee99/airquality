import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';

import 'Weather_info_data.dart';


class WeatherService {
  final Dio _dio = Dio();

  Future<List<HourlyWeather>> fetchHourlyWeather({
    required int nx,
    required int ny,
  }) async {
    final now = DateTime.now();
    final baseDate = _getBaseDate(now);
    final baseTime = _getBaseTime(now);
    final serviceKey = 'Hmyyh9ZiYNt4vOZZdasLtsfACBE+bL/+2PevBXn00OmYRdYQUZsHzJt+Lup4p4MK3m4HnRlV8Sy043CoDzm7Lg==';

    final response = await _dio.get(
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
  }

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
}

void setWeatherGridCoordinates(WidgetRef ref, double lat, double lng) {
  print('[DEBUG] setWeatherGridCoordinates - lat: $lat, lng: $lng');

  try {
    final grid = GridUtil.convertToGrid(lat, lng);
    final nx = grid['nx'];
    final ny = grid['ny'];

    print('[DEBUG] 변환된 격자좌표: nx=$nx, ny=$ny');

    if (nx == null || ny == null) {
      print('[ERROR] 변환 실패: nx 또는 ny가 null입니다');
      return;
    }

    ref.read(nxProvider.notifier).state = nx;
    ref.read(nyProvider.notifier).state = ny;

    print('[DEBUG] 상태 업데이트 완료');

  } catch (e) {
    print('[ERROR] setWeatherGridCoordinates 실패: $e');
  }
}