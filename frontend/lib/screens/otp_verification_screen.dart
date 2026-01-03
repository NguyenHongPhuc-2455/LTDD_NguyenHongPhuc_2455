import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class OTPVerificationScreen extends StatefulWidget {
  const OTPVerificationScreen({super.key});

  @override
  _OTPVerificationScreenState createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final _otpController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    final userId = args['userId'] as int;
    final email = args['email'] as String;

    return Scaffold(
      appBar: AppBar(title: Text('Enter OTP Code')),
      body: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.email, size: 64, color: Colors.indigo),
            SizedBox(height: 24),
            Text(
              'OTP Sent to:',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              email,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 32),
            TextField(
              controller: _otpController,
              decoration: InputDecoration(
                labelText: 'Enter 6-Digit OTP',
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, letterSpacing: 8),
            ),
            SizedBox(height: 24),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () async {
                      setState(() => _isLoading = true);
                      final result = await _authService.verifyOTP(
                        userId,
                        _otpController.text,
                      );
                      setState(() => _isLoading = false);

                      if (result['success']) {
                        final token = result['data']['token'];
                        final role = result['data']['role'];

                        if (role == 'Admin' || role == 'Manager') {
                          Navigator.pushReplacementNamed(
                            context,
                            '/admin',
                            arguments: {'token': token, 'role': role},
                          );
                        } else {
                          Navigator.pushReplacementNamed(
                            context,
                            '/home',
                            arguments: token,
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(result['message'])),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                    ),
                    child: Text('Verify OTP'),
                  ),
          ],
        ),
      ),
    );
  }
}
