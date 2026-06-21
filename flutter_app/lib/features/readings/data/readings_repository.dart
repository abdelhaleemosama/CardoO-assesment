import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import 'reading_model.dart';

class ReadingsRepository {
  ReadingsRepository(this._dio);
  final Dio _dio;

  Future<Reading> fetchLatest() async {
    final res = await _dio.get<Map<String, dynamic>>('/readings/latest');
    return Reading.fromJson(res.data!);
  }

  Future<List<Reading>> fetchHistory({int limit = 50}) async {
    final res = await _dio.get<List<dynamic>>(
      '/readings',
      queryParameters: {'limit': limit},
    );
    return res.data!
        .map((e) => Reading.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }
}

final readingsRepositoryProvider = Provider<ReadingsRepository>(
  (ref) => ReadingsRepository(ref.watch(dioProvider)),
);
