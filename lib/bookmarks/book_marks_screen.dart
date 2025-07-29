import 'package:flutter/material.dart';

class BookMarksScreen extends StatelessWidget {
  const BookMarksScreen({Key? key}) : super(key: key);

  final List<Map<String, dynamic>> bookmarks = const [
    {
      'placeName': '서울특별시 중구 을지로 100',
      'latitude': 37.5665,
      'longitude': 126.9780,
    },
    {
      'placeName': '부산광역시 해운대구 우동 1234',
      'latitude': 35.1796,
      'longitude': 129.0756,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('즐겨찾기')),
      body:
          bookmarks.isEmpty
              ? const Center(child: Text('즐겨찾는 장소가 없습니다.'))
              : ListView.builder(
                itemCount: bookmarks.length,
                itemBuilder: (context, index) {
                  final bookmark = bookmarks[index];
                  return ListTile(
                    title: Text(bookmark['placeName']),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                     //삭제 기능 추가해야함
                      },
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder:
                            (_) => AlertDialog(
                              title: Text(bookmark['placeName']),
                              content: SizedBox(
                                width: double.maxFinite,
                                child: _AirQualityAndWeatherDetails(
                                  latitude: bookmark['latitude'],
                                  longitude: bookmark['longitude'],
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('닫기'),
                                ),
                              ],
                            ),
                      );
                    },
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 즐겨찾기 기능
        },
        child: const Icon(Icons.add),
        tooltip: '즐겨찾기 추가',
      ),
    );
  }
}

class _AirQualityAndWeatherDetails extends StatelessWidget {
  final double latitude;
  final double longitude;

  const _AirQualityAndWeatherDetails({
    Key? key,
    required this.latitude,
    required this.longitude,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text('대기질: 미세먼지 23㎍/㎥, 초미세먼지 15㎍/㎥, 오존 0.03ppm'),
        SizedBox(height: 8),
        Text('날씨: 맑음, 기온 25°C, 습도 60%, 풍속 2.5m/s'),
      ],
    );
  }
}
