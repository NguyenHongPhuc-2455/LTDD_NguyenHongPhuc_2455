import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/role_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  String _selectedRole = '';
  final _authService = AuthService();
  final _roleService = RoleService();
  bool _isLoading = false;
  List<String> _roles = [];

  @override
  void initState() {
    super.initState();
    _loadRoles();
  }

  Future<void> _loadRoles() async {
    try {
      final roles = await _roleService.getRolesPublic();
      setState(() {
        _roles = roles;
        if (_roles.isNotEmpty) {
          _selectedRole = _roles[0]; // Set default to first role
        }
      });
    } catch (e) {
      print('Error loading roles: $e');
      // Fallback to default roles
      setState(() {
        _roles = ['Admin', 'Khách hàng', 'Manager'];
        _selectedRole = _roles[0];
      });
    }
  }

  void _register() async {
    // Validate email
    if (!_emailController.text.endsWith('@gmail.com')) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Email must be a Gmail address')));
      return;
    }

    setState(() => _isLoading = true);
    final result = await _authService.register(
      _usernameController.text,
      _passwordController.text,
      _fullNameController.text,
      _selectedRole,
      _emailController.text,
    );
    setState(() => _isLoading = false);

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration Successful! Please Login.')),
      );
      Navigator.pop(context); // Go back to Login
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result['message'])));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.indigo.shade800, Colors.indigo.shade400],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.0),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.person_add_alt_1_rounded,
                      size: 64,
                      color: Colors.indigo,
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Create Account',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo,
                          ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Join us to manage your events',
                      style: TextStyle(color: Colors.grey),
                    ),
                    SizedBox(height: 32),
                    TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                      obscureText: true,
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _fullNameController,
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(Icons.badge_outlined),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email (@gmail.com)',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 16),
                    _roles.isEmpty
                        ? CircularProgressIndicator()
                        : DropdownButtonFormField<String>(
                            value: _selectedRole.isEmpty ? null : _selectedRole,
                            decoration: InputDecoration(
                              labelText: 'Role',
                              prefixIcon: Icon(Icons.work_outline),
                            ),
                            items: _roles.map((role) {
                              return DropdownMenuItem(
                                value: role,
                                child: Text(role),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedRole = value!;
                              });
                            },
                          ),
                    SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: _isLoading
                          ? Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                              onPressed: _selectedRole.isEmpty
                                  ? null
                                  : _register,
                              child: Text(
                                'REGISTER',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                    ),
                    SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('Already have an account? Login'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
