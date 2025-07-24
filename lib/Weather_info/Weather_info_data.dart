import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'Weather_info_controller..dart';

final weatherServiceProvider = Provider((ref) => WeatherService());
final weatherProvider = FutureProvider.autoDispose<List<HourlyWeather>>((ref) async {
  ref.keepAlive();

  final nx = ref.watch(nxProvider);
  final ny = ref.watch(nyProvider);

  print('[DEBUG] weatherProvider에서 사용하는 nx: $nx, ny: $ny');
  final service = ref.watch(weatherServiceProvider);
  return await service.fetchHourlyWeather(nx: nx, ny: ny);
});

final nxProvider = StateProvider<int>((ref) => 44); // 초기값
final nyProvider = StateProvider<int>((ref) => 127);
final selectedPlaceNameProvider = StateProvider<String>((ref) => '');
final showAllForecastProvider = StateProvider<bool>((ref) => false);
final selectedForecastIndexProvider = StateProvider<int?>((ref) => null);


class HourlyWeather {
  final String time;
  final String temp;
  final String windSpeed;
  final String windDir;
  final String sky;
  final String pty;
  final String pop;
  final String humidity;
  final String pcp;

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

class GridUtil {
  static const double RE = 6371.00877; // Earth radius (km)
  static const double GRID = 5.0;      // Grid spacing (km)
  static const double SLAT1 = 30.0;    // Projection latitude 1 (degree)
  static const double SLAT2 = 60.0;    // Projection latitude 2 (degree)
  static const double OLON = 126.0;    // Reference longitude (degree)
  static const double OLAT = 38.0;     // Reference latitude (degree)
  static const double XO = 43;         // Origin X coordinate (GRID)
  static const double YO = 136;        // Origin Y coordinate (GRID)

  static Map<String, int> convertToGrid(double lat, double lng) {
    double DEGRAD = pi / 180.0;
    double re = RE / GRID;
    double slat1 = SLAT1 * DEGRAD;
    double slat2 = SLAT2 * DEGRAD;
    double olon = OLON * DEGRAD;
    double olat = OLAT * DEGRAD;

    double sn = tan(pi * 0.25 + slat2 * 0.5) / tan(pi * 0.25 + slat1 * 0.5);
    sn = log(cos(slat1) / cos(slat2)) / log(sn);
    double sf = tan(pi * 0.25 + slat1 * 0.5);
    sf = pow(sf, sn) * cos(slat1) / sn;
    double ro = tan(pi * 0.25 + olat * 0.5);
    ro = re * sf / pow(ro, sn);

    double ra = tan(pi * 0.25 + lat * DEGRAD * 0.5);
    ra = re * sf / pow(ra, sn);
    double theta = lng * DEGRAD - olon;
    if (theta > pi) theta -= 2.0 * pi;
    if (theta < -pi) theta += 2.0 * pi;
    theta *= sn;

    int nx = (ra * sin(theta) + XO + 0.5).floor();
    int ny = (ro - ra * cos(theta) + YO + 0.5).floor();

    return {'nx': nx, 'ny': ny};
  }
}

