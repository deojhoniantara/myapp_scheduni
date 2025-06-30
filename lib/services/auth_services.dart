import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<UserCredential?> signInWithGoogle() async {
    try {
      print('Starting Google Sign-In process...');
      
      // Check if Google Play Services is available
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print('Google Sign-In was cancelled by user');
        return null;
      }

      print('Google user selected: ${googleUser.email}');
      
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      print('Google authentication completed');

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print('Signing in to Firebase with Google credential...');
      final userCredential = await _auth.signInWithCredential(credential);
      print('Successfully signed in: ${userCredential.user?.email}');
      
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error: ${e.code} - ${e.message}');
      switch (e.code) {
        case 'account-exists-with-different-credential':
          print('Account exists with different credential');
          break;
        case 'invalid-credential':
          print('Invalid credential');
          break;
        case 'operation-not-allowed':
          print('Operation not allowed');
          break;
        case 'user-disabled':
          print('User disabled');
          break;
        case 'user-not-found':
          print('User not found');
          break;
        case 'weak-password':
          print('Weak password');
          break;
        case 'invalid-verification-code':
          print('Invalid verification code');
          break;
        case 'invalid-verification-id':
          print('Invalid verification ID');
          break;
        default:
          print('Unknown Firebase Auth error: ${e.code}');
      }
      return null;
    } catch (e) {
      print('General Error signing in with Google: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      print('Successfully signed out');
    } catch (e) {
      print('Error signing out: $e');
    }
  }
}
