import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';
import 'package:blog/models/blog.dart';
import 'dart:async';

class OfflineService {
  StreamSubscription<ConnectivityResult>? connectivitySubscription;

  OfflineService() {
    _initConnectivity();
  }

  void _initConnectivity() {
    try {
      connectivitySubscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
        if (result != ConnectivityResult.none) {
          syncOfflineBlogs();
        }
      } as void Function(List<ConnectivityResult> event)?) as StreamSubscription<ConnectivityResult>?;
    } catch (e) {
      print('Error initializing connectivity: $e');
    }
  }

  void dispose() {
    connectivitySubscription?.cancel();
  }

  Future<void> saveBlogLocally(Blog blog) async {
    try {
      final box = await Hive.openBox<Blog>('blogs');
      await box.put(blog.id, blog);
    } catch (e) {
      print('Error saving blog locally: $e');
    }
  }

  Future<void> syncOfflineBlogs() async {
    try {
      final box = await Hive.openBox<Blog>('blogs');
      final blogs = box.values.toList();
      for (Blog blog in blogs) {
        // Check if the blog needs to be updated on Firebase
        // Upload blog to Firebase if needed
        await uploadBlogToFirebase(blog);
      }
      print('Offline blogs synced');
    } catch (e) {
      print('Error syncing offline blogs: $e');
    }
  }

  Future<void> uploadBlogToFirebase(Blog blog) async {
    // Implement your logic to upload the blog to Firebase
    // For example:
    // await FirebaseFirestore.instance.collection('blogs').doc(blog.id).set(blog.toJson());
  }
}
