import { Controller, Get } from '@nestjs/common';

@Controller()
export class AppController {
  @Get()
  getRoot(): string {
    return 'ManaCareer API is running';
  }

  @Get('health')
  getHealth() {
    return { status: 'ok' };
  }
}