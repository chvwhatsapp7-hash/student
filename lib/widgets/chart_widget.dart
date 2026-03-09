import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ChartConfig {
  final String? label;
  final Color? color;

  ChartConfig({this.label, this.color});
}

class ChartContainer extends StatelessWidget {
  final Map<String, ChartConfig> config;
  final Widget child;

  const ChartContainer({
    super.key,
    required this.config,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: child,
    );
  }
}

// Line Chart Widget
class LineChartWidget extends StatelessWidget {
  final Map<String, ChartConfig> config;
  final List<FlSpot> data;
  final String title;

  const LineChartWidget({
    super.key,
    required this.config,
    required this.data,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final key = config.keys.first;
    final cfg = config[key];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),

        AspectRatio(
          aspectRatio: 1.7,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: true),

              borderData: FlBorderData(show: true),

              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true),
                ),
              ),

              lineTouchData: LineTouchData(
                enabled: true,
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (touchedSpot) => Colors.white,
                  tooltipPadding: const EdgeInsets.all(8),
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      return LineTooltipItem(
                        '${cfg?.label ?? key}\n${spot.y}',
                        TextStyle(
                          color: cfg?.color ?? Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),

              lineBarsData: [
                LineChartBarData(
                  spots: data,
                  isCurved: true,
                  color: cfg?.color ?? Colors.blue,
                  barWidth: 3,
                  dotData: FlDotData(show: true),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Chart Legend Widget
class ChartLegend extends StatelessWidget {
  final Map<String, ChartConfig> config;

  const ChartLegend({
    super.key,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: config.entries.map((entry) {
        return Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: entry.value.color ?? Colors.grey,
                shape: BoxShape.rectangle,
              ),
            ),
            const SizedBox(width: 4),
            Text(entry.value.label ?? entry.key),
            const SizedBox(width: 12),
          ],
        );
      }).toList(),
    );
  }
}