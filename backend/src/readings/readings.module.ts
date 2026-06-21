import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Reading } from './entities/reading.entity';
import { ReadingsController } from './readings.controller';
import { ReadingsService } from './readings.service';
import { ReadingsGateway } from './readings.gateway';

@Module({
  imports: [TypeOrmModule.forFeature([Reading])],
  controllers: [ReadingsController],
  providers: [ReadingsService, ReadingsGateway],
})
export class ReadingsModule {}
