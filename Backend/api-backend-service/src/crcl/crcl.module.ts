import { Module } from '@nestjs/common';
import { CrClService } from './crcl.service';
import { CrClController } from './crcl.controller';

@Module({
  providers: [CrClService],
  controllers: [CrClController],
  exports: [CrClService],
})
export class CrClModule {}
