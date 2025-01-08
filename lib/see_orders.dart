import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frcrce_canteen_app/feedbacks.dart';
import 'feedbacks.dart'; // Import the feedback page

class SeeOrdersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('See Orders'),
      ),
      body: OrderList(),
    );
  }
}

class OrderList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('order_pending').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text('No orders found.'),
          );
        }

        var orderDocs = snapshot.data!.docs;
        return ListView.builder(
          itemCount: orderDocs.length,
          itemBuilder: (context, index) {
            var order = orderDocs[index];
            return OrderCard(order: order);
          },
        );
      },
    );
  }
}

class OrderCard extends StatelessWidget {
  final QueryDocumentSnapshot order;

  const OrderCard({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var orderData = order.data() as Map<String, dynamic>;
    var status = orderData['status'];
    var userName = orderData['userName'];
    var totalAmount = orderData['totalAmount'];

    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => _showOrderDetails(context, order),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'User: $userName',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                'Status: $status',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                'Total: ₹$totalAmount',
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOrderDetails(BuildContext context, QueryDocumentSnapshot order) {
    showDialog(
      context: context,
      builder: (context) => OrderDetailsDialog(order: order),
    );
  }
}

class OrderDetailsDialog extends StatelessWidget {
  final QueryDocumentSnapshot order;

  const OrderDetailsDialog({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var orderData = order.data() as Map<String, dynamic>;
    var cartItems = orderData['cartItems'];
    var userName = orderData['userName'];
    var totalAmount = orderData['totalAmount'];

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Order Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Divider(),
            Text('User: $userName'),
            Text('Total Amount: ₹$totalAmount'),
            SizedBox(height: 8),
            Text(
              'Status:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(
              decoration: InputDecoration(
                hintText: 'Enter custom status',
              ),
              onSubmitted: (value) {
                _updateOrderStatus(context, value);
              },
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _markOrderAsCompleted(context),
              child: Text('Mark as Completed'),
            ),
          ],
        ),
      ),
    );
  }

  void _updateOrderStatus(BuildContext context, String newStatus) async {
    try {
      var orderId = order.id;

      await FirebaseFirestore.instance.collection('order_pending').doc(orderId).update({
        'status': newStatus,
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Status updated')));

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating status')));
      print('Error updating status: $e');
    }
  }

  void _markOrderAsCompleted(BuildContext context) async {
    try {
      var orderId = order.id;

      await FirebaseFirestore.instance.collection('order_pending').doc(orderId).update({
        'status': 'completed',
      });

      var orderData = order.data() as Map<String, dynamic>;

      await FirebaseFirestore.instance.collection('completed_orders').doc(orderId).set({
        ...orderData,
        'status': 'completed',
      });

      await FirebaseFirestore.instance.collection('order_pending').doc(orderId).delete();

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Order marked as completed')));

      Navigator.pop(context);

      // Show feedback banner after marking order as complete
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: GestureDetector(
            onTap: () {
              // Navigate to feedback page when banner is clicked
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FeedbacksPage()),
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.feedback, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Give Feedback',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
          backgroundColor: Colors.blue, // Change color as per your design
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error marking order as completed')));
      print('Error marking order as completed: $e');
    }
  }
}

void main() {
  runApp(MaterialApp(
    home: SeeOrdersPage(),
  ));
}
