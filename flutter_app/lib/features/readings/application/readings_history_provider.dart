import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/ws_client.dart';
import '../data/reading_model.dart';
import '../data/readings_repository.dart';

/// Last N readings (newest first from the API). Auto-invalidates whenever
/// a new reading arrives over the WebSocket so the chart stays current.
final readingsHistoryProvider = FutureProvider<List<Reading>>((ref) async {
  ref.listen(readingStreamProvider, (_, __) {
    ref.invalidateSelf();
  });
  return ref.watch(readingsRepositoryProvider).fetchHistory(limit: 50);
});
