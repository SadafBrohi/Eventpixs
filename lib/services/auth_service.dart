import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Future<User?> signUp(String name, String email, String password) async {
    try {
      final userCred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCred.user;

      if (user != null) {
        await user.updateDisplayName(name);
        await user.reload(); 

        await _db.collection('users').doc(user.uid).set({
          'name': name,
          'email': email,
        });
      }

      return _auth.currentUser; 
    } on FirebaseAuthException catch (e) {
      print('SignUp Error: ${e.code} - ${e.message}');
      return null;
    }
  }

  Future<User?> signIn(String email, String password) async {
    try {
      final userCred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return userCred.user;
    } on FirebaseAuthException catch (e) {
      print('SignIn Error: ${e.code} - ${e.message}');
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Stream<User?> authStateChanges() => _auth.authStateChanges();

}

