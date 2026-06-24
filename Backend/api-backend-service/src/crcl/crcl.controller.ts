import { Controller, Post, Body, UseGuards, Request } from '@nestjs/common';
import { CrClService } from './crcl.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { ApiTags, ApiBearerAuth, ApiOperation, ApiResponse } from '@nestjs/swagger';
import { CalculateCrClDto } from './dto/crcl.dto';

@ApiTags('CrCl')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('crcl')
export class CrClController {
  constructor(private readonly crclService: CrClService) {}

  @Post('calculate')
  @ApiOperation({
    summary: 'Tính CrCl (Creatinine Clearance) theo công thức Cockcroft-Gault',
    description:
      'Tính độ thanh thải creatinine để đánh giá chức năng thận và hỗ trợ điều chỉnh liều thuốc',
  })
  @ApiResponse({
    status: 201,
    description: 'Kết quả tính CrCl và phân loại chức năng thận',
    schema: {
      example: {
        input: { age: 72, weight: 70, serumCreatinine: 1.2, gender: 'male' },
        crcl: 56.94,
        unit: 'mL/min',
        formula: 'Cockcroft-Gault',
        renalFunction: {
          classification: 'MODERATE_IMPAIRMENT',
          description: 'Suy thận trung bình',
          recommendation: 'Cần điều chỉnh liều nhiều loại thuốc',
        },
      },
    },
  })
  async calculate(@Body() body: CalculateCrClDto, @Request() req) {
    const userId = req.user?.userId;
    return this.crclService.calculate(
      body.age,
      body.weight,
      body.serumCreatinine,
      body.gender,
      userId,
    );
  }
}
