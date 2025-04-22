import 'dart:math';


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:proj4dart/proj4dart.dart'  ;
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
  final List<String> cities = ['현재위치', '서울시', '안양시', '부산시'];
  double? _currentTMX;
  double? _currentTMY;

  @override
  void initState() {
    super.initState();
    _initCurrentLocation();
  }

  Future<void> _initCurrentLocation() async {
    try {
      // 현재 GPS 위치 받아오기
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      double lat = position.latitude;
      double lon = position.longitude;

      print('📍 현재 위치 정보:');
      print('위도: $lat, 경도: $lon');

      // 투영 정의: WGS84 (위도/경도)
      final wgs84 = Projection.get('EPSG:4326')!;

      // EPSG:2097 (GRS80 TM중부원점)
      final tmMid = Projection.add(
        'EPSG:2097',
        '+proj=tmerc +lat_0=38 +lon_0=127 +k=1 +x_0=200000 +y_0=500000 '
            '+ellps=GRS80 +units=m +no_defs',
      );

      // WGS84 (위도, 경도) → TM 좌표 (EPSG:2097)
      final input = Point(x: lon, y: lat);  // 경도, 위도 순서
      final tmPoint = wgs84.transform(tmMid, input);

      // 변환된 TM 좌표
      final tmx = double.parse(tmPoint.x.toStringAsFixed(2));
      final tmy = double.parse(tmPoint.y.toStringAsFixed(2));

      setState(() {
        _currentTMX = tmx;
        _currentTMY = tmy;
      });

      print('🧭 TM 좌표로 변환된 값: TMX: $tmx, TMY: $tmy');
    } catch (e) {
      print('❌ 오류 발생: $e');
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
          children: cities.map((city) {
            if (city == '현재위치') {
              // 현재 위치가 제대로 로딩되었을 때, TMX, TMY 값을 넘겨줍니다.
              return (_currentTMX != null && _currentTMY != null)
                  ? AirQualityCityView(cityName: city, tmX: _currentTMX!, tmY: _currentTMY!)
                  : Center(child: Text('📍 현재 위치를 불러오는 중...'));
            } else {
              // 미리 정의된 다른 도시들의 TMX, TMY 값
              final Map<String, Map<String, double>> cityCoordinates = {
                '서울시': {'tmX': 196522.26, 'tmY': 431492.67},
                '안양시': {'tmX': 601234.56, 'tmY': 198765.43},
                '부산시': {'tmX': 2466340.0, 'tmY': 391049.0},
              };
              final tmX = cityCoordinates[city]?['tmX'] ?? 60.0;
              final tmY = cityCoordinates[city]?['tmY'] ?? 127.0;
              return AirQualityCityView(cityName: city, tmX: tmX, tmY: tmY);
            }
          }).toList(),
        ),
      ),
    );
  }
}
class AirQualityCityView extends ConsumerWidget {
  final String cityName;
  final double tmX;
  final double tmY;

  AirQualityCityView({required this.cityName, required this.tmX, required this.tmY});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

class LatLngToTM {
  static const double RE = 6371.00877;
  static const double GRID = 5.0;
  static const double SLAT1 = 30.0;
  static const double SLAT2 = 60.0;
  static const double OLON = 126.0;
  static const double OLAT = 38.0;
  static const double XO = 43;
  static const double YO = 136;

  static Map<String, double> convert(double lat, double lon) {
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
    double theta = lon * DEGRAD - olon;
    if (theta > pi) theta -= 2.0 * pi;
    if (theta < -pi) theta += 2.0 * pi;
    theta *= sn;

    double x = ra * sin(theta) + XO;
    double y = ro - ra * cos(theta) + YO;

    return {'x': x, 'y': y};
  }
}
