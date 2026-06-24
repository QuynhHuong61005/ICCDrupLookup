import { Module } from '@nestjs/common';
import { PrismaModule } from './prisma/prisma.module';
import { AuthModule } from './auth/auth.module';
import { UsersModule } from './users/users.module';
import { IcdModule } from './icd/icd.module';
import { DrugsModule } from './drugs/drugs.module';
import { InteractionsModule } from './interactions/interactions.module';
import { PrescriptionsModule } from './prescriptions/prescriptions.module';
import { DashboardModule } from './dashboard/dashboard.module';
import { CrClModule } from './crcl/crcl.module';
import { PediatricDoseModule } from './pediatric-dose/pediatric-dose.module';

import { AppController } from './app.controller';

@Module({
  imports: [
    PrismaModule,
    AuthModule,
    UsersModule,
    IcdModule,
    DrugsModule,
    InteractionsModule,
    PrescriptionsModule,
    DashboardModule,
    CrClModule,
    PediatricDoseModule,
  ],
  controllers: [AppController],
  providers: [],
})
export class AppModule {}
