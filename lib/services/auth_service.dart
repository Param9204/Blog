import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:blog/models/user.dart';
import 'package:blog/services/auth_service.dart';

class AuthService with ChangeNotifier {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  User? _user;

  User? get user => _user;

  bool get isAuthenticated => _user != null;

  AuthService() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(firebase_auth.User? firebaseUser) async {
    _user = firebaseUser != null ? User.fromFirebaseUser(firebaseUser) : null;
    notifyListeners();
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  Future<void> registerWithEmailAndPassword(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      throw Exception('Failed to register: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

}
