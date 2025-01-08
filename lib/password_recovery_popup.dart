import 'package:flutter/material.dart';

class PasswordRecoveryPopup extends StatelessWidget {
  final void Function() onRecover; // Update parameter type

  PasswordRecoveryPopup({super.key, required this.onRecover});

  final TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Recover Account'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: emailController,
            decoration: const InputDecoration(
              labelText: 'Enter Email',
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Call the onRecover function without arguments
              onRecover();
            },
            child: const Text('Recover'),
          ),
        ],
      ),
    );
  }
}