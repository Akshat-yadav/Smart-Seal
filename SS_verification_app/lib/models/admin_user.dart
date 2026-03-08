class AdminUser {
  const AdminUser({required this.id, required this.email, required this.name});

  final String id;
  final String email;
  final String name;

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: (json['id'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
    );
  }
}
