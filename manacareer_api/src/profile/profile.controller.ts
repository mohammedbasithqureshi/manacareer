import { Controller, Get, Post, Body, Param } from '@nestjs/common';
import { prisma } from '../prisma';

@Controller('profile')
export class ProfileController {

  @Get(':firebaseUid')
  async getProfile(@Param('firebaseUid') firebaseUid: string) {
    const profile = await prisma.profile.findUnique({
      where: { firebaseUid },
    });
    return profile ?? { exists: false };
  }

  @Post()
  async saveProfile(@Body() body: any) {
    const { firebaseUid, ...data } = body;
    const profile = await prisma.profile.upsert({
      where: { firebaseUid },
      update: { ...data, updatedAt: new Date() },
      create: { firebaseUid, ...data },
    });
    return profile;
  }
}