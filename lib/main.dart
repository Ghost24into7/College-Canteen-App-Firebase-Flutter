import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:frcrce_canteen_app/account.dart';
import 'package:frcrce_canteen_app/add_dish.dart';
import 'package:frcrce_canteen_app/add_user.dart';
import 'package:frcrce_canteen_app/cartpage.dart';
import 'package:frcrce_canteen_app/chatbot.dart';
import 'package:frcrce_canteen_app/dashboard.dart';
import 'package:frcrce_canteen_app/order_page.dart';
import 'package:frcrce_canteen_app/pay.dart';
import 'package:frcrce_canteen_app/remove_dish.dart';
import 'package:frcrce_canteen_app/Display_users.dart';
import 'package:frcrce_canteen_app/menu_page.dart';
import 'package:frcrce_canteen_app/login_page.dart';
import 'package:frcrce_canteen_app/search.dart';
import 'package:frcrce_canteen_app/see_orders.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    // Replace with actual values
    options: const FirebaseOptions(
      apiKey: "AIzaSyAHoDHYb5f2LM1SBkDe4tn04IMGDDkzzlI",
      appId: "1:813866267059:android:f3357efbc6a662238cdbc6",
      messagingSenderId: "813866267059",
      projectId: "cann-505f7",
      storageBucket: "cann-505f7.appspot.com",
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      // Check the authentication state
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // If we are waiting for Firebase Auth to initialize, show a loading indicator
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        final User? user = snapshot.data;

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Canteen App',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            brightness: Brightness.dark,
            secondaryHeaderColor: Colors.tealAccent,
            scaffoldBackgroundColor: Colors.grey[900],
          ),
          initialRoute: '/login',
          routes: {
            '/menu': (context) => const MenuPage(),
            '/cart': (context) => const CartPage(),
            '/add_user': (context) => const AddUserPage(),
            '/display_user': (context) => const DisplayUsersPage(),
            '/profile': (context) => const ProfilePage(),
            '/login': (context) => const MyLogin(),
            '/add_dish': (context) => const AddDishPage(),
            '/remove_dish': (context) => const RemoveDishPage(),
            '/admin_portal': (context) => const AdminPortalScreen(),
            '/chatbot': (context) => const ChatbotScreen(),
            '/search': (context) => const SearchPage(),
            '/order': (context) => const OrderPage(),
            '/seeorder': (context) =>  SeeOrdersPage(),
            '/pay' : (context) => const Home(),
          },
        );
      },
    );
  }
}
