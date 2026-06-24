import { Controller, Get, Query, Param, UseGuards } from '@nestjs/common';
import { IcdService } from './icd.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { ApiTags, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';

@ApiTags('ICD-10')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('icd')
export class IcdController {
  constructor(private readonly icdService: IcdService) {}

  @Get()
  @ApiQuery({ name: 'q', required: false })
  @ApiQuery({ name: 'page', required: false, type: Number })
  async search(@Query('q') query: string = '', @Query('page') page: string = '1') {
    const pageNum = parseInt(page, 10) || 1;
    const limit = 20;
    const skip = (pageNum - 1) * limit;
    
    const items = await this.icdService.search(query, skip, limit);
    return {
      items,
      page: pageNum,
      hasMore: items.length === limit,
    };
  }

  @Get(':id')
  async findOne(@Param('id') id: string) {
    return this.icdService.findOne(id);
  }
}
