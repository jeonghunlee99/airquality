import 'package:dio/dio.dart';

import 'air_quality_data.dart';

class AirQualityService {
  final Dio dio = Dio();
  final String apiKey =
      "Hmyyh9ZiYNt4vOZZdasLtsfACBE%2BbL%2F%2B2PevBXn00OmYRdYQUZsHzJt%2BLup4p4MK3m4HnRlV8Sy043CoDzm7Lg%3D%3D";
  final String baseUrl = "http://apis.data.go.kr/B552584/ArpltnInforInqireSvc/";

  Future<List<AirQualityItem>> fetchAirQuality() async {
    String url =
        "${baseUrl}getMsrstnAcctoRltmMesureDnsty?serviceKey=$apiKey&"
        "returnType=json&numOfRows=1&pageNo=1&stationName=종로구&dataTerm=DAILY&ver=1.3";

    Dio dio = Dio();

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
          print("AirQualityItem Data: ");
          print("PM2.5 Grade 1h: ${airQuality.pm25Grade1h}");
          print("PM10 Value 24: ${airQuality.pm10Value24}");
          print("SO2 Value: ${airQuality.so2Value}");
          print("PM10 Grade 1h: ${airQuality.pm10Grade1h}");
          print("O3 Grade: ${airQuality.o3Grade}");
          print("PM10 Value: ${airQuality.pm10Value}");
          print("KHai Grade: ${airQuality.khaiGrade}");
          print("PM2.5 Value: ${airQuality.pm25Value}");
          print("Mang Name: ${airQuality.mangName}");
          print("NO2 Value: ${airQuality.no2Value}");
          print("SO2 Grade: ${airQuality.so2Grade}");
          print("KHai Value: ${airQuality.khaiValue}");
          print("CO Value: ${airQuality.coValue}");
          print("NO2 Grade: ${airQuality.no2Grade}");
          print("PM2.5 Value 24: ${airQuality.pm25Value24}");
          print("PM2.5 Grade: ${airQuality.pm25Grade}");
          print("CO Grade: ${airQuality.coGrade}");
          print("Data Time: ${airQuality.dataTime}");
          print("PM10 Grade: ${airQuality.pm10Grade}");
          print("O3 Value: ${airQuality.o3Value}");

          airQualityList.add(airQuality);
        }

        return airQualityList;
      } else {
        print("API 호출 실패: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("오류 발생: $e");
      return [];
    }
  }
}
