import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:proj4dart/proj4dart.dart';

import 'air_quality_controller.dart';
import 'air_quality_data.dart';

class CurrentLocationAirQualityScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<CurrentLocationAirQualityScreen> createState() =>
      _CurrentLocationAirQualityScreenState();
}

class _CurrentLocationAirQualityScreenState
    extends ConsumerState<CurrentLocationAirQualityScreen> {
  bool _isSearching = false; // 추가
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _startSearch() {
    setState(() {
      _isSearching = true;
    });
  }

  void _stopSearch() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
    });
  }

  Future<void> _initLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final wgs84 = Projection.get('EPSG:4326')!;
      final tmMid = Projection.add(
        'EPSG:2097',
        '+proj=tmerc +lat_0=38 +lon_0=127 +k=1 +x_0=200000 +y_0=500000 +ellps=GRS80 +units=m +no_defs',
      );

      final input = Point(x: position.longitude, y: position.latitude);
      final tmPoint = wgs84.transform(tmMid, input);

      ref.read(tmXProvider.notifier).state = double.parse(
        tmPoint.x.toStringAsFixed(2),
      );
      ref.read(tmYProvider.notifier).state = double.parse(
        tmPoint.y.toStringAsFixed(2),
      );
    } catch (e) {
      print('위치 정보 오류: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final tmX = ref.watch(tmXProvider);
    final tmY = ref.watch(tmYProvider);

    return Scaffold(
      appBar: AppBar(
        title:
            _isSearching
                ? TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: '지역 이름 입력',
                    border: InputBorder.none,
                  ),
                  onSubmitted: (value) {
                    // TODO: 여기서 검색 동작 구현
                    print('검색: $value');
                  },
                )
                : Text('현재 위치 대기질'),
        actions: [
          _isSearching
              ? IconButton(icon: Icon(Icons.close), onPressed: _stopSearch)
              : IconButton(icon: Icon(Icons.search), onPressed: _startSearch),
        ],
      ),
      body:
          tmX == null || tmY == null
              ? Center(child: CircularProgressIndicator())
              : AirQualityCityView(cityName: '현재위치', tmX: tmX, tmY: tmY),
    );
  }
}

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
    return FutureBuilder<String?>(
      future: AirQualityService2().getNearbyStation(tmX: tmX, tmY: tmY),
      builder: (context, stationSnapshot) {
        if (stationSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!stationSnapshot.hasData || stationSnapshot.data == null) {
          return Center(child: Text('❌ 측정소 정보를 불러올 수 없습니다.'));
        }

        final stationName = stationSnapshot.data!;
        return FutureBuilder<List<AirQualityItem>>(
          future: AirQualityService().fetchAirQualityByStation(stationName),
          builder: (context, dataSnapshot) {
            if (dataSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (dataSnapshot.hasError ||
                !dataSnapshot.hasData ||
                dataSnapshot.data!.isEmpty) {
              return Center(
                child: Text('$stationName: ❌ 대기질 데이터를 불러올 수 없습니다.'),
              );
            }

            final item = dataSnapshot.data!.first;
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center, // 중앙 정렬
                  crossAxisAlignment: CrossAxisAlignment.center, // 수평 중앙 정렬
                  children: [
                    Text(
                      '$stationName (${item.dataTime})',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    buildAirQualityRow('PM10', item.pm10Value, 'pm10'),
                    buildAirQualityRow('PM2.5', item.pm25Value, 'pm25'),
                    buildAirQualityRow('O₃', item.o3Value, 'o3'),
                    buildAirQualityRow('SO₂', item.so2Value, 'so2'),
                    buildAirQualityRow('NO₂', item.no2Value, 'no2'),
                    buildAirQualityRow('CO', item.coValue, 'co'),
                    buildAirQualityRow('KHAI 지수', item.khaiGrade, 'khai'),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
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
      const SizedBox(width: 8),
      Text(
        '$label: $value (${level.label})',
        style: TextStyle(color: level.color, fontWeight: FontWeight.bold),
      ),
    ],
  );
}
