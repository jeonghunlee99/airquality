import 'package:dio/dio.dart';

class KakaoSearchService {
  final Dio _dio = Dio();
  final String _kakaoApiKey = '8e7ff93e3e9c6b1028bdc86ce07d1722';

  Future<List<Map<String, dynamic>>> searchKeyword(String keyword) async {
    final encodedKeyword = Uri.encodeQueryComponent(keyword);
    final url =
        'https://dapi.kakao.com/v2/local/search/keyword.json?query=$encodedKeyword';

    try {
      final response = await _dio.get(
        url,
        options: Options(headers: {'Authorization': 'KakaoAK $_kakaoApiKey'}),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        List searchResults = data['documents'];


        final filtered = searchResults.where((place) {
          final placeName = place['place_name'] ?? '';
          return placeName.contains(keyword);
        }).toList();

        return filtered.cast<Map<String, dynamic>>();
      } else {
        print('API 요청 실패: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('오류 발생: $e');
      return [];
    }
  }
}