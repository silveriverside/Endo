class Era {
  String name;
  DateTime startDate;
  List<CustomPeriod> periods;

  Era({
    required this.name,
    DateTime? startDate,
    List<CustomPeriod>? periods,
  }) : 
    startDate = startDate ?? DateTime.now(),
    periods = periods ?? [
      CustomPeriod(name: '云', duration: 1),
      CustomPeriod(name: '星', duration: 3),
      CustomPeriod(name: '摇光', duration: 12),
    ];

  // 计算当前所处的大周期
  Map<String, int> calculateCurrentPeriods(DateTime referenceDate) {
    final daysSinceStart = referenceDate.difference(startDate).inDays;
    
    final Map<String, int> currentPeriods = {};
    
    for (var period in periods) {
      currentPeriods[period.name] = (daysSinceStart ~/ period.duration) + 1;
    }
    
    return currentPeriods;
  }

  // 计算从纪元开始到当前时间的精确时间
  Duration calculateTimeSinceStart(DateTime referenceDate) {
    return referenceDate.difference(startDate);
  }

  // 格式化日期显示
  String formatDate(DateTime date) {
    final currentPeriods = calculateCurrentPeriods(date);
    final timeSinceStart = calculateTimeSinceStart(date);
    
    final periodStrings = currentPeriods.entries
      .map((entry) => '${entry.value}${entry.key}')
      .join('-');
    
    final timeString = '${timeSinceStart.inHours}时'
      '-${timeSinceStart.inMinutes % 60}分'
      '-${timeSinceStart.inSeconds % 60}秒';
    
    return '$name历-$periodStrings-$timeString';
  }
}

class CustomPeriod {
  String name;  // 周期名称,如'云'、'星'、'摇光'
  int duration; // 周期包含的天数

  CustomPeriod({
    required this.name,
    required this.duration,
  });

  // 验证周期名称是否合法
  static bool isValidPeriodName(String name) {
    // 不超过10个汉字或20个英文字母
    final RegExp validNameRegex = RegExp(r'^[\u4e00-\u9fa5]{1,10}|[a-zA-Z]{1,20}$');
    return validNameRegex.hasMatch(name);
  }
}

class CalendarManager {
  static Era? _currentEra;

  // 创建新纪元
  static Era createEra(String name) {
    if (!CustomPeriod.isValidPeriodName(name)) {
      throw ArgumentError('纪元名称不合法');
    }
    
    _currentEra = Era(name: name);
    return _currentEra!;
  }

  // 获取当前纪元
  static Era? getCurrentEra() {
    return _currentEra;
  }

  // 自定义大周期
  static void customizePeriods(List<CustomPeriod> newPeriods) {
    if (_currentEra == null) {
      throw StateError('请先创建纪元');
    }

    // 验证新的周期名称
    for (var period in newPeriods) {
      if (!CustomPeriod.isValidPeriodName(period.name)) {
        throw ArgumentError('周期名称不合法: ${period.name}');
      }
    }

    _currentEra!.periods = newPeriods;
  }
}