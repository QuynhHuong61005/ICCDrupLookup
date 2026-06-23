import 'package:flutter/material.dart';
import 'package:medprescribe_frontend/services/mock_data_service.dart';
import 'package:medprescribe_frontend/shared/constants/app_constants.dart';
import 'package:medprescribe_frontend/shared/widgets/app_button.dart';
import 'package:medprescribe_frontend/shared/widgets/app_card.dart';

class RoleManagementScreen extends StatefulWidget {
  const RoleManagementScreen({super.key});

  @override
  State<RoleManagementScreen> createState() => _RoleManagementScreenState();
}

class _RoleManagementScreenState extends State<RoleManagementScreen> {
  final List<UserMock> _userList = List.from(MockDataService.users);

  // Permission Matrix state mapping
  // Role -> Permission -> State
  final Map<String, Map<String, bool>> _rolePermissions = {
    'ADMIN': {
      'MANAGE_SYSTEM': true,
      'WRITE_USERS': true,
      'READ_USERS': true,
      'WRITE_PRESCRIPTION': true,
      'READ_PRESCRIPTION': true,
      'READ_DRUGS': true,
      'WRITE_DRUGS': true,
    },
    'DOCTOR': {
      'MANAGE_SYSTEM': false,
      'WRITE_USERS': false,
      'READ_USERS': true,
      'WRITE_PRESCRIPTION': true,
      'READ_PRESCRIPTION': true,
      'READ_DRUGS': true,
      'WRITE_DRUGS': true,
    },
    'PHARMACIST': {
      'MANAGE_SYSTEM': false,
      'WRITE_USERS': false,
      'READ_USERS': true,
      'WRITE_PRESCRIPTION': false,
      'READ_PRESCRIPTION': true,
      'READ_DRUGS': true,
      'WRITE_DRUGS': false,
    },
  };

  void _toggleUserActive(int index, bool value) {
    setState(() {
      final oldUser = _userList[index];
      _userList[index] = UserMock(
        userId: oldUser.userId,
        fullName: oldUser.fullName,
        email: oldUser.email,
        role: oldUser.role,
        isActive: value,
      );
    });
  }

  void _togglePermission(String role, String permission, bool value) {
    setState(() {
      _rolePermissions[role]?[permission] = value;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('Updated permission: $permission for role $role to $value'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final permissions = [
      'MANAGE_SYSTEM',
      'WRITE_USERS',
      'READ_USERS',
      'WRITE_PRESCRIPTION',
      'READ_PRESCRIPTION',
      'READ_DRUGS',
      'WRITE_DRUGS'
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 900) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: _buildUserListPanel(theme),
                ),
                AppSpacing.gapW16,
                Expanded(
                  flex: 4,
                  child: _buildPermissionMatrixPanel(theme, permissions),
                ),
              ],
            );
          } else {
            return SingleChildScrollView(
              child: Column(
                children: [
                  _buildUserListPanel(theme),
                  AppSpacing.gapH16,
                  _buildPermissionMatrixPanel(theme, permissions),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildUserListPanel(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCard(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('User Directory', style: theme.textTheme.titleMedium),
              AppButton(
                text: 'New User',
                icon: Icons.person_add,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Mock "Create User" Dialog triggered.')),
                  );
                },
                width: 140,
              ),
            ],
          ),
        ),
        AppSpacing.gapH16,
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _userList.length,
          itemBuilder: (context, index) {
            final user = _userList[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: AppCard(
                padding: EdgeInsets.zero,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        theme.colorScheme.primary.withValues(alpha: 0.08),
                    child: Icon(Icons.person, color: theme.colorScheme.primary),
                  ),
                  title: Text(
                    user.fullName,
                    style: theme.textTheme.bodyLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('${user.email} • ${user.role}'),
                  trailing: Switch(
                    value: user.isActive,
                    onChanged: (val) => _toggleUserActive(index, val),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPermissionMatrixPanel(
      ThemeData theme, List<String> permissions) {
    final rolesList = ['ADMIN', 'DOCTOR', 'PHARMACIST'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCard(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('RBAC Permission Matrix',
                  style: theme.textTheme.titleMedium),
              AppButton(
                text: 'Create Role',
                icon: Icons.add,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Mock "Create Role" Dialog triggered.')),
                  );
                },
                width: 140,
              ),
            ],
          ),
        ),
        AppSpacing.gapH16,
        AppCard(
          padding: EdgeInsets.zero,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: [
                const DataColumn(label: Text('Permission / Resource')),
                ...rolesList.map((role) => DataColumn(label: Text(role))),
              ],
              rows: permissions.map((perm) {
                return DataRow(
                  cells: [
                    DataCell(
                      Text(
                        perm.replaceAll('_', ' '),
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ),
                    ...rolesList.map((role) {
                      final hasPermission =
                          _rolePermissions[role]?[perm] ?? false;
                      return DataCell(
                        Checkbox(
                          value: hasPermission,
                          onChanged: role == 'ADMIN'
                              ? null // Admin permissions are locked / immutable
                              : (val) {
                                  if (val != null) {
                                    _togglePermission(role, perm, val);
                                  }
                                },
                        ),
                      );
                    }),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
