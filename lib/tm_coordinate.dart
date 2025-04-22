import 'dart:math';

/// 장반경
const double _longRadius = 6378137;

/// 단반경
const double _shortRadius = 6356752.31425;

/// 투영원점 경도
const double originLong = 127;

/// 투영원점 위도
const double originLat = 38;

class TMCalculation {
  /// [lat] 위도
  /// [long] 경도
  /// [callback] 위경도를 TM 좌표 값으로 변환해서 전달하는 콜백
  /// 위도 -> TM 좌표 E
  /// 경도 -> TM 좌표 N
  TMCalculation({
    required double lat,
    required double long,
    required Function(double n, double e) callback,
  }) {
    double latRadian = degreeToRadian(lat);
    var t = pow(tan(latRadian), 2);
    var e2 = (pow(_longRadius, 2) - pow(_shortRadius, 2)) / pow(_longRadius, 2);
    var e2Prime =
        (pow(_longRadius, 2) - pow(_shortRadius, 2)) / pow(_shortRadius, 2);
    var c = (e2 / (1 - e2)) * pow(cos(latRadian), 2);
    var longRadian = degreeToRadian(long);
    var originRadian = degreeToRadian(originLong);
    var a = (longRadian - originRadian) * cos(degreeToRadian(lat));
    var n = _longRadius / sqrt(1 - (e2 * pow(sin(degreeToRadian(lat)), 2)));
    var m = calcM(lat: lat, e2: e2);
    var m0 = calcM(lat: originLat, e2: e2);

    var y1 = (pow(a, 3) / 6) * (1 - t + c);
    var y2 =
        (pow(a, 5) / 120) * (5 - 18 * t + pow(t, 2) + 72 * c - 58 * e2Prime);
    var Y = 200000 + 1 * n * (a + y1 + y2);

    var x1 = (pow(a, 4) / 24) * (5 - t + 9 * c + 4 * pow(c, 2));
    var x2 = (pow(a, 6) / 720) *
        (61 - (58 * t) + pow(t, 2) + (600 * c) - (330 * e2Prime));
    var X = 600000 +
        1 * (m - m0 + (n * tan(latRadian)) * ((pow(a, 2) / 2) + x1 + x2));

    callback(Y, X);
  }

  double degreeToRadian(value) => pi / 180 * value;

  double calcM({required double lat, required double e2}) {
    var latRadian = degreeToRadian(lat);
    var p = lat * (pi / 180);
    var m1 =
        (1 - (e2 / 4) - ((3 * pow(e2, 2)) / 64) - ((5 * pow(e2, 3)) / 256)) * p;
    var m2 =
        ((3 * e2) / 8) + ((3 * pow(e2, 2)) / 32) + ((45 * pow(e2, 3)) / 1024);
    m2 = m2 * sin(2 * latRadian);
    var m3 = ((15 * pow(e2, 2)) / 256) + ((45 * pow(e2, 3)) / 1024);
    m3 = m3 * sin(4 * latRadian);
    var m4 = ((35 * pow(e2, 3)) / 3072) * sin(6 * latRadian);
    var M = _longRadius * (m1 - m2 + m3 - m4);

    return M;
  }
}