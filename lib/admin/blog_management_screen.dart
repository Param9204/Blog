import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:blog/models/blog.dart';
import 'package:blog/services/blog_service.dart';

class BlogsManagementScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final blogService = Provider.of<BlogService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Blogs Management'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<List<Blog>>(
          stream: blogService.getAllBlogs(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No blogs found.'));
            }

            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Blog blog = snapshot.data![index];
                return _buildBlogCard(context, blog);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildBlogCard(BuildContext context, Blog blog) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: Icon(Icons.article, size: 40),
        title: Text(
          blog.title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Text('By: ${blog.authorEmail}'),
        trailing: IconButton(
          icon: Icon(Icons.delete, color: Colors.redAccent),
          onPressed: () {
            _showDeleteBlogDialog(context, blog.id);
          },
        ),
      ),
    );
  }

  void _showDeleteBlogDialog(BuildContext context, String blogId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Blog?'),
          content: Text('Are you sure you want to delete this blog?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteBlog(context, blogId);
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteBlog(BuildContext context, String blogId) {
    final blogService = Provider.of<BlogService>(context, listen: false);
    blogService.deleteBlog(blogId).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Blog deleted successfully.')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete blog: $error')),
      );
    });
  }
}
