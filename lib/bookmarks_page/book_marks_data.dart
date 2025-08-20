import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../Weather_info_page/Weather_info_data.dart';
import '../airquality_page/air_quality_data.dart';
import '../utils/auth_service.dart';
import '../utils/tm_converter.dart';

final airQualityAndWeatherProvider = FutureProvider.family<
  ({
    String stationName,
    List<AirQualityItem> airQualityItems,
    List<HourlyWeather> weatherItems,
  }),
  ({double lat, double lng})
>((ref, coords) async {
  final nearbyStationService = ref.watch(nearbyStationServiceProvider);
  final airQualityService = ref.watch(airQualityServiceProvider);
  final weatherService = ref.watch(weatherServiceProvider);

  // TM 좌표 변환
  final tmPoint = convertLatLngToTM(coords.lng, coords.lat);

  // 대기질
  final stationName = await nearbyStationService.getNearbyStation(
    tmX: tmPoint.x,
    tmY: tmPoint.y,
  );
  final airQualityItems =
      stationName != null && stationName.isNotEmpty
          ? await airQualityService.fetchAirQualityByStation(stationName)
          : <AirQualityItem>[];

  // 날씨 격자 변환
  final grid = GridUtil.convertToGrid(coords.lat, coords.lng);
  final nx = grid['nx'];
  final ny = grid['ny'];
  final weatherItems =
      (nx != null && ny != null)
          ? await weatherService.fetchHourlyWeather(nx: nx, ny: ny)
          : <HourlyWeather>[];

  return (
    stationName: stationName ?? '',
    airQualityItems: airQualityItems,
    weatherItems: weatherItems,
  );
});

final bookmarksProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final auth = ref.watch(authStateProvider).value;
  if (auth == null) return const Stream.empty();

  return FirebaseFirestore.instance
      .collection('users')
      .doc(auth.uid)
      .collection('bookmarks')
      .snapshots()
      .map((snapshot) =>
      snapshot.docs.map((doc) => {
        ...doc.data(),
        'id': doc.id,
      }).toList());
});
