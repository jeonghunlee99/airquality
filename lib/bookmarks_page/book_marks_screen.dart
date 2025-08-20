import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/auth_service.dart';
import '../utils/search_controller.dart';
import '../utils/weather_code_utils.dart';
import 'book_marks_controll.dart';
import 'book_marks_data.dart';

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
    final bookmarksAsyncValue = ref.watch(bookmarksProvider);
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      backgroundColor:
          Theme.of(context).brightness == Brightness.light
              ? Colors.white
              : Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        forceMaterialTransparency: true,
        centerTitle: true,
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
      body: authState.when(
        data: (user) {
          if (user == null) {
            return const Center(
              child: Text(
                "로그인 후 즐겨찾기를 사용할 수 있습니다.",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            );
          }

          if (isSearching) {
            return ListView.builder(
              itemCount: searchSuggestions.length,
              itemBuilder: (context, index) {
                final suggestion = searchSuggestions[index];
                return ListTile(
                  title: Text(suggestion['place_name'] ?? ''),
                  subtitle: Text(suggestion['address_name'] ?? ''),
                  onTap: () async {
                    final place = {
                      'placeName': suggestion['address_name'] ?? '',
                      'latitude': double.parse(suggestion['y']),
                      'longitude': double.parse(suggestion['x']),
                    };

                    final controller = ref.read(bookmarksControllerProvider);

                    await controller.addBookmark(place);

                    _searchController.stopSearch();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        padding: EdgeInsets.zero,
                        behavior: SnackBarBehavior.floating,

                        content: Builder(
                          builder: (BuildContext context) {
                            final isDarkMode =
                                Theme.of(context).brightness == Brightness.dark;

                            final gradientColors =
                                isDarkMode
                                    ? [
                                      Colors.grey.shade900,
                                      Colors.blueGrey.shade800,
                                    ]
                                    : [Colors.white, const Color(0xFFB3E5FC)];

                            final borderColor =
                                isDarkMode
                                    ? Colors.blueGrey.shade700
                                    : Colors.blue.shade200;
                            final textColor =
                                isDarkMode ? Colors.white : Colors.black;

                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 15,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: gradientColors,
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: borderColor,
                                  width: 1.0,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withAlpha((255 * 0.7).round()),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.star,

                                    color:
                                        isDarkMode
                                            ? Colors.yellowAccent
                                            : Colors.lightBlue,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    '즐겨찾기에 추가되었습니다.',
                                    style: TextStyle(
                                      color: textColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            );
          } else {
            return bookmarksAsyncValue.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('에러 발생: $error')),
              data: (bookmarks) {
                if (bookmarks.isEmpty) {
                  return const Center(child: Text('즐겨찾는 장소가 없습니다.'));
                }
                return ListView.builder(
                  itemCount: bookmarks.length,
                  itemBuilder: (context, index) {
                    final bookmark = bookmarks[index];
                    final gradientColors =
                        Theme.of(context).brightness == Brightness.dark
                            ? [Colors.grey.shade900, Colors.blueGrey.shade800]
                            : [Colors.white, const Color(0xFFB3E5FC)];

                    return Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: gradientColors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        title: Text(
                          bookmark['placeName'],
                          style: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            final controller = ref.read(
                              bookmarksControllerProvider,
                            );

                            controller.deleteBookmark(bookmark['id']);
                          },
                        ),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder:
                                (_) => Dialog(
                                  insetPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 24,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: SizedBox(
                                    width: double.infinity,
                                    height:
                                        MediaQuery.of(context).size.height *
                                        0.9,
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                            24,
                                            24,
                                            24,
                                            8,
                                          ),
                                          child: Text(
                                            bookmark['placeName'],
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const Divider(height: 1),
                                        Expanded(
                                          child: SingleChildScrollView(
                                            padding: const EdgeInsets.all(16),
                                            child: _AirQualityAndWeatherDetails(
                                              latitude: bookmark['latitude'],
                                              longitude: bookmark['longitude'],
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                            0,
                                            0,
                                            0,
                                            16,
                                          ),
                                          child: TextButton(
                                            onPressed:
                                                () =>
                                                    Navigator.of(context).pop(),
                                            child: Text(
                                              '닫기',
                                              style: TextStyle(
                                                color:
                                                    Theme.of(
                                                              context,
                                                            ).brightness ==
                                                            Brightness.dark
                                                        ? Colors.white
                                                        : Colors.black,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            );
          }
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("에러 발생: $e")),
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
    final asyncData = ref.watch(
      airQualityAndWeatherProvider((lat: latitude, lng: longitude)),
    );

    return asyncData.when(
      loading:
          () => const SizedBox(
            height: 100,
            child: Center(child: CircularProgressIndicator()),
          ),
      error:
          (error, _) => Padding(
            padding: const EdgeInsets.all(16),
            child: Text('정보 불러오기 실패: $error'),
          ),
      data: (data) {
        final aq =
            data.airQualityItems.isNotEmpty ? data.airQualityItems.first : null;
        final item =
            data.weatherItems.isNotEmpty ? data.weatherItems.first : null;

        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (aq != null)
                _InfoCard(
                  title: '📍 대기질 정보',
                  subtitle: '측정소: ${data.stationName}',
                  children: [
                    _InfoTile('🕒 데이터 시간', aq.dataTime),
                    _InfoTile('미세먼지(PM10)', '${aq.pm10Value} ㎍/㎥'),
                    _InfoTile('초미세먼지(PM2.5)', '${aq.pm25Value} ㎍/㎥'),
                    _InfoTile('오존(O₃)', '${aq.o3Value} ppm'),
                    _InfoTile('이산화황(SO₂)', '${aq.so2Value} ppm'),
                    _InfoTile('이산화질소(NO₂)', '${aq.no2Value} ppm'),
                    _InfoTile('일산화탄소(CO)', '${aq.coValue} ppm'),
                  ],
                ),
              const SizedBox(height: 24),
              if (item != null)
                _InfoCard(
                  title: '🌤️ 날씨 예보',
                  subtitle: '🕒 시간: ${item.time}',
                  children: [
                    _InfoTile('🌡️ 기온', '${item.temp}°C'),
                    _InfoTile('💧 습도', '${item.humidity}%'),
                    _InfoTile('💨 풍속', '${item.windSpeed} m/s'),
                    _InfoTile('🧭 풍향', '${item.windDir}°'),
                    _InfoTile('☁️ 하늘 상태', getSky(item.sky)),
                    _InfoTile('🌧️ 강수형태', getPty(item.pty)),
                    _InfoTile('🌂 강수량', item.pcp),
                    _InfoTile('📈 강수확률', '${item.pop}%'),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> children;

  const _InfoCard({
    required this.title,
    required this.subtitle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              isDark
                  ? [Colors.grey.shade900, Colors.blueGrey.shade800]
                  : [Colors.white, const Color(0xFFB3E5FC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const Divider(height: 24, thickness: 1.2, color: Colors.black26),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;

  const _InfoTile(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}
