import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/sleep_service.dart';
import '../models/sleep_record.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('司辰'),
          bottom: const TabBar(
            tabs: [
              Tab(text: '今日计划'),
              Tab(text: '记录'),
              Tab(text: '日历视图'),
              Tab(text: '设置'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            IdealScheduleView(),
            RecordView(),
            CalendarDataView(),
            SettingsScreen(),
          ],
        ),
      ),
    );
  }
}

class IdealScheduleView extends StatelessWidget {
  const IdealScheduleView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SleepService>(
      builder: (context, sleepService, child) {
        final idealSchedule = sleepService.currentIdealSchedule;
        final currentCalendar = sleepService.getCurrentCalendarDisplay();
        
        if (idealSchedule == null) {
          return const Center(
            child: Text('还没有记录睡眠数据,无法生成理想时间表'),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '当前日历',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currentCalendar,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildScheduleCard(
              '理想作息时间表',
              sleepService.settings.lifeEventTemplates.map((template) {
                final time = idealSchedule[template.id];
                if (time == null) return const SizedBox.shrink();
                
                return _buildTimeRow(template.name, time);
              }).whereType<Widget>().toList(),
            ),
            const SizedBox(height: 16),
            _buildAverageSleepCard(context, sleepService),
            const SizedBox(height: 16),
            _buildCircadianInfo(context, sleepService),
          ],
        );
      },
    );
  }

  Widget _buildScheduleCard(String title, List<Widget> rows) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            ...rows,
          ],
        ),
      ),
    );
  }

  Widget _buildTimeRow(String label, DateTime time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(DateFormat('HH:mm').format(time)),
        ],
      ),
    );
  }

  Widget _buildAverageSleepCard(BuildContext context, SleepService service) {
    final avgDuration = service.getAverageSleepDuration();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '睡眠统计',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            Text(
              '最近7天平均睡眠时长: ${avgDuration?.inHours ?? 0}小时'
              ' ${(avgDuration?.inMinutes ?? 0) % 60}分钟',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircadianInfo(BuildContext context, SleepService service) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '生物钟信息',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            Text('当前生物钟周期: ${service.settings.circadianRhythm.toStringAsFixed(1)}小时'),
            Text(
              '理想睡眠时长: ${(service.settings.circadianRhythm / 3).toStringAsFixed(1)}小时'
            ),
          ],
        ),
      ),
    );
  }
}

class RecordView extends StatefulWidget {
  const RecordView({Key? key}) : super(key: key);

  @override
  State<RecordView> createState() => _RecordViewState();
}

class _RecordViewState extends State<RecordView> {
  DateTime selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          selectedDate.hour,
          selectedDate.minute,
        );
      });
    }
  }

  Future<void> _selectTime(BuildContext context, String label, DateTime? initialTime, Function(DateTime) onTimeSelected) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialTime ?? DateTime.now()),
    );

    if (picked != null) {
      final selectedTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        picked.hour,
        picked.minute,
      );
      onTimeSelected(selectedTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SleepService>(
      builder: (context, sleepService, child) {
        final todayRecord = sleepService.getTodayRecord();
        final recentRecords = sleepService.getRecentRecords();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '记录',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => _selectDate(context),
                          icon: const Icon(Icons.calendar_today),
                          label: Text(DateFormat('yyyy-MM-dd').format(selectedDate)),
                        ),
                      ],
                    ),
                    const Divider(),
                    _buildRecordButton(
                      context,
                      '记录起床时间',
                      todayRecord?.wakeUpTime,
                      (time) {
                        final newRecord = SleepRecord(
                          date: selectedDate,
                          wakeUpTime: time,
                          sleepTime: todayRecord?.sleepTime,
                          napStartTime: todayRecord?.napStartTime,
                          napDuration: todayRecord?.napDuration,
                          breakfastTime: todayRecord?.breakfastTime,
                          lunchTime: todayRecord?.lunchTime,
                          dinnerTime: todayRecord?.dinnerTime,
                        );
                        sleepService.addSleepRecord(newRecord);
                      },
                    ),
                    _buildRecordButton(
                      context,
                      '记录入睡时间',
                      todayRecord?.sleepTime,
                      (time) {
                        final newRecord = SleepRecord(
                          date: selectedDate,
                          sleepTime: time,
                          wakeUpTime: todayRecord?.wakeUpTime,
                          napStartTime: todayRecord?.napStartTime,
                          napDuration: todayRecord?.napDuration,
                          breakfastTime: todayRecord?.breakfastTime,
                          lunchTime: todayRecord?.lunchTime,
                          dinnerTime: todayRecord?.dinnerTime,
                        );
                        sleepService.addSleepRecord(newRecord);
                      },
                    ),
                    if (todayRecord != null) ...[
                      const Divider(),
                      Text('睡眠时长: ${_formatDuration(todayRecord.sleepDuration)}'),
                    ],
                  ],
                ),
              ),
            ),
            if (recentRecords.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                '历史记录',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...recentRecords.map((record) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('yyyy-MM-dd').format(record.date),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (record.wakeUpTime != null)
                        Text('起床时间: ${DateFormat('HH:mm').format(record.wakeUpTime!)}'),
                      if (record.sleepTime != null)
                        Text('入睡时间: ${DateFormat('HH:mm').format(record.sleepTime!)}'),
                      if (record.sleepDuration != null)
                        Text('睡眠时长: ${_formatDuration(record.sleepDuration)}'),
                    ],
                  ),
                ),
              )).toList(),
            ],
          ],
        );
      },
    );
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return '尚未完成记录';
    return '${duration.inHours}小时 ${duration.inMinutes % 60}分钟';
  }

  Widget _buildRecordButton(
    BuildContext context,
    String label,
    DateTime? time,
    Function(DateTime) onTimeSelected,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          TextButton(
            onPressed: () => _selectTime(context, label, time, onTimeSelected),
            child: Text(
              time != null
                  ? DateFormat('HH:mm').format(time)
                  : '点击记录',
            ),
          ),
        ],
      ),
    );
  }
}

class CalendarDataView extends StatefulWidget {
  const CalendarDataView({Key? key}) : super(key: key);

  @override
  State<CalendarDataView> createState() => _CalendarDataViewState();
}

class _CalendarDataViewState extends State<CalendarDataView> {
  @override
  Widget build(BuildContext context) {
    return Consumer<SleepService>(
      builder: (context, sleepService, child) {
        final recentRecords = sleepService.getRecentRecords(limit: 10).reversed.toList();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              '睡眠周期分析',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            _buildSleepDurationChart(recentRecords),
            const SizedBox(height: 16),
            _buildAwakeDurationChart(recentRecords),
            const SizedBox(height: 16),
            _buildDetailedRecordTable(recentRecords),
          ],
        );
      },
    );
  }

  Widget _buildSleepDurationChart(List<SleepRecord> records) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              '睡眠时长',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _calculateMaxDuration(records, isSleep: true),
                  barGroups: records.map((record) {
                    final sleepDuration = record.sleepDuration?.inHours.toDouble() ?? 0;
                    return BarChartGroupData(
                      x: records.indexOf(record),
                      barRods: [
                        BarChartRodData(
                          toY: sleepDuration,
                          color: Colors.blue,
                          width: 16,
                        ),
                      ],
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) => Text(
                          DateFormat('MM-dd').format(records[value.toInt()].date),
                          style: const TextStyle(fontSize: 10),
                        ),
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAwakeDurationChart(List<SleepRecord> records) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              '清醒时长',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _calculateMaxDuration(records, isSleep: false),
                  barGroups: records.map((record) {
                    final awakeDuration = _calculateAwakeDuration(record)?.inHours.toDouble() ?? 0;
                    return BarChartGroupData(
                      x: records.indexOf(record),
                      barRods: [
                        BarChartRodData(
                          toY: awakeDuration,
                          color: Colors.orange,
                          width: 16,
                        ),
                      ],
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) => Text(
                          DateFormat('MM-dd').format(records[value.toInt()].date),
                          style: const TextStyle(fontSize: 10),
                        ),
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedRecordTable(List<SleepRecord> records) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              '详细记录',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Table(
              border: TableBorder.all(color: Colors.grey[300]!),
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1.5),
                2: FlexColumnWidth(1.5),
                3: FlexColumnWidth(1.5),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(color: Colors.grey[200]),
                  children: const [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('日期', textAlign: TextAlign.center),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('起床时间', textAlign: TextAlign.center),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('入睡时间', textAlign: TextAlign.center),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('睡眠时长', textAlign: TextAlign.center),
                    ),
                  ],
                ),
                ...records.map((record) => TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        DateFormat('MM-dd').format(record.date),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        record.wakeUpTime != null 
                          ? DateFormat('HH:mm').format(record.wakeUpTime!) 
                          : '-',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        record.sleepTime != null 
                          ? DateFormat('HH:mm').format(record.sleepTime!) 
                          : '-',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        record.sleepDuration != null
                          ? '${record.sleepDuration!.inHours}时${record.sleepDuration!.inMinutes % 60}分'
                          : '-',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                )).toList(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  double _calculateMaxDuration(List<SleepRecord> records, {bool isSleep = true}) {
    final durations = records.map((record) {
      if (isSleep) {
        return record.sleepDuration?.inHours.toDouble() ?? 0;
      } else {
        return _calculateAwakeDuration(record)?.inHours.toDouble() ?? 0;
      }
    });
    return durations.isNotEmpty ? (durations.reduce((a, b) => a > b ? a : b) * 1.2) : 10;
  }

  Duration? _calculateAwakeDuration(SleepRecord record) {
    if (record.wakeUpTime != null && record.sleepTime != null) {
      return record.sleepTime!.difference(record.wakeUpTime!);
    }
    return null;
  }
}