import { Injectable, UnauthorizedException, BadRequestException } from '@nestjs/common';
import { UsersService } from '../users/users.service';
import { PrismaService } from '../prisma/prisma.service';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { authenticator } from 'otplib';
import * as qrcode from 'qrcode';
import { randomBytes } from 'crypto';

@Injectable()
export class AuthService {
  constructor(
    private usersService: UsersService,
    private prisma: PrismaService,
    private jwtService: JwtService,
  ) {}

  async validateUser(email: string, pass: string): Promise<any> {
    const user: any = await this.usersService.findByEmail(email);
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
      sub: user.userId, 
      email: user.email, 
      role: user.role.roleName,
      permissions: user.role.permissions.map((p: any) => p.permission.permissionName)
    };
    
    const accessToken = this.jwtService.sign(payload);
    const refreshToken = randomBytes(40).toString('hex');
    
    // Set refresh token expiration (e.g., 7 days)
    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + 7);

    // Persist in DB
    await this.prisma.refreshToken.create({
      data: {
        userId: user.userId,
        token: refreshToken,
        expiresAt,
      },
    });

    return {
      accessToken,
      refreshToken,
      user: {
        userId: user.userId,
        email: user.email,
        fullName: user.fullName,
        roleName: user.role.roleName,
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

  async verifyOtp(email: string, code: string) {
    const user: any = await this.usersService.findByEmail(email);
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
      include: { user: { include: { role: { include: { permissions: { include: { permission: true } } } } } } },
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
    return this.generateTokens(record.user);
  }

  async setup2fa(userId: string) {
    const user: any = await this.usersService.findById(userId);
    if (user.otpEnabled) {
      throw new BadRequestException('2FA is already enabled');
    }

    const secret = authenticator.generateSecret();
    const otpauthUrl = authenticator.keyuri(user.email, 'MedPrescribe', secret);
    
    // Temporarily save secret
    await this.prisma.user.update({
      where: { userId },
      data: { otpSecret: secret },
    });

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

    await this.prisma.user.update({
      where: { userId },
      data: { otpEnabled: true },
    });

    return { message: '2FA successfully enabled' };
  }

  async disable2fa(userId: string) {
    await this.prisma.user.update({
      where: { userId },
      data: { otpEnabled: false, otpSecret: null },
    });
    return { message: '2FA successfully disabled' };
  }
}
