class User {
  final int id;
  final String name;
  final String username;
  final String roleName;
  final String className;
  final String token;

  User({
    required this.id,
    required this.name,
    required this.username,
    required this.roleName,
    required this.className,
    required this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final user = data['user'];
    return User(
      id: user['id'] ?? 0,
      name: user['name'] ?? '',
      username: user['username'] ?? '',
      roleName: user['role']?['name'] ?? '',
      className: user['class']?['name'] ?? '',
      token: data['token'] ?? '',
    );
  }
}
