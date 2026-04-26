import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get currentFirebaseUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserModel> register({
    required String name,
    required String phone,
    required String email,
    required String password,
    required String address,
    required String city,
    required String district,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final uid = credential.user!.uid;

      final user = UserModel(
        id: uid,
        name: name.trim(),
        phone: phone.trim(),
        email: email.trim(),
        address: address.trim(),
        city: city.trim(),
        district: district,
        createdAt: DateTime.now(),
      );

      await _db.collection('users').doc(uid).set(user.toMap());

      return user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final uid = credential.user!.uid;

      final doc = await _db.collection('users').doc(uid).get();

      if (!doc.exists) {
        throw Exception('User profile not found. Please register again.');
      }

      return UserModel.fromMap(doc.data()!);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  Future<UserModel?> getCurrentUserProfile() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;

    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;

    return UserModel.fromMap(doc.data()!);
  }

  Future<UserModel> updateProfile({
    required String userId,
    required String name,
    required String phone,
    required String address,
    required String city,
    required String district,
    String? profileImageUrl,
  }) async {
    await _db.collection('users').doc(userId).update({
      'name': name.trim(),
      'phone': phone.trim(),
      'address': address.trim(),
      'city': city.trim(),
      'district': district.trim(),
      'profileImageUrl': (profileImageUrl ?? '').trim().isEmpty
          ? null
          : profileImageUrl!.trim(),
    });

    final updated = await _db.collection('users').doc(userId).get();
    return UserModel.fromMap(updated.data()!);
  }

  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'No internet connection.';
      default:
        return e.message ?? 'Authentication failed. Please try again.';
    }
  }
}
