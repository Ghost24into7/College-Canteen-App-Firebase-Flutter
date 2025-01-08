import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddUserPage extends StatefulWidget {
  const AddUserPage({super.key});

  @override
  _AddUserPageState createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController rollNoController = TextEditingController();
  final TextEditingController collegeMailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  String _selectedRole = 'student';
  bool _agreeToPrivacyPolicy = false;
  bool _isPasswordVisible = false;
  bool _passwordGenerated = false;

  String _generatedPassword = '';

  String _suggestStrongPassword() {
    List<String> characterSets = [
      'abcdefghijklmnopqrstuvwxyz',
      'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
      '0123456789',
      '!@#\$%^&*()'
    ];

    int length = 12;

    String password = '';
    for (int i = 0; i < length; i++) {
      String charSet = characterSets[i % characterSets.length];
      String character = charSet[Random().nextInt(charSet.length)];
      password += character;
    }

    return password;
  }

  void _generatePassword() {
    setState(() {
      _generatedPassword = _suggestStrongPassword();
      _passwordGenerated = true;
      passwordController.text = _generatedPassword;
      confirmPasswordController.text = _generatedPassword;
    });
  }

  void registerUser(BuildContext context) async {
    if (_agreeToPrivacyPolicy) {
      try {
        if (!_passwordGenerated) {
          _generatePassword();
        }

        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: collegeMailController.text,
          password: passwordController.text,
        );

        await FirebaseAuth.instance.sendPasswordResetEmail(email: collegeMailController.text);

        String userId = userCredential.user!.uid;
        String userCollection = _selectedRole == 'student' ? 'student' : 'teacher';

        // Saving user information in the selected role collection
        await FirebaseFirestore.instance.collection(userCollection).doc(collegeMailController.text).set({
          'name': nameController.text,
          'rollNo': rollNoController.text,
          'collegeMail': collegeMailController.text,
          'role': _selectedRole,
        });

        // Saving user information in the 'users' collection
        await FirebaseFirestore.instance.collection('users').doc(userId).set({
          'name': nameController.text,
          'collegeMail': collegeMailController.text,
          'role': _selectedRole,
        });

        // Creating subcollections for user
        await FirebaseFirestore.instance.collection(userCollection).doc(collegeMailController.text).collection('carts').doc('userCart').set({});
        await FirebaseFirestore.instance.collection(userCollection).doc(collegeMailController.text).collection('activities').doc('userActivities').set({});
        await FirebaseFirestore.instance.collection(userCollection).doc(collegeMailController.text).collection('completedOrders').doc('userCompletedOrders').set({});
        await FirebaseFirestore.instance.collection(userCollection).doc(collegeMailController.text).collection('orders').doc('userOrders').set({});
        await FirebaseFirestore.instance.collection(userCollection).doc(collegeMailController.text).collection('orderHistory').doc('userOrderHistory').set({});

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully registered! Password sent to your email.')),
        );

        if (_selectedRole == 'admin') {
          Navigator.of(context).pushReplacementNamed('/admin_screen');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error registering user: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please agree to the privacy policy!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add User'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 20.0),
              TextField(
                controller: rollNoController,
                decoration: const InputDecoration(labelText: 'Roll No.'),
              ),
              const SizedBox(height: 20.0),
              TextField(
                controller: collegeMailController,
                decoration: const InputDecoration(labelText: 'College Mail ID'),
              ),
              const SizedBox(height: 20.0),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                    icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                  ),
                ),
                obscureText: !_isPasswordVisible,
                onTap: () {
                  if (!_passwordGenerated) {
                    _generatePassword();
                  }
                },
              ),
              const SizedBox(height: 20.0),
              TextField(
                controller: confirmPasswordController,
                decoration: const InputDecoration(labelText: 'Confirm Password'),
                obscureText: true,
              ),
              const SizedBox(height: 20.0),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                onChanged: (String? value) {
                  setState(() {
                    _selectedRole = value!;
                  });
                },
                items: <String>['student', 'teacher', 'admin']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20.0),
              CheckboxListTile(
                title: const Text('Agree to Privacy Policy'),
                value: _agreeToPrivacyPolicy,
                onChanged: (value) {
                  setState(() {
                    _agreeToPrivacyPolicy = value!;
                  });
                },
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () => registerUser(context),
                child: const Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
