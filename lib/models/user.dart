class User {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    required this.createdAt,
  });

  // Converter para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Criar a partir de JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      photoUrl: json['photoUrl'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
