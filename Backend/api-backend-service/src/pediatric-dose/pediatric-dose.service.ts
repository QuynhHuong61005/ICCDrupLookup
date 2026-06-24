import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class PediatricDoseService {
  constructor(private prisma: PrismaService) {}

  /**
   * Tính liều trẻ em theo công thức Young (dựa trên tuổi):
   * Liều trẻ em = (Tuổi / (Tuổi + 12)) × Liều người lớn
   */
  calculateByYoung(age: number, adultDose: number): number {
    const dose = (age / (age + 12)) * adultDose;
    return Math.round(dose * 100) / 100;
  }

  /**
   * Tính liều trẻ em theo công thức Clark (dựa trên cân nặng):
   * Liều trẻ em = (Cân nặng trẻ / Cân nặng người lớn chuẩn) × Liều người lớn
   */
  calculateByClark(weight: number, adultDose: number, adultWeight: number = 70): number {
    const dose = (weight / adultWeight) * adultDose;
    return Math.round(dose * 100) / 100;
  }

  /**
   * Phân loại nhóm tuổi trẻ em
   */
  classifyAgeGroup(age: number): { group: string; description: string } {
    if (age < 1) {
      return { group: 'INFANT', description: 'Trẻ nhũ nhi (< 1 tuổi)' };
    } else if (age < 2) {
      return { group: 'TODDLER', description: 'Trẻ tập đi (1–2 tuổi)' };
    } else if (age < 6) {
      return { group: 'PRESCHOOL', description: 'Trẻ mầm non (2–5 tuổi)' };
    } else if (age < 12) {
      return { group: 'SCHOOL_AGE', description: 'Trẻ tiểu học (6–11 tuổi)' };
    } else {
      return { group: 'ADOLESCENT', description: 'Trẻ vị thành niên (12–17 tuổi)' };
    }
  }

  /**
   * Lưu ý an toàn khi dùng thuốc cho trẻ em
   */
  getSafetyNote(age: number): string {
    if (age < 1) {
      return 'Trẻ nhũ nhi rất nhạy cảm. Chỉ dùng thuốc khi có chỉ định của bác sĩ nhi khoa.';
    } else if (age < 2) {
      return 'Cần thận trọng cao. Tham khảo bác sĩ trước khi dùng bất kỳ thuốc nào.';
    } else if (age < 6) {
      return 'Kiểm tra kỹ hướng dẫn sử dụng. Nhiều thuốc có phiên bản dạng siro cho trẻ nhỏ.';
    } else {
      return 'Theo dõi phản ứng thuốc và điều chỉnh liều nếu cần thiết.';
    }
  }

  async calculate(
    age: number,
    weight: number,
    adultDose: number,
    adultWeight: number = 70,
    drugName?: string,
    userId?: string,
  ) {
    const doseByYoung = this.calculateByYoung(age, adultDose);
    const doseByClark = this.calculateByClark(weight, adultDose, adultWeight);
    const ageGroup = this.classifyAgeGroup(age);
    const safetyNote = this.getSafetyNote(age);

    // Liều khuyến nghị: trung bình của 2 công thức, làm tròn 2 chữ số
    const recommendedDose = Math.round(((doseByYoung + doseByClark) / 2) * 100) / 100;

    if (userId) {
      try {
        await this.prisma.auditLog.create({
          data: {
            userId,
            action: 'CALCULATE_PEDIATRIC_DOSE',
            tableName: 'pediatric_dose_calculations',
            newValues: {
              age,
              weight,
              adultDose,
              adultWeight,
              drugName,
              recommendedDose,
            },
          },
        });
      } catch (err) {
        console.error('Failed to write audit log for calculatePediatricDose:', err);
      }
    }

    return {
      input: {
        age,
        weight,
        adultDose,
        adultWeight,
        drugName: drugName || null,
      },
      ageGroup,
      results: {
        byYoungFormula: {
          dose: doseByYoung,
          unit: 'mg',
          formula: "Young: (Age / (Age + 12)) × Adult Dose",
        },
        byClarkFormula: {
          dose: doseByClark,
          unit: 'mg',
          formula: "Clark: (Child Weight / Adult Weight) × Adult Dose",
        },
        recommendedDose: {
          dose: recommendedDose,
          unit: 'mg',
          note: 'Trung bình của 2 công thức Young và Clark',
        },
      },
      safetyNote,
      disclaimer:
        'Đây chỉ là liều ước tính. Cần tham khảo bác sĩ hoặc dược sĩ trước khi dùng thuốc cho trẻ em.',
    };
  }
}
