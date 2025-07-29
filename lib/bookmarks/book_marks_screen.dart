import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/search_controller.dart';



final bookmarksProvider =
StateProvider<List<Map<String, dynamic>>>((ref) => [
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
]);

class BookMarksScreen extends ConsumerStatefulWidget {
  const BookMarksScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<BookMarksScreen> createState() =>
      _BookMarksScreenState();
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
        title: isSearching
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
      body: isSearching
          ? ListView.builder(
        itemCount: searchSuggestions.length,
        itemBuilder: (context, index) {
          final suggestion = searchSuggestions[index];
          return ListTile(
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
          );
        },
      )
          : bookmarks.isEmpty
          ? const Center(child: Text('즐겨찾는 장소가 없습니다.'))
          : ListView.builder(
        itemCount: bookmarks.length,
        itemBuilder: (context, index) {
          final bookmark = bookmarks[index];
          return ListTile(
            title: Text(bookmark['placeName']),
            trailing: IconButton(
              icon:
              const Icon(Icons.delete, color: Colors.red),
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
                builder: (_) => AlertDialog(
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
                      onPressed: () =>
                          Navigator.of(context).pop(),
                      child: const Text('닫기'),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _AirQualityAndWeatherDetails extends StatelessWidget {
  final double latitude;
  final double longitude;

  const _AirQualityAndWeatherDetails({
    Key? key,
    required this.latitude,
    required this.longitude,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text('대기질: 미세먼지 23㎍/㎥, 초미세먼지 15㎍/㎥, 오존 0.03ppm'),
        SizedBox(height: 8),
        Text('날씨: 맑음, 기온 25°C, 습도 60%, 풍속 2.5m/s'),
      ],
    );
  }
}

