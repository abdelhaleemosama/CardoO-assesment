import { ApiProperty } from '@nestjs/swagger';
import { IsNumber, IsString, Length, Max, Min } from 'class-validator';

export class CreateReadingDto {
  @ApiProperty({ example: 'esp32-wokwi-1', minLength: 1, maxLength: 64 })
  @IsString()
  @Length(1, 64)
  deviceId!: string;

  @ApiProperty({ example: 24.7, minimum: -50, maximum: 100 })
  @IsNumber()
  @Min(-50)
  @Max(100)
  temperature!: number;

  @ApiProperty({ example: 58.3, minimum: 0, maximum: 100 })
  @IsNumber()
  @Min(0)
  @Max(100)
  humidity!: number;
}
