import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medprescribe_frontend/features/admin/data/models/role_model.dart';
import 'package:medprescribe_frontend/features/admin/data/repositories/admin_repository.dart';

// ─── Admin State ─────────────────────────────────────────────────

class AdminState {
  final List<RoleModel> roles;
  final List<PermissionModel> allPermissions;
  final List<AdminUserModel> users;
  final bool isLoading;
  final String? error;
  final String? successMessage;

  const AdminState({
    this.roles = const [],
    this.allPermissions = const [],
    this.users = const [],
    this.isLoading = false,
    this.error,
    this.successMessage,
  });

  AdminState copyWith({
    List<RoleModel>? roles,
    List<PermissionModel>? allPermissions,
    List<AdminUserModel>? users,
    bool? isLoading,
    String? error,
    String? successMessage,
    bool clearMessages = false,
  }) {
    return AdminState(
      roles: roles ?? this.roles,
      allPermissions: allPermissions ?? this.allPermissions,
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
      error: clearMessages ? null : (error ?? this.error),
      successMessage: clearMessages ? null : (successMessage ?? this.successMessage),
    );
  }
}

// ─── Admin Notifier ──────────────────────────────────────────────

class AdminNotifier extends StateNotifier<AdminState> {
  final AdminRepository _repo;

  AdminNotifier(this._repo) : super(const AdminState()) {
    loadAll();
  }

  Future<void> loadAll() async {
    state = state.copyWith(isLoading: true);
    try {
      final results = await Future.wait([
        _repo.getRoles(),
        _repo.getAllPermissions(),
        _repo.getUsers(),
      ]);
      state = AdminState(
        roles: results[0] as List<RoleModel>,
        allPermissions: results[1] as List<PermissionModel>,
        users: results[2] as List<AdminUserModel>,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> assignPermission(String roleId, String permissionId) async {
    state = state.copyWith(clearMessages: true);
    try {
      await _repo.assignPermission(roleId, permissionId);
      // Reload roles from backend to get fresh data
      await loadAll();
      state = state.copyWith(successMessage: 'Permission assigned successfully.');
    } catch (e) {
      state = state.copyWith(
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> revokePermission(String roleId, String permissionId) async {
    state = state.copyWith(clearMessages: true);
    try {
      await _repo.revokePermission(roleId, permissionId);
      // Update local state optimistically
      final updatedRoles = state.roles.map((r) {
        if (r.roleId != roleId) return r;
        return RoleModel(
          roleId: r.roleId,
          roleName: r.roleName,
          description: r.description,
          permissions: r.permissions
              .where((p) => p.permissionId != permissionId)
              .toList(),
          userCount: r.userCount,
        );
      }).toList();
      state = state.copyWith(
        roles: updatedRoles,
        successMessage: 'Permission revoked successfully.',
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  void clearMessages() => state = state.copyWith(clearMessages: true);
}

// ─── Providers ───────────────────────────────────────────────────

final adminRepositoryProvider =
    Provider<AdminRepository>((ref) => AdminRepository());

final adminProvider =
    StateNotifierProvider<AdminNotifier, AdminState>((ref) {
  return AdminNotifier(ref.watch(adminRepositoryProvider));
});
