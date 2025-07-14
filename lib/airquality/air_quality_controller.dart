import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:proj4dart/proj4dart.dart';

import '../kakao_search_service.dart';
import 'air_quality_data.dart';

class AirQualityService {
  final Dio dio = Dio();
  final String apiKey =
      "Hmyyh9ZiYNt4vOZZdasLtsfACBE%2BbL%2F%2B2PevBXn00OmYRdYQUZsHzJt%2BLup4p4MK3m4HnRlV8Sy043CoDzm7Lg%3D%3D";
  final String baseUrl = "http://apis.data.go.kr/B552584/ArpltnInforInqireSvc/";

  Future<List<AirQualityItem>> fetchAirQualityByStation(
    String stationName,
  ) async {
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

class NearbyStationService {
  final Dio _dio = Dio();
  final String _apiKey =
      'Hmyyh9ZiYNt4vOZZdasLtsfACBE+bL/+2PevBXn00OmYRdYQUZsHzJt+Lup4p4MK3m4HnRlV8Sy043CoDzm7Lg=='; // 인코딩된 키 사용
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

      if (items is List && items.isNotEmpty) {
        final firstStation = items[0];

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

Future<void> initLocation(WidgetRef ref) async {
  try {
    // 🔸 위치 권한 확인 및 요청 추가
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('사용자가 위치 권한을 거부했습니다.');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('위치 권한이 영구적으로 거부되었습니다. 설정에서 수동으로 허용해야 합니다.');
      return;
    }

    // ✅ 기존 코드 그대로 유지
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setCoordinates(ref, position.longitude, position.latitude);
  } catch (e) {
    print('위치 정보 오류: $e');
  }
}


void setCoordinates(WidgetRef ref, double lng, double lat) {
  final wgs84 = Projection.get('EPSG:4326')!;
  final tmMid = Projection.add(
    'EPSG:2097',
    '+proj=tmerc +lat_0=38 +lon_0=127 +k=1 +x_0=200000 +y_0=500000 +ellps=GRS80 +units=m +no_defs',
  );

  final input = Point(x: lng, y: lat);
  final tmPoint = wgs84.transform(tmMid, input);

  ref.read(tmXProvider.notifier).state = double.parse(tmPoint.x.toStringAsFixed(2));
  ref.read(tmYProvider.notifier).state = double.parse(tmPoint.y.toStringAsFixed(2));
}

Future<void> handleSearch(WidgetRef ref, String keyword) async {
  if (keyword.isEmpty) {
    ref.read(searchSuggestionsProvider.notifier).state = [];
    return;
  }

  final results = await KakaoSearchService().searchKeyword(keyword);
  ref.read(searchSuggestionsProvider.notifier).state = results;
}