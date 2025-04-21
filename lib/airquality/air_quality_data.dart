import 'package:flutter_riverpod/flutter_riverpod.dart';

final airQualityProvider = StateProvider<List<AirQualityItem>>((ref) => []);

class AirQualityItem {
  final String pm25Grade1h;
  final String pm10Value24;
  final String so2Value;
  final String pm10Grade1h;
  final String o3Grade;
  final String pm10Value;
  final String? pm25Flag;
  final String khaiGrade;
  final String pm25Value;
  final String? no2Flag;
  final String mangName;
  final String no2Value;
  final String so2Grade;
  final String? coFlag;
  final String khaiValue;
  final String coValue;
  final String? pm10Flag;
  final String no2Grade;
  final String pm25Value24;
  final String? o3Flag;
  final String pm25Grade;
  final String? so2Flag;
  final String coGrade;
  final String dataTime;
  final String pm10Grade;
  final String o3Value;

  AirQualityItem({
    required this.pm25Grade1h,
    required this.pm10Value24,
    required this.so2Value,
    required this.pm10Grade1h,
    required this.o3Grade,
    required this.pm10Value,
    this.pm25Flag,
    required this.khaiGrade,
    required this.pm25Value,
    this.no2Flag,
    required this.mangName,
    required this.no2Value,
    required this.so2Grade,
    this.coFlag,
    required this.khaiValue,
    required this.coValue,
    this.pm10Flag,
    required this.no2Grade,
    required this.pm25Value24,
    this.o3Flag,
    required this.pm25Grade,
    this.so2Flag,
    required this.coGrade,
    required this.dataTime,
    required this.pm10Grade,
    required this.o3Value,
  });
}
