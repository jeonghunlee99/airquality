import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/search_controller.dart';
import 'Weather_info_data.dart';

class WeatherInfoScreen extends ConsumerStatefulWidget {
  const WeatherInfoScreen({super.key});

  @override
  ConsumerState<WeatherInfoScreen> createState() => _WeatherInfoScreenState();
}

int? selectedForecastIndex;

class _WeatherInfoScreenState extends ConsumerState<WeatherInfoScreen> {
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
    final nx = ref.watch(nxProvider);
    final ny = ref.watch(nyProvider);
    final weatherAsync = ref.watch(weatherProvider);
    final placeName = ref.watch(selectedPlaceNameProvider);
    final isSearching = ref.watch(isSearchingProvider);
    final searchSuggestions = ref.watch(searchSuggestionsProvider);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title:
            isSearching
                ? TextField(
                  controller: _searchController.searchController,
                  decoration: InputDecoration(
                    hintText: '주소 검색',
                    border: InputBorder.none,
                    suffixIcon: IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        _searchController.stopSearch();
                      },
                    ),
                  ),
                  autofocus: true,
                  onChanged: _searchController.onSearchChanged,
                )
                : Text('$placeName 날씨 예보'),
        actions: [
          if (!isSearching)
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                _searchController.startSearch();
              },
            ),
        ],
      ),
      body:
          isSearching
              ? ListView.builder(
                itemCount: searchSuggestions.length,
                itemBuilder: (context, index) {
                  final place = searchSuggestions[index];
                  return ListTile(
                    title: Text(place['place_name'] ?? ''),
                    subtitle: Text(place['address_name'] ?? ''),
                    onTap: () {
                      final lat = double.tryParse(place['y'] ?? '');
                      final lon = double.tryParse(place['x'] ?? '');
                      final placeName = place['place_name'] ?? '';

                      if (lat != null && lon != null) {
                        final grid = GridUtil.convertToGrid(lat, lon);
                        ref.read(nxProvider.notifier).state = grid['nx']!;
                        ref.read(nyProvider.notifier).state = grid['ny']!;
                        ref.read(selectedPlaceNameProvider.notifier).state =
                            placeName;

                        _searchController.stopSearch();
                      }
                    },
                  );
                },
              )
              : (nx == null || ny == null)
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                color: Colors.black,
                onRefresh: () => ref.refresh(weatherProvider.future),
                child: weatherAsync.when(
                  data: (weatherList) {
                    if (weatherList.isEmpty) {
                      return ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [Center(child: Text('예보 데이터가 없습니다.'))],
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
                                        child: Text(
                                          '🌡️ 기온: ${closest.temp}°C',
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          '💧 습도: ${closest.humidity}%',
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '💨 풍속: ${closest.windSpeed} m/s',
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          '🧭 풍향: ${closest.windDir}°',
                                        ),
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
                          height: 240,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: remainingForecasts.length,
                            itemBuilder: (context, index) {
                              final item = remainingForecasts[index];
                              final selectedIndex = ref.watch(
                                selectedForecastIndexProvider,
                              );
                              final isSelected = selectedIndex == index;

                              return GestureDetector(
                                onTap: () {
                                  final notifier = ref.read(
                                    selectedForecastIndexProvider.notifier,
                                  );
                                  notifier.state = isSelected ? null : index;
                                },
                                child: Container(
                                  width:
                                      isSelected
                                          ? MediaQuery.of(context).size.width -
                                              24 -
                                              16
                                          : 100,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 12,
                                  ),
                                  child:
                                      isSelected
                                          ? Card(
                                            color: Colors.blue.shade50,
                                            elevation: 3,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(16),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    '${item.time} 예보',
                                                    style: const TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          '🌡️ 기온: ${item.temp}°C',
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Text(
                                                          '💧 습도: ${item.humidity}%',
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          '💨 풍속: ${item.windSpeed} m/s',
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Text(
                                                          '🧭 풍향: ${item.windDir}°',
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    '☁️ 하늘상태: ${_getSky(item.sky)}',
                                                  ),
                                                  Text(
                                                    '🌧️ 강수형태: ${_getPty(item.pty)}',
                                                  ),
                                                  Text('🌂 강수량: ${item.pcp}'),
                                                  Text('📈 강수확률: ${item.pop}%'),
                                                ],
                                              ),
                                            ),
                                          )
                                          : Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: Colors.grey.shade300,
                                              ),
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  item.time,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text('🌡 ${item.temp}°'),
                                                const SizedBox(height: 4),
                                                Text('💧 ${item.humidity}%'),
                                                const SizedBox(height: 4),
                                                Text(_getSkyEmoji(item.sky)),
                                              ],
                                            ),
                                          ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                  loading:
                      () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) {
                    final isRetrying = ref.watch(retryLoadingProvider);

                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error, color: Colors.red, size: 48),
                          const SizedBox(height: 16),
                          const Text(
                            '오류가 발생했습니다.\n다시 시도해주세요.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 20),
                          isRetrying
                              ? const CircularProgressIndicator()
                              : ElevatedButton.icon(
                                onPressed: () async {
                                  ref
                                      .read(retryLoadingProvider.notifier)
                                      .state = true;

                                  // ignore: unused_result
                                  await ref.refresh(weatherProvider.future);

                                  ref
                                      .read(retryLoadingProvider.notifier)
                                      .state = false;
                                },
                                icon: const Icon(
                                  Icons.refresh,
                                  color: Colors.black,
                                ),
                                label: const Text(
                                  '다시 시도',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                        ],
                      ),
                    );
                  },
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
