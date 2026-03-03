class AuthUser {
  final String id;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phoneNumber;
  final int? points;
  final bool? isVerified;
  final String? role;

  const AuthUser({
    required this.id,
    this.firstName,
    this.lastName,
    this.points,
    this.email,
    this.phoneNumber,
    this.isVerified,
    this.role,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: (json['id'] as String?) ?? '',
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      email: json['email'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      points: json['points'] as int?,
      isVerified: json['isVerified'] as bool?,
      role: json['role'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'points': points,
      'isVerified': isVerified,
      'role': role,
    };
  }
}
