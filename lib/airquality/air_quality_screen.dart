import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../kakao_search_service.dart';
import '../widget/air_quality_city_view.dart';
import 'air_quality_controller.dart';
import 'air_quality_data.dart';

import 'dart:async';



class CurrentLocationAirQualityScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<CurrentLocationAirQualityScreen> createState() =>
      _CurrentLocationAirQualityScreenState();
}

class _CurrentLocationAirQualityScreenState
    extends ConsumerState<CurrentLocationAirQualityScreen> {

  final TextEditingController _searchController = TextEditingController();
  final KakaoSearchService _kakaoService = KakaoSearchService();


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
    ref.read(isSearchingProvider.notifier).state = true;
  }

  void _stopSearch() {
    ref.read(isSearchingProvider.notifier).state = false;
    _searchController.clear();
    ref.read(searchSuggestionsProvider.notifier).state = [];
  }


  void _onSearchChanged(String keyword) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    _debounce = Timer(Duration(milliseconds: 300), () async {
      if (keyword.isEmpty) {
        ref.read(searchSuggestionsProvider.notifier).state = [];
        return;
      }

      final results = await _kakaoService.searchKeyword(keyword);
      ref.read(searchSuggestionsProvider.notifier).state = results;
    });
  }


  @override
  Widget build(BuildContext context) {
    final tmX = ref.watch(tmXProvider);
    final tmY = ref.watch(tmYProvider);

    final isSearching = ref.watch(isSearchingProvider);
    final searchSuggestions = ref.watch(searchSuggestionsProvider);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: isSearching
            ? TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: '주소 검색',
            border: InputBorder.none,
          ),
          onChanged: _onSearchChanged,
        )
            : Text('대기질 정보'),
        actions: [
          isSearching
              ? IconButton(icon: Icon(Icons.close), onPressed: _stopSearch)
              : IconButton(icon: Icon(Icons.search), onPressed: _startSearch),
        ],
      ),
      body: Column(
        children: [
          if (isSearching && searchSuggestions.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: searchSuggestions.length,
                itemBuilder: (context, index) {
                  final place = searchSuggestions[index];
                  return ListTile(
                    title: Text(place['place_name']),
                    subtitle: Text(place['address_name']),
                    onTap: () {
                      double lat = double.parse(place['y']);
                      double lng = double.parse(place['x']);
                      setCoordinates(ref, lng, lat);
                      _stopSearch();
                    },
                  );
                },
              ),
            ),
          if (!isSearching)
            Expanded(
              child: (tmX == null || tmY == null)
                  ? Center(child: CircularProgressIndicator())
                  : AirQualityCityView(cityName: '현재위치', tmX: tmX, tmY: tmY),
            ),
        ],
      ),
    );
  }
}
