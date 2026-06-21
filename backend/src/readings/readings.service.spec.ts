import { Test } from '@nestjs/testing';
import { NotFoundException } from '@nestjs/common';
import { getRepositoryToken } from '@nestjs/typeorm';
import { Reading } from './entities/reading.entity';
import { ReadingsService } from './readings.service';
import { ReadingsGateway } from './readings.gateway';

describe('ReadingsService', () => {
  let service: ReadingsService;
  let repo: {
    create: jest.Mock;
    save: jest.Mock;
    find: jest.Mock;
    findOne: jest.Mock;
  };
  let gateway: { broadcastNew: jest.Mock };

  beforeEach(async () => {
    repo = {
      create: jest.fn((x) => x as Reading),
      save: jest.fn(),
      find: jest.fn(),
      findOne: jest.fn(),
    };
    gateway = { broadcastNew: jest.fn() };

    const moduleRef = await Test.createTestingModule({
      providers: [
        ReadingsService,
        { provide: getRepositoryToken(Reading), useValue: repo },
        { provide: ReadingsGateway, useValue: gateway },
      ],
    }).compile();

    service = moduleRef.get(ReadingsService);
  });

  it('create() persists the reading and broadcasts via WS', async () => {
    const dto = { deviceId: 'esp32-test', temperature: 25.5, humidity: 60 };
    const saved: Reading = {
      id: 'r-1',
      ...dto,
      createdAt: new Date('2026-01-01T00:00:00Z'),
    };
    repo.save.mockResolvedValue(saved);

    const result = await service.create(dto);

    expect(repo.create).toHaveBeenCalledWith(dto);
    expect(repo.save).toHaveBeenCalled();
    expect(gateway.broadcastNew).toHaveBeenCalledWith(saved);
    expect(result).toEqual(saved);
  });

  it('latest() throws 404 when nothing exists', async () => {
    repo.findOne.mockResolvedValue(null);
    await expect(service.latest()).rejects.toBeInstanceOf(NotFoundException);
  });

  it('latest() returns the most recent row', async () => {
    const row: Reading = {
      id: 'r-2',
      deviceId: 'esp32-test',
      temperature: 24,
      humidity: 55,
      createdAt: new Date(),
    };
    repo.findOne.mockResolvedValue(row);
    await expect(service.latest()).resolves.toBe(row);
    expect(repo.findOne).toHaveBeenCalledWith({
      where: {},
      order: { createdAt: 'DESC' },
    });
  });

  it('list(limit) delegates with order desc and take limit', async () => {
    const rows: Reading[] = [];
    repo.find.mockResolvedValue(rows);
    await expect(service.list(25)).resolves.toBe(rows);
    expect(repo.find).toHaveBeenCalledWith({
      order: { createdAt: 'DESC' },
      take: 25,
    });
  });
});
