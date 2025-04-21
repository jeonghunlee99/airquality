import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

class AirQualityTabScreen extends StatelessWidget {
  final List<String> cities = ['서울시', '안양시' ,'부산시'];

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

  final Map<String, List<String>> cityStations = {
    '서울시': ['종로구', '강남구', '동작구' , '강동구' ],
    '안양시': ['동안구', '만안구'],
    '부산시': ['광안리']
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<String> stations = cityStations[cityName] ?? [];

    return ListView.builder(
      itemCount: stations.length,
      itemBuilder: (context, index) {
        final station = stations[index];

        return FutureBuilder<List<AirQualityItem>>(
          future: AirQualityService().fetchAirQualityByStation(station),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return ListTile(title: Text('$station: 불러오는 중...'));
            } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
              return ListTile(title: Text('$station: 데이터 없음 또는 오류'));
            }

            final item = snapshot.data!.first;
            return Card(
              margin: EdgeInsets.all(8),
              child: ListTile(
                title: Text('$station (${item.dataTime})'),
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
