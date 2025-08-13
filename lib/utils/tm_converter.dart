import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:proj4dart/proj4dart.dart';
import '../airquality_page/air_quality_data.dart';

final wgs84 = Projection.get('EPSG:4326')!;
final tmMid = Projection.add(
  'EPSG:2097',
  '+proj=tmerc +lat_0=38 +lon_0=127 +k=1 +x_0=200000 +y_0=500000 +ellps=GRS80 +units=m +no_defs',
);

Point convertLatLngToTM(double lng, double lat) {
  final input = Point(x: lng, y: lat);
  return wgs84.transform(tmMid, input);
}

void setCoordinates(WidgetRef ref, double lng, double lat) {
  final tmPoint = convertLatLngToTM(lng, lat);

  ref.read(tmXProvider.notifier).state = double.parse(
    tmPoint.x.toStringAsFixed(2),
  );
  ref.read(tmYProvider.notifier).state = double.parse(
    tmPoint.y.toStringAsFixed(2),
  );
}
