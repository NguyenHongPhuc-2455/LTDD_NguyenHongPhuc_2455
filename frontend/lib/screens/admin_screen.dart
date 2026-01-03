import 'package:flutter/material.dart';

class AdminScreen extends StatelessWidget {
  final String token;
  final String role;

  const AdminScreen({super.key, required this.token, required this.role});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.admin_panel_settings, size: 100, color: Colors.blue),
            SizedBox(height: 20),
            Text(
              'Welcome, $role!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('Manage your system resources here.'),
            SizedBox(height: 30),
            if (role == 'Admin') ...[
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/user_management',
                    arguments: token,
                  );
                },
                child: Text('Manage Users'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/role_management',
                    arguments: token,
                  );
                },
                child: Text('Manage Roles'),
              ),
              SizedBox(height: 10),
            ],
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/admin_all_events',
                  arguments: token,
                );
              },
              child: Text('Manage All Events'),
            ),
          ],
        ),
      ),
    );
  }
}
