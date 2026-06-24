import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class DrugsService {
  constructor(private prisma: PrismaService) {}

  async search(query: string, ingredient: string = '', skip = 0, take = 20) {
    const orConditions: any[] = [
      { brandName: { contains: query, mode: 'insensitive' } },
      { activeIngredient: { contains: query, mode: 'insensitive' } },
    ];
    
    const whereClause: any = { OR: orConditions };
    if (ingredient) {
      whereClause.activeIngredient = ingredient;
    }

    return this.prisma.drug.findMany({
      where: whereClause,
      skip,
      take,
      orderBy: { brandName: 'asc' },
    });
  }

  async findOne(id: string) {
    const drug = await this.prisma.drug.findUnique({
      where: { drugId: id },
      include: {
        interactions1: {
          include: { drug2: true },
        },
        interactions2: {
          include: { drug1: true },
        },
      },
    });

    if (!drug) {
      throw new NotFoundException(`Drug with ID ${id} not found`);
    }

    // Combine interactions where this drug is drug1 or drug2
    const interactions = [
      ...drug.interactions1.map((i) => ({
        interactionId: i.interactionId,
        otherDrugId: i.drug2Id,
        otherDrugName: i.drug2.brandName,
        severity: i.severity,
        description: i.description,
      })),
      ...drug.interactions2.map((i) => ({
        interactionId: i.interactionId,
        otherDrugId: i.drug1Id,
        otherDrugName: i.drug1.brandName,
        severity: i.severity,
        description: i.description,
      })),
    ];

    return {
      drugId: drug.drugId,
      brandName: drug.brandName,
      activeIngredient: drug.activeIngredient,
      concentration: drug.concentration,
      dosageForm: drug.dosageForm,
      manufacturer: drug.manufacturer,
      interactions,
    };
  }

  async getIngredients() {
    const result = await this.prisma.drug.findMany({
      select: { activeIngredient: true },
      distinct: ['activeIngredient'],
      orderBy: { activeIngredient: 'asc' },
    });
    return result.map(r => r.activeIngredient).filter(i => i);
  }
}
