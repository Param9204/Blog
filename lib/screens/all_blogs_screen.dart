import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:blog/models/blog.dart';
import 'package:blog/services/blog_service.dart';
import 'package:blog/widgets/blog_card.dart';

class AllBlogsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final blogService = Provider.of<BlogService>(context);

    return Scaffold(
      // appBar: AppBar(
      //   title: Text('All Blogs'),
      // ),
      body: StreamBuilder<List<Blog>>(
        stream: blogService.getAllBlogs(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          final blogs = snapshot.data ?? [];
          if (blogs.isEmpty) {
            return Center(child: Text('No blogs found.'));
          }
          return ListView.builder(
            itemCount: blogs.length,
            itemBuilder: (context, index) {
              return BlogCard(blog: blogs[index], actions: [],);
            },
          );
        },
      ),
    );
  }
}
