import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hydramind/core/constants/app_colors.dart';
import 'package:provider/provider.dart';
import '../providers/report_provider.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ReportProvider>().loadWeeklyReport();
    });
  }

  @override
  Widget build(BuildContext context) {
    final report = context.watch<ReportProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text("Weekly Report")),
      body: report.isLoading
          ? const Center(child: CircularProgressIndicator())
          : report.weeklyData.isEmpty
              ? const Center(child: Text("No data available"))
              : Column(
                  children: [
                    /// SUMMARY CARD
                    _buildSummary(report),

                    const SizedBox(height: 10),

                    ///  GRAPH ADD
                    _buildGraph(report),

                    const SizedBox(height: 10),

                    /// LIST
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.only(bottom: 20),
                        itemCount: report.weeklyData.length,
                        itemBuilder: (context, index) {
                          final data = report.weeklyData[index];

                          final intake = data['intake'] ?? 0;
                          final goal = data['goal'] ?? 1;
                          final percent =
                              ((intake / goal) * 100).clamp(0, 100).round();

                          return Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 6),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /// TOP ROW
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    /// LEFT
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          data['date'],
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600),
                                        ),
                                        const SizedBox(height: 6),
                                        Text("💧 $intake ml"),
                                      ],
                                    ),

                                    /// RIGHT
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text("🎯 $percent%"),
                                        const SizedBox(height: 4),
                                        Text("😊 ${data['mood'] ?? '-'}"),
                                        Text("⚡ ${data['energy'] ?? '-'}"),
                                      ],
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 10),

                                LinearProgressIndicator(
                                  value: percent / 100,
                                  minHeight: 6,
                                  backgroundColor: Colors.grey.withOpacity(0.2),
                                  valueColor: AlwaysStoppedAnimation(
                                    percent >= 100
                                        ? Colors.green
                                        : Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }

  ///SUMMARY CALCULATION
  Widget _buildSummary(ReportProvider report) {
    final data = report.weeklyData;

    final avgIntake = data.isEmpty
        ? 0
        : (data.map((e) => (e['intake'] ?? 0) as int).reduce((a, b) => a + b) /
                data.length)
            .round();

    final avgGoal = data.isEmpty
        ? 1
        : (data.map((e) => (e['goal'] ?? 0) as int).reduce((a, b) => a + b) /
                data.length)
            .round();

    final percent = ((avgIntake / avgGoal) * 100).clamp(0, 100).round();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "This Week",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text("💧 Avg Intake: $avgIntake ml"),
          Text("🎯 Goal Completion: $percent%"),
        ],
      ),
    );
  }

  Widget _buildGraph(ReportProvider report) {
    final data = report.weeklyData;

    if (data.isEmpty) return const SizedBox();

    ///  SPOTS
    List<FlSpot> spots = [];

    for (int i = 0; i < data.length; i++) {
      final intake = (data[i]['intake'] ?? 0);
      final goal = (data[i]['goal'] ?? 1);

      double percent = (intake / goal) * 100;
      percent = percent.clamp(0, 100);

      spots.add(FlSpot(i.toDouble(), percent));
    }

    ///  MONTH LABEL
    final firstDate = DateTime.parse(data.first['date']);
    final month = "${_getMonth(firstDate.month)} ${firstDate.year}";

    return Column(
      children: [
        Container(
          height: 220,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              ///  Y AXIS LABEL
              RotatedBox(
                quarterTurns: -1,
                child: Text(
                  "Completion (%)",
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: LineChart(
                  LineChartData(
                    minY: 0,
                    maxY: 100,

                    /// GRID
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 25,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: Colors.grey.withOpacity(0.1),
                          strokeWidth: 1,
                        );
                      },
                    ),

                    borderData: FlBorderData(show: false),

                    /// AXIS
                    titlesData: FlTitlesData(
                      /// Y AXIS
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 35,
                          interval: 25,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              "${value.toInt()}%",
                              style: const TextStyle(fontSize: 10),
                            );
                          },
                        ),
                      ),

                      /// X AXIS
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            int index = value.toInt();

                            if (index < 0 || index >= data.length) {
                              return const SizedBox();
                            }

                            final date = DateTime.parse(data[index]['date']);

                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                "${date.day}",
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          },
                        ),
                      ),

                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),

                    /// LINE
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        curveSmoothness: 0.4,
                        barWidth: 3,
                        color: Colors.teal,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, bar, index) {
                            return FlDotCirclePainter(
                              radius: 4,
                              color: Colors.teal,
                              strokeWidth: 2,
                              strokeColor: Colors.white,
                            );
                          },
                        ),

                        //dotData: FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.teal.withOpacity(0.15),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        ///MONTH LABEL
        const SizedBox(height: 6),
        Text(
          month,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  /// MONTH HELPER
  String _getMonth(int month) {
    const months = [
      "",
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December"
    ];
    return months[month];
  }
}
