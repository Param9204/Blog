import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class User {
  final String id;
  final String email;

  User({
    required this.id,
    required this.email,
  });


  factory User.fromMap(Map<String, dynamic> data, String documentId) {
    return User(
      id: documentId,
      email: data['email'] ?? '',
    );
  }


  factory User.fromFirebaseUser(firebase_auth.User firebaseUser) {
    return User(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
    );
  }
}
