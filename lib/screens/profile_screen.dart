import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:blog/services/auth_service.dart'; // Import AuthService

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.blue.shade900,
        elevation: 0, // No shadow at the app bar
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade900, Colors.blue.shade600],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 20),
              Center(
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 80,
                    color: Colors.blue.shade900,
                  ),
                ),
              ),

              SizedBox(height: 10),
              Card(
                color: Colors.white,
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Email:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        '${authService.user?.email ?? 'Not available'}',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  _logout(context);
                },
                child: Text(
                  'Logout',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _logout(BuildContext context) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.signOut();
    Navigator.of(context).pushReplacementNamed('/login');
  }
}
