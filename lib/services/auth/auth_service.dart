import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  //instance of auth
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // instance of firestore
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  //Get the current user
  Future<UserCredential> signInWithEmailandPassword(
      String email, String password) async {
    try {
      UserCredential userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // add a new document for the user in users collection if it doesn't already exists
      _fireStore.collection("users").doc(userCredential.user!.uid).set({
        "uid": userCredential.user!.uid,
        "name": userCredential.user!.displayName,
        "email": email,
        "createdAt": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  //Create a new user
  Future<UserCredential> signUpWithEmailandPassword(
      String name, String email, String password) async {
    try {
      UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Now, set the display name
      await userCredential.user?.updateDisplayName(name);

      _fireStore.collection("users").doc(userCredential.user!.uid).set({
        "uid": userCredential.user!.uid,
        "name": name,
        "email": email,
        "createdAt": FieldValue.serverTimestamp(),
      });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  //Sign out
  Future<void> signOut() async {
    return await FirebaseAuth.instance.signOut();
  }
}
