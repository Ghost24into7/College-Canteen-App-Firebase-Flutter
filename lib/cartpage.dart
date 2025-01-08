import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'checkout.dart'; // Import the file where CheckoutPage is defined
import 'package:firebase_auth/firebase_auth.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late User _user;
  late Map<String, int> _cartItemsMap = {};
  late List<Map<String, dynamic>> _dishesList = [];
  late String _userName = '';
  late String _userRole = '';

  @override
  void initState() {
    super.initState();
    _getUser();
  }

  void _getUser() async {
    _user = FirebaseAuth.instance.currentUser!;
    await _getUserDetails();
    _fetchCartItems();
  }

  Future<void> _getUserDetails() async {
    DocumentSnapshot userSnapshot =
    await FirebaseFirestore.instance.collection('users').doc(_user.uid).get();
    Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;
    setState(() {
      _userName = userData['name'];
      _userRole = userData['role'];
    });
  }

  void _fetchCartItems() async {
    DocumentSnapshot cartSnapshot =
    await FirebaseFirestore.instance.collection('cart').doc(_user.uid).get();

    if (cartSnapshot.exists) {
      setState(() {
        _cartItemsMap = Map<String, int>.from(cartSnapshot.data() as Map<String, dynamic>);
      });
      _fetchDishes();
    }
  }

  void _fetchDishes() async {
    QuerySnapshot dishesSnapshot =
    await FirebaseFirestore.instance.collection('dishes').get();
    setState(() {
      _dishesList = dishesSnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
      ),
      body: _cartItemsMap.isEmpty
          ? Center(
        child: Text('No items in cart'),
      )
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _cartItemsMap.length,
              itemBuilder: (context, index) {
                final itemName = _cartItemsMap.keys.elementAt(index);
                final itemQuantity = _cartItemsMap.values.elementAt(index);
                final dishData = _dishesList.firstWhere(
                      (dish) => dish['dishName'] == itemName,
                  orElse: () => {},
                );

                if (dishData.isEmpty) {
                  return ListTile(
                    title: Text(itemName),
                    subtitle: Text('Quantity: $itemQuantity'),
                  );
                }

                final imageUrl = dishData['imageUrl'] as String?;
                final price = double.tryParse(dishData['price'] ?? '0.0') ?? 0.0;

                return ListTile(
                  title: Text(itemName),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Quantity: $itemQuantity'),
                      Text('Price: ₹${price.toStringAsFixed(2)}'),
                    ],
                  ),
                  leading: imageUrl != null
                      ? Image.network(
                    imageUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  )
                      : Icon(Icons.error),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => _updateQuantity(itemName, itemQuantity - 1),
                        icon: Icon(Icons.remove),
                      ),
                      IconButton(
                        onPressed: () => _updateQuantity(itemName, itemQuantity + 1),
                        icon: Icon(Icons.add),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          _buildTotalSection(),
          _buildButtonSection(context),
        ],
      ),
    );
  }

  Widget _buildTotalSection() {
    double totalAmount = _calculateTotalAmount();

    return ListTile(
      title: Text('Total: ₹${totalAmount.toStringAsFixed(2)}'),
    );
  }

  Widget _buildButtonSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            onPressed: () => _clearCart(context),
            child: Text('Clear Cart'),
          ),
          ElevatedButton(
            onPressed: () {
              _checkoutAndRedirect(context);
            },
            child: Text('Checkout'),
          ),
        ],
      ),
    );
  }

  void _checkoutAndRedirect(BuildContext context) async {
    // Store cart details in Firestore under "orders" collection
    Map<String, dynamic> orderData = {
      'userName': _userName,
      'userRole': _userRole,
      'totalAmount': _calculateTotalAmount(),
      'cartItems': _cartItemsMap,
    };

    await FirebaseFirestore.instance.collection('orders').doc(_user.uid).set(orderData);

    // Clear the cart
    _cartItemsMap.clear();
    await FirebaseFirestore.instance.collection('cart').doc(_user.uid).delete();

    // Navigate to CheckoutScreen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CheckoutScreen()),
    );
  }

  void _updateQuantity(String itemName, int newQuantity) {
    if (newQuantity > 0) {
      setState(() {
        _cartItemsMap[itemName] = newQuantity;
        FirebaseFirestore.instance.collection('cart').doc(_user.uid).set(_cartItemsMap);
      });
    } else {
      setState(() {
        _cartItemsMap.remove(itemName);
        FirebaseFirestore.instance.collection('cart').doc(_user.uid).set(_cartItemsMap);
      });
    }
  }

  void _clearCart(BuildContext context) {
    setState(() {
      _cartItemsMap.clear();
      FirebaseFirestore.instance.collection('cart').doc(_user.uid).delete();
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Cart cleared!')));
  }

  double _calculateTotalAmount() {
    double totalAmount = 0.0;
    _cartItemsMap.forEach((itemName, quantity) {
      final dishData = _dishesList.firstWhere(
            (dish) => dish['dishName'] == itemName,
        orElse: () => {},
      );

      if (dishData.isNotEmpty) {
        final price = double.tryParse(dishData['price'] ?? '0.0') ?? 0.0;
        totalAmount += price * quantity;
      }
    });
    return totalAmount;
  }
}
