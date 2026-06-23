import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class IcdService {
  constructor(private prisma: PrismaService) {}

  async search(query: string, skip = 0, take = 20) {
    return this.prisma.iCDCode.findMany({
      where: {
        OR: [
          { diseaseName: { contains: query, mode: 'insensitive' } },
          { icdCode: { contains: query, mode: 'insensitive' } },
        ],
      },
      skip,
      take,
      orderBy: { icdCode: 'asc' },
    });
  }

  async findOne(id: string) {
    const icd = await this.prisma.iCDCode.findUnique({
      where: { icdId: id },
      include: {
        mappings: {
          include: {
            drug: true,
          },
        },
      },
    });

    if (!icd) {
      throw new NotFoundException(`ICD code with ID ${id} not found`);
    }

    return {
      icdId: icd.icdId,
      icdCode: icd.icdCode,
      diseaseName: icd.diseaseName,
      diseaseGroup: icd.diseaseGroup,
      recommendedDrugs: icd.mappings.map((m) => ({
        drugId: m.drug.drugId,
        brandName: m.drug.brandName,
        activeIngredient: m.drug.activeIngredient,
        standardDosage: m.standardDosage,
        bhytStatus: m.bhytStatus,
      })),
    };
  }
}
  