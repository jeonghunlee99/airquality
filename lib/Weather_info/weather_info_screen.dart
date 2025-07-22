import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../kakao_search_service.dart';
import '../place_search_delegate.dart';
import 'Weather_info_data.dart';

class WeatherInfoScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<WeatherInfoScreen> createState() => _WeatherInfoScreenState();
}

class _WeatherInfoScreenState extends ConsumerState<WeatherInfoScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  bool isSearching = false;
  List<Map<String, dynamic>> searchSuggestions = [];
  final KakaoSearchService _kakaoSearchService = KakaoSearchService();

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String keyword) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 300), () async {
      if (keyword.isEmpty) {
        setState(() {
          searchSuggestions = [];
        });
        return;
      }

      final results = await _kakaoSearchService.searchKeyword(keyword);
      setState(() {
        searchSuggestions = results;
      });
    });
  }

  void _startSearch() {
    setState(() {
      isSearching = true;
      searchSuggestions = [];
      _searchController.clear();
    });
  }

  void _stopSearch() {
    setState(() {
      isSearching = false;
      searchSuggestions = [];
      _searchController.clear();
    });
  }

  void _onSuggestionTap(Map<String, dynamic> place) {
    final placeName = place['place_name'] ?? '알 수 없는 장소';
    final lat = double.tryParse(place['y'] ?? '');
    final lon = double.tryParse(place['x'] ?? '');

    print('선택한 장소: $placeName, 위도: $lat, 경도: $lon');

    // TODO: lat, lon -> nx, ny 변환 및 날씨 조회 로직 추가

    _stopSearch();
  }

  @override
  Widget build(BuildContext context) {
    final weatherAsync = ref.watch(weatherProvider);


      return Scaffold(
        appBar: AppBar(
          title: const Text('날씨 정보'),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () async {
                final selectedPlace = await showSearch(
                  context: context,
                  delegate: PlaceSearchDelegate(),
                );

                if (selectedPlace != null) {
                  final lat = double.parse(selectedPlace['y']);
                  final lon = double.parse(selectedPlace['x']);

                  final grid = GridUtil.convertToGrid(lat, lon);

                  ref.read(nxProvider.notifier).state = grid['nx']!;
                  ref.read(nyProvider.notifier).state = grid['ny']!;
                }
              },
            )
          ],
        ),
      body: isSearching
          ? ListView.builder(
        itemCount: searchSuggestions.length,
        itemBuilder: (context, index) {
          final place = searchSuggestions[index];
          return ListTile(
            title: Text(place['place_name'] ?? ''),
            subtitle: Text(place['address_name'] ?? ''),
            onTap: () => _onSuggestionTap(place),
          );
        },
      )
          : RefreshIndicator(
        onRefresh: () async {
          await ref.refresh(weatherProvider.future);
        },
        child: weatherAsync.when(
          data: (weatherList) {
            if (weatherList.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  Center(child: Text('예보 데이터가 없습니다.')),
                ],
              );
            }

            final nowHour = DateTime.now().hour;
            final closest = weatherList.reduce((a, b) {
              final diffA =
              ((int.tryParse(a.time.split(":")[0]) ?? 0) - nowHour)
                  .abs();
              final diffB =
              ((int.tryParse(b.time.split(":")[0]) ?? 0) - nowHour)
                  .abs();
              return diffA < diffB ? a : b;
            });

            final remainingForecasts =
            weatherList.where((w) => w != closest).toList();

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Card(
                    color: Colors.blue.shade50,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${closest.time} 예보',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child:
                                Text('🌡️ 기온: ${closest.temp}°C'),
                              ),
                              Expanded(
                                child:
                                Text('💧 습도: ${closest.humidity}%'),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child:
                                Text('💨 풍속: ${closest.windSpeed} m/s'),
                              ),
                              Expanded(
                                child:
                                Text('🧭 풍향: ${closest.windDir}°'),
                              ),
                            ],
                          ),
                          Text('☁️ 하늘상태: ${_getSky(closest.sky)}'),
                          Text('🌧️ 강수형태: ${_getPty(closest.pty)}'),
                          Text('🌂 강수량: ${closest.pcp}'),
                          Text('📈 강수확률: ${closest.pop}%'),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: const Text(
                    '다른 시간 예보',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: remainingForecasts.length,
                    itemBuilder: (context, index) {
                      final item = remainingForecasts[index];
                      return Container(
                        width: 100,
                        margin:
                        const EdgeInsets.only(left: 8, right: 8),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              item.time,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text('🌡 ${item.temp}°'),
                            Text('💧 ${item.humidity}%'),
                            Text(_getSkyEmoji(item.sky)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
          loading: () =>
          const Center(child: CircularProgressIndicator()),
          error: (err, stack) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              Center(child: Text('오류 발생: $err')),
            ],
          ),
        ),
      ),
    );
  }
}

String _getSky(String code) {
  switch (code) {
    case '1':
      return '맑음';
    case '3':
      return '구름많음';
    case '4':
      return '흐림';
    default:
      return '-';
  }
}

String _getPty(String code) {
  switch (code) {
    case '0':
      return '없음';
    case '1':
      return '비';
    case '2':
      return '비/눈';
    case '3':
      return '눈';
    case '4':
      return '소나기';
    default:
      return '-';
  }
}

String _getSkyEmoji(String code) {
  switch (code) {
    case '1':
      return '☀️';
    case '3':
      return '⛅';
    case '4':
      return '☁️';
    default:
      return '❓';
  }
}
