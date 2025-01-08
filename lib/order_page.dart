import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({Key? key}) : super(key: key);

  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> with TickerProviderStateMixin {
  late Stream<DocumentSnapshot> _orderStream;
  late String _userId = '';

  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _getCurrentUserId();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );

    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.repeat(reverse: true);
  }

  void _getCurrentUserId() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _userId = user.uid;
        _orderStream = FirebaseFirestore.instance
            .collection('order_pending')
            .doc(_userId)
            .snapshots();
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Details'),
      ),
      body: _userId.isEmpty
          ? Center(
        child: CircularProgressIndicator(),
      )
          : StreamBuilder<DocumentSnapshot>(
        stream: _orderStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(
              child: Text('No order details found.'),
            );
          }

          var orderData = snapshot.data!.data() as Map<String, dynamic>;
          var cartItems = orderData['cartItems'] as Map<String, dynamic>; // Updated this line
          var status = orderData['status'] ?? '';
          var userRole = orderData['userRole'] ?? '';
          var userName = orderData['userName'] ?? '';
          var totalAmount = orderData['totalAmount'] ?? '';

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeTransition(
                  opacity: _animation,
                  child: Text(
                    'Order Status: $status',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 20),
                Text('Cart Items:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      var itemName = cartItems.keys.elementAt(index);
                      var itemQuantity = cartItems[itemName];
                      return ListTile(
                        title: Text(itemName),
                        subtitle: Text('Quantity: $itemQuantity'),
                      );
                    },
                  ),
                ),
                SizedBox(height: 20),
                Text('User Role: $userRole', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Text('User Name: $userName', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Text('Total Amount: \₹${totalAmount.toStringAsFixed(2)}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add your fun animation here
          _animationController.forward();
        },
        child: Icon(Icons.star),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: OrderPage(),
  ));
}
