import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class IcdService {
  constructor(private prisma: PrismaService) {}

  async search(query: string, group: string = '', skip = 0, take = 20) {
    const orConditions: any[] = [
      { diseaseName: { contains: query, mode: 'insensitive' } },
      { icdCode: { contains: query, mode: 'insensitive' } },
    ];
    
    const whereClause: any = { OR: orConditions };
    if (group) {
      whereClause.diseaseGroup = group;
    }

    return this.prisma.iCDCode.findMany({
      where: whereClause,
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

  async getGroups() {
    const result = await this.prisma.iCDCode.findMany({
      select: { diseaseGroup: true },
      distinct: ['diseaseGroup'],
      orderBy: { diseaseGroup: 'asc' },
    });
    return result.map(r => r.diseaseGroup).filter(g => g);
  }
}
