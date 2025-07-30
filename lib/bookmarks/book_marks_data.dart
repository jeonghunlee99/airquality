import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../airquality/air_quality_data.dart';
import '../utils/tm_converter.dart';

final airQualityByLatLngProvider = FutureProvider.family<
    ({String stationName, List<AirQualityItem> items}),
    ({double lat, double lng})
>((ref, coords) async {
  final nearbyStationService = ref.watch(nearbyStationServiceProvider);
  final airQualityService = ref.watch(airQualityServiceProvider);

  final tmPoint = convertLatLngToTM(coords.lng, coords.lat);

  final stationName = await nearbyStationService.getNearbyStation(
    tmX: tmPoint.x,
    tmY: tmPoint.y,
  );

  if (stationName == null || stationName.isEmpty) {
    return (stationName: '', items: <AirQualityItem>[]);
  }

  final items = await airQualityService.fetchAirQualityByStation(stationName);

  return (stationName: stationName, items: items);
});
