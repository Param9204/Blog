import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:blog/screens/all_blogs_screen.dart';
import 'package:blog/screens/blog_composition_screen.dart';
import 'package:blog/screens/explore_screen.dart';
import 'package:blog/screens/trending_screen.dart';
import 'package:blog/screens/search_screen.dart';
import 'package:blog/screens/profile_screen.dart'; // Import your ProfileScreen here
import 'package:blog/services/auth_service.dart'; // Import AuthService

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _animationController;

  static List<Widget> _widgetOptions = <Widget>[
    AllBlogsScreen(), // Display AllBlogsScreen as the first screen
    BlogCompositionScreen(),
    ExploreScreen(),
    TrendingScreen(),
    SearchScreen()
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _animationController.reverse();
  }

  void _navigateToProfileScreen() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ProfileScreen(),
    ));
  }

  void _logout() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.signOut();
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Home',
          style: TextStyle(color: Colors.black),

        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.person, color: Colors.black),
            onPressed: _navigateToProfileScreen,
          ),
          SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: Container(
        margin: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedFontSize: 14,
            unselectedFontSize: 12,
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.edit),
                label: 'Compose',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.explore),
                label: 'Explore',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.trending_up),
                label: 'Trending',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label: 'Search',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.blue,
            unselectedItemColor: Colors.blueGrey,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
              _animationController.forward(from: 0.0);
            },
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(
      primarySwatch: Colors.blue,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    ),
    home: HomeScreen(),
  ));
}
