class SleepRecord {
  final DateTime date;
  final DateTime? sleepTime;      // 入睡时间
  final DateTime? wakeUpTime;     // 起床时间
  final DateTime? napStartTime;   // 午睡开始时间
  final Duration? napDuration;    // 午睡时长
  final DateTime? breakfastTime;  // 早餐时间
  final DateTime? lunchTime;      // 午餐时间
  final DateTime? dinnerTime;     // 晚餐时间

  SleepRecord({
    required this.date,
    this.sleepTime,
    this.wakeUpTime,
    this.napStartTime,
    this.napDuration,
    this.breakfastTime,
    this.lunchTime,
    this.dinnerTime,
  });

  // 计算实际睡眠时长
  Duration? get sleepDuration {
    if (sleepTime != null && wakeUpTime != null) {
      return wakeUpTime!.difference(sleepTime!);
    }
    return null;
  }
}

// 理想生活周期时间表
class IdealSchedule {
  final DateTime wakeUpTime;      // 理想起床时间
  final DateTime breakfastTime;   // 理想早餐时间
  final DateTime napStartTime;    // 理想午睡开始时间
  final Duration napDuration;     // 理想午睡时长
  final DateTime lunchTime;       // 理想午餐时间
  final DateTime dinnerTime;      // 理想晚餐时间
  final DateTime sleepTime;       // 理想入睡时间

  IdealSchedule({
    required this.wakeUpTime,
    required this.breakfastTime,
    required this.napStartTime,
    required this.napDuration,
    required this.lunchTime,
    required this.dinnerTime,
    required this.sleepTime,
  });

  // 根据最后一次入睡时间生成新的理想时间表
  static IdealSchedule generateFromLastSleep(DateTime lastSleepTime) {
    // 计算理想的8小时睡眠后的起床时间
    final wakeUpTime = lastSleepTime.add(const Duration(hours: 8));
    
    // 基于起床时间计算其他时间点
    return IdealSchedule(
      wakeUpTime: wakeUpTime,
      breakfastTime: wakeUpTime.add(const Duration(minutes: 30)),
      lunchTime: wakeUpTime.add(const Duration(hours: 5)),
      napStartTime: wakeUpTime.add(const Duration(hours: 6)),
      napDuration: const Duration(minutes: 30),
      dinnerTime: wakeUpTime.add(const Duration(hours: 12)),
      sleepTime: wakeUpTime.add(const Duration(hours: 16)),
    );
  }
}