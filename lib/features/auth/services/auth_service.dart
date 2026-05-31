import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserModel?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return _getUserModel(cred.user!);
  }

  Future<UserModel?> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await cred.user!.updateDisplayName(name);

    final user = UserModel(
      uid: cred.user!.uid,
      name: name,
      email: email,
      plan: 'free',
      createdAt: DateTime.now(),
    );

    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(user.toMap());

    return user;
  }

  Future<UserModel?> signInWithGoogle() async {
    final account = await _googleSignIn.signIn();
    if (account == null) return null;

    final auth = await account.authentication;
    final cred = GoogleAuthProvider.credential(
      accessToken: auth.accessToken,
      idToken: auth.idToken,
    );

    final result = await _auth.signInWithCredential(cred);
    final user = result.user!;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) {
      final model = UserModel(
        uid: user.uid,
        name: user.displayName ?? 'User',
        email: user.email ?? '',
        plan: 'free',
        createdAt: DateTime.now(),
      );
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(model.toMap());
    }

    return _getUserModel(user);
  }

  Future<UserModel?> signInAsGuest() async {
    final cred = await _auth.signInAnonymously();
    final user = UserModel(
      uid: cred.user!.uid,
      name: 'Guest',
      email: '',
      plan: 'free',
      createdAt: DateTime.now(),
    );
    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(user.toMap());
    return user;
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<UserModel?> _getUserModel(User user) async {
    final doc =
        await _firestore.collection('users').doc(user.uid).get();
    if (doc.exists) {
      return UserModel.fromMap({...doc.data()!, 'uid': user.uid});
    }
    return null;
  }
}
