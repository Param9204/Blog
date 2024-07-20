import 'package:cloud_firestore/cloud_firestore.dart';

class Blog {
  String id;
  String title;
  String content;
  String authorId;
  DateTime createdAt;
  List<String> categories;
  List<String> tags;
  String imageUrl;
  String authorEmail;
  int likes;
  int dislikes;
  List<String> likedBy;
  List<String> dislikedBy;
  int viewCount; // Add this field

  Blog({
    required this.id,
    required this.title,
    required this.content,
    required this.authorId,
    required this.createdAt,
    required this.categories,
    required this.tags,
    required this.imageUrl,
    required this.authorEmail,
    this.likes = 0,
    this.dislikes = 0,
    required this.likedBy,
    required this.dislikedBy,
    this.viewCount = 0, // Initialize this field
  });

  factory Blog.fromMap(Map<String, dynamic> data, String documentId) {
    return Blog(
      id: documentId,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      authorId: data['authorId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      categories: List<String>.from(data['categories'] ?? []),
      tags: List<String>.from(data['tags'] ?? []),
      imageUrl: data['imageUrl'] ?? '',
      authorEmail: data['authorEmail'] ?? '',
      likes: data['likes'] ?? 0,
      dislikes: data['dislikes'] ?? 0,
      likedBy: List<String>.from(data['likedBy'] ?? []),
      dislikedBy: List<String>.from(data['dislikedBy'] ?? []),
      viewCount: data['viewCount'] ?? 0, // Add this field
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'authorId': authorId,
      'createdAt': createdAt,
      'categories': categories,
      'tags': tags,
      'imageUrl': imageUrl,
      'authorEmail': authorEmail,
      'likes': likes,
      'dislikes': dislikes,
      'likedBy': likedBy,
      'dislikedBy': dislikedBy,
      'viewCount': viewCount, // Add this field
    };
  }
}
