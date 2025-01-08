/*import 'package:flutter/material.dart';
import 'package:your_app/recommendation.dart'; // Import the Recommendation Service

class MenuPage extends StatefulWidget {
  const MenuPage({Key? key}) : super(key: key);

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  RecommendationService _recommendationService = RecommendationService(); // Instantiate the Recommendation Service

  late List<String> recommendations = [];

  @override
  void initState() {
    super.initState();
    _generateRecommendations(); // Call method to generate recommendations
  }

  Future<void> _generateRecommendations() async {
    String userUid = ''; // Get the current user's UID (you may have already implemented this)
    List<String> generatedRecommendations =
    await _recommendationService.generateRecommendations(userUid);

    setState(() {
      recommendations = generatedRecommendations;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FRCRCE Canteen'),
        // Other app bar configurations...
      ),
      body: Column(
        children: [
          // Your existing menu items widget...
          // Add a section to display recommendations
          if (recommendations.isNotEmpty)
            _buildRecommendationsSection(),
        ],
      ),
      // Other scaffold configurations...
    );
  }

  Widget _buildRecommendationsSection() {
    return Column(
      children: [
        const SizedBox(height: 20),
        Text(
          'Recommendations for You',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        // Display recommendations as a list
        ListView.builder(
          shrinkWrap: true,
          itemCount: recommendations.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(recommendations[index]),
            );
          },
        ),
      ],
    );
  }
}*/
