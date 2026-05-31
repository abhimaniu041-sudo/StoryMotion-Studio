import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> createUserDocument(UserModel user) async {
    await _firestore.collection('users').doc(user.uid).set(user.toMap());
  }

  Future<UserModel?> getUserDocument(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap({...doc.data()!, 'uid': uid});
  }

  Stream<QuerySnapshot> getUserProjectsStream(String userId) {
    return _firestore
        .collection('projects')
        .where('user_id', isEqualTo: userId)
        .orderBy('created_at', descending: true)
        .snapshots();
  }

  Stream<DocumentSnapshot> getProjectStatusStream(String projectId) {
    return _firestore
        .collection('projects')
        .doc(projectId)
        .snapshots();
  }

  Future<void> deleteProjectDocument(String projectId) async {
    await _firestore.collection('projects').doc(projectId).delete();
  }

  Future<void> updateProjectStatus({
    required String projectId,
    required String status,
    required String currentStep,
    required int stepNumber,
    required double progress,
  }) async {
    await _firestore.collection('projects').doc(projectId).update({
      'status': status,
      'current_step': currentStep,
      'step_number': stepNumber,
      'progress': progress,
    });
  }
}
