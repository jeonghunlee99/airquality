import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'Weather_info_controller..dart';

final weatherServiceProvider = Provider((ref) => WeatherService());
final weatherProvider = FutureProvider.autoDispose<List<HourlyWeather>>((
  ref,
) async {
  ref.keepAlive();

  final service = ref.read(weatherServiceProvider);
  return await service.fetchHourlyWeather(nx: 55, ny: 127);
});

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
