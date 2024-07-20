import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:blog/admin/authservice.dart';
import 'admin_home_screen.dart';

class AdminRegisterScreen extends StatefulWidget {
  @override
  _AdminRegisterScreenState createState() => _AdminRegisterScreenState();
}

class _AdminRegisterScreenState extends State<AdminRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _email = '';
  String _password = '';

  void _register() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        final authService = Provider.of<Auth_Service>(context, listen: false);
        final userCredential = await authService.createUserWithEmailAndPassword(_email, _password);

        // Store the admin's name and email in Firestore
        await FirebaseFirestore.instance.collection('admins').doc(userCredential.user!.uid).set({
          'name': _name,
          'email': _email,
        });

        // Navigate to admin home screen after successful registration
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => AdminHomeScreen()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration Failed: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(' '),
        backgroundColor: Colors.blue.shade900,
        automaticallyImplyLeading: false,
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
          child: Center(
            child: SingleChildScrollView(
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 10,
                shadowColor: Colors.black.withOpacity(0.5),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Text(
                          'Admin Register',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade900,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 30),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Name',
                            prefixIcon: Icon(Icons.person, color: Colors.blue.shade900),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.blue.shade900),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.blue.shade900),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.blueAccent),
                            ),
                          ),
                          style: TextStyle(color: Colors.black),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                          onSaved: (value) => _name = value!,
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email, color: Colors.blue.shade900),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.blue.shade900),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.blue.shade900),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.blueAccent),
                            ),
                          ),
                          style: TextStyle(color: Colors.black),
                          validator: (value) {
                            if (value == null || !value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                          onSaved: (value) => _email = value!,
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock, color: Colors.blue.shade900),
                            suffixIcon: IconButton(
                              icon: Icon(
                                Icons.visibility,
                                color: Colors.blue.shade900,
                              ),
                              onPressed: () {},
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.blue.shade900),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.blue.shade900),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.blueAccent),
                            ),
                          ),
                          obscureText: true,
                          style: TextStyle(color: Colors.black),
                          validator: (value) {
                            if (value == null || value.length < 6) {
                              return 'Please enter a password with at least 6 characters';
                            }
                            return null;
                          },
                          onSaved: (value) => _password = value!,
                        ),
                        SizedBox(height: 30),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            elevation: 5,
                            padding: EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text('Register', style: TextStyle(fontSize: 18)),
                          onPressed: _register,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
