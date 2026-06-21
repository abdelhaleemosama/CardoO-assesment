import { Injectable, Logger, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Reading } from './entities/reading.entity';
import { CreateReadingDto } from './dto/create-reading.dto';
import { ReadingsGateway } from './readings.gateway';

@Injectable()
export class ReadingsService {
  private readonly logger = new Logger(ReadingsService.name);

  constructor(
    @InjectRepository(Reading)
    private readonly readings: Repository<Reading>,
    private readonly gateway: ReadingsGateway,
  ) {}

  async create(dto: CreateReadingDto): Promise<Reading> {
    const saved = await this.readings.save(this.readings.create(dto));
    this.logger.log(
      `[POST] device=${saved.deviceId} temp=${saved.temperature}°C humidity=${saved.humidity}% id=${saved.id}`,
    );
    this.gateway.broadcastNew(saved);
    return saved;
  }

  async latest(): Promise<Reading> {
    const row = await this.readings.findOne({
      where: {},
      order: { createdAt: 'DESC' },
    });
    if (!row) throw new NotFoundException('No readings yet');
    this.logger.debug(`[GET latest] id=${row.id} createdAt=${row.createdAt.toISOString()}`);
    return row;
  }

  list(limit: number): Promise<Reading[]> {
    return this.readings.find({
      order: { createdAt: 'DESC' },
      take: limit,
    });
  }
}
