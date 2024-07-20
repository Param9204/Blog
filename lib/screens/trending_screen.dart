import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:blog/services/blog_service.dart';
import 'package:blog/models/blog.dart';
import 'package:blog/widgets/blog_card.dart';

class TrendingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: Text('Trending Blogs')),
      body: StreamBuilder<List<Blog>>(
        stream: Provider.of<BlogService>(context).getAllBlogs(), // Fetch all blogs
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final blogs = snapshot.data ?? [];

          // Filter and sort blogs by the number of likes in descending order
          final likedBlogs = blogs.where((blog) => blog.likes > 0).toList();
          likedBlogs.sort((a, b) => b.likes.compareTo(a.likes));

          if (likedBlogs.isEmpty) {
            return Center(child: Text('No liked blogs found.'));
          }

          return ListView.builder(
            itemCount: likedBlogs.length,
            itemBuilder: (context, index) {
              return BlogCard(blog: likedBlogs[index], actions: [],);
            },
          );
        },
      ),
    );
  }
}
