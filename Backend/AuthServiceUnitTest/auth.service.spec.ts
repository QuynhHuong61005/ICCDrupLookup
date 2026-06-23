import { Test, TestingModule } from '@nestjs/testing';
import { AuthService } from './auth.service';
import { UsersService } from '../users/users.service';
import { PrismaService } from '../prisma/prisma.service';
import { JwtService } from '@nestjs/jwt';
import { UnauthorizedException, BadRequestException } from '@nestjs/common';

describe('AuthService', () => {
  let service: AuthService;
  let usersService: jest.Mocked<UsersService>;
  let prismaService: jest.Mocked<PrismaService>;
  let jwtService: jest.Mocked<JwtService>;

  const mockUser = {
    userId: '1',
    email: 'test@example.com',
    fullName: 'Test User',
    passwordHash: 'hashedpassword',
    isActive: true,
    otpEnabled: false,
    otpSecret: 'secret',
    role: {
      roleName: 'DOCTOR',
      permissions: [
        {
          permission: {
            permissionName: 'READ_PRESCRIPTION',
          },
        },
      ],
    },
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AuthService,
        {
          provide: UsersService,
          useValue: {
            findByEmail: jest.fn(),
            findById: jest.fn(),
          },
        },
        {
          provide: PrismaService,
          useValue: {
            refreshToken: {
              create: jest.fn(),
              findUnique: jest.fn(),
              delete: jest.fn(),
            },
            user: {
              update: jest.fn(),
            },
          },
        },
        {
          provide: JwtService,
          useValue: {
            sign: jest.fn().mockReturnValue('mock-jwt-token'),
          },
        },
      ],
    }).compile();

    service = module.get<AuthService>(AuthService);
    usersService = module.get(UsersService);
    prismaService = module.get(PrismaService);
    jwtService = module.get(JwtService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('login', () => {
    it('should return requires2FA true if user has 2FA enabled', async () => {
      const result = await service.login({ ...mockUser, otpEnabled: true });
      expect(result).toEqual({ requires2FA: true });
    });

    it('should generate tokens if 2FA is disabled', async () => {
      jest.spyOn(prismaService.refreshToken, 'create').mockResolvedValue({} as any);

      const result = await service.login(mockUser) as any;
      expect(result).toHaveProperty('accessToken');
      expect(result).toHaveProperty('refreshToken');
      expect(result.user.email).toBe(mockUser.email);
    });
  });

  describe('disable2fa', () => {
    it('should disable 2fa successfully', async () => {
      jest.spyOn(prismaService.user, 'update').mockResolvedValue({} as any);

      const result = await service.disable2fa('1');
      expect(result.message).toContain('successfully disabled');
      expect(prismaService.user.update).toHaveBeenCalledWith({
        where: { userId: '1' },
        data: { otpEnabled: false, otpSecret: null },
      });
    });
  });
});
