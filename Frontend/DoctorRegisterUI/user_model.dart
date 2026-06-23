/// Represents a logged-in user with their role and permissions.
class UserModel {
  final String userId;
  final String fullName;
  final String email;
  final String roleId;
  final String roleName;
  final bool isActive;
  final bool otpEnabled;

  const UserModel({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.roleId,
    required this.roleName,
    required this.isActive,
    required this.otpEnabled,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'] ?? json['user_id'] ?? '',
      fullName: json['fullName'] ?? json['full_name'] ?? '',
      email: json['email'] ?? '',
      roleId: json['roleId'] ?? json['role_id'] ?? '',
      roleName: json['roleName'] ?? json['role']?['roleName'] ?? json['role']?['role_name'] ?? '',
      isActive: json['isActive'] ?? json['is_active'] ?? true,
      otpEnabled: json['otpEnabled'] ?? json['otp_enabled'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'fullName': fullName,
        'email': email,
        'roleId': roleId,
        'roleName': roleName,
        'isActive': isActive,
        'otpEnabled': otpEnabled,
      };

  UserModel copyWith({
    String? userId,
    String? fullName,
    String? email,
    String? roleId,
    String? roleName,
    bool? isActive,
    bool? otpEnabled,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      roleId: roleId ?? this.roleId,
      roleName: roleName ?? this.roleName,
      isActive: isActive ?? this.isActive,
      otpEnabled: otpEnabled ?? this.otpEnabled,
    );
  }

  bool get isAdmin => roleName.toUpperCase() == 'ADMIN';
  bool get isDoctor => roleName.toUpperCase() == 'DOCTOR';
  bool get isPharmacist => roleName.toUpperCase() == 'PHARMACIST';
}
