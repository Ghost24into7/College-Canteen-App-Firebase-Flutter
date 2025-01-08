import 'package:flutter/material.dart';

class PasswordRecoveryScreen extends StatelessWidget {
  final String email;
  final TextEditingController otpController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();

  PasswordRecoveryScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Password Recovery'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextFormField(
              controller: otpController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Enter OTP',
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Enter New Password',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _verifyOTPAndResetPassword(context);
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.orangeAccent),
              ),
              child: const Text('Confirm'),
            ),
          ],
        ),
      ),
    );
  }

  void _verifyOTPAndResetPassword(BuildContext context) {
    String otp = otpController.text;
    String newPassword = newPasswordController.text;

    // Placeholder logic to verify OTP and reset password
    // In a real app, you would replace this with your own implementation
    // For now, let's assume the OTP is hardcoded as '123456'
    if (otp == '123456') {
      // If OTP is correct, simulate resetting the password
      // Here you would typically call your backend API to reset the password
      // For now, let's just print a message
      print('Password reset successful for $email');

      // Navigate the user back to the login page
      Navigator.pop(context);
    } else {
      // If OTP is incorrect, show an error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Incorrect OTP. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
