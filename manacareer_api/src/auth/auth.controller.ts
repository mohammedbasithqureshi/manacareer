import { Controller, Post, Body, UnauthorizedException } from '@nestjs/common';
import { getAuth } from 'firebase-admin/auth';
import { prisma } from '../prisma';
import '../firebase-admin';

@Controller('auth')
export class AuthController {
  @Post('google')
  async googleSignIn(@Body('idToken') idToken: string) {
    if (!idToken) throw new UnauthorizedException('Missing idToken');

    const decoded = await getAuth().verifyIdToken(idToken);

    if (!decoded.email) throw new UnauthorizedException('Google account has no email');

    const user = await prisma.user.upsert({
      where: { email: decoded.email },
      update: { name: decoded.name ?? null },
      create: { email: decoded.email, name: decoded.name ?? null },
    });

    return { user };
  }
}