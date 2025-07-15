import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'dart:convert';

final weatherProvider = FutureProvider.autoDispose<Map<String, dynamic>>((
  ref,
) async {
  final DateTime now = DateTime.now();

  final String baseDate = _getBaseDate(now);
  final String baseTime = _getBaseTime(now);

  final int nx = 55;
  final int ny = 127;

  final String serviceKey =
      'Hmyyh9ZiYNt4vOZZdasLtsfACBE+bL/+2PevBXn00OmYRdYQUZsHzJt+Lup4p4MK3m4HnRlV8Sy043CoDzm7Lg==';
  final Dio dio = Dio();

  final url =
      'https://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getVilageFcst';

  final response = await dio.get(
    url,
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

  final rawData = response.data;
  final Map<String, dynamic> data =
      rawData is String ? jsonDecode(rawData) : rawData;
  final items = data['response']['body']['items']['item'] as List<dynamic>;
  final String today = _formatDate(now);

  // 오늘 날짜의 TMP 항목만 추출

  final tmpList =
      items
          .where(
            (item) => item['category'] == 'TMP' && item['fcstDate'] == today,
          )
          .toList()
        ..sort((a, b) => a['fcstTime'].compareTo(b['fcstTime']));

  final resultList =
      tmpList.map((item) {
        final time = item['fcstTime'].toString();
        final temp = item['fcstValue'].toString();
        return {'time': time.substring(0, 2) + ':00', 'temp': temp};
      }).toList();

  return {'baseTime': baseTime, 'data': resultList};
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
