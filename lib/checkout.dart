import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'menu_page.dart'; // Import your menu page file

class CheckoutScreen extends StatefulWidget {
  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  late User _user;
  late Map<String, dynamic> _orderData = {};
  late Map<String, dynamic> _cartItems = {};
  late String _userName = '';
  late String _userRole = '';
  late double _totalAmount = 0.0;
  late bool _isOnlinePaymentSelected = false;

  @override
  void initState() {
    super.initState();
    _getUser();
  }

  void _getUser() {
    _user = FirebaseAuth.instance.currentUser!;
    _fetchOrder();
  }

  void _fetchOrder() async {
    try {
      DocumentSnapshot orderSnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .doc(_user.uid)
          .get();

      if (orderSnapshot.exists) {
        setState(() {
          _orderData = orderSnapshot.data() as Map<String, dynamic>;
          _cartItems = _orderData['cartItems'];
          _totalAmount = (_orderData['totalAmount'] ?? 0.0).toDouble();
          _userName = _orderData['userName'];
          _userRole = _orderData['userRole'];
        });
      }
    } catch (error) {
      print('Error fetching order: $error');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Failed to fetch order. Please try again later.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  void _placeOrder() async {
    try {
      await FirebaseFirestore.instance
          .collection('order_pending')
          .doc(_user.uid)
          .set({
        'cartItems': _cartItems,
        'totalAmount': _totalAmount,
        'userName': _userName,
        'userRole': _userRole,
        'status': 'pending', // Add the 'status' field with value 'pending'
      });

      await FirebaseFirestore.instance.collection('orders').doc(_user.uid).delete();

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Success'),
            content: const Text('Your order has been placed successfully.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const MenuPage()), // Redirect to menu page
                  );
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (error) {
      print('Error placing order: $error');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Failed to place order. Please try again later.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Summary:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _cartItems.isEmpty
                  ? const Center(
                child: Text('No items in cart'),
              )
                  : ListView.builder(
                itemCount: _cartItems.length,
                itemBuilder: (context, index) {
                  final item = _cartItems.keys.toList()[index];
                  final quantity = _cartItems[item];
                  return ListTile(
                    title: Text(item),
                    subtitle: Text('Quantity: $quantity'),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Total Amount: ₹$_totalAmount',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'User Name: $_userName',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'User Role: $_userRole',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Payment Method:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                Radio(
                  value: false,
                  groupValue: _isOnlinePaymentSelected,
                  onChanged: (value) {
                    setState(() {
                      _isOnlinePaymentSelected = value as bool;
                    });
                  },
                ),
                const Text('Cash on Delivery'),
                Radio(
                  value: true,
                  groupValue: _isOnlinePaymentSelected,
                  onChanged: (value) {
                    setState(() {
                      _isOnlinePaymentSelected = value as bool;
                    });
                  },
                ),
                const Text('Online Payment'),
              ],
            ),
            const SizedBox(height: 20),
            _isOnlinePaymentSelected
                ? ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/pay');
              },
              child: const Text('Proceed to Pay'),
            )
                : ElevatedButton(
              onPressed: () {
                // Place order
                _placeOrder();
              },
              child: const Text('Place Order'),
            ),
          ],
        ),
      ),
    );
  }
}
