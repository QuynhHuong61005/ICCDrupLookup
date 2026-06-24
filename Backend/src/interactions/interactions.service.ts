import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class InteractionsService {
  constructor(private prisma: PrismaService) {}

  async checkInteractions(drugIds: string[], userId?: string) {
    if (!drugIds || drugIds.length < 2) {
      return { results: [], hasAnyInteraction: false };
    }

    if (userId) {
      try {
        await this.prisma.auditLog.create({
          data: {
            userId,
            action: 'CHECK_INTERACTIONS',
            tableName: 'drug_interactions',
            newValues: { drugIds },
          },
        });
      } catch (err) {
        // Fail silently so interaction check works even if audit logging fails
        console.error('Failed to write audit log for checkInteractions:', err);
      }
    }

    const interactions = await this.prisma.drugInteraction.findMany({
      where: {
        AND: [
          { drug1Id: { in: drugIds } },
          { drug2Id: { in: drugIds } },
        ],
      },
      include: {
        drug1: true,
        drug2: true,
      },
    });

    const results = [];
    for (let i = 0; i < drugIds.length; i++) {
      for (let j = i + 1; j < drugIds.length; j++) {
        const id1 = drugIds[i];
        const id2 = drugIds[j];
        
        const interaction = interactions.find(
          (int) => (int.drug1Id === id1 && int.drug2Id === id2) || 
                   (int.drug1Id === id2 && int.drug2Id === id1)
        );

        if (interaction) {
          results.push({
            drug1Id: id1,
            drug2Id: id2,
            drug1Name: id1 === interaction.drug1Id ? interaction.drug1.brandName : interaction.drug2.brandName,
            drug2Name: id2 === interaction.drug2Id ? interaction.drug2.brandName : interaction.drug1.brandName,
            hasInteraction: true,
            interaction: {
              severity: interaction.severity,
              description: interaction.description,
            },
          });
        } else {
          // Fetch drug names for the pair even if no interaction
          const d1 = await this.prisma.drug.findUnique({ where: { drugId: id1 } });
          const d2 = await this.prisma.drug.findUnique({ where: { drugId: id2 } });
          results.push({
            drug1Id: id1,
            drug2Id: id2,
            drug1Name: d1?.brandName || 'Unknown',
            drug2Name: d2?.brandName || 'Unknown',
            hasInteraction: false,
            interaction: null,
          });
        }
      }
    }

    return {
      results,
      hasAnyInteraction: interactions.length > 0,
    };
  }
}
