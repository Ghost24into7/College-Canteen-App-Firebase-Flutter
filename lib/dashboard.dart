import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:frcrce_canteen_app/add_dish.dart';
import 'package:frcrce_canteen_app/add_user.dart';
import 'package:frcrce_canteen_app/completed_orders.dart';
import 'package:frcrce_canteen_app/feedbacks.dart';
import 'package:frcrce_canteen_app/orders.dart';
import 'package:frcrce_canteen_app/Display_users.dart';
import 'package:frcrce_canteen_app/remove_dish.dart';
import 'package:frcrce_canteen_app/see_orders.dart';

class AdminPortalScreen extends StatefulWidget {
  const AdminPortalScreen({Key? key}) : super(key: key);

  @override
  _AdminPortalScreenState createState() => _AdminPortalScreenState();
}

class _AdminPortalScreenState extends State<AdminPortalScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  late ValueNotifier<int> _onlineUsersCount;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _presenceRef =
  FirebaseDatabase.instance.reference().child('.info/connected');

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();

    _onlineUsersCount = ValueNotifier<int>(0);

    _presenceRef.onValue.listen((event) {
      int onlineUsersCount = _calculateOnlineUsers(event);
      _onlineUsersCount.value = onlineUsersCount;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _onlineUsersCount.dispose();
    super.dispose();
  }

  int _calculateOnlineUsers(event) {
    int onlineUsersCount = 0;
    Map<String, dynamic>? values = event.snapshot.value as Map<String, dynamic>?;

    if (values != null) {
      values.forEach((key, value) {
        if (value == true) {
          onlineUsersCount++;
        }
      });
    }
    return onlineUsersCount;
  }

  Future<void> _navigateToPage(BuildContext context, Widget page) async {
    try {
      // Navigate to specified page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => page),
      );
    } catch (error) {
      print(error);
    }
  }

  Widget _buildCategoryCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return FadeTransition(
      opacity: _animation,
      child: ScaleTransition(
        scale: _animation,
        child: Card(
          elevation: 8.0,
          color: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(
                    icon,
                    color: iconColor,
                    size: 36.0,
                  ),
                  const SizedBox(width: 20.0),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Admin Portal'),
          backgroundColor: Colors.deepPurple,
          actions: [
            IconButton(
              onPressed: () {
                _animationController.reset();
                _animationController.forward();
              },
              icon: const Icon(Icons.refresh),
            ),
            IconButton(
              onPressed: () async {
                await _auth.signOut();
                Navigator.pushReplacementNamed(context, '/login');
              },
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
        body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
    _buildCategoryCard(
    title: 'User Management',
    icon: Icons.person,
    iconColor: Colors.blue,
    backgroundColor: Colors.lightGreenAccent,
    onTap: () {},
    ),
    const SizedBox(height: 20.0),
    _buildSubcategoryCard(
    title: 'Add User',
    icon: Icons.person_add,
    iconColor: Colors.green,
    backgroundColor: Colors.lightGreenAccent,
    onTap: () => _navigateToPage(context, const AddUserPage()),
    ),
    const SizedBox(height: 10.0),
    _buildSubcategoryCard(
    title: 'Display User',
    icon: Icons.person_remove,
    iconColor: Colors.red,
    backgroundColor: Colors.redAccent,
    onTap: () => _navigateToPage(context, const DisplayUsersPage()),
    ),
    const SizedBox(height: 20.0),
    _buildCategoryCard(
    title: 'Menu Management',
    icon: Icons.restaurant_menu,
    iconColor: Colors.green,
    backgroundColor: Colors.lightGreenAccent,
    onTap: () {},
    ),
    const SizedBox(height: 20.0),
    _buildSubcategoryCard(
    title: 'Add Dish',
    icon: Icons.add_circle_outline,
    iconColor: Colors.green,
    backgroundColor: Colors.lightGreenAccent,
    onTap: () => _navigateToPage(context, const AddDishPage()),
    ),
    const SizedBox(height: 10.0),
    _buildSubcategoryCard(
    title: 'Remove Dish',
    icon: Icons.remove_circle_outline,
    iconColor: Colors.red,
    backgroundColor: Colors.redAccent,
    onTap: () => _navigateToPage(context, const RemoveDishPage()),
    ),
    const SizedBox(height: 20.0),
    _buildCategoryCard(
    title: 'Orders',
    icon: Icons.shopping_cart,
    iconColor: Colors.orange,
    backgroundColor: Colors.orangeAccent,
    onTap: () {},
    ),
    const SizedBox(height: 20.0),
    _buildSubcategoryCard(
    title: 'View Orders',
    icon: Icons.list_alt,
    iconColor: Colors.orange,
    backgroundColor: Colors.orangeAccent,
    onTap: () => _navigateToPage(context, SeeOrdersPage()),
    ),
    const SizedBox(height: 20.0),
    _buildSubcategoryCard(
    title: 'Completed Orders',
    icon: Icons.done_all,
    iconColor: Colors.purple,
    backgroundColor: Colors.greenAccent,
    onTap: () =>
    _navigateToPage(context, const CompletedOrdersPage()),
    ),
    const SizedBox(height: 20.0),
    _buildCategoryCard(
    title: 'Feedbacks',
    icon: Icons.feedback,
    iconColor: Colors.red,
    backgroundColor: Colors.redAccent,
      onTap: () => _navigateToPage(context, const FeedbacksPage()),
    ),
      const SizedBox(height: 20.0),
      ValueListenableBuilder<int>(
        valueListenable: _onlineUsersCount,
        builder: (context, count, _) {
          return Card(
            elevation: 8.0,
            color: Colors.lightBlueAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.analytics,
                        color: Colors.blue,
                        size: 36.0,
                      ),
                      const SizedBox(width: 20.0),
                      Text(
                        'Online Users: $count',
                        style: const TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () {
                      _animationController.reset();
                      _animationController.forward();
                    },
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ],
    ),
        ),
    );
  }

  Widget _buildSubcategoryCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        elevation: 8.0,
        color: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      icon,
                      color: iconColor,
                      size: 36.0,
                    ),
                    const SizedBox(width: 20.0),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ],
                ),
                const Icon(Icons.arrow_forward_ios, color: Colors.deepPurple),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
