import {
  Column,
  CreateDateColumn,
  Entity,
  Index,
  PrimaryGeneratedColumn,
} from 'typeorm';
import { ApiProperty } from '@nestjs/swagger';

@Entity('readings')
export class Reading {
  @ApiProperty({ format: 'uuid' })
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @ApiProperty({ example: 'esp32-wokwi-1' })
  @Index()
  @Column({ length: 64 })
  deviceId!: string;

  @ApiProperty({ example: 24.7, description: 'Temperature in °C' })
  @Column('double precision')
  temperature!: number;

  @ApiProperty({ example: 58.3, description: 'Relative humidity in %' })
  @Column('double precision')
  humidity!: number;

  @ApiProperty({ type: String, format: 'date-time' })
  @CreateDateColumn({ type: 'timestamptz' })
  createdAt!: Date;
}
