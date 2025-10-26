import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class UserProvider with ChangeNotifier {
  UserModel? _user;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  UserModel? get user => _user;

  bool get isLoggedIn => _user != null;

  Future<void> loadUser() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      final doc = await _db.collection('users').doc(currentUser.uid).get();
      if (doc.exists) {
        _user = UserModel.fromMap(doc.data()!, currentUser.uid);
        notifyListeners();
      }
    }
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }
}
