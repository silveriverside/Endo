import 'package:flutter/material.dart';
import '../models/sleep_record.dart';
import '../models/user_settings.dart';
import '../models/custom_calendar.dart';

class SleepService extends ChangeNotifier {
  final List<SleepRecord> _records = [];
  UserSettings _settings = UserSettings();
  Map<String, DateTime>? _currentIdealSchedule;
  bool _isFirstLaunch = true;

  // 获取所有记录
  List<SleepRecord> get records => List.unmodifiable(_records);
  
  // 获取用户设置
  UserSettings get settings => _settings;
  
  // 获取当前理想时间表
  Map<String, DateTime>? get currentIdealSchedule => _currentIdealSchedule;

  // 是否是第一次启动
  bool get isFirstLaunch => _isFirstLaunch;

  // 初始化方法
  void initialize() {
    // 检查是否已经创建过纪元
    if (_settings.currentEra == null) {
      _isFirstLaunch = true;
    } else {
      _isFirstLaunch = false;
    }
    notifyListeners();
  }

  // 创建新纪元
  void createEra(String name) {
    _settings.createEra(name);
    _isFirstLaunch = false;
    notifyListeners();
  }

  // 自定义大周期
  void customizePeriods(List<CustomPeriod> newPeriods) {
    _settings.customizePeriods(newPeriods);
    notifyListeners();
  }

  // 更新用户设置
  void updateSettings(UserSettings newSettings) {
    _settings = newSettings;
    _updateIdealSchedule();
    notifyListeners();
  }

  // 更新生物钟周期
  void updateCircadianRhythm(double hours) {
    _settings.circadianRhythm = hours;
    _updateIdealSchedule();
    notifyListeners();
  }

  // 添加生活事件模板
  void addLifeEventTemplate(LifeEventTemplate template) {
    _settings.addLifeEventTemplate(template);
    _updateIdealSchedule();
    notifyListeners();
  }

  // 更新生活事件模板
  void updateLifeEventTemplate(String id, LifeEventTemplate newTemplate) {
    _settings.updateLifeEventTemplate(id, newTemplate);
    _updateIdealSchedule();
    notifyListeners();
  }

  // 删除生活事件模板
  void removeLifeEventTemplate(String id) {
    _settings.removeLifeEventTemplate(id);
    _updateIdealSchedule();
    notifyListeners();
  }

  // 添加新的睡眠记录
  void addSleepRecord(SleepRecord record) {
    // 检查是否已存在同一天的记录
    final existingIndex = _records.indexWhere((r) => 
      r.date.year == record.date.year && 
      r.date.month == record.date.month && 
      r.date.day == record.date.day
    );

    if (existingIndex != -1) {
      _records[existingIndex] = record;
    } else {
      _records.add(record);
    }

    _updateIdealSchedule();
    notifyListeners();
  }

  // 更新现有记录
  void updateRecord(SleepRecord oldRecord, SleepRecord newRecord) {
    final index = _records.indexWhere((r) => 
      r.date.year == oldRecord.date.year && 
      r.date.month == oldRecord.date.month && 
      r.date.day == oldRecord.date.day
    );
    
    if (index != -1) {
      _records[index] = newRecord;
      _updateIdealSchedule();
      notifyListeners();
    }
  }

  // 获取最近的记录
  SleepRecord? getLatestRecord() {
    if (_records.isEmpty) return null;
    return _records.last;
  }

  // 更新理想时间表
  void _updateIdealSchedule() {
    final latestRecord = getLatestRecord();
    if (latestRecord?.sleepTime != null) {
      _currentIdealSchedule = _settings.generateIdealSchedule(
        latestRecord!.sleepTime!
      );
    } else if (latestRecord?.wakeUpTime != null) {
      // 如果有起床时间但没有入睡时间,根据生物钟周期反推
      final idealSleepTime = latestRecord!.wakeUpTime!.subtract(
        Duration(minutes: (_settings.circadianRhythm * 60 / 3).round())
      );
      _currentIdealSchedule = _settings.generateIdealSchedule(idealSleepTime);
    }
    notifyListeners();
  }

  // 获取今天的记录
  SleepRecord? getTodayRecord() {
    final today = DateTime.now();
    try {
      return _records.firstWhere(
        (record) => 
          record.date.year == today.year &&
          record.date.month == today.month &&
          record.date.day == today.day,
      );
    } catch (e) {
      return null;
    }
  }

  // 计算平均睡眠时长
  Duration? getAverageSleepDuration({int days = 7}) {
    final recentRecords = _records.reversed.take(days).toList();
    if (recentRecords.isEmpty) return null;

    int totalMinutes = 0;
    int validRecords = 0;

    for (var record in recentRecords) {
      if (record.sleepDuration != null) {
        totalMinutes += record.sleepDuration!.inMinutes;
        validRecords++;
      }
    }

    if (validRecords == 0) return null;
    return Duration(minutes: totalMinutes ~/ validRecords);
  }

  // 获取最近的记录列表
  List<SleepRecord> getRecentRecords({int limit = 7}) {
    return _records.reversed.take(limit).toList();
  }

  // 获取当前日历显示
  String getCurrentCalendarDisplay() {
    final latestRecord = getLatestRecord();
    if (latestRecord == null || _settings.currentEra == null) {
      return '尚未创建纪元';
    }
    return _settings.currentEra!.formatDate(DateTime.now());
  }
}