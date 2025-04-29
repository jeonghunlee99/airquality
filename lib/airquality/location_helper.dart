import 'package:geolocator/geolocator.dart';
import 'package:proj4dart/proj4dart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../airquality/air_quality_data.dart';

Future<void> initLocation(WidgetRef ref) async {
  try {
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
