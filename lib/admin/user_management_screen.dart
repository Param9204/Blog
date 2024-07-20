import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:blog/models/user.dart';
import 'package:blog/services/blog_service.dart';
import 'package:blog/services/auth_service.dart';

class UsersManagementScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final blogService = Provider.of<BlogService>(context);
    final authService = Provider.of<AuthService>(context);
    final currentUserEmail = authService.user?.email;

    return Scaffold(
      appBar: AppBar(
        title: Text('Users Management'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (currentUserEmail != null) ...[
              Text(
                'Logged in as: $currentUserEmail',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 20),
            ],
            Expanded(
              child: StreamBuilder<List<User>>(
                stream: blogService.getUsers(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No users found.'));
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      User user = snapshot.data![index];
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 10),
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(16),
                          title: Text(
                            user.email ?? 'Email not available',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          subtitle: Text('User ID: ${user.id}'),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.redAccent),
                            onPressed: () {
                              _showDeleteUserDialog(context, user.email ?? '');
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteUserDialog(BuildContext context, String email) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete User?'),
          content: Text('Are you sure you want to delete this user?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteUser(context, email);
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteUser(BuildContext context, String email) {
    final blogService = Provider.of<BlogService>(context, listen: false);
    blogService.deleteUserByEmail(email).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User deleted successfully.')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete user: $error')),
      );
    });
  }
}
