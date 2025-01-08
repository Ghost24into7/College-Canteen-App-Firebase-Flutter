import 'package:flutter/material.dart';
import 'package:frcrce_canteen_app/SearchResultDetailPage.dart';
import 'package:frcrce_canteen_app/menu_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _searchResults = [];
  bool _showResults = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<String>> _fetchSearchResults(String query) async {
    setState(() {
      _isLoading = true;
    });

    final response = await http.get(Uri.parse('https://api.example.com/search?query=$query'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<String>.from(data['results']);
    } else {
      throw Exception('Failed to load search results');
    }
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      _showResults = query.isNotEmpty;
      _isLoading = true;
    });

    try {
      final results = await _fetchSearchResults(query);
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error: $e');
    }
  }

  void _onSearchResultTap(String result) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchResultDetailPage(searchResult: result),
      ),
    );
  }

  void _navigateToHome() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MenuPage(),
      ),
    );
  }

  void _navigateToSearch() {
    // Navigate to search page
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: (value) {
                // Debouncing
                Future.delayed(const Duration(milliseconds: 500), () {
                  _performSearch(value);
                });
              },
            ),
          ),
          _isLoading
              ? const Center(
            child: CircularProgressIndicator(),
          )
              : _showResults
              ? Expanded(
            child: _searchResults.isNotEmpty
                ? ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    _onSearchResultTap(_searchResults[index]);
                  },
                  child: Card(
                    elevation: 2.0,
                    margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    child: ListTile(
                      title: Text(
                        _searchResults[index],
                        style: const TextStyle(fontSize: 16.0),
                      ),
                    ),
                  ),
                );
              },
            )
                : Center(
              child: Text(
                _searchController.text.isEmpty ? 'Start typing to search' : 'No results found',
                style: const TextStyle(fontSize: 18.0),
              ),
            ),
          )
              : const SizedBox(),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              onPressed: _navigateToHome,
              icon: const Icon(Icons.home),
            ),
            IconButton(
              onPressed: _navigateToSearch,
              icon: const Icon(Icons.search),
            ),
          ],
        ),
      ),
    );
  }
}