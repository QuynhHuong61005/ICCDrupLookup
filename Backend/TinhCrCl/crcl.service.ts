import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class CrClService {
  constructor(private prisma: PrismaService) {}

  /**
   * Tính CrCl (Creatinine Clearance) theo công thức Cockcroft-Gault:
   * CrCl = [(140 - age) × weight] / (72 × serum creatinine)
   * Nhân 0.85 nếu là nữ
   */
  calculateCrCl(age: number, weight: number, serumCreatinine: number, gender: string): number {
    const base = ((140 - age) * weight) / (72 * serumCreatinine);
    const crcl = gender === 'female' ? base * 0.85 : base;
    return Math.round(crcl * 100) / 100; // Làm tròn 2 chữ số thập phân
  }

  /**
   * Phân loại mức độ suy thận dựa trên CrCl
   */
  classifyRenalFunction(crcl: number): {
    classification: string;
    description: string;
    recommendation: string;
  } {
    if (crcl >= 90) {
      return {
        classification: 'NORMAL',
        description: 'Chức năng thận bình thường',
        recommendation: 'Không cần điều chỉnh liều',
      };
    } else if (crcl >= 60) {
      return {
        classification: 'MILD_IMPAIRMENT',
        description: 'Suy thận nhẹ',
        recommendation: 'Theo dõi, có thể cần điều chỉnh liều một số thuốc',
      };
    } else if (crcl >= 30) {
      return {
        classification: 'MODERATE_IMPAIRMENT',
        description: 'Suy thận trung bình',
        recommendation: 'Cần điều chỉnh liều nhiều loại thuốc',
      };
    } else if (crcl >= 15) {
      return {
        classification: 'SEVERE_IMPAIRMENT',
        description: 'Suy thận nặng',
        recommendation: 'Cần điều chỉnh liều đáng kể, tham khảo chuyên gia',
      };
    } else {
      return {
        classification: 'KIDNEY_FAILURE',
        description: 'Suy thận giai đoạn cuối',
        recommendation: 'Cần tư vấn chuyên gia thận học, nhiều thuốc chống chỉ định',
      };
    }
  }

  async calculate(
    age: number,
    weight: number,
    serumCreatinine: number,
    gender: string,
    userId?: string,
  ) {
    const crcl = this.calculateCrCl(age, weight, serumCreatinine, gender);
    const renalFunction = this.classifyRenalFunction(crcl);

    if (userId) {
      try {
        await this.prisma.auditLog.create({
          data: {
            userId,
            action: 'CALCULATE_CRCL',
            tableName: 'crcl_calculations',
            newValues: { age, weight, serumCreatinine, gender, crcl },
          },
        });
      } catch (err) {
        console.error('Failed to write audit log for calculateCrCl:', err);
      }
    }

    return {
      input: { age, weight, serumCreatinine, gender },
      crcl,
      unit: 'mL/min',
      formula: 'Cockcroft-Gault',
      renalFunction,
    };
  }
}
