import { MigrationInterface, QueryRunner } from 'typeorm';

export class InitReadings1700000000000 implements MigrationInterface {
  name = 'InitReadings1700000000000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      CREATE TABLE "readings" (
        "id" uuid NOT NULL DEFAULT gen_random_uuid(),
        "deviceId" varchar(64) NOT NULL,
        "temperature" double precision NOT NULL,
        "humidity" double precision NOT NULL,
        "createdAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
        CONSTRAINT "PK_readings_id" PRIMARY KEY ("id")
      )
    `);
    await queryRunner.query(
      `CREATE INDEX "IDX_readings_deviceId" ON "readings" ("deviceId")`,
    );
    await queryRunner.query(
      `CREATE INDEX "IDX_readings_createdAt" ON "readings" ("createdAt" DESC)`,
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`DROP INDEX "IDX_readings_createdAt"`);
    await queryRunner.query(`DROP INDEX "IDX_readings_deviceId"`);
    await queryRunner.query(`DROP TABLE "readings"`);
  }
}
