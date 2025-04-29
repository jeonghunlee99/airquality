import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../kakao_search_service.dart';
import '../widget/air_quality_city_view.dart';
import 'air_quality_data.dart';

import 'dart:async';

import 'location_helper.dart';

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
    initLocation(ref);
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
                    setCoordinates(ref,lng, lat);
                    _stopSearch();
                  },
                );
              },
            ),
          Expanded(
            child: _isSearching
                ? SizedBox.shrink()
                : (tmX == null || tmY == null
                ? Center(child: CircularProgressIndicator())
                : AirQualityCityView(cityName: '현재위치', tmX: tmX, tmY: tmY)),
          ),
        ],
      ),
    );
  }
}
