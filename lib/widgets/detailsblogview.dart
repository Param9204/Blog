import 'package:flutter/material.dart';
import 'package:blog/models/blog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:blog/models/user.dart';
import 'package:blog/services/auth_service.dart';
import 'package:provider/provider.dart';

class DetailedBlogView extends StatefulWidget {
  final Blog blog;

  const DetailedBlogView({Key? key, required this.blog}) : super(key: key);

  @override
  _DetailedBlogViewState createState() => _DetailedBlogViewState();
}

class _DetailedBlogViewState extends State<DetailedBlogView> {
  late int _likes;
  late int _dislikes;

  @override
  void initState() {
    _likes = widget.blog.likes;
    _dislikes = widget.blog.dislikes;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>(); // Use context.watch instead of Provider.of

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.blog.title),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.blog.imageUrl != null)
                Image.network(
                  widget.blog.imageUrl!,
                  fit: BoxFit.cover,
                ),
              SizedBox(height: 16.0),
              Text(
                widget.blog.title,
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              FutureBuilder<User?>(
                future: _getAuthor(widget.blog.authorId, authService),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text('Loading...');
                  } else if (snapshot.hasError ||
                      !snapshot.hasData ||
                      snapshot.data == null) {
                    return Text('By Unknown Author');
                  } else {
                    return Text('By ${snapshot.data!.email}');
                  }
                },
              ),
              SizedBox(height: 16.0),
              Text(
                'Category: ${widget.blog.categories.join(", ")}',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              Wrap(
                spacing: 8.0,
                children: widget.blog.tags
                    .map((tag) => Chip(label: Text(tag)))
                    .toList(),
              ),
              SizedBox(height: 16.0),
              Text(
                widget.blog.content,
                style: TextStyle(fontSize: 18.0),
              ),
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.thumb_up),
                    onPressed: () {
                      _handleLike(authService);
                    },
                  ),
                  Text('$_likes'),
                  SizedBox(width: 16.0),
                  IconButton(
                    icon: Icon(Icons.thumb_down),
                    onPressed: () {
                      _handleDislike(authService);
                    },
                  ),
                  Text('$_dislikes'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleLike(AuthService authService) async {
    if (_hasUserLikedOrDisliked(authService)) {
      return; // Do nothing if user has already liked or disliked
    }

    final updatedLikes = _likes + 1;

    // Update local state optimistically
    setState(() {
      _likes = updatedLikes;
    });

    try {
      // Update Firestore document for likes
      await FirebaseFirestore.instance
          .collection('blogs')
          .doc(widget.blog.id)
          .update({
        'likes': updatedLikes,
        'likedBy': FieldValue.arrayUnion([authService.user!.id]),
      });
    } catch (e) {
      // Handle error
      print('Error updating likes: $e');
    }
  }

  Future<void> _handleDislike(AuthService authService) async {
    if (_hasUserLikedOrDisliked(authService)) {
      return; // Do nothing if user has already liked or disliked
    }

    final updatedDislikes = _dislikes + 1;

    // Update local state optimistically
    setState(() {
      _dislikes = updatedDislikes;
    });

    try {
      // Update Firestore document for dislikes
      await FirebaseFirestore.instance
          .collection('blogs')
          .doc(widget.blog.id)
          .update({
        'dislikes': updatedDislikes,
        'dislikedBy': FieldValue.arrayUnion([authService.user!.id]),
      });
    } catch (e) {
      // Handle error
      print('Error updating dislikes: $e');
    }
  }

  bool _hasUserLikedOrDisliked(AuthService authService) {
    final userId = authService.user!.id;
    return widget.blog.likedBy.contains(userId) ||
        widget.blog.dislikedBy.contains(userId);
  }

  Future<User?> _getAuthor(String? authorId, AuthService authService) async {
    if (authorId == null) {
      final currentUser = authService.user;
      if (currentUser != null) {
        return User(email: currentUser.email ?? '', id: currentUser.id);
      } else {
        return null;
      }
    }

    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(authorId)
          .get();

      if (snapshot.exists) {
        return User(
          id: snapshot.id,
          email: snapshot['email'] as String,
        );
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching author email: $e');
      return null;
    }
  }
}
