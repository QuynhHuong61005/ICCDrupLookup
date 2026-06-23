import { Controller, Get, Post, Patch, Delete, Param, Body, UseGuards } from '@nestjs/common';
import { UsersService } from './users.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { ApiTags, ApiBearerAuth, ApiOperation } from '@nestjs/swagger';
import { CreateUserDto, UpdateUserDto, CreateRoleDto } from './dto/users.dto';

@ApiTags('Admin / Users')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, RolesGuard)
@Controller('admin')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Roles('SUPER_ADMIN', 'ADMIN')
  @Get('users')
  @ApiOperation({ summary: 'Get all users' })
  async getUsers() {
    const users = await this.usersService.findAllUsers();
    return users.map((u) => ({
      userId: u.userId,
      email: u.email,
      fullName: u.fullName,
      roleName: u.role.roleName,
      isActive: u.isActive,
    }));
  }

  @Roles('SUPER_ADMIN')
  @Post('users')
  @ApiOperation({ summary: 'Create a new user' })
  async createUser(@Body() dto: CreateUserDto) {
    const u = await this.usersService.createUser(dto);
    return { userId: u.userId, email: u.email, fullName: u.fullName };
  }

  @Roles('SUPER_ADMIN')
  @Patch('users/:userId')
  @ApiOperation({ summary: 'Update a user' })
  async updateUser(@Param('userId') userId: string, @Body() dto: UpdateUserDto) {
    const u = await this.usersService.updateUser(userId, dto);
    return { userId: u.userId, email: u.email, isActive: u.isActive };
  }

  @Roles('SUPER_ADMIN')
  @Post('users/:userId/enable')
  @ApiOperation({ summary: 'Enable a user' })
  async enableUser(@Param('userId') userId: string) {
    return this.usersService.enableUser(userId);
  }

  @Roles('SUPER_ADMIN')
  @Post('users/:userId/disable')
  @ApiOperation({ summary: 'Disable a user' })
  async disableUser(@Param('userId') userId: string) {
    return this.usersService.disableUser(userId);
  }

  @Roles('SUPER_ADMIN', 'ADMIN')
  @Get('roles')
  @ApiOperation({ summary: 'Get all roles' })
  async getRoles() {
    const roles = await this.usersService.findAllRoles();
    return roles.map((r) => ({
      roleId: r.roleId,
      roleName: r.roleName,
      description: r.description,
      userCount: r._count.users,
      permissions: r.permissions.map((p) => p.permission.permissionName),
    }));
  }

  @Roles('SUPER_ADMIN')
  @Post('roles')
  @ApiOperation({ summary: 'Create a new role' })
  async createRole(@Body() dto: CreateRoleDto) {
    return this.usersService.createRole(dto);
  }

  @Roles('SUPER_ADMIN')
  @Patch('roles/:roleId')
  @ApiOperation({ summary: 'Update a role' })
  async updateRole(@Param('roleId') roleId: string, @Body() dto: CreateRoleDto) {
    return this.usersService.updateRole(roleId, dto);
  }

  @Roles('SUPER_ADMIN')
  @Delete('roles/:roleId')
  @ApiOperation({ summary: 'Delete a role' })
  async deleteRole(@Param('roleId') roleId: string) {
    return this.usersService.deleteRole(roleId);
  }

  @Roles('SUPER_ADMIN', 'ADMIN')
  @Get('permissions')
  @ApiOperation({ summary: 'Get all permissions' })
  async getPermissions() {
    return this.usersService.findAllPermissions();
  }

  @Roles('SUPER_ADMIN')
  @Post('permissions')
  @ApiOperation({ summary: 'Create a new permission' })
  async createPermission(@Body() body: { permissionName: string, description?: string }) {
    return this.usersService.createPermission(body.permissionName, body.description);
  }

  @Roles('SUPER_ADMIN')
  @Delete('permissions/:permissionId')
  @ApiOperation({ summary: 'Delete a permission' })
  async deletePermission(@Param('permissionId') permissionId: string) {
    return this.usersService.deletePermission(permissionId);
  }

  @Roles('SUPER_ADMIN')
  @Post('roles/:roleId/permissions/:permissionId')
  @ApiOperation({ summary: 'Assign a permission to a role' })
  async assignPermission(
    @Param('roleId') roleId: string,
    @Param('permissionId') permissionId: string,
  ) {
    return this.usersService.assignPermissionToRole(roleId, permissionId);
  }

  @Roles('SUPER_ADMIN')
  @Delete('roles/:roleId/permissions/:permissionId')
  @ApiOperation({ summary: 'Revoke a permission from a role' })
  async revokePermission(
    @Param('roleId') roleId: string,
    @Param('permissionId') permissionId: string,
  ) {
    return this.usersService.revokePermissionFromRole(roleId, permissionId);
  }
}
