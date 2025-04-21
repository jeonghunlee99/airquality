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
      title: 'Air Quality',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: AirQualityScreen(),
    );
  }
}

class AirQualityScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final airQualityData = ref.watch(airQualityProvider);
    final airQualityService = AirQualityService();

    return Scaffold(
      appBar: AppBar(title: Text('Air Quality in 종로구')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () async {
              final data = await airQualityService.fetchAirQuality();
              ref.read(airQualityProvider.notifier).state = data;
            },
            child: Text("공기질 데이터 불러오기"),
          ),

          Expanded(
            child:
            airQualityData.isEmpty
                ? Center(child: Text("데이터 없음. 버튼을 눌러 데이터를 불러오세요."))
                : ListView.builder(
              itemCount: airQualityData.length,
              itemBuilder: (context, index) {
                final item = airQualityData[index];
                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text("측정 시간: ${item.dataTime}"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("미세먼지(PM10): ${item.pm10Value}㎍/㎥"),
                        Text("초미세먼지(PM2.5): ${item.pm25Value}㎍/㎥"),
                        Text("오존(O₃): ${item.o3Value}ppm"),
                        Text("이산화황(SO₂): ${item.so2Value}ppm"),
                        Text("이산화질소(NO₂): ${item.no2Value}ppm"),
                        Text("일산화탄소(CO): ${item.coValue}ppm"),
                        Text("통합대기환경지수(KHAI): ${item.khaiGrade}"),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
