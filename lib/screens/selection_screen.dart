import 'package:flutter/material.dart';

class SelectionScreen extends StatefulWidget {
  @override
  _SelectionScreenState createState() => _SelectionScreenState();
}

class _SelectionScreenState extends State<SelectionScreen> {
  bool isUserButtonPressed = false;
  bool isAdminButtonPressed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade900, Colors.blue.shade600],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Welcome to Your Blog 😎',
                style: TextStyle(
                  fontSize: 36,
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
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 50),
              buildAnimatedButton(
                context,
                'User',
                Icons.person,
                Colors.blue,
                Colors.blueAccent,
                isUserButtonPressed,
                    () => setState(() => isUserButtonPressed = true),
                    () {
                  setState(() => isUserButtonPressed = false);
                  Navigator.pushNamed(context, '/login');
                },
                    () => setState(() => isUserButtonPressed = false),
              ),
              SizedBox(height: 30),
              buildAnimatedButton(
                context,
                'Admin',
                Icons.admin_panel_settings,
                Colors.red,
                Colors.redAccent,
                isAdminButtonPressed,
                    () => setState(() => isAdminButtonPressed = true),
                    () {
                  setState(() => isAdminButtonPressed = false);
                  Navigator.pushNamed(context, '/admin');
                },
                    () => setState(() => isAdminButtonPressed = false),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildAnimatedButton(
      BuildContext context,
      String text,
      IconData icon,
      Color color,
      Color accentColor,
      bool isPressed,
      VoidCallback onTapDown,
      VoidCallback onTapUp,
      VoidCallback onTapCancel,
      ) {
    return GestureDetector(
      onTapDown: (_) => onTapDown(),
      onTapUp: (_) => onTapUp(),
      onTapCancel: () => onTapCancel(),
      child: Transform.scale(
        scale: isPressed ? 0.95 : 1.0,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isPressed ? [accentColor.withOpacity(0.7), color.withOpacity(0.7)] : [accentColor, color],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30.0),
            boxShadow: isPressed
                ? []
                : [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: Offset(0, 6),
              ),
            ],
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 80),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 28, color: Colors.white),
              SizedBox(width: 12),
              Text(
                text,
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
