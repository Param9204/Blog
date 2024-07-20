import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:blog/services/auth_service.dart';
import 'package:blog/admin/user_management_screen.dart';
import 'package:blog/admin/blog_management_screen.dart';
import 'package:blog/screens/login_screen.dart';

class AdminHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              authService.signOut();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Admin Dashboard',
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildGridItem(
                    context,
                    icon: Icons.person,
                    label: 'Manage Users',
                    onTap: () {
                      Navigator.of(context).pushNamed('/user-management');
                    },
                  ),
                  _buildGridItem(
                    context,
                    icon: Icons.article,
                    label: 'Manage Blogs',
                    onTap: () {
                      Navigator.of(context).pushNamed('/blog-management');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridItem(BuildContext context, {required IconData icon, required String label, required Function onTap}) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.lightBlueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Colors.white),
              SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
