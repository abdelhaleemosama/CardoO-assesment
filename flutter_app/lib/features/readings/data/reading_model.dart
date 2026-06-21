import 'package:freezed_annotation/freezed_annotation.dart';

part 'reading_model.freezed.dart';
part 'reading_model.g.dart';

@freezed
class Reading with _$Reading {
  const factory Reading({
    required String id,
    required String deviceId,
    required double temperature,
    required double humidity,
    required DateTime createdAt,
  }) = _Reading;

  factory Reading.fromJson(Map<String, dynamic> json) => _$ReadingFromJson(json);
}
