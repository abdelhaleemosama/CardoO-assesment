import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/ws_client.dart';
import '../data/reading_model.dart';
import '../data/readings_repository.dart';

/// Always exposes the most recent reading. Bootstraps from REST,
/// then merges WebSocket pushes, plus a 5 s polling fallback for the case
/// where the WS happens to drop.
class LatestReadingNotifier extends AsyncNotifier<Reading> {
  Timer? _poll;

  @override
  Future<Reading> build() async {
    final repo = ref.watch(readingsRepositoryProvider);

    ref.listen(readingStreamProvider, (_, next) {
      next.whenData((reading) => state = AsyncData(reading));
    });

    _poll = Timer.periodic(const Duration(seconds: 5), (_) async {
      try {
        state = AsyncData(await repo.fetchLatest());
      } catch (_) {
        // swallow — keep the last known good value
      }
    });

    ref.onDispose(() => _poll?.cancel());

    return repo.fetchLatest();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      ref.read(readingsRepositoryProvider).fetchLatest,
    );
  }
}

final latestReadingProvider =
    AsyncNotifierProvider<LatestReadingNotifier, Reading>(
  LatestReadingNotifier.new,
);
