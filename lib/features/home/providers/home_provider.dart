import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

final firebaseServiceProvider =
    Provider<FirebaseService>((ref) => FirebaseService());

final recentProjectsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
  if (userId.isEmpty) return Stream.value([]);

  return FirebaseFirestore.instance
      .collection('projects')
      .where('user_id', isEqualTo: userId)
      .orderBy('created_at', descending: true)
      .limit(5)
      .snapshots()
      .map((snap) => snap.docs
          .map((d) => {...d.data(), 'id': d.id})
          .toList());
});
