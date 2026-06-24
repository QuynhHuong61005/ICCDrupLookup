import { IsArray, IsNotEmpty, IsString, ArrayMinSize } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CheckInteractionsDto {
  @ApiProperty({
    example: ['123e4567-e89b-12d3-a456-426614174000', '123e4567-e89b-12d3-a456-426614174001'],
    description: 'Array of drug IDs (UUIDs) to check for interactions',
    type: [String],
  })
  @IsArray()
  @ArrayMinSize(2)
  @IsString({ each: true })
  @IsNotEmpty({ each: true })
  drugIds!: string[];
}
