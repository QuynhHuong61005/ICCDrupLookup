import { Controller, Post, Body, UseGuards, Request } from '@nestjs/common';
import { PediatricDoseService } from './pediatric-dose.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { ApiTags, ApiBearerAuth, ApiOperation, ApiResponse } from '@nestjs/swagger';
import { CalculatePediatricDoseDto } from './dto/pediatric-dose.dto';

@ApiTags('Pediatric Dose')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('pediatric-dose')
export class PediatricDoseController {
  constructor(private readonly pediatricDoseService: PediatricDoseService) {}

  @Post('calculate')
  @ApiOperation({
    summary: 'Tính liều thuốc cho trẻ em',
    description:
      'Tính liều thuốc phù hợp cho trẻ em dựa trên tuổi và cân nặng theo công thức Young và Clark',
  })
  @ApiResponse({
    status: 201,
    description: 'Kết quả tính liều trẻ em theo 2 công thức',
    schema: {
      example: {
        input: { age: 5, weight: 20, adultDose: 500, adultWeight: 70, drugName: 'amoxicillin' },
        ageGroup: { group: 'PRESCHOOL', description: 'Trẻ mầm non (2–5 tuổi)' },
        results: {
          byYoungFormula: { dose: 147.06, unit: 'mg', formula: 'Young: (Age / (Age + 12)) × Adult Dose' },
          byClarkFormula: { dose: 142.86, unit: 'mg', formula: 'Clark: (Child Weight / Adult Weight) × Adult Dose' },
          recommendedDose: { dose: 144.96, unit: 'mg', note: 'Trung bình của 2 công thức Young và Clark' },
        },
        safetyNote: 'Kiểm tra kỹ hướng dẫn sử dụng. Nhiều thuốc có phiên bản dạng siro cho trẻ nhỏ.',
        disclaimer: 'Đây chỉ là liều ước tính. Cần tham khảo bác sĩ hoặc dược sĩ trước khi dùng thuốc cho trẻ em.',
      },
    },
  })
  async calculate(@Body() body: CalculatePediatricDoseDto, @Request() req) {
    const userId = req.user?.userId;
    return this.pediatricDoseService.calculate(
      body.age,
      body.weight,
      body.adultDose,
      body.adultWeight ?? 70,
      body.drugName,
      userId,
    );
  }
}
