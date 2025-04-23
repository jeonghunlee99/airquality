

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:proj4dart/proj4dart.dart';

import 'air_quality_controller.dart';
import 'air_quality_data.dart';

class CurrentLocationAirQualityScreen extends StatefulWidget {
  @override
  State<CurrentLocationAirQualityScreen> createState() => _CurrentLocationAirQualityScreenState();
}

class _CurrentLocationAirQualityScreenState extends State<CurrentLocationAirQualityScreen> {
  double? _tmX;
  double? _tmY;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      final wgs84 = Projection.get('EPSG:4326')!;
      final tmMid = Projection.add(
        'EPSG:2097',
        '+proj=tmerc +lat_0=38 +lon_0=127 +k=1 +x_0=200000 +y_0=500000 +ellps=GRS80 +units=m +no_defs',
      );

      final input = Point(x: position.longitude, y: position.latitude);
      final tmPoint = wgs84.transform(tmMid, input);

      setState(() {
        _tmX = double.parse(tmPoint.x.toStringAsFixed(2));
        _tmY = double.parse(tmPoint.y.toStringAsFixed(2));
      });
    } catch (e) {
      print('위치 정보 오류: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_tmX == null || _tmY == null) {
      return Scaffold(
        appBar: AppBar(title: Text("현재 위치 대기질")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("현재 위치 대기질")),
      body: AirQualityCityView(cityName: '현재위치', tmX: _tmX!, tmY: _tmY!),
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
            if (dataSnapshot.hasError || !dataSnapshot.hasData || dataSnapshot.data!.isEmpty) {
              return Center(child: Text('$stationName: ❌ 대기질 데이터를 불러올 수 없습니다.'));
            }

            final item = dataSnapshot.data!.first;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('$stationName (${item.dataTime})',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text('• PM10: ${item.pm10Value} ㎍/㎥'),
                      Text('• PM2.5: ${item.pm25Value} ㎍/㎥'),
                      Text('• O₃: ${item.o3Value} ppm'),
                      Text('• SO₂: ${item.so2Value} ppm'),
                      Text('• NO₂: ${item.no2Value} ppm'),
                      Text('• CO: ${item.coValue} ppm'),
                      Text('• KHAI 지수: ${item.khaiGrade}'),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}