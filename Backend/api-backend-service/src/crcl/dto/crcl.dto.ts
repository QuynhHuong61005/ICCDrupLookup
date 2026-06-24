import { IsNumber, IsString, IsIn, Min, Max } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CalculateCrClDto {
  @ApiProperty({
    example: 72,
    description: 'Age of the patient in years',
    minimum: 0,
    maximum: 120,
  })
  @IsNumber()
  @Min(0)
  @Max(120)
  age!: number;

  @ApiProperty({
    example: 70,
    description: 'Weight of the patient in kilograms',
    minimum: 1,
    maximum: 300,
  })
  @IsNumber()
  @Min(1)
  @Max(300)
  weight!: number;

  @ApiProperty({
    example: 1.2,
    description: 'Serum creatinine level in mg/dL',
    minimum: 0.1,
  })
  @IsNumber()
  @Min(0.1)
  serumCreatinine!: number;

  @ApiProperty({
    example: 'male',
    description: 'Gender of the patient: male or female',
    enum: ['male', 'female'],
  })
  @IsString()
  @IsIn(['male', 'female'])
  gender!: string;
}
