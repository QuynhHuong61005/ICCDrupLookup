import { Test, TestingModule } from '@nestjs/testing';
import { InteractionsService } from './interactions.service';
import { PrismaService } from '../prisma/prisma.service';

describe('InteractionsService', () => {
  let service: InteractionsService;
  let prismaService: jest.Mocked<PrismaService>;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        InteractionsService,
        {
          provide: PrismaService,
          useValue: {
            drugInteraction: {
              findMany: jest.fn().mockResolvedValue([]),
            },
            drug: {
              findUnique: jest.fn(),
            },
            auditLog: {
              create: jest.fn(),
            },
          },
        },
      ],
    }).compile();

    service = module.get<InteractionsService>(InteractionsService);
    prismaService = module.get(PrismaService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  it('should return empty results if drugIds is empty or has less than 2 drugs', async () => {
    const result1 = await service.checkInteractions([]);
    expect(result1).toEqual({ results: [], hasAnyInteraction: false });

    const result2 = await service.checkInteractions(['1']);
    expect(result2).toEqual({ results: [], hasAnyInteraction: false });
  });

  it('should check interactions and log audit if userId is provided', async () => {
    const drugIds = ['1', '2'];
    jest.spyOn(prismaService.drug, 'findUnique')
      .mockResolvedValueOnce({ brandName: 'Drug A' } as any)
      .mockResolvedValueOnce({ brandName: 'Drug B' } as any);

    const result = await service.checkInteractions(drugIds, 'user-123');
    expect(prismaService.auditLog.create).toHaveBeenCalled();
    expect(result.hasAnyInteraction).toBe(false);
    expect(result.results.length).toBe(1);
    expect(result.results[0].drug1Name).toBe('Drug A');
    expect(result.results[0].drug2Name).toBe('Drug B');
  });
});
