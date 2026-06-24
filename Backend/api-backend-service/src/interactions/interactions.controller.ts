import { Controller, Post, Body, UseGuards, Request } from '@nestjs/common';
import { InteractionsService } from './interactions.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { ApiTags, ApiBearerAuth, ApiOperation } from '@nestjs/swagger';
import { CheckInteractionsDto } from './dto/interactions.dto';

@ApiTags('Interactions')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('interactions')
export class InteractionsController {
  constructor(private readonly interactionsService: InteractionsService) {}

  @Post('check-batch')
  @ApiOperation({ summary: 'Check interactions for a list of drug IDs' })
  async checkBatch(@Body() body: CheckInteractionsDto, @Request() req) {
    const userId = req.user?.userId;
    return this.interactionsService.checkInteractions(body.drugIds, userId);
  }
}
