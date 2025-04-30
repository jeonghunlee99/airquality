import 'package:flutter_riverpod/flutter_riverpod.dart';

final airQualityProvider = StateProvider<List<AirQualityItem>>((ref) => []);
final tmXProvider = StateProvider<double?>((ref) => null);
final tmYProvider = StateProvider<double?>((ref) => null);
final currentLocationProvider = StateProvider<({double tmX, double tmY})?>((ref) => null);
final isLoadingProvider = StateProvider<bool>((ref) => false);


class AirQualityItem {
  final String pm25Grade1h;
  final String pm10Value24;
  final String so2Value;
  final String pm10Grade1h;
  final String o3Grade;
  final String pm10Value;
  final String khaiGrade;
  final String pm25Value;
  final String mangName;
  final String no2Value;
  final String so2Grade;
  final String khaiValue;
  final String coValue;
  final String no2Grade;
  final String pm25Value24;
  final String pm25Grade;
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
    required this.khaiGrade,
    required this.pm25Value,
    required this.mangName,
    required this.no2Value,
    required this.so2Grade,
    required this.khaiValue,
    required this.coValue,
    required this.no2Grade,
    required this.pm25Value24,
    required this.pm25Grade,
    required this.coGrade,
    required this.dataTime,
    required this.pm10Grade,
    required this.o3Value,
  });

  factory AirQualityItem.fromJson(Map<String, dynamic> json) {
    return AirQualityItem(
      pm25Grade1h: json["pm25Grade1h"] ?? "0",
      pm10Value24: json["pm10Value24"] ?? "0",
      so2Value: json["so2Value"] ?? "0",
      pm10Grade1h: json["pm10Grade1h"] ?? "0",
      o3Grade: json["o3Grade"] ?? "0",
      pm10Value: json["pm10Value"] ?? "0",
      khaiGrade: json["khaiGrade"] ?? "0",
      pm25Value: json["pm25Value"] ?? "0",
      mangName: json["mangName"] ?? "0",
      no2Value: json["no2Value"] ?? "0",
      so2Grade: json["so2Grade"] ?? "0",
      khaiValue: json["khaiValue"] ?? "0",
      coValue: json["coValue"] ?? "0",
      no2Grade: json["no2Grade"] ?? "0",
      pm25Value24: json["pm25Value24"] ?? "0",
      pm25Grade: json["pm25Grade"] ?? "0",
      coGrade: json["coGrade"] ?? "0",
      dataTime: json["dataTime"] ?? "",
      pm10Grade: json["pm10Grade"] ?? "0",
      o3Value: json["o3Value"] ?? "0",
    );
  }
}
