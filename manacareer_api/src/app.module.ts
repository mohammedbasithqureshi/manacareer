import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { AuthController } from './auth/auth.controller';
import { OpportunitiesController } from './opportunities/opportunities.controller';
import { ProfileController } from './profile/profile.controller';

@Module({
  imports: [],
  controllers: [AppController, AuthController, OpportunitiesController, ProfileController],
  providers: [AppService],
})
export class AppModule {}