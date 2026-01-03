import 'package:flutter/material.dart';
import '../services/user_service.dart';

class UserManagementScreen extends StatefulWidget {
  final String token;

  const UserManagementScreen({super.key, required this.token});

  @override
  _UserManagementScreenState createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  late UserService _userService;
  List<dynamic> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _userService = UserService(widget.token);
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() => _isLoading = true);
    try {
      final users = await _userService.getUsers();
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _showUserDialog({Map<String, dynamic>? user}) async {
    final isEdit = user != null;
    final usernameController = TextEditingController(
      text: user?['Username'] ?? '',
    );
    final passwordController = TextEditingController();
    final fullNameController = TextEditingController(
      text: user?['FullName'] ?? '',
    );
    final emailController = TextEditingController(text: user?['Email'] ?? '');
    String selectedRole = user?['RoleName'] ?? 'Khách hàng';

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Edit User' : 'Add User'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isEdit)
                TextField(
                  controller: usernameController,
                  decoration: InputDecoration(labelText: 'Username'),
                ),
              if (!isEdit)
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
              TextField(
                controller: fullNameController,
                decoration: InputDecoration(labelText: 'Full Name'),
              ),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              DropdownButtonFormField<String>(
                value: selectedRole,
                items: ['Admin', 'Manager', 'Khách hàng']
                    .map(
                      (role) =>
                          DropdownMenuItem(value: role, child: Text(role)),
                    )
                    .toList(),
                onChanged: (value) => selectedRole = value!,
                decoration: InputDecoration(labelText: 'Role'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final userData = {
                  'fullName': fullNameController.text,
                  'email': emailController.text,
                  'role': selectedRole,
                };

                if (!isEdit) {
                  userData['username'] = usernameController.text;
                  userData['password'] = passwordController.text;
                  await _userService.createUser(userData);
                } else {
                  await _userService.updateUser(user['UserID'], userData);
                }

                Navigator.pop(context);
                _fetchUsers();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isEdit ? 'User updated' : 'User created'),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: Text(isEdit ? 'Update' : 'Create'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteUser(int id) async {
    if (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Delete User'),
            content: Text('Are you sure?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false) {
      try {
        await _userService.deleteUser(id);
        _fetchUsers();
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User Management')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showUserDialog(),
        child: Icon(Icons.add),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _users.length,
              itemBuilder: (context, index) {
                final user = _users[index];
                return Card(
                  margin: EdgeInsets.all(8),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(user['Username'][0].toUpperCase()),
                    ),
                    title: Text('${user['FullName']} (${user['Username']})'),
                    subtitle: Text(
                      '${user['RoleName']} - ${user['Email'] ?? "No Email"}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showUserDialog(user: user),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteUser(user['UserID']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
