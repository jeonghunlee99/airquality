import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:proj4dart/proj4dart.dart';
import '../widget/air_quality_city_view.dart';
import 'air_quality_data.dart';
import 'package:geocoding/geocoding.dart'; // 추가!

class CurrentLocationAirQualityScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<CurrentLocationAirQualityScreen> createState() =>
      _CurrentLocationAirQualityScreenState();
}

class _CurrentLocationAirQualityScreenState
    extends ConsumerState<CurrentLocationAirQualityScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _startSearch() {
    setState(() {
      _isSearching = true;
    });
  }

  void _stopSearch() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
    });
  }

  Future<void> _initLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final wgs84 = Projection.get('EPSG:4326')!;
      final tmMid = Projection.add(
        'EPSG:2097',
        '+proj=tmerc +lat_0=38 +lon_0=127 +k=1 +x_0=200000 +y_0=500000 +ellps=GRS80 +units=m +no_defs',
      );

      final input = Point(x: position.longitude, y: position.latitude);
      final tmPoint = wgs84.transform(tmMid, input);

      ref.read(tmXProvider.notifier).state = double.parse(
        tmPoint.x.toStringAsFixed(2),
      );
      ref.read(tmYProvider.notifier).state = double.parse(
        tmPoint.y.toStringAsFixed(2),
      );
    } catch (e) {
      print('위치 정보 오류: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final tmX = ref.watch(tmXProvider);
    final tmY = ref.watch(tmYProvider);

    return Scaffold(
      appBar: AppBar(
        title:
            _isSearching
                ? TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: '지역 이름 입력',
                    border: InputBorder.none,
                  ),
              onSubmitted: (value) async {
                if (value.isEmpty) {
                  print('검색어가 비어있습니다.');
                  return;
                }

                try {
                  List<Location> locations = await locationFromAddress(value);

                  if (locations.isNotEmpty) {
                    final firstLocation = locations.first;
                    if (firstLocation != null) {
                      double latitude = firstLocation.latitude;
                      double longitude = firstLocation.longitude;
                      print('검색한 주소의 위도: $latitude, 경도: $longitude');
                    } else {
                      print('검색 결과는 있지만 값이 없습니다.');
                    }
                  } else {
                    print('검색 결과가 없습니다.');
                  }
                } catch (e) {
                  print('지오코딩 오류: $e');
                }
              },
                )
                : Text('현재 위치 대기질'),
        actions: [
          _isSearching
              ? IconButton(icon: Icon(Icons.close), onPressed: _stopSearch)
              : IconButton(icon: Icon(Icons.search), onPressed: _startSearch),
        ],
      ),
      body:
          tmX == null || tmY == null
              ? Center(child: CircularProgressIndicator())
              : AirQualityCityView(cityName: '현재위치', tmX: tmX, tmY: tmY),
    );
  }
}


