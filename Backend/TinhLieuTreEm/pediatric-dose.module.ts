import { Module } from '@nestjs/common';
import { PediatricDoseService } from './pediatric-dose.service';
import { PediatricDoseController } from './pediatric-dose.controller';

@Module({
  providers: [PediatricDoseService],
  controllers: [PediatricDoseController],
  exports: [PediatricDoseService],
})
export class PediatricDoseModule {}
