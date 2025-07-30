import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/search_controller.dart';
import 'book_marks_data.dart';

final bookmarksProvider = StateProvider<List<Map<String, dynamic>>>(
  (ref) => [
    {
      'placeName': '서울특별시 중구 을지로 100',
      'latitude': 37.5665,
      'longitude': 126.9780,
    },
    {
      'placeName': '부산광역시 해운대구 우동 1234',
      'latitude': 35.1796,
      'longitude': 129.0756,
    },
  ],
);

class BookMarksScreen extends ConsumerStatefulWidget {
  const BookMarksScreen({super.key});

  @override
  ConsumerState<BookMarksScreen> createState() => _BookMarksScreenState();
}

class _BookMarksScreenState extends ConsumerState<BookMarksScreen> {
  late final CustomSearchController _searchController;

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
    final isSearching = ref.watch(isSearchingProvider);
    final searchSuggestions = ref.watch(searchSuggestionsProvider);
    final bookmarks = ref.watch(bookmarksProvider);

    return Scaffold(
      appBar: AppBar(
        title:
            isSearching
                ? TextField(
                  controller: _searchController.searchController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: '장소 검색',
                    border: InputBorder.none,
                  ),
                  onChanged: _searchController.onSearchChanged,
                )
                : const Text('즐겨찾기'),
        actions: [
          IconButton(
            icon: Icon(isSearching ? Icons.close : Icons.search),
            onPressed: () {
              if (isSearching) {
                _searchController.stopSearch();
              } else {
                _searchController.startSearch();
              }
            },
          ),
        ],
      ),
      body:
          isSearching
              ? ListView.builder(
                itemCount: searchSuggestions.length,
                itemBuilder: (context, index) {
                  final suggestion = searchSuggestions[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: SizedBox(
                      height: 80, // 기본보다 조금 더 높은 높이
                      child: ListTile(
                        title: Text(suggestion['place_name'] ?? ''),
                        subtitle: Text(suggestion['address_name'] ?? ''),
                        onTap: () {
                          final place = {
                            'placeName': suggestion['address_name'] ?? '',
                            'latitude': double.parse(suggestion['y']),
                            'longitude': double.parse(suggestion['x']),
                          };
                          final updatedBookmarks = [...bookmarks, place];
                          ref.read(bookmarksProvider.notifier).state =
                              updatedBookmarks;
                          _searchController.stopSearch();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('즐겨찾기에 추가되었습니다.')),
                          );
                        },
                      ),
                    ),
                  );
                },
              )
              : bookmarks.isEmpty
              ? const Center(child: Text('즐겨찾는 장소가 없습니다.'))
              : ListView.builder(
                itemCount: bookmarks.length,
                itemBuilder: (context, index) {
                  final bookmark = bookmarks[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      title: Text(bookmark['placeName']),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          final updatedBookmarks = [...bookmarks]
                            ..removeAt(index);
                          ref.read(bookmarksProvider.notifier).state =
                              updatedBookmarks;
                        },
                      ),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder:
                              (_) => AlertDialog(
                                title: Text(bookmark['placeName']),
                                content: SizedBox(
                                  width: double.maxFinite,
                                  child: _AirQualityAndWeatherDetails(
                                    latitude: bookmark['latitude'],
                                    longitude: bookmark['longitude'],
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed:
                                        () => Navigator.of(context).pop(),
                                    child: const Text('닫기'),
                                  ),
                                ],
                              ),
                        );
                      },
                    ),
                  );
                },
              ),
    );
  }
}

class _AirQualityAndWeatherDetails extends ConsumerWidget {
  final double latitude;
  final double longitude;

  const _AirQualityAndWeatherDetails({
    required this.latitude,
    required this.longitude,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final airQualityAsync = ref.watch(
      airQualityByLatLngProvider((lat: latitude, lng: longitude)),
    );

    return airQualityAsync.when(
      loading:
          () => const SizedBox(
            height: 100,
            child: Center(child: CircularProgressIndicator()),
          ),
      error: (error, _) => Text('대기질 정보 불러오기 실패: $error'),
      data: (data) {
        if (data.items.isEmpty) {
          return const Text('대기질 데이터가 없습니다.');
        }

        final item = data.items.first;

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('측정소: ${data.stationName}'),
            Text('데이터 시간: ${item.dataTime}'),
            const SizedBox(height: 8),
            Text('미세먼지(PM10): ${item.pm10Value} ㎍/㎥'),
            Text('초미세먼지(PM2.5): ${item.pm25Value} ㎍/㎥'),
            Text('오존(O₃): ${item.o3Value} ppm'),
            Text('이산화황(SO₂): ${item.so2Value} ppm'),
            Text('이산화질소(NO₂): ${item.no2Value} ppm'),
            Text('일산화탄소(CO): ${item.coValue} ppm'),
            // 필요시 추가 표시 가능
          ],
        );
      },
    );
  }
}

