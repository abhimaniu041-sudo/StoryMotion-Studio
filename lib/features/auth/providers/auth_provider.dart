import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/user_model.dart';
import '../services/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authStateProvider = StreamProvider<UserModel?>((ref) async* {
  final service = ref.read(authServiceProvider);
  await for (final user in service.authStateChanges) {
    if (user == null) {
      yield null;
    } else {
      final doc = await service._getUserModel(user);
      yield doc;
    }
  }
});

final currentUserProvider = StateProvider<UserModel?>((ref) => null);
