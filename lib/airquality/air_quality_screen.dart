import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widget/air_quality_city_view.dart';
import 'air_quality_controller.dart';
import 'air_quality_data.dart';
import '../utils/search_controller.dart';

class CurrentLocationAirQualityScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<CurrentLocationAirQualityScreen> createState() =>
      _CurrentLocationAirQualityScreenState();
}

class _CurrentLocationAirQualityScreenState
    extends ConsumerState<CurrentLocationAirQualityScreen> {
  late CustomSearchController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = CustomSearchController(ref);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tmX = ref.watch(tmXProvider);
    final tmY = ref.watch(tmYProvider);

    final isSearching = ref.watch(isSearchingProvider);
    final searchSuggestions = ref.watch(searchSuggestionsProvider);
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        centerTitle: true,
        title:
            isSearching
                ? TextField(
                  controller: _searchController.searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: '주소 검색',
                    border: InputBorder.none,
                  ),
                  onChanged: _searchController.onSearchChanged,
                )
                : Text('대기질 정보'),
        actions: [
          isSearching
              ? IconButton(
                icon: Icon(Icons.close),
                onPressed: _searchController.stopSearch,
              )
              : IconButton(
                icon: Icon(Icons.search),
                onPressed: _searchController.startSearch,
              ),
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
                      _searchController.stopSearch();
                    },
                  );
                },
              ),
            ),
          if (!isSearching)
            Expanded(
              child:
                  (tmX == null || tmY == null)
                      ? Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                        child: AirQualityCityView(
                          cityName: '현재위치',
                          tmX: tmX,
                          tmY: tmY,
                        ),
                      ),
            ),
        ],
      ),
    );
  }
}
