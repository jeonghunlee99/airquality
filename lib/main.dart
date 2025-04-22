import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'airquality/air_quality_controller.dart';
import 'airquality/air_quality_data.dart';

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Air Quality App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: AirQualityTabScreen(),
    );
  }
}

class AirQualityTabScreen extends StatefulWidget {
  @override
  _AirQualityTabScreenState createState() => _AirQualityTabScreenState();
}

class _AirQualityTabScreenState extends State<AirQualityTabScreen> {
  final List<String> cities = ['서울시', '안양시' ,'부산시'];

  @override
  void initState() {
    super.initState();
    _printCurrentLocation();
  }

  Future<void> _printCurrentLocation() async {
    try {
      Position position = await getCurrentPosition();
      print('현재 위치: 위도 ${position.latitude}, 경도 ${position.longitude}');
    } catch (e) {
      print('위치 가져오기 오류: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: cities.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text('도시별 대기질 정보'),
          bottom: TabBar(
            tabs: cities.map((city) => Tab(text: city)).toList(),
          ),
        ),
        body: TabBarView(
          children: cities.map((city) => AirQualityCityView(cityName: city)).toList(),
        ),
      ),
    );
  }
}

class AirQualityCityView extends ConsumerWidget {
  final String cityName;

  AirQualityCityView({required this.cityName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 도시별 TM 좌표 매핑
    final Map<String, Map<String, double>> cityCoordinates = {
      '서울시': {'tmX': 199532.3, 'tmY': 451949.0},
      '안양시': {'tmX': 195223.4, 'tmY': 442182.5},
      '부산시': {'tmX': 266340.0, 'tmY': 391049.0},
    };

    final tmX = cityCoordinates[cityName]?['tmX'] ?? 60.0;
    final tmY = cityCoordinates[cityName]?['tmY'] ?? 127.0;

    return FutureBuilder<String?>(
      future: AirQualityService2().getNearbyStation(tmX: tmX, tmY: tmY),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: Text('$cityName: 측정소 정보를 불러오는 중...'));
        } else if (!snapshot.hasData || snapshot.data == null) {
          return Center(child: Text('$cityName: 측정소 정보를 가져올 수 없습니다.'));
        }

        final stationName = snapshot.data!;

        return FutureBuilder<List<AirQualityItem>>(
          future: AirQualityService().fetchAirQualityByStation(stationName),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: Text('$stationName: 공기질 데이터 불러오는 중...'));
            } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('$stationName: 공기질 데이터 없음 또는 오류'));
            }

            final item = snapshot.data!.first;
            return Card(
              margin: EdgeInsets.all(16),
              child: ListTile(
                title: Text('$stationName (${item.dataTime})'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('PM10: ${item.pm10Value} ㎍/㎥'),
                    Text('PM2.5: ${item.pm25Value} ㎍/㎥'),
                    Text('O₃: ${item.o3Value} ppm'),
                    Text('SO₂: ${item.so2Value} ppm'),
                    Text('NO₂: ${item.no2Value} ppm'),
                    Text('CO: ${item.coValue} ppm'),
                    Text('KHAI 지수: ${item.khaiGrade}'),
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

Future<Position> getCurrentPosition() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    throw Exception("위치 서비스가 꺼져 있습니다.");
  }

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      throw Exception("위치 권한이 거부되었습니다.");
    }
  }

  return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
}