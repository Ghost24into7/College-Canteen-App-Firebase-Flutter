import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frcrce_canteen_app/dashboard.dart';
import 'package:frcrce_canteen_app/menu_page.dart';
import 'package:frcrce_canteen_app/password_recovery_popup.dart';
import 'package:frcrce_canteen_app/password_recovery_screen.dart';

class MyLogin extends StatefulWidget {
  const MyLogin({Key? key}) : super(key: key);

  @override
  _MyLoginState createState() => _MyLoginState();
}

class _MyLoginState extends State<MyLogin> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  UserType _selectedUserType = UserType.student;
  String _loginMessage = '';
  late Timer _quoteTimer;
  int _quoteIndex = 0;
  final List<String> _quotes = [
    "I'm on a seafood diet. I see food and I eat it!",
    "Why did the tomato turn red? Because it saw the salad dressing!",
    "You can't live a full life on an empty stomach.",
    "Everything gets better with coffee.",
    "Life is short. Eat dessert first!",
    "Never trust a skinny cook.",
    "Good food is good mood.",
    "Food is our common ground, a universal experience.",
    "Eating is a necessity but cooking is an art.",
    "You don't need a silver fork to eat good food.",
    "I like food. I like eating. And I don't want to deprive myself of good food."
  ];

  @override
  void initState() {
    super.initState();
    _startQuoteTimer();
  }

  @override
  void dispose() {
    _quoteTimer.cancel();
    super.dispose();
  }

  void _startQuoteTimer() {
    _quoteTimer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      setState(() {
        _quoteIndex = (_quoteIndex + 1) % _quotes.length;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'FRCRCE Canteen Login',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.orangeAccent,
      ),
      body: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Text(
                  _quotes[_quoteIndex],
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                ListTile(
                  title: Text(
                    'Student',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _selectedUserType == UserType.student ? Colors.orange : Colors.black,
                    ),
                  ),
                  leading: Radio<UserType>(
                    value: UserType.student,
                    groupValue: _selectedUserType,
                    onChanged: (UserType? value) {
                      setState(() {
                        _selectedUserType = value!;
                      });
                    },
                  ),
                ),
                ListTile(
                  title: Text(
                    'Teacher',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _selectedUserType == UserType.teacher ? Colors.orange : Colors.black,
                    ),
                  ),
                  leading: Radio<UserType>(
                    value: UserType.teacher,
                    groupValue: _selectedUserType,
                    onChanged: (UserType? value) {
                      setState(() {
                        _selectedUserType = value!;
                      });
                    },
                  ),
                ),
                ListTile(
                  title: Text(
                    'Admin',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _selectedUserType == UserType.admin ? Colors.orange : Colors.black,
                    ),
                  ),
                  leading: Radio<UserType>(
                    value: UserType.admin,
                    groupValue: _selectedUserType,
                    onChanged: (UserType? value) {
                      setState(() {
                        _selectedUserType = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'College Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    backgroundColor: Colors.orangeAccent,
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  _loginMessage,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    _showRecoveryDialog();
                  },
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: Colors.orangeAccent,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
    String email = _emailController.text;
    String password = _passwordController.text;

    try {
      if (_selectedUserType == UserType.admin) {
        // Check if admin role is selected and use default credentials
        if (email == 'admin' && password == 'admin') {
          // If default admin credentials are entered, navigate to admin portal
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AdminPortalScreen()),
          );
          return; // Return to prevent further execution
        } else {
          // If default admin credentials are not entered, show error message
          setState(() {
            _loginMessage = 'Invalid credentials for admin.';
          });
          return; // Return to prevent further execution
        }
      }

      // For student and teacher roles, use Firestore authentication
      // Fetch user details from Firestore based on entered email
      QuerySnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').where('collegeMail', isEqualTo: email).get();
      if (userSnapshot.docs.isNotEmpty) {
        // User exists
        Map<String, dynamic> userData = userSnapshot.docs.first.data() as Map<String, dynamic>;
        String role = userData['role'];

        if ((_selectedUserType == UserType.student && role == 'student') ||
            (_selectedUserType == UserType.teacher && role == 'teacher')) {
          // Student or Teacher role selected and user role matches
          UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: email,
            password: password,
          );

          setState(() {
            _loginMessage = 'Login successful!';
          });
          await Future.delayed(const Duration(seconds: 2));

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MenuPage()),
          );
          return;
        }
      }

      setState(() {
        _loginMessage = 'Invalid credentials or user role.';
      });
    } catch (e) {
      setState(() {
        _loginMessage = 'Error: $e';
      });
    }
  }

  void _showRecoveryDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return PasswordRecoveryPopup(onRecover: _recoverAccount);
      },
    );
  }

  void _recoverAccount() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return PasswordRecoveryScreen(email: _emailController.text);
      },
    );
  }
}

enum UserType {
  student,
  teacher,
  admin,
}