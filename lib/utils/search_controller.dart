import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'kakao_search_service.dart';

final isSearchingProvider = StateProvider<bool>((ref) => false);
final searchSuggestionsProvider = StateProvider<List<Map<String, dynamic>>>(
  (ref) => [],
);

Future<void> handleSearch(WidgetRef ref, String keyword) async {
  if (keyword.isEmpty) {
    ref.read(searchSuggestionsProvider.notifier).state = [];
    return;
  }

  final results = await KakaoSearchService().searchKeyword(keyword);
  ref.read(searchSuggestionsProvider.notifier).state = results;
}

class CustomSearchController {
  final WidgetRef ref;
  final TextEditingController searchController = TextEditingController();
  Timer? _debounce;

  CustomSearchController(this.ref);

  void startSearch() {
    ref.read(isSearchingProvider.notifier).state = true;
  }

  void stopSearch() {
    ref.read(isSearchingProvider.notifier).state = false;
    searchController.clear();
    ref.read(searchSuggestionsProvider.notifier).state = [];
  }

  void onSearchChanged(String keyword) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      handleSearch(ref, keyword);
    });
  }

  void dispose() {
    _debounce?.cancel();
    searchController.dispose();
  }
}
