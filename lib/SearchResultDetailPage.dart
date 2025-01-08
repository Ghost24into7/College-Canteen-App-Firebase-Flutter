// search_result_detail_page.dart

import 'package:flutter/material.dart';

class SearchResultDetailPage extends StatelessWidget {
  final String searchResult;

  const SearchResultDetailPage({super.key, required this.searchResult});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Result Detail'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            searchResult,
            style: const TextStyle(fontSize: 24.0),
          ),
        ),
      ),
    );
  }
}
