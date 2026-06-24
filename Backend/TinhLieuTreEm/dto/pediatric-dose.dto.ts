import { IsNumber, IsString, IsOptional, Min, Max } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CalculatePediatricDoseDto {
  @ApiProperty({
    example: 5,
    description: 'Tuổi của trẻ (năm)',
    minimum: 0,
    maximum: 17,
  })
  @IsNumber()
  @Min(0)
  @Max(17)
  age!: number;

  @ApiProperty({
    example: 20,
    description: 'Cân nặng của trẻ (kg)',
    minimum: 0.5,
    maximum: 100,
  })
  @IsNumber()
  @Min(0.5)
  @Max(100)
  weight!: number;

  @ApiProperty({
    example: 10,
    description: 'Liều người lớn (mg)',
    minimum: 0.01,
  })
  @IsNumber()
  @Min(0.01)
  adultDose!: number;

  @ApiPropertyOptional({
    example: 70,
    description: 'Cân nặng người lớn chuẩn (kg) - mặc định 70kg',
    default: 70,
  })
  @IsNumber()
  @IsOptional()
  @Min(40)
  @Max(120)
  adultWeight?: number;

  @ApiPropertyOptional({
    example: 'amoxicillin',
    description: 'Tên thuốc (tuỳ chọn, để tra thêm thông tin)',
  })
  @IsString()
  @IsOptional()
  drugName?: string;
}
