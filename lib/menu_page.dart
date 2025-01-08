import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MenuPage());
}

class MenuItem {
  final String name;
  final String description;
  final double price;
  final String imageUrl;

  MenuItem({
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
  });
}

class MenuPage extends StatefulWidget {
  const MenuPage({Key? key}) : super(key: key);

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  late List<MenuItem> menuItems = [];
  late Stream<DocumentSnapshot<Object?>> _cartStream = const Stream.empty();
  MenuItem? _selectedMenuItem;

  late FirebaseFirestore _firestore;
  late DocumentReference _userCartDocument;
  late List<String> recommendations = []; // Add this line

  @override
  void initState() {
    super.initState();
    _firestore = FirebaseFirestore.instance;
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        String uid = user.uid;
        _userCartDocument = _firestore.collection('cart').doc(uid);
        getMenuItems();
        _cartStream = _userCartDocument.snapshots(); // Update cart stream
        _checkOrderStatus(uid); // Check order status when user logs in
        _fetchRecommendations(); // Fetch recommendations
      }
    });
  }

  Future<void> getMenuItems() async {
    try {
      QuerySnapshot querySnapshot =
      await _firestore.collection('dishes').get();

      List<MenuItem> items = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return MenuItem(
          name: data['dishName'],
          description: data['description'],
          price: double.parse(data['price'].toString()),
          imageUrl: data['imageUrl'],
        );
      }).toList();

      setState(() {
        menuItems = items;
      });
    } catch (e) {
      print('Error fetching menu items: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error fetching menu items. Please try again later.'),
        ),
      );
    }
  }

  Future<void> _checkOrderStatus(String uid) async {
    try {
      DocumentSnapshot orderSnapshot =
      await _firestore.collection('order_pending').doc(uid).get();
      if (orderSnapshot.exists) {
        Map<String, dynamic>? data =
        orderSnapshot.data() as Map<String, dynamic>?; // Explicit cast
        if (data != null && data.containsKey('status')) {
          String status = data['status'] as String; // Accessing 'status' field
          if (status == 'pending') {
            _showOrderPopup();
          }
        }
      }
    } catch (e) {
      print('Error checking order status: $e');
    }
  }

  void _showOrderPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Your order is pending!'),
          content: Text(
              'Your order is pending. Do you want to proceed to the order page?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/order');
              },
              child: Text('Order Page'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _fetchRecommendations() async {
    try {
      // Fetch recommendations from your recommendation service
      List<String> fetchedRecommendations = await RecommendationService().getRecommendations(); // Adjust this according to your recommendation service
      setState(() {
        recommendations = fetchedRecommendations;
      });
    } catch (e) {
      print('Error fetching recommendations: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'FRCRCE Canteen',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          _buildProfileButton(context),
          _buildCartIcon(context),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                return _buildMenuItemCard(context, menuItems[index]);
              },
            ),
          ),
          if (recommendations.isNotEmpty) _buildRecommendationsSection(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
        ],
        selectedItemColor: Colors.deepOrange,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.black,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/search');
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/chatbot');
        },
        child: const Icon(
          Icons.chat,
        ),
      ),
    );
  }

  Widget _buildMenuItemCard(BuildContext context, MenuItem item) {
    final bool isSelected = _selectedMenuItem == item;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedMenuItem = isSelected ? null : item;
          });
        },
        child: Card(
          color: isSelected ? Colors.orange[200] : Colors.orange[100],
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16.0)),
                child: Image.network(
                  item.imageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: TextStyle(
                        fontSize: isSelected ? 24 : 20,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.deepOrange : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Transform.scale(
                          scale: 1.2,
                          child: IconButton(
                            icon: const Icon(
                              Icons.add_circle,
                              color: Colors.deepOrange,
                              size: 30,
                            ),
                            onPressed: () {
                              addToCart(item);
                            },
                          ),
                        ),
                        Transform.scale(
                          scale: 1.2,
                          child: IconButton(
                            icon: const Icon(
                              Icons.remove_circle,
                              color: Colors.deepOrange,
                              size: 30,
                            ),
                            onPressed: () {
                              removeFromCart(item);
                            },
                          ),
                        ),
                        Text(
                          '₹${item.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.deepOrange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    if (isSelected)
                      Text(
                        item.description,
                        style: const TextStyle(
                          color: Colors.black,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileButton(BuildContext context) {
    return IconButton(
      icon: const Icon(
        Icons.person_outline,
        color: Colors.white,
      ),
      onPressed: () {
        Navigator.pushNamed(context, '/profile');
      },
    );
  }

  Widget _buildCartIcon(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Object?>>(
      stream: _cartStream,
      builder: (context, snapshot) {
        int itemCount = 0;
        if (snapshot.connectionState == ConnectionState.active &&
            snapshot.hasData) {
          Map<String, dynamic>? cartData =
              snapshot.data?.data() as Map<String, dynamic>? ?? {};

          // Calculate the total number of items in the cart
          itemCount = cartData.values.fold<int>(
              0, (prev, quantity) => prev + (quantity as int));
        }
        return Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.pushNamed(context, '/cart');
              },
              color: Colors.white,
            ),
            if (itemCount > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    itemCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  void addToCart(MenuItem item) async {
    try {
      // Check if the item already exists in the user's cart
      DocumentSnapshot<Object?> cartSnapshot = await _userCartDocument.get();
      Map<String, dynamic>? cartData =
          cartSnapshot.data() as Map<String, dynamic>? ?? {};

      if (cartData.containsKey(item.name)) {
        // If the item exists, increment its quantity
        await _userCartDocument.update({
          item.name: FieldValue.increment(1),
        });
      } else {
        // If the item doesn't exist, add it with quantity 1
        await _userCartDocument.set({
          item.name: 1,
        }, SetOptions(merge: true));
      }
    } catch (e) {
      print('Error adding item to cart: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error adding item to cart. Please try again later.'),
        ),
      );
    }
  }

  void removeFromCart(MenuItem item) async {
    try {
      // Check if the item already exists in the user's cart
      DocumentSnapshot<Object?> cartSnapshot = await _userCartDocument.get();
      Map<String, dynamic>? cartData =
          cartSnapshot.data() as Map<String, dynamic>? ?? {};

      if (cartData.containsKey(item.name) && cartData[item.name] > 1) {
        // If the item exists and its quantity is more than 1, decrement its quantity
        await _userCartDocument.update({
          item.name: FieldValue.increment(-1),
        });
      } else if (cartData.containsKey(item.name) && cartData[item.name] == 1) {
        // If the item exists and its quantity is 1, remove it from the cart
        await _userCartDocument.update({
          item.name: FieldValue.delete(),
        });
      }
    } catch (e) {
      print('Error removing item from cart: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
          Text('Error removing item from cart. Please try again later.'),
        ),
      );
    }
  }

  Widget _buildRecommendationsSection() {
    return Column(
      children: [
        const SizedBox(height: 20),
        Text(
          'Recommended for you',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: recommendations.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(recommendations[index]),
              onTap: () {
                // Handle recommendation item tap
              },
            );
          },
        ),
      ],
    );
  }
}

// RecommendationService class is assumed to be implemented separately
class RecommendationService {
  Future<List<String>> getRecommendations() async {
    // Fetch recommendations from some external service
    // This method should return a list of recommended items
    return []; // Placeholder, replace with actual implementation
  }
}
