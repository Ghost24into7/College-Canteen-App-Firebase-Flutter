import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbacksPage extends StatelessWidget {
  const FeedbacksPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedbacks'),
      ),
      body: const FeedbacksList(),
    );
  }
}

class FeedbacksList extends StatelessWidget {
  const FeedbacksList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('feedback').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }
        if (snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('No feedbacks available.'),
          );
        }
        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var feedback = snapshot.data!.docs[index];
            return FeedbackItem(
              overallRating: feedback['overall_rating'],
              customFeedback: feedback['custom_feedback'],
            );
          },
        );
      },
    );
  }
}

class FeedbackItem extends StatelessWidget {
  final int overallRating;
  final String customFeedback;

  const FeedbackItem({
    Key? key,
    required this.overallRating,
    required this.customFeedback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10.0),
      elevation: 5.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Overall Rating: $overallRating',
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
              ],
            ),
            const SizedBox(height: 10.0),
            Text(
              'Feedback: $customFeedback',
              style: const TextStyle(
                fontSize: 16.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

