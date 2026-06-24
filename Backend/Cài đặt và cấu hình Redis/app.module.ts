import { Module } from '@nestjs/common';
import { PrismaModule } from './prisma/prisma.module';
import { AuthModule } from './auth/auth.module';
import { UsersModule } from './users/users.module';
import { IcdModule } from './icd/icd.module';
import { DrugsModule } from './drugs/drugs.module';
import { InteractionsModule } from './interactions/interactions.module';
import { PrescriptionsModule } from './prescriptions/prescriptions.module';
import { DashboardModule } from './dashboard/dashboard.module';

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
  ],
  controllers: [AppController],
  providers: [],
})
export class AppModule {}
