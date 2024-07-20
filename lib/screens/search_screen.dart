import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:blog/models/blog.dart';
import 'package:blog/services/blog_service.dart';
import 'package:blog/widgets/detailsblogview.dart';
import '../services/auth_service.dart';
import '../widgets/blog_card.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<Blog> _allBlogs = [];
  List<Blog> _filteredBlogs = [];
  TextEditingController _searchController = TextEditingController();
  List<String> _selectedCategories = [];
  List<String> _selectedTags = [];

  final List<String> _categories = [
    'Programming',
    'Sports',
    'Bollywood',
    'Hollywood',
    'Tech',
    'Health',
    'Science',
  ];

  final List<String> _tags = [
    'Flutter',
    'Dart',
    'Football',
    'Cricket',
    'Movies',
    'Music',
    'Technology',
    'Fitness',
    'Research',
  ];

  @override
  void initState() {
    super.initState();
    _loadBlogs();
  }

  void _loadBlogs() {
    final blogService = Provider.of<BlogService>(context, listen: false);
    blogService.getAllBlogs().listen((blogs) {
      setState(() {
        _allBlogs = blogs;
        _filteredBlogs = blogs; // Initialize filteredBlogs with all blogs
      });
    }, onError: (e) {
      print('Error loading blogs: $e');
    });
  }

  void _searchBlogs(String query) {
    List<Blog> searchResults = _allBlogs.where((blog) {
      final titleLower = blog.title.toLowerCase();
      final searchLower = query.toLowerCase();
      final matchesCategory = _selectedCategories.isEmpty || _selectedCategories.any((category) => blog.categories.contains(category));
      final matchesTag = _selectedTags.isEmpty || blog.tags.any((tag) => _selectedTags.contains(tag));

      return titleLower.contains(searchLower) && matchesCategory && matchesTag;
    }).toList();

    setState(() {
      _filteredBlogs = searchResults;
    });
  }

  void _showFilterSelector() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Select Categories and Tags'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Categories',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: _categories.map((category) {
                        final isSelected = _selectedCategories.contains(category);
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selectedCategories.remove(category);
                              } else {
                                _selectedCategories.add(category);
                              }
                            });
                          },
                          child: Chip(
                            label: Text(category),
                            backgroundColor: isSelected ? Colors.blue : Colors.grey[200],
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Tags',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: _tags.map((tag) {
                        final isSelected = _selectedTags.contains(tag);
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selectedTags.remove(tag);
                              } else {
                                _selectedTags.add(tag);
                              }
                            });
                          },
                          child: Chip(
                            label: Text(tag),
                            backgroundColor: isSelected ? Colors.blue : Colors.grey[200],
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _searchBlogs(_searchController.text);
                  },
                  child: Text('OK', style: TextStyle(color: Colors.blue)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Search Blogs'),
      //   backgroundColor: Colors.white,
      // ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: _searchBlogs,
                    decoration: InputDecoration(
                      hintText: 'Search blogs...',
                      prefixIcon: Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _searchBlogs('');
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _showFilterSelector,
                  style: ElevatedButton.styleFrom(
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(12),
                  ),
                  child: Icon(Icons.filter_list),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredBlogs.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: BlogCard(
                    blog: _filteredBlogs[index],
                    actions: [],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
