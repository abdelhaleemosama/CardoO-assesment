import { Logger } from '@nestjs/common';
import {
  OnGatewayConnection,
  OnGatewayDisconnect,
  WebSocketGateway,
  WebSocketServer,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';
import { Reading } from './entities/reading.entity';

@WebSocketGateway({ cors: { origin: '*' } })
export class ReadingsGateway implements OnGatewayConnection, OnGatewayDisconnect {
  private readonly logger = new Logger(ReadingsGateway.name);

  @WebSocketServer()
  server!: Server;

  handleConnection(client: Socket): void {
    this.logger.log(`WS connected: ${client.id}`);
  }

  handleDisconnect(client: Socket): void {
    this.logger.log(`WS disconnected: ${client.id}`);
  }

  broadcastNew(reading: Reading): void {
    this.server.emit('reading:new', reading);
  }
}
