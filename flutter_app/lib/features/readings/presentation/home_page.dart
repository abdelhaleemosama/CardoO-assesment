import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/api/ws_client.dart';
import '../application/latest_reading_provider.dart';
import '../data/reading_model.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final latest = ref.watch(latestReadingProvider);
    final connected = ref.watch(wsConnectedProvider).valueOrNull ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('CardoO · Live'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: _ConnChip(connected: connected),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(latestReadingProvider.notifier).refresh(),
        child: latest.when(
          loading: () => const _Centered(child: CircularProgressIndicator()),
          error: (e, _) => _Centered(child: _ErrorView(error: e)),
          data: (r) => _ReadingView(reading: r),
        ),
      ),
    );
  }
}

class _ReadingView extends StatelessWidget {
  const _ReadingView({required this.reading});
  final Reading reading;

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat.Hms();
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _Card(
          icon: Icons.thermostat,
          color: Colors.orange,
          label: 'Temperature',
          value: '${reading.temperature.toStringAsFixed(1)} °C',
        ),
        const SizedBox(height: 16),
        _Card(
          icon: Icons.water_drop,
          color: Colors.blue,
          label: 'Humidity',
          value: '${reading.humidity.toStringAsFixed(1)} %',
        ),
        const SizedBox(height: 24),
        Center(
          child: Text(
            'Device ${reading.deviceId} · updated ${fmt.format(reading.createdAt.toLocal())}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.15),
              radius: 32,
              child: Icon(icon, color: color, size: 36),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 6),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConnChip extends StatelessWidget {
  const _ConnChip({required this.connected});
  final bool connected;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(
        connected ? Icons.cloud_done : Icons.cloud_off,
        size: 18,
        color: connected ? Colors.green.shade700 : Colors.red.shade700,
      ),
      label: Text(connected ? 'live' : 'offline'),
      backgroundColor:
          connected ? Colors.green.shade50 : Colors.red.shade50,
      visualDensity: VisualDensity.compact,
    );
  }
}

class _Centered extends StatelessWidget {
  const _Centered({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Center(child: child);
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error});
  final Object error;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 12),
            Text('Failed to load: $error', textAlign: TextAlign.center),
          ],
        ),
      );
}
