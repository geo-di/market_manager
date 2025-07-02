import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:market_manager/constants.dart';
import 'package:intl/intl.dart';
import 'dart:core';

class HistoryLineChart extends StatefulWidget {

  final Map<DateTime, double> data;
  final bool isInteractive;

  const HistoryLineChart({super.key, required this.data, required this.isInteractive});

  @override
  State<HistoryLineChart> createState() => _HistoryLineChartState();
}

class _HistoryLineChartState extends State<HistoryLineChart> {

  bool showAvg = false;
  late List<FlSpot> _spots;
  late List<DateTime> _dates;

  Color get chartColor {
    return Theme.of(context).brightness == Brightness.dark
        ? kLightAppBarBackground
        : kPrimaryDarkColor;
  }


  @override
  void initState() {
    super.initState();
    _prepareData();
  }

  void _prepareData() {

    final entries = widget.data.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    if (entries.isEmpty) {
      _dates = [];
      _spots = [];
      return;
    }

    final latestDate = entries.last.key;
    final cutoffDate = DateTime(latestDate.year, latestDate.month - 3, latestDate.day);

    final filtered = entries.where((e) => e.key.isAfter(cutoffDate) || e.key.isAtSameMomentAs(cutoffDate)).toList();

    _dates = filtered.map((e) => e.key).toList();
    _spots = [
      for (int i = 0; i < filtered.length; i++)
        FlSpot(i.toDouble(), filtered[i].value)
    ];
  }

  @override
  Widget build(BuildContext context) {

    return !widget.isInteractive
      ? Padding(
          padding: const EdgeInsets.only(
            right: 25,
            left: 12,
            top: 35,
            bottom: 12,
          ),
          child: LineChart(
            mainData(),
          ),
        )
      : Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(
              right: 25,
              left: 12,
              top: 35,
              bottom: 12,
            ),
            child: LineChart(
              showAvg ? avgData() : mainData(),
            ),
          ),
          SizedBox(
            width: 60,
            height: 34,
            child: TextButton(
              onPressed: () {
                setState(() {
                  showAvg = !showAvg;
                });
              },
              child: Text(
                'avg',
                style: TextStyle(
                  fontSize: 12,
                  color: showAvg
                      ? kAppWhite.withValues(alpha: 0.5)
                      : kAppWhite,
                ),
              ),
            ),
          ),
        ],
      );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(fontWeight: FontWeight.bold, fontSize: 12);

    if (value < 0 || value >= _dates.length) return const SizedBox();

    final date = _dates[value.toInt()];
    final label = DateFormat.MMMd().format(date);

    return SideTitleWidget(
      meta: meta,
      space: 8,
      child: Text(label, style: style),
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(fontWeight: FontWeight.bold, fontSize: 12);

    final minY = _spots.map((e) => e.y).reduce((a, b) => a < b ? a : b);

    if (value.toInt() == minY.toInt() - 1) {
      return const SizedBox();
    }

    return Text('${value.toInt()}', style: style, textAlign: TextAlign.left);
  }


  LineChartData mainData() {
    return LineChartData(
      lineTouchData: LineTouchData(
        enabled: widget.isInteractive
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: (_spots.isEmpty)
            ? 1
            : ((_spots.map((e) => e.y).reduce((a, b) => a > b ? a : b) -
            _spots.map((e) => e.y).reduce((a, b) => a < b ? a : b)) /
            4)
            .clamp(1, double.infinity),
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) => const FlLine(
          color: Colors.white,
          strokeWidth: 1,
        ),
        getDrawingVerticalLine: (value) => const FlLine(
          color: Colors.white,
          strokeWidth: 1,
        ),
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
            reservedSize: 32,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: leftTitleWidgets,
            interval: (_spots.isEmpty)
                ? 1
                : ((_spots.map((e) => e.y).reduce((a, b) => a > b ? a : b) -
                _spots.map((e) => e.y).reduce((a, b) => a < b ? a : b)) /
                4)
                .clamp(1, double.infinity),
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: (_spots.length - 1).toDouble(),
      minY: _spots.map((e) => e.y).reduce((a, b) => a < b ? a : b) - 1,
      maxY: _spots.map((e) => e.y).reduce((a, b) => a > b ? a : b) + 1,
      lineBarsData: [
        LineChartBarData(
          spots: _spots,
          isCurved: true,
          color: chartColor,
          barWidth: 4,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: chartColor.withAlpha(100)

          ),
        ),
      ],
    );
  }

  LineChartData avgData() {
    final average = _spots.isNotEmpty
        ? _spots.map((e) => e.y).reduce((a, b) => a + b) / _spots.length
        : 0.0;

    return mainData().copyWith(
      lineBarsData: [
        LineChartBarData(
          spots: List.generate(
            _spots.length,
                (index) => FlSpot(index.toDouble(), average),
          ),
          isCurved: true,
          color: chartColor,
          barWidth: 4,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: chartColor.withAlpha(100),
          ),
        ),
      ],
    );
  }
}