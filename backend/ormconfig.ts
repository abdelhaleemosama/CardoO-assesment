import 'reflect-metadata';
import { DataSource } from 'typeorm';
import { Reading } from './src/readings/entities/reading.entity';
import * as dotenv from 'dotenv';

dotenv.config();

const url = process.env.DATABASE_URL ?? 'postgres://cardoo:cardoo@localhost:5432/cardoo';

export default new DataSource({
  type: 'postgres',
  url,
  entities: [Reading],
  migrations: ['migrations/*.ts'],
  synchronize: false,
  logging: false,
});
