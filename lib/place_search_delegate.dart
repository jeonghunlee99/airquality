import 'package:flutter/material.dart';

import 'kakao_search_service.dart';

class PlaceSearchDelegate extends SearchDelegate<Map<String, dynamic>?> {
  final KakaoSearchService _searchService = KakaoSearchService();

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _searchService.searchKeyword(query),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final results = snapshot.data!;

        if (results.isEmpty) return const Center(child: Text('검색 결과 없음'));

        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final place = results[index];
            return ListTile(
              title: Text(place['place_name'] ?? '이름 없음'),
              subtitle: Text(place['address_name'] ?? ''),
              onTap: () => close(context, place),
            );
          },
        );
      },
    );
  }
}
