import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:blog/services/blog_service.dart';
import 'package:blog/models/blog.dart';
import 'package:blog/widgets/detailsblogview.dart';
import 'package:blog/screens/edit_blog.dart';
import 'package:blog/services/auth_service.dart';

class ExploreScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.user;

    if (user == null) {
      return Scaffold(
        body: Center(
          child: Text('Please log in to see the blogs.'),
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.deepPurple,
            child: Center(
              child: Text(
                'Logged in as: ${user.email}',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Blog>>(
              stream: Provider.of<BlogService>(context).getBlogsByUser(user.id),
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
                    return GestureDetector(
                      onLongPress: () => _confirmDelete(context, blogs[index]),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailedBlogView(blog: blogs[index]),
                          ),
                        );
                      },
                      child: _buildBlogListItem(context, blogs[index]),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlogListItem(BuildContext context, Blog blog) {
    return Card(
      elevation: 5.0,
      margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailedBlogView(blog: blog),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.all(12.0),
              title: Text(
                blog.title ?? 'No Title',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.deepPurple),
              ),
              subtitle: FutureBuilder<String?>(
                future: _getAuthorEmail(blog.authorId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text('Loading...', style: TextStyle(color: Colors.grey));
                  } else if (snapshot.hasError) {
                    return Text('Error fetching email', style: TextStyle(color: Colors.red));
                  } else if (snapshot.hasData && snapshot.data != null) {
                    return Text(snapshot.data!, style: TextStyle(fontSize: 14.0, color: Colors.grey[600]));
                  } else {
                    return Text('Unknown Author', style: TextStyle(color: Colors.grey));
                  }
                },
              ),
              leading: FutureBuilder<String?>(
                future: _getImageUrl(blog.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircleAvatar(child: Icon(Icons.person));
                  } else if (snapshot.hasError) {
                    return CircleAvatar(child: Icon(Icons.person));
                  } else if (snapshot.hasData && snapshot.data != null) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(30.0),
                      child: Image.network(
                        snapshot.data!,
                        fit: BoxFit.cover,
                        width: 50.0,
                        height: 50.0,
                      ),
                    );
                  } else {
                    return CircleAvatar(child: Icon(Icons.person));
                  }
                },
              ),
              trailing: IconButton(
                icon: Icon(Icons.edit, color: Colors.deepPurple),
                onPressed: () {
                  _handleEdit(context, blog);
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                blog.content ?? 'No Content',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 16.0, color: Colors.grey[700]),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${blog.likes} Likes', style: TextStyle(fontSize: 14.0, color: Colors.deepPurple)),
                  Text('${blog.dislikes} Dislikes', style: TextStyle(fontSize: 14.0, color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> _getAuthorEmail(String? authorId) async {
    if (authorId == null) {
      return '';
    }

    try {
      final snapshot = await FirebaseFirestore.instance.collection('users').doc(authorId).get();
      if (snapshot.exists) {
        final data = snapshot.data();
        if (data != null && data.containsKey('email')) {
          return data['email'] as String?;
        } else {
          return '';
        }
      } else {
        return '';
      }
    } catch (e) {
      print('Error fetching author email: $e');
      return '';
    }
  }

  Future<String?> _getImageUrl(String blogId) async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('blogs').doc(blogId).get();
      if (snapshot.exists) {
        return snapshot.data()!['imageUrl'] as String?;
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching blog image URL: $e');
      return null;
    }
  }

  void _handleEdit(BuildContext context, Blog blog) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditBlogScreen(blog: blog),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Blog blog) async {
    final confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Delete'),
        content: Text('Are you sure you want to delete this blog?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel', style: TextStyle(color: Colors.deepPurple)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await Provider.of<BlogService>(context, listen: false).deleteBlog(blog.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Blog deleted successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete blog: $e')),
        );
      }
    }
  }
}
