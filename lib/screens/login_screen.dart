import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:blog/services/auth_service.dart';
import 'package:blog/utils/validators.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  bool _obscurePassword = true;

  void _login() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        await Provider.of<AuthService>(context, listen: false)
            .signInWithEmailAndPassword(_email, _password);

        // Navigate to home screen after successful login
        Navigator.of(context).pushReplacementNamed('/home');
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Login Failed: ${e.toString()}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade900,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade900, Colors.blue.shade600],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Image.asset('assets/mamu.jpg', height: 120), // Add a logo or image
                SizedBox(height: 20),
                Text(
                  'Welcome Back!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.black54,
                        offset: Offset(3.0, 3.0),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Please login to your account',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 30),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 10,
                  shadowColor: Colors.black.withOpacity(0.3),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          CustomTextField(
                            label: 'Email',
                            icon: Icons.email,
                            onSaved: (value) => _email = value!,
                            validator: validateEmail,
                            isObscure: false,
                          ),
                          SizedBox(height: 20),
                          CustomTextField(
                            label: 'Password',
                            icon: Icons.lock,
                            onSaved: (value) => _password = value!,
                            validator: validatePassword,
                            isObscure: _obscurePassword,
                            togglePasswordVisibility: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          SizedBox(height: 20),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              elevation: 10,
                              padding: EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: Text('Login', style: TextStyle(fontSize: 18)),
                            onPressed: _login,
                          ),
                          SizedBox(height: 10),
                          TextButton(
                            child: Text(
                              'Register',
                              style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
                            ),
                            onPressed: () {
                              Navigator.of(context).pushReplacementNamed('/register');
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isObscure;
  final Function(String?) onSaved;
  final String? Function(String?)? validator;
  final VoidCallback? togglePasswordVisibility;

  const CustomTextField({
    required this.label,
    required this.icon,
    required this.onSaved,
    required this.validator,
    this.isObscure = false,
    this.togglePasswordVisibility,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue.shade900),
        suffixIcon: togglePasswordVisibility != null
            ? IconButton(
          icon: Icon(
            isObscure ? Icons.visibility : Icons.visibility_off,
            color: Colors.blue.shade900,
          ),
          onPressed: togglePasswordVisibility,
        )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.blue.shade900),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.blue.shade900),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.blueAccent),
        ),
        filled: true,
        fillColor: Colors.blue.shade50,
      ),
      obscureText: isObscure,
      style: TextStyle(color: Colors.black),
      validator: validator,
      onSaved: onSaved,
    );
  }
}
