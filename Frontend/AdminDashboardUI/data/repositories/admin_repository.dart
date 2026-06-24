import 'package:medprescribe_frontend/features/admin/data/models/role_model.dart';
import 'package:medprescribe_frontend/services/api_service.dart';

/// Handles RBAC administration API calls backed by real PostgreSQL database.
class AdminRepository {
  final ApiService _api;

  AdminRepository({ApiService? apiService}) : _api = apiService ?? api;

  Future<List<RoleModel>> getRoles() async {
    final response =
        await _api.get<List<dynamic>>('/admin/roles');
    return response
        .map((e) => RoleModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<PermissionModel>> getAllPermissions() async {
    final response =
        await _api.get<List<dynamic>>('/admin/permissions');
    return response
        .map((e) => PermissionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> assignPermission(
      String roleId, String permissionId) async {
    await _api.post<dynamic>(
      '/admin/roles/$roleId/permissions/$permissionId',
      data: {},
    );
  }

  Future<void> revokePermission(String roleId, String permissionId) async {
    await _api.delete<dynamic>(
        '/admin/roles/$roleId/permissions/$permissionId');
  }

  Future<List<AdminUserModel>> getUsers() async {
    final response =
        await _api.get<List<dynamic>>('/admin/users');
    return response
        .map((e) => AdminUserModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
