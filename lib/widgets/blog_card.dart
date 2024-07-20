import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:blog/models/blog.dart';
import 'package:blog/services/auth_service.dart';
import 'package:blog/widgets/detailsblogview.dart';
import 'package:provider/provider.dart';
import '../services/blog_service.dart';
import '../services/offline_service.dart'; // Ensure this import

class BlogCard extends StatelessWidget {
  final Blog blog;
  final List<Widget> actions;

  const BlogCard({Key? key, required this.blog, required this.actions}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userEmail = blog.authorEmail; // Get author's email directly from blog

    return Card(
      elevation: 4.0,
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
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
                blog.title,
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Author: ${blog.authorEmail}'), // Display author's email
                  Text('Category: ${blog.categories.join(', ')}'),
                ],
              ),
              leading: CircleAvatar(
                backgroundImage: NetworkImage(blog.imageUrl),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.download),
                    onPressed: () async {
                      OfflineService offlineService = OfflineService();
                      await offlineService.saveBlogLocally(blog);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Blog downloaded for offline reading')));
                    },
                  ),
                  ...actions,
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                blog.content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          blog.likedBy.contains(userEmail) ? Icons.thumb_up : Icons.thumb_up_outlined,
                        ),
                        onPressed: () {
                          _toggleLike(context, blog, userEmail);
                        },
                      ),
                      Text('${blog.likes} Likes'),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          blog.dislikedBy.contains(userEmail) ? Icons.thumb_down : Icons.thumb_down_outlined,
                        ),
                        onPressed: () {
                          _toggleDislike(context, blog, userEmail);
                        },
                      ),
                      Text('${blog.dislikes} Dislikes'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleLike(BuildContext context, Blog blog, String userEmail) {
    final blogService = Provider.of<BlogService>(context, listen: false);
    if (blog.likedBy.contains(userEmail)) {
      blogService.removeLike(blog.id, userEmail);
    } else {
      blogService.addLike(blog.id, userEmail);
    }
  }

  void _toggleDislike(BuildContext context, Blog blog, String userEmail) {
    final blogService = Provider.of<BlogService>(context, listen: false);
    if (blog.dislikedBy.contains(userEmail)) {
      blogService.removeDislike(blog.id, userEmail);
    } else {
      blogService.addDislike(blog.id, userEmail);
    }
  }
}
