import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  AuthService({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user;
    if (user != null) {
      if (displayName != null && displayName.isNotEmpty) {
        await user.updateDisplayName(displayName);
      }
      await _createUserProfile(user.uid, {
        'email': user.email,
        'displayName': displayName ?? user.displayName,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    return credential;
  }

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() => _auth.signOut();

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserProfile(String uid) {
    return _firestore.collection('users').doc(uid).get();
  }

  Future<void> _createUserProfile(String uid, Map<String, dynamic> data) async {
    final ref = _firestore.collection('users').doc(uid);
    await ref.set(data, SetOptions(merge: true));
  }
}
