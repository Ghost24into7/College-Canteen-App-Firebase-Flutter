import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({Key? key}) : super(key: key);

  @override
  _CompletedOrdersPageState createState() => _CompletedOrdersPageState();
}

class _CompletedOrdersPageState extends State<OrderHistoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Completed Orders'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('completed_orders')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error occurred while fetching data: ${snapshot.error}'),
            );
          }
          if (snapshot.hasData && snapshot.data!.exists) {
            var orderData = snapshot.data!.data() as Map<String, dynamic>;
            if (orderData['status'] == 'pending') {
              _updateOrderStatus();
            }
            return _buildOrderList(orderData);
          } else {
            return const Center(
              child: Text('No completed orders found.'),
            );
          }
        },
      ),
    );
  }

  void _updateOrderStatus() {
    FirebaseFirestore.instance
        .collection('completed_orders')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      'status': 'completed',
      'date': DateTime.now().toString().split(' ')[0], // Current date
      'time': DateTime.now().toString().split(' ')[1], // Current time
    });
  }

  Widget _buildOrderList(Map<String, dynamic> orderData) {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CartItemsPage(orderData['cartItems']),
                ),
              );
            },
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order Details',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'User Role: ${orderData['userRole']}',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'User Name: ${orderData['userName']}',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Total Amount: ${orderData['totalAmount']}',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Status: ${orderData['status']}',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class CartItemsPage extends StatelessWidget {
  final Map<String, dynamic> cartItems;

  const CartItemsPage(this.cartItems);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart Items'),
      ),
      body: ListView(
        children: cartItems.entries.map((entry) {
          return ListTile(
            title: Text(entry.key), // Assuming item name is the key
            subtitle: Text('Quantity: ${entry.value}'),
          );
        }).toList(),
      ),
    );
  }
}
