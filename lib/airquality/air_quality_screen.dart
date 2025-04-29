import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:proj4dart/proj4dart.dart';
import '../kakao_search_service.dart';
import '../widget/air_quality_city_view.dart';
import 'air_quality_data.dart';

import 'dart:async';

class CurrentLocationAirQualityScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<CurrentLocationAirQualityScreen> createState() =>
      _CurrentLocationAirQualityScreenState();
}

class _CurrentLocationAirQualityScreenState
    extends ConsumerState<CurrentLocationAirQualityScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  final KakaoSearchService _kakaoService = KakaoSearchService();
  List<Map<String, dynamic>> _searchSuggestions = [];

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
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
      _searchSuggestions.clear();
    });
  }

  Future<void> _initLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _setCoordinates(position.longitude, position.latitude);
    } catch (e) {
      print('위치 정보 오류: $e');
    }
  }

  void _setCoordinates(double lng, double lat) {
    final wgs84 = Projection.get('EPSG:4326')!;
    final tmMid = Projection.add(
      'EPSG:2097',
      '+proj=tmerc +lat_0=38 +lon_0=127 +k=1 +x_0=200000 +y_0=500000 +ellps=GRS80 +units=m +no_defs',
    );

    final input = Point(x: lng, y: lat);
    final tmPoint = wgs84.transform(tmMid, input);

    ref.read(tmXProvider.notifier).state = double.parse(
      tmPoint.x.toStringAsFixed(2),
    );
    ref.read(tmYProvider.notifier).state = double.parse(
      tmPoint.y.toStringAsFixed(2),
    );
  }

  void _onSearchChanged(String keyword) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    _debounce = Timer(Duration(milliseconds: 300), () async {
      if (keyword.isEmpty) {
        setState(() {
          _searchSuggestions = [];
        });
        return;
      }

      final results = await _kakaoService.searchKeyword(keyword);
      setState(() {
        _searchSuggestions = results;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final tmX = ref.watch(tmXProvider);
    final tmY = ref.watch(tmYProvider);

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: '주소 검색',
            border: InputBorder.none,
          ),
          onChanged: _onSearchChanged,
        )
            : Text('현재 위치 대기질'),
        actions: [
          _isSearching
              ? IconButton(icon: Icon(Icons.close), onPressed: _stopSearch)
              : IconButton(icon: Icon(Icons.search), onPressed: _startSearch),
        ],
      ),
      body: Column(
        children: [
          if (_isSearching && _searchSuggestions.isNotEmpty)
            ListView.builder(
              shrinkWrap: true,
              itemCount: _searchSuggestions.length > 5 ? 5 : _searchSuggestions.length,
              itemBuilder: (context, index) {
                final place = _searchSuggestions[index];
                return ListTile(
                  title: Text(place['place_name']),
                  subtitle: Text(place['address_name']),
                  onTap: () {
                    double lat = double.parse(place['y']);
                    double lng = double.parse(place['x']);
                    _setCoordinates(lng, lat);
                    _stopSearch(); // 검색 종료
                  },
                );
              },
            ),
          Expanded(
            child: _isSearching
                ? SizedBox.shrink() // 검색 중일 때는 아무것도 안 보여줌
                : (tmX == null || tmY == null
                ? Center(child: CircularProgressIndicator())
                : AirQualityCityView(cityName: '현재위치', tmX: tmX, tmY: tmY)),
          ),
        ],
      ),
    );
  }
}
