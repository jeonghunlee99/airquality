import 'package:dio/dio.dart';

import 'air_quality_data.dart';

class AirQualityService {
  final Dio dio = Dio();
  final String apiKey =
      "Hmyyh9ZiYNt4vOZZdasLtsfACBE%2BbL%2F%2B2PevBXn00OmYRdYQUZsHzJt%2BLup4p4MK3m4HnRlV8Sy043CoDzm7Lg%3D%3D";
  final String baseUrl = "http://apis.data.go.kr/B552584/ArpltnInforInqireSvc/";

  Future<List<AirQualityItem>> fetchAirQualityByStation(
      String stationName) async {
    String url =
        "${baseUrl}getMsrstnAcctoRltmMesureDnsty?serviceKey=$apiKey&"
        "returnType=json&numOfRows=1&pageNo=1&stationName=$stationName&dataTerm=DAILY&ver=1.3";

    try {
      Response response = await dio.get(url);

      if (response.statusCode == 200) {
        final jsonData = response.data;
        List<AirQualityItem> airQualityList = [];
        final items = jsonData['response']['body']['items'];

        for (var i in items) {
          AirQualityItem airQuality = AirQualityItem(
            pm25Grade1h: i["pm25Grade1h"] ?? "0",
            pm10Value24: i["pm10Value24"] ?? "0",
            so2Value: i["so2Value"] ?? "0",
            pm10Grade1h: i["pm10Grade1h"] ?? "0",
            o3Grade: i["o3Grade"] ?? "0",
            pm10Value: i["pm10Value"] ?? "0",
            khaiGrade: i["khaiGrade"] ?? "0",
            pm25Value: i["pm25Value"] ?? "0",
            mangName: i["mangName"] ?? "0",
            no2Value: i["no2Value"] ?? "0",
            so2Grade: i["so2Grade"] ?? "0",
            khaiValue: i["khaiValue"] ?? "0",
            coValue: i["coValue"] ?? "0",
            no2Grade: i["no2Grade"] ?? "0",
            pm25Value24: i["pm25Value24"] ?? "0",
            pm25Grade: i["pm25Grade"] ?? "0",
            coGrade: i["coGrade"] ?? "0",
            dataTime: i["dataTime"] ?? "",
            pm10Grade: i["pm10Grade"] ?? "0",
            o3Value: i["o3Value"] ?? "0",
          );


          airQualityList.add(airQuality);
        }

        return airQualityList;
      } else {
        print("API 호출 실패1: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("오류 발생12: $e");
      return [];
    }
  }



}

class AirQualityService2 {
  final Dio _dio = Dio();
  final String _apiKey = 'Hmyyh9ZiYNt4vOZZdasLtsfACBE+bL/+2PevBXn00OmYRdYQUZsHzJt+Lup4p4MK3m4HnRlV8Sy043CoDzm7Lg=='; // 인코딩된 키 사용
  Future<String?> getNearbyStation({
    required double tmX,
    required double tmY,
  }) async {
    final String url =
        'http://apis.data.go.kr/B552584/MsrstnInfoInqireSvc/getNearbyMsrstnList';

    try {
      final response = await _dio.get(
        url,
        queryParameters: {
          'serviceKey': _apiKey,
          'returnType': 'json',
          'tmX': tmX,
          'tmY': tmY,
          'ver': '1.1',
        },
      );

      final data = response.data;
      print("전체 응답: $data");

      final items = data['response']?['body']?['items'];

      // 여기서 items가 List인지 확인
      if (items is List && items.isNotEmpty) {
        final firstStation = items[0];


        // Map 형태인지 확인 후 접근
        if (firstStation is Map<String, dynamic> &&
            firstStation.containsKey('stationName')) {
          return firstStation['stationName'] as String;
        }
      } else {
        print("측정소 리스트가 비어 있거나 형식이 맞지 않습니다.");
      }
    } catch (e) {
      print('Error fetching nearby station12: $e');
    }

    return null;
  }

}