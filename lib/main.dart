import 'package:blog/admin/authservice.dart';
import 'package:blog/admin/blog_management_screen.dart';
import 'package:blog/admin/user_management_screen.dart';
import 'package:blog/services/blog_adaptor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:blog/services/blog_service.dart';
import 'package:blog/services/auth_service.dart';
import 'package:blog/screens/login_screen.dart';
import 'package:blog/screens/register_screen.dart';
import 'package:blog/screens/home_screen.dart';
import 'package:blog/screens/explore_screen.dart';
import 'package:blog/screens/search_screen.dart';
import 'package:blog/screens/selection_screen.dart'; // Import the new screen
import 'package:blog/models/blog.dart';
import 'package:blog/screens/selection_screen.dart'; // Import selection screen
import 'package:blog/admin/admin_login_screen.dart'; // Import admin login screen
import 'package:blog/admin/admin_register_screen.dart'; // Import admin register screen
import 'package:blog/admin/admin_home_screen.dart';
import 'package:blog/admin/user_management_screen.dart';
import 'package:blog/admin/blog_management_screen.dart';// Import admin home screen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Hive.initFlutter();
  Hive.registerAdapter(BlogAdapter());

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => Auth_Service()),
        ChangeNotifierProvider(create: (_) => BlogService()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Your App Title',
        initialRoute: '/',
        routes: {
          '/': (context) => SelectionScreen(),
          '/login': (context) => LoginScreen(),
          '/register': (context) => RegisterScreen(),
          '/home': (context) => HomeScreen(),
          '/explore': (context) => ExploreScreen(),
          '/search': (context) => SearchScreen(),
          '/admin': (context) => AdminLoginScreen(),
          '/adminRegister': (context) => AdminRegisterScreen(),
          '/adminHome': (context) => AdminHomeScreen(),
          '/user-management': (context) => UsersManagementScreen(),
          '/blog-management': (context) => BlogsManagementScreen(),
          // Ensure these route names match the ones you use for navigation
        },
      ),
    );
  }
}
