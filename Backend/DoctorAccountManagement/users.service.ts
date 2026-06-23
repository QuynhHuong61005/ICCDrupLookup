import { Injectable, BadRequestException, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import * as bcrypt from 'bcrypt';
import { CreateUserDto, UpdateUserDto, CreateRoleDto } from './dto/users.dto';

@Injectable()
export class UsersService {
  constructor(private prisma: PrismaService) {}

  async findByEmail(email: string) {
    return this.prisma.user.findUnique({
      where: { email },
      include: {
        role: { include: { permissions: { include: { permission: true } } } },
      },
    });
  }

  async findById(userId: string) {
    return this.prisma.user.findUnique({
      where: { userId },
      include: {
        role: { include: { permissions: { include: { permission: true } } } },
      },
    });
  }

  async findAllUsers() {
    return this.prisma.user.findMany({
      include: { role: true },
    });
  }

  async createUser(dto: CreateUserDto) {
    const existingUser = await this.prisma.user.findUnique({ where: { email: dto.email } });
    if (existingUser) {
      throw new BadRequestException('Email already exists');
    }
    const hashedPassword = await bcrypt.hash(dto.password, 10);
    return this.prisma.user.create({
      data: {
        email: dto.email,
        fullName: dto.fullName,
        passwordHash: hashedPassword,
        roleId: dto.roleId,
        isActive: true,
      },
      include: { role: true },
    });
  }

  async updateUser(userId: string, dto: UpdateUserDto) {
    const user = await this.prisma.user.findUnique({ where: { userId } });
    if (!user) throw new NotFoundException('User not found');
    
    return this.prisma.user.update({
      where: { userId },
      data: {
        fullName: dto.fullName !== undefined ? dto.fullName : undefined,
        roleId: dto.roleId !== undefined ? dto.roleId : undefined,
        isActive: dto.isActive !== undefined ? dto.isActive : undefined,
      },
      include: { role: true },
    });
  }

  async disableUser(userId: string) {
    return this.updateUser(userId, { isActive: false });
  }

  async enableUser(userId: string) {
    return this.updateUser(userId, { isActive: true });
  }

  async findAllRoles() {
    return this.prisma.role.findMany({
      include: {
        permissions: { include: { permission: true } },
        _count: { select: { users: true } },
      },
    });
  }

  async createRole(dto: CreateRoleDto) {
    const existing = await this.prisma.role.findFirst({ where: { roleName: dto.roleName } });
    if (existing) throw new BadRequestException('Role name already exists');
    
    return this.prisma.role.create({
      data: {
        roleName: dto.roleName,
        description: dto.description || '',
      },
    });
  }

  async updateRole(roleId: string, dto: Partial<CreateRoleDto>) {
    return this.prisma.role.update({
      where: { roleId },
      data: dto,
    });
  }

  async deleteRole(roleId: string) {
    const role = await this.prisma.role.findUnique({ where: { roleId }, include: { users: true } });
    if (!role) throw new NotFoundException('Role not found');
    if (role.users.length > 0) throw new BadRequestException('Cannot delete role with existing users');
    
    return this.prisma.role.delete({ where: { roleId } });
  }

  async findAllPermissions() {
    return this.prisma.permission.findMany();
  }

  async createPermission(permissionName: string, description?: string) {
    return this.prisma.permission.create({
      data: { permissionName, description: description || '' },
    });
  }

  async deletePermission(permissionId: string) {
    return this.prisma.permission.delete({
      where: { permissionId },
    });
  }

  async assignPermissionToRole(roleId: string, permissionId: string) {
    return this.prisma.rolePermission.create({
      data: { roleId, permissionId },
    });
  }

  async revokePermissionFromRole(roleId: string, permissionId: string) {
    return this.prisma.rolePermission.delete({
      where: { roleId_permissionId: { roleId, permissionId } },
    });
  }
}
