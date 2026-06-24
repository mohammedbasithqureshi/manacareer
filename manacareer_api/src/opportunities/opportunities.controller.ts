import { Controller, Get, Param, Query } from '@nestjs/common';
import { prisma } from '../prisma';

@Controller('opportunities')
export class OpportunitiesController {
  @Get()
  findAll(@Query('type') type?: string, @Query('district') district?: string) {
    return prisma.opportunity.findMany({
      where: {
        ...(type && type !== 'all' ? { type } : {}),
        ...(district && district !== 'All districts' ? { district } : {}),
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return prisma.opportunity.findUnique({ where: { id } });
  }
}