import {
  Body,
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Post,
  Query,
} from '@nestjs/common';
import {
  ApiCreatedResponse,
  ApiNotFoundResponse,
  ApiOkResponse,
  ApiOperation,
  ApiTags,
} from '@nestjs/swagger';
import { CreateReadingDto } from './dto/create-reading.dto';
import { ListReadingsQueryDto } from './dto/list-readings.query.dto';
import { Reading } from './entities/reading.entity';
import { ReadingsService } from './readings.service';

@ApiTags('readings')
@Controller('readings')
export class ReadingsController {
  constructor(private readonly service: ReadingsService) {}

  @Post()
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: 'Submit a new sensor reading' })
  @ApiCreatedResponse({ type: Reading })
  create(@Body() dto: CreateReadingDto): Promise<Reading> {
    return this.service.create(dto);
  }

  @Get('latest')
  @ApiOperation({ summary: 'Get the most recent reading' })
  @ApiOkResponse({ type: Reading })
  @ApiNotFoundResponse({ description: 'No readings yet' })
  latest(): Promise<Reading> {
    return this.service.latest();
  }

  @Get()
  @ApiOperation({ summary: 'List recent readings, newest first' })
  @ApiOkResponse({ type: Reading, isArray: true })
  list(@Query() query: ListReadingsQueryDto): Promise<Reading[]> {
    return this.service.list(query.limit);
  }
}
