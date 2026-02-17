import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  /// CURRENT USER
  static User? get currentUser => _auth.currentUser;

  // ===============================
  // EMAIL LOGIN / SIGNUP
  // ===============================
  static Future<User?> signInWithEmail({
    required String email,
    required String password,
    required bool isLogin,
  }) async {
    UserCredential userCredential;

    if (isLogin) {
      userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } else {
      userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    }

    await _saveUser(userCredential.user!);

    return userCredential.user;
  }

  // ===============================
  // GOOGLE LOGIN
  // ===============================
  static Future<User?> signInWithGoogle() async {
    await _googleSignIn.initialize(serverClientId: null);

    final googleUser = await _googleSignIn.authenticate();

    final googleAuth = googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);

    await _saveUser(userCredential.user!);

    return userCredential.user;
  }

  // ===============================
  // SAVE USER IN FIRESTORE
  // ===============================
  static Future<void> _saveUser(User user) async {
    await _firestore.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'email': user.email,
      'lastLogin': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // ===============================
  // CHECK PROFILE COMPLETE
  // ===============================
  static Future<bool> isProfileComplete(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();

    final data = doc.data();

    return data?['name'] != null &&
        data?['age'] != null &&
        data?['weight'] != null &&
        data?['activity'] != null;
  }

  // ===============================
  // LOGOUT
  // ===============================
  static Future<void> logout() async {
    await _auth.signOut();
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
  }
}
