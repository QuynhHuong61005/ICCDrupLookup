/// Permission model.
class PermissionModel {
  final String permissionId;
  final String permissionName;
  final String? description;

  const PermissionModel({
    required this.permissionId,
    required this.permissionName,
    this.description,
  });

  factory PermissionModel.fromJson(Map<String, dynamic> json) {
    return PermissionModel(
      permissionId: json['permissionId'] ?? json['permission_id'] ?? '',
      permissionName: json['permissionName'] ?? json['permission_name'] ?? '',
      description: json['description'],
    );
  }
}

/// Role model with assigned permissions.
class RoleModel {
  final String roleId;
  final String roleName;
  final String? description;
  final List<PermissionModel> permissions;
  final int userCount;

  const RoleModel({
    required this.roleId,
    required this.roleName,
    this.description,
    this.permissions = const [],
    this.userCount = 0,
  });

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    final rawPerms = json['permissions'] as List<dynamic>? ?? [];
    final permissions = rawPerms.map((e) {
      if (e is String) {
        // Backend sends permissions as plain strings e.g. "MANAGE_SYSTEM"
        return PermissionModel(permissionId: e, permissionName: e);
      }
      // Nested under role_permissions
      final data = e is Map && e.containsKey('permission')
          ? e['permission'] as Map<String, dynamic>
          : e as Map<String, dynamic>;
      return PermissionModel.fromJson(data);
    }).toList();

    return RoleModel(
      roleId: json['roleId'] ?? json['role_id'] ?? '',
      roleName: json['roleName'] ?? json['role_name'] ?? '',
      description: json['description'],
      permissions: permissions,
      userCount: (json['userCount'] as num?)?.toInt() ??
          (json['_count']?['users'] as num?)?.toInt() ?? 0,
    );
  }

  bool hasPermission(String permissionName) {
    return permissions.any(
      (p) => p.permissionName.toUpperCase() == permissionName.toUpperCase(),
    );
  }
}

/// User list item for admin management.
class AdminUserModel {
  final String userId;
  final String fullName;
  final String email;
  final String roleId;
  final String roleName;
  final bool isActive;

  const AdminUserModel({
    required this.userId,
    required this.fullName,
    required this.email,
    this.roleId = '',
    required this.roleName,
    required this.isActive,
  });

  factory AdminUserModel.fromJson(Map<String, dynamic> json) {
    final role = json['role'] as Map<String, dynamic>? ?? {};
    return AdminUserModel(
      userId: json['userId'] ?? json['user_id'] ?? '',
      fullName: json['fullName'] ?? json['full_name'] ?? '',
      email: json['email'] ?? '',
      roleId: json['roleId'] ?? json['role_id'] ?? role['roleId'] ?? '',
      roleName: json['roleName'] ?? json['role_name'] ??
          role['roleName'] ?? role['role_name'] ?? '',
      isActive: json['isActive'] ?? json['is_active'] ?? true,
    );
  }
}
