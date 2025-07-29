import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../airquality/air_quality_controller.dart';
import '../airquality/air_quality_data.dart';

class AirQualityCityView extends ConsumerWidget {
  final String cityName;
  final double tmX;
  final double tmY;

  const AirQualityCityView({
    required this.cityName,
    required this.tmX,
    required this.tmY,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final airQualityAsync = ref.watch(airQualityProvider);
    final isLoading = ref.watch(isLoadingProvider);

    return airQualityAsync.when(
      loading:
          () => const Center(
            child: CircularProgressIndicator(color: Colors.black),
          ),
      error: (error, _) => Center(child: Text('❌ ${error.toString()}')),
      data: (data) {
        final stationName = data.stationName;
        final items = data.items;

        if (items.isEmpty) {
          return const Center(child: Text('❌ 데이터 없음'));
        }

        final item = items.first;

        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Stack(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  height: MediaQuery.of(context).size.height * 0.85,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.white, Colors.yellow[200]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha((255 * 0.1).round()),
                        blurRadius: 10,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '$stationName\n(${item.dataTime})',
                          textAlign: TextAlign.center,
                          style: Theme.of(
                            context,
                          ).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: GridView.count(
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 1.2,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              buildAirQualityCard(
                                'PM10',
                                item.pm10Value,
                                'pm10',
                              ),
                              buildAirQualityCard(
                                'PM2.5',
                                item.pm25Value,
                                'pm25',
                              ),
                              buildAirQualityCard('O₃', item.o3Value, 'o3'),
                              buildAirQualityCard('SO₂', item.so2Value, 'so2'),
                              buildAirQualityCard('NO₂', item.no2Value, 'no2'),
                              buildAirQualityCard('CO', item.coValue, 'co'),
                              buildAirQualityCard(
                                'KHAI',
                                item.khaiGrade,
                                'khai',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TextButton.icon(
                              onPressed: () async {
                                ref.read(isLoadingProvider.notifier).state =
                                    true;
                                await initLocation(ref);
                                ref.read(isLoadingProvider.notifier).state =
                                    false;
                              },
                              icon: const Icon(
                                Icons.my_location,
                                color: Colors.black,
                              ),
                              label: const Text(
                                '현재 위치 재조회',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () => showInfoDialog(context),
                              icon: const Icon(
                                Icons.info_outline,
                                color: Colors.black,
                              ),
                              label: const Text(
                                '지수 설명',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                if (isLoading)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha((255 * 0.7).round()),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(color: Colors.black),
                            SizedBox(height: 16),
                            Text(
                              '현재 위치를 가져오는 중이에요!',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

Widget buildAirQualityCard(String label, String value, String type) {
  final level = getAirQualityLevel(type, value);

  return Card(
    color: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(level.icon, color: level.color, size: 32),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('$value (${level.label})', style: TextStyle(color: level.color)),
        ],
      ),
    ),
  );
}

void showInfoDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('대기질 지수 설명'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow('PM10', '미세먼지 입자 크기 10μm 이하, 호흡기에 침투할 수 있어요.'),
              _buildInfoRow('PM2.5', '초미세먼지, 입자 크기 2.5μm 이하. 건강에 더 치명적입니다.'),
              _buildInfoRow('O₃ (오존)', '지상 오존은 호흡기에 해롭고 눈을 자극할 수 있습니다.'),
              _buildInfoRow('SO₂ (아황산가스)', '화석연료 연소 등으로 발생, 호흡기 자극.'),
              _buildInfoRow('NO₂ (이산화질소)', '자동차 배기가스 주요 성분, 호흡기 질환 유발.'),
              _buildInfoRow('CO (일산화탄소)', '무색무취의 독성 가스, 고농도 노출 시 치명적입니다.'),
              _buildInfoRow('KHAI 지수', '대기질 종합 지수 (여러 오염물질 수치를 종합한 지표).'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('닫기', style: TextStyle(color: Colors.black)),
          ),
        ],
      );
    },
  );
}

Widget _buildInfoRow(String title, String description) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        Text(description),
      ],
    ),
  );
}

String getAirQualityGrade(String type, String rawValue) {
  double value = double.tryParse(rawValue) ?? 0;

  switch (type.toLowerCase()) {
    case 'pm10':
      if (value <= 30) return '좋음';
      if (value <= 50) return '조금 좋음';
      if (value <= 80) return '평균';
      if (value <= 100) return '조금 나쁨';
      return '나쁨';

    case 'pm25':
      if (value <= 15) return '좋음';
      if (value <= 25) return '조금 좋음';
      if (value <= 35) return '평균';
      if (value <= 50) return '조금 나쁨';
      return '나쁨';

    case 'o3':
      if (value <= 0.030) return '좋음';
      if (value <= 0.050) return '조금 좋음';
      if (value <= 0.070) return '평균';
      if (value <= 0.090) return '조금 나쁨';
      return '나쁨';

    case 'so2':
      if (value <= 0.010) return '좋음';
      if (value <= 0.020) return '조금 좋음';
      if (value <= 0.030) return '평균';
      if (value <= 0.050) return '조금 나쁨';
      return '나쁨';

    case 'no2':
      if (value <= 0.020) return '좋음';
      if (value <= 0.030) return '조금 좋음';
      if (value <= 0.050) return '평균';
      if (value <= 0.100) return '조금 나쁨';
      return '나쁨';

    case 'co':
      if (value <= 2.0) return '좋음';
      if (value <= 5.0) return '조금 좋음';
      if (value <= 8.0) return '평균';
      if (value <= 10.0) return '조금 나쁨';
      return '나쁨';

    case 'khai':
      if (value <= 50) return '좋음';
      if (value <= 75) return '조금 좋음';
      if (value <= 100) return '평균';
      if (value <= 150) return '조금 나쁨';
      return '나쁨';

    default:
      return '정보 없음';
  }
}

class AirQualityLevel {
  final String label;
  final Color color;
  final IconData icon;

  AirQualityLevel(this.label, this.color, this.icon);
}

AirQualityLevel getAirQualityLevel(String type, String rawValue) {
  final grade = getAirQualityGrade(type, rawValue);
  switch (grade) {
    case '좋음':
      return AirQualityLevel(
        '좋음',
        Colors.green,
        Icons.sentiment_very_satisfied,
      );
    case '조금 좋음':
      return AirQualityLevel(
        '조금 좋음',
        Colors.lightGreen,
        Icons.sentiment_satisfied,
      );
    case '평균':
      return AirQualityLevel('평균', Colors.amber, Icons.sentiment_neutral);
    case '조금 나쁨':
      return AirQualityLevel(
        '조금 나쁨',
        Colors.orange,
        Icons.sentiment_dissatisfied,
      );
    case '나쁨':
      return AirQualityLevel(
        '나쁨',
        Colors.red,
        Icons.sentiment_very_dissatisfied,
      );
    default:
      return AirQualityLevel('정보 없음', Colors.grey, Icons.help_outline);
  }
}

Widget buildAirQualityRow(String label, String value, String type) {
  final level = getAirQualityLevel(type, value);

  return Row(
    children: [
      Icon(level.icon, color: level.color),
      const SizedBox(width: 15),
      Text(
        '$label: $value (${level.label})',
        style: TextStyle(
          fontSize: 25,
          color: level.color,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  );
}
