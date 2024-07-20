import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Auth_Service extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> createUserWithEmailAndPassword(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
