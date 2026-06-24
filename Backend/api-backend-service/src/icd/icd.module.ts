import { Module } from '@nestjs/common';
import { IcdService } from './icd.service';
import { IcdController } from './icd.controller';

@Module({
  providers: [IcdService],
  controllers: [IcdController],
})
export class IcdModule {}
