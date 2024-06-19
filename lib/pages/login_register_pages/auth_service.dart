import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

Future<void> loginWithGoogle({
  required FirebaseAuth auth,
  required BuildContext context,
  required GoogleSignIn googleSignIn,
}) async {
  try {
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) return;

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final UserCredential userCredential =
        await auth.signInWithCredential(credential);

    if (userCredential.user != null) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  } catch (e) {
    debugPrint('Error signing in with Google: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Failed to sign in with Google'),
      ),
    );
  }
}
