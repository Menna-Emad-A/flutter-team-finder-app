import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign Up
  Future<User?> signUpWithEmail(
      String email, String password, String username) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;

      // Create a new document for the user in Firestore
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'username': username,
          'email': email,
          'profilePicture': '', // You can add a default profile picture URL
          // Add any additional user fields here
        });
      }

      return user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Login
  Future<User?> loginWithEmail(String email, String password) async {
    try {
      UserCredential result =
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return result.user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }
  // Sign In with Google
  Future<User?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        // The user canceled the sign-in
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google [UserCredential]
      UserCredential result = await _auth.signInWithCredential(credential);
      User? user = result.user;

      // Check if user data exists in Firestore
      DocumentSnapshot doc = await _firestore.collection('users').doc(user!.uid).get();
      if (!doc.exists) {
        // If not, create a new document
        await _firestore.collection('users').doc(user.uid).set({
          'username': user.displayName ?? '',
          'email': user.email ?? '',
          'profilePicture': user.photoURL ?? '',
          // Add any additional user fields here
        });
      }

      return user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Sign In with Facebook
  Future<User?> signInWithFacebook() async {
    try {
      // Trigger the sign-in flow
      final LoginResult result = await FacebookAuth.instance.login();

      if (result.status != LoginStatus.success) {
        // The user canceled the sign-in
        return null;
      }

      // Create a credential from the access token
      final OAuthCredential credential =
      FacebookAuthProvider.credential(result.accessToken!.token);

      // Sign in to Firebase with the Facebook [UserCredential]
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      // Check if user data exists in Firestore
      DocumentSnapshot doc = await _firestore.collection('users').doc(user!.uid).get();
      if (!doc.exists) {
        // If not, create a new document
        await _firestore.collection('users').doc(user.uid).set({
          'username': user.displayName ?? '',
          'email': user.email ?? '',
          'profilePicture': user.photoURL ?? '',
          // Add any additional user fields here
        });
      }

      return user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

}
