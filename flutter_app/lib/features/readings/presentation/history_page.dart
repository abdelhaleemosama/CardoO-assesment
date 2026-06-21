import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../application/readings_history_provider.dart';
import '../data/reading_model.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(readingsHistoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('CardoO · History')),
      body: history.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed: $e')),
        data: (rows) {
          if (rows.isEmpty) {
            return const Center(child: Text('No readings yet'));
          }
          // API returns newest first; chart wants oldest first.
          final ordered = rows.reversed.toList();
          return Padding(
            padding: const EdgeInsets.fromLTRB(12, 16, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Legend(),
                const SizedBox(height: 12),
                Expanded(child: _Chart(rows: ordered)),
                const SizedBox(height: 8),
                Text(
                  'Last ${ordered.length} readings',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        _Swatch(color: Colors.orange, label: 'Temperature (°C)'),
        SizedBox(width: 20),
        _Swatch(color: Colors.blue, label: 'Humidity (%)'),
      ],
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.color, required this.label});
  final Color color;
  final String label;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(label),
      ],
    );
  }
}

class _Chart extends StatelessWidget {
  const _Chart({required this.rows});
  final List<Reading> rows;

  @override
  Widget build(BuildContext context) {
    final tempSpots = <FlSpot>[];
    final humSpots = <FlSpot>[];
    for (var i = 0; i < rows.length; i++) {
      tempSpots.add(FlSpot(i.toDouble(), rows[i].temperature));
      humSpots.add(FlSpot(i.toDouble(), rows[i].humidity));
    }

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: 100,
        gridData: const FlGridData(show: true),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 36),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: (rows.length / 5).clamp(1, 9999).toDouble(),
              reservedSize: 28,
              getTitlesWidget: (v, _) {
                final idx = v.toInt();
                if (idx < 0 || idx >= rows.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    DateFormat.Hm().format(rows[idx].createdAt.toLocal()),
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: tempSpots,
            color: Colors.orange,
            barWidth: 2.5,
            isCurved: true,
            dotData: const FlDotData(show: false),
          ),
          LineChartBarData(
            spots: humSpots,
            color: Colors.blue,
            barWidth: 2.5,
            isCurved: true,
            dotData: const FlDotData(show: false),
          ),
        ],
      ),
    );
  }
}
