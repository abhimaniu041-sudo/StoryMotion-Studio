import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/project_model.dart';

final allProjectsProvider =
    StreamProvider<List<ProjectModel>>((ref) {
  final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
  if (userId.isEmpty) return Stream.value([]);

  return FirebaseFirestore.instance
      .collection('projects')
      .where('user_id', isEqualTo: userId)
      .orderBy('created_at', descending: true)
      .snapshots()
      .map((snap) => snap.docs
          .map((d) => ProjectModel.fromMap(d.data(), d.id))
          .toList());
});
