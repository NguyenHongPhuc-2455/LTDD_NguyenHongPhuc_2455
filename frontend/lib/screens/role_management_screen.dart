import 'package:flutter/material.dart';
import '../services/role_service.dart';

class RoleManagementScreen extends StatefulWidget {
  final String token;

  const RoleManagementScreen({super.key, required this.token});

  @override
  _RoleManagementScreenState createState() => _RoleManagementScreenState();
}

class _RoleManagementScreenState extends State<RoleManagementScreen> {
  final _roleService = RoleService();
  List<dynamic> _roles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRoles();
  }

  void _fetchRoles() async {
    try {
      final roles = await _roleService.getRoles(widget.token);
      setState(() {
        _roles = roles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load roles')));
    }
  }

  void _showRoleDialog({Map<String, dynamic>? role}) {
    final nameController = TextEditingController(
      text: role != null ? role['RoleName'] : '',
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(role == null ? 'Add Role' : 'Edit Role'),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(labelText: 'Role Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              bool success;
              if (role == null) {
                success = await _roleService.createRole(
                  widget.token,
                  nameController.text,
                );
              } else {
                success = await _roleService.updateRole(
                  widget.token,
                  role['RoleID'],
                  nameController.text,
                );
              }

              if (success) {
                Navigator.pop(context);
                _fetchRoles();
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Success')));
              } else {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Failed')));
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteRole(int id) async {
    final confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Delete'),
        content: Text('Are you sure you want to delete this role?'),
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
    );

    if (confirm == true) {
      final success = await _roleService.deleteRole(widget.token, id);
      if (success) {
        _fetchRoles();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Role deleted')));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to delete role')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manage Roles')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _roles.length,
              itemBuilder: (context, index) {
                final role = _roles[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(
                      role['RoleName'],
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showRoleDialog(role: role),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteRole(role['RoleID']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showRoleDialog(),
        backgroundColor: Colors.indigo,
        child: Icon(Icons.add),
      ),
    );
  }
}
