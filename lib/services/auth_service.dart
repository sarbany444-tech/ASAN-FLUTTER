import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';
import '../models/enums.dart';
import '../models/user_model.dart';

class AuthService {
  AuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentFirebaseUser => _auth.currentUser;
  String? get currentUserId => _auth.currentUser?.uid;

  Future<UserModel?> getCurrentUser() async {
    final uid = currentUserId;
    if (uid == null) return null;
    final doc = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data()!, uid);
  }

  Stream<UserModel?> userStream(String uid) {
    return _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromMap(doc.data()!, uid);
    });
  }

  Future<UserModel> signUp({
    required String email,
    required String password,
    required String displayName,
    UserRole role = UserRole.student,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = credential.user!.uid;
    await credential.user!.updateDisplayName(displayName);

    final user = UserModel(
      uid: uid,
      email: email,
      displayName: displayName,
      role: role,
      createdAt: DateTime.now(),
    );

    await _firestore.collection(AppConstants.usersCollection).doc(uid).set({
      ...user.toMap(),
      'isApproved': role != UserRole.teacher,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return user;
  }

  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = credential.user!.uid;
    final doc = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .get();

    if (!doc.exists) {
      final user = UserModel(
        uid: uid,
        email: email,
        displayName: credential.user!.displayName ?? 'User',
        photoUrl: credential.user!.photoURL,
        createdAt: DateTime.now(),
      );
      await _firestore.collection(AppConstants.usersCollection).doc(uid).set({
        ...user.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      return user;
    }

    final user = UserModel.fromMap(doc.data()!, uid);
    if (user.isBanned) {
      await _auth.signOut();
      throw FirebaseAuthException(
        code: 'account-banned',
        message: 'Your account has been banned.',
      );
    }
    return user;
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> resetPassword(String email) =>
      _auth.sendPasswordResetEmail(email: email);

  Future<void> updateProfile({
    required String uid,
    String? displayName,
    String? bio,
    String? photoUrl,
    String? preferredLanguage,
  }) async {
    final updates = <String, dynamic>{};
    if (displayName != null) updates['displayName'] = displayName;
    if (bio != null) updates['bio'] = bio;
    if (photoUrl != null) updates['photoUrl'] = photoUrl;
    if (preferredLanguage != null) {
      updates['preferredLanguage'] = preferredLanguage;
    }
    if (updates.isNotEmpty) {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .update(updates);
    }
  }

  Future<void> addStrike(String uid, String reason) async {
    final userRef =
        _firestore.collection(AppConstants.usersCollection).doc(uid);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(userRef);
      if (!snapshot.exists) return;
      final data = snapshot.data()!;
      final strikeCount = (data['strikeCount'] as int? ?? 0) + 1;

      final updates = <String, dynamic>{'strikeCount': strikeCount};

      if (strikeCount >= AppConstants.maxStrikesBeforeBan) {
        updates['status'] = AccountStatus.banned.value;
      } else if (strikeCount >= AppConstants.maxStrikesBeforeSuspension) {
        updates['status'] = AccountStatus.suspended.value;
        updates['suspendedUntil'] = Timestamp.fromDate(
          DateTime.now().add(
            Duration(days: AppConstants.suspensionDays),
          ),
        );
      }

      transaction.update(userRef, updates);
    });

    await _firestore
        .collection(AppConstants.strikesCollection)
        .doc(uid)
        .collection('records')
        .add({
      'reason': reason,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
