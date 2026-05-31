class UserModel {
  final String uid;
  final String name;
  final String email;
  final String plan;
  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.plan,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? 'User',
      email: map['email'] ?? '',
      plan: map['plan'] ?? 'free',
      createdAt: map['created_at'] != null
          ? (map['created_at'] as dynamic).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'plan': plan,
      'created_at': createdAt,
    };
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? plan,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      plan: plan ?? this.plan,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
