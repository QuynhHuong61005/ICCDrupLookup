import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class IcdService {
  constructor(private prisma: PrismaService) {}

  async search(query: string, skip = 0, take = 20) {
    return this.prisma.iCDCode.findMany({
      where: {
        OR: [
          { name_en: { contains: query, mode: 'insensitive' } },
          { name_vi: { contains: query, mode: 'insensitive' } },
          { code: { contains: query, mode: 'insensitive' } },
        ],
      },
      skip,
      take,
      orderBy: { code: 'asc' },
    });
  }

  async findOne(id: string) {
    const icd = await this.prisma.iCDCode.findUnique({
      where: { code: id },
    });

    if (!icd) {
      throw new NotFoundException(`ICD code with ID ${id} not found`);
    }

    return {
      icdId: icd.code,
      icdCode: icd.code,
      diseaseName: icd.name_vi || icd.name_en,
      diseaseGroup: icd.diseaseGroup,
      recommendedDrugs: [], // ICD to drug mapping is removed in DB schema v2
    };
  }
}
