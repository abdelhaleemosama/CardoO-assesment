import 'reflect-metadata';
import dataSource from '../ormconfig';
import { Reading } from '../src/readings/entities/reading.entity';

async function main(): Promise<void> {
  await dataSource.initialize();
  const repo = dataSource.getRepository(Reading);

  const count = 50;
  const now = Date.now();
  const rows: Partial<Reading>[] = Array.from({ length: count }, (_, i) => {
    const t = now - (count - i) * 3000;
    return {
      deviceId: 'esp32-wokwi-1',
      temperature: 22 + Math.sin(i / 4) * 3 + (Math.random() - 0.5),
      humidity: 55 + Math.cos(i / 5) * 8 + (Math.random() - 0.5) * 2,
      createdAt: new Date(t),
    };
  });

  await repo.save(rows as Reading[]);
  console.log(`Seeded ${count} readings`);
  await dataSource.destroy();
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
