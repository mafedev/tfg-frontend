class LoginResponse {
  final String username;
  final String email;
  final String role;
  final String phone;
  final String token;

  LoginResponse({
    required this.username,
    required this.email,
    required this.role,
    required this.phone,
    required this.token,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      username: json['username'],
      email: json['email'],
      role: json['role'],
      phone: json['phone'],
      token: json['token'],
    );
  }
}
