import { Injectable, UnauthorizedException, BadRequestException } from '@nestjs/common';
import { UsersService } from '../users/users.service';
import { PrismaService } from '../prisma/prisma.service';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { authenticator } from 'otplib';
import * as qrcode from 'qrcode';
import { randomBytes } from 'crypto';
import { RegisterDto } from './dto/auth.dto';

@Injectable()
export class AuthService {
  constructor(
    private usersService: UsersService,
    private prisma: PrismaService,
    private jwtService: JwtService,
  ) {}

  async validateUser(identifier: string, pass: string): Promise<any> {
    const user: any = await this.usersService.findByIdentifier(identifier);
    if (user && user.isActive) {
      const isMatch = await bcrypt.compare(pass, user.passwordHash);
      if (isMatch) {
        const { passwordHash, otpSecret, ...result } = user;
        return result;
      }
    }
    return null;
  }

  async validateUserById(userId: string): Promise<any> {
    const user: any = await this.usersService.findById(userId);
    if (user && user.isActive) {
      const { passwordHash, otpSecret, ...result } = user;
      return result;
    }
    return null;
  }

  private async generateTokens(user: any) {
    const payload = { 
      sub: user.id, 
      phoneNumber: user.phoneNumber, 
      role: user.role.name,
      permissions: user.role.permissions.map((p: any) => p.permission.name)
    };
    
    const accessToken = this.jwtService.sign(payload);
    const refreshToken = randomBytes(40).toString('hex');
    
    // Set refresh token expiration (e.g., 7 days)
    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + 7);

    // Persist in DB
    await this.prisma.refreshToken.create({
      data: {
        userId: user.id,
        token: refreshToken,
        expiresAt,
      },
    });

    return {
      accessToken,
      refreshToken,
      user: {
        id: user.id,
        phoneNumber: user.phoneNumber,
        fullName: user.fullName,
        roleName: user.role.name,
        permissions: payload.permissions,
      }
    };
  }

  async login(user: any) {
    if (user.otpEnabled) {
      return { requires2FA: true };
    }
    return this.generateTokens(user);
  }

  async verifyOtp(phoneNumber: string, code: string) {
    const user: any = await this.usersService.findByPhoneNumber(phoneNumber);
    if (!user || !user.otpEnabled || !user.otpSecret) {
      throw new UnauthorizedException('2FA not enabled or user not found');
    }

    const isValid = authenticator.verify({ token: code, secret: user.otpSecret });
    if (!isValid) {
      throw new UnauthorizedException('Invalid OTP code');
    }

    return this.generateTokens(user);
  }

  async refreshTokens(token: string) {
    const record = await this.prisma.refreshToken.findUnique({
      where: { token },
      include: { users: { include: { role: { include: { permissions: { include: { permission: true } } } } } } },
    });

    if (!record) {
      throw new UnauthorizedException('Invalid refresh token');
    }

    if (record.expiresAt < new Date()) {
      await this.prisma.refreshToken.delete({ where: { id: record.id } });
      throw new UnauthorizedException('Refresh token expired');
    }

    // Revoke old token
    await this.prisma.refreshToken.delete({ where: { id: record.id } });

    // Generate new ones
    return this.generateTokens(record.users);
  }

  async setup2fa(userId: string) {
    const user: any = await this.usersService.findById(userId);
    if (user.otpEnabled) {
      throw new BadRequestException('2FA is already enabled');
    }

    const secret = authenticator.generateSecret();
    const otpauthUrl = authenticator.keyuri(user.phoneNumber, 'MedPrescribe', secret);
    // OTP not supported in current DB schema

    const qrCodeImage = await qrcode.toDataURL(otpauthUrl);
    return { qrCodeImage, secret };
  }

  async enable2fa(userId: string, code: string) {
    const user: any = await this.usersService.findById(userId);
    if (!user.otpSecret) {
      throw new BadRequestException('2FA setup not initiated');
    }

    const isValid = authenticator.verify({ token: code, secret: user.otpSecret });
    if (!isValid) {
      throw new UnauthorizedException('Invalid code');
    }

    // OTP not supported in current DB schema

    return { message: '2FA successfully enabled' };
  }

  async disable2fa(userId: string) {
    // OTP not supported
    return { message: '2FA successfully disabled' };
  }

  async register(dto: RegisterDto) {
    // 1. Find the 'DOCTOR' role
    let doctorRole = await this.prisma.role.findUnique({
      where: { name: 'DOCTOR' }
    });

    if (!doctorRole) {
      doctorRole = await this.prisma.role.create({
        data: { name: 'DOCTOR', description: 'Medical Doctor' }
      });
    }

    return this.usersService.createUser({
      fullName: dto.fullName,
      password: dto.password,
      roleId: doctorRole.id,
      phoneNumber: dto.email, // Map frontend email field to backend phoneNumber
      cchnNumber: dto.cchnNumber,
    });
  }
}
