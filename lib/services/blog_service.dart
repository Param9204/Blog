import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:blog/models/blog.dart';
import '../models/user.dart';

class BlogService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Blog>> getBlogsByUser(String userId) {
    return _firestore
        .collection('blogs')
        .where('authorId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Blog.fromMap(doc.data(), doc.id)).toList();
    });
  }

  Stream<List<Blog>> getAllBlogs() {
    return _firestore.collection('blogs').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Blog.fromMap(doc.data(), doc.id)).toList();
    });
  }

  Future<void> addBlog(Blog blog) async {
    await _firestore.collection('blogs').add(blog.toMap());
    notifyListeners(); // Notify listeners after adding blog
  }

  Future<void> updateBlog(Blog blog) async {
    try {
      await _firestore.collection('blogs').doc(blog.id).update(blog.toMap());
      notifyListeners(); // Notify listeners after updating blog
    } catch (e) {
      print('Error updating blog: $e');
      throw e; // Throw the error so it can be caught in the UI layer
    }
  }

  Future<void> deleteBlog(String blogId) async {
    try {
      await _firestore.collection('blogs').doc(blogId).delete();
      notifyListeners(); // Notify listeners after deleting blog
    } catch (e) {
      print('Error deleting blog: $e');
      throw e; // Throw the error so it can be caught in the UI layer
    }
  }

  Future<void> addLike(String blogId, String userId) async {
    final blogRef = _firestore.collection('blogs').doc(blogId);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(blogRef);
      if (!snapshot.exists) {
        throw Exception("Blog does not exist!");
      }
      final blog = Blog.fromMap(snapshot.data()!, snapshot.id);
      if (blog.likedBy.contains(userId)) {
        return;
      }
      final updatedLikedBy = List<String>.from(blog.likedBy)..add(userId);
      final updatedLikes = blog.likes + 1;
      if (blog.dislikedBy.contains(userId)) {
        final updatedDislikedBy = List<String>.from(blog.dislikedBy)..remove(userId);
        final updatedDislikes = blog.dislikes - 1;
        transaction.update(blogRef, {
          'likedBy': updatedLikedBy,
          'likes': updatedLikes,
          'dislikedBy': updatedDislikedBy,
          'dislikes': updatedDislikes,
        });
      } else {
        transaction.update(blogRef, {
          'likedBy': updatedLikedBy,
          'likes': updatedLikes,
        });
      }
    });
    notifyListeners();
  }

  Future<void> removeLike(String blogId, String userId) async {
    final blogRef = _firestore.collection('blogs').doc(blogId);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(blogRef);
      if (!snapshot.exists) {
        throw Exception("Blog does not exist!");
      }
      final blog = Blog.fromMap(snapshot.data()!, snapshot.id);
      if (!blog.likedBy.contains(userId)) {
        return;
      }
      final updatedLikedBy = List<String>.from(blog.likedBy)..remove(userId);
      final updatedLikes = blog.likes - 1;
      transaction.update(blogRef, {
        'likedBy': updatedLikedBy,
        'likes': updatedLikes,
      });
    });
    notifyListeners();
  }

  Future<void> addDislike(String blogId, String userId) async {
    final blogRef = _firestore.collection('blogs').doc(blogId);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(blogRef);
      if (!snapshot.exists) {
        throw Exception("Blog does not exist!");
      }
      final blog = Blog.fromMap(snapshot.data()!, snapshot.id);
      if (blog.dislikedBy.contains(userId)) {
        return;
      }
      final updatedDislikedBy = List<String>.from(blog.dislikedBy)..add(userId);
      final updatedDislikes = blog.dislikes + 1;
      if (blog.likedBy.contains(userId)) {
        final updatedLikedBy = List<String>.from(blog.likedBy)..remove(userId);
        final updatedLikes = blog.likes - 1;
        transaction.update(blogRef, {
          'dislikedBy': updatedDislikedBy,
          'dislikes': updatedDislikes,
          'likedBy': updatedLikedBy,
          'likes': updatedLikes,
        });
      } else {
        transaction.update(blogRef, {
          'dislikedBy': updatedDislikedBy,
          'dislikes': updatedDislikes,
        });
      }
    });
    notifyListeners();
  }

  Future<void> removeDislike(String blogId, String userId) async {
    final blogRef = _firestore.collection('blogs').doc(blogId);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(blogRef);
      if (!snapshot.exists) {
        throw Exception("Blog does not exist!");
      }
      final blog = Blog.fromMap(snapshot.data()!, snapshot.id);
      if (!blog.dislikedBy.contains(userId)) {
        return;
      }
      final updatedDislikedBy = List<String>.from(blog.dislikedBy)..remove(userId);
      final updatedDislikes = blog.dislikes - 1;
      transaction.update(blogRef, {
        'dislikedBy': updatedDislikedBy,
        'dislikes': updatedDislikes,
      });
    });
    notifyListeners();
  }

  // New Methods
  Future<Blog> getBlogById(String blogId) async {
    try {
      final doc = await _firestore.collection('blogs').doc(blogId).get();
      if (doc.exists) {
        return Blog.fromMap(doc.data()!, doc.id);
      } else {
        throw Exception("Blog not found");
      }
    } catch (e) {
      print('Error fetching blog: $e');
      throw e;
    }
  }

  Future<void> incrementViewCount(String blogId) async {
    final blogRef = _firestore.collection('blogs').doc(blogId);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(blogRef);
      if (!snapshot.exists) {
        throw Exception("Blog does not exist!");
      }
      final blog = Blog.fromMap(snapshot.data()!, snapshot.id);
      final updatedViewCount = blog.viewCount + 1;
      transaction.update(blogRef, {
        'viewCount': updatedViewCount,
      });
    });
    notifyListeners();
  }

  // Add getUsers and deleteUser methods
  Stream<List<User>> getUsers() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => User.fromMap(doc.data(), doc.id)).toList();
    });
  }

  Future<void> deleteUserByEmail(String email) async {
    try {
      // Query user document by email and delete
      final querySnapshot = await _firestore.collection('users').where('email', isEqualTo: email).get();
      if (querySnapshot.docs.isNotEmpty) {
        final userId = querySnapshot.docs.first.id;
        await _firestore.collection('users').doc(userId).delete();
        notifyListeners(); // Notify listeners after deleting user
      } else {
        throw Exception('User not found'); // Handle if user not found
      }
    } catch (e) {
      print('Error deleting user: $e');
      throw e; // Throw the error so it can be caught in the UI layer
    }
  }



}
