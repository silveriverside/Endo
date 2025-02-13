import 'custom_calendar.dart';

class UserSettings {
  double circadianRhythm;    // 生物钟周期(小时)
  List<LifeEventTemplate> lifeEventTemplates;
  Era? currentEra;

  UserSettings({
    this.circadianRhythm = 24.2,
    List<LifeEventTemplate>? lifeEventTemplates,
    this.currentEra,
  }) : lifeEventTemplates = lifeEventTemplates ?? [
    LifeEventTemplate.wakeUp(),
    LifeEventTemplate(
      id: 'breakfast',
      name: '早餐',
      offsetFromWakeUp: const Duration(minutes: 30),
    ),
    LifeEventTemplate(
      id: 'lunch',
      name: '午餐',
      offsetFromWakeUp: const Duration(hours: 5),
    ),
    LifeEventTemplate(
      id: 'nap',
      name: '午睡',
      offsetFromWakeUp: const Duration(hours: 6),
    ),
    LifeEventTemplate(
      id: 'dinner',
      name: '晚餐',
      offsetFromWakeUp: const Duration(hours: 12),
    ),
    LifeEventTemplate.sleep(),
  ];

  // 创建新纪元
  void createEra(String name) {
    currentEra = CalendarManager.createEra(name);
  }

  // 自定义大周期
  void customizePeriods(List<CustomPeriod> newPeriods) {
    if (currentEra == null) {
      throw StateError('请先创建纪元');
    }
    CalendarManager.customizePeriods(newPeriods);
  }

  // 根据生物钟周期计算下一个理想起床时间
  DateTime calculateNextWakeUpTime(DateTime lastSleepTime) {
    // 计算理想睡眠时长(生物钟周期的1/3)
    final idealSleepDuration = Duration(
      minutes: (circadianRhythm * 60 / 3).round()
    );
    return lastSleepTime.add(idealSleepDuration);
  }

  // 根据生物钟周期和模板生成完整的理想时间表
  Map<String, DateTime> generateIdealSchedule(DateTime lastSleepTime) {
    final wakeUpTime = calculateNextWakeUpTime(lastSleepTime);
    
    return Map.fromEntries(
      lifeEventTemplates.map((template) => MapEntry(
        template.id,
        wakeUpTime.add(template.offsetFromWakeUp),
      )),
    );
  }

  // 添加新的生活事件模板
  void addLifeEventTemplate(LifeEventTemplate template) {
    // 确保不重复添加固定事件
    if (!template.isEditable || 
        lifeEventTemplates.any((t) => t.id == template.id)) {
      return;
    }
    
    // 按照时间顺序插入
    final index = lifeEventTemplates.indexWhere(
      (t) => t.offsetFromWakeUp > template.offsetFromWakeUp
    );
    
    if (index == -1) {
      lifeEventTemplates.add(template);
    } else {
      lifeEventTemplates.insert(index, template);
    }
  }

  // 删除生活事件模板
  void removeLifeEventTemplate(String id) {
    lifeEventTemplates.removeWhere(
      (template) => template.id == id && template.isEditable
    );
  }

  // 更新生活事件模板
  void updateLifeEventTemplate(String id, LifeEventTemplate newTemplate) {
    final index = lifeEventTemplates.indexWhere((t) => t.id == id);
    if (index != -1 && lifeEventTemplates[index].isEditable) {
      lifeEventTemplates[index] = newTemplate;
      // 重新排序
      lifeEventTemplates.sort(
        (a, b) => a.offsetFromWakeUp.compareTo(b.offsetFromWakeUp)
      );
    }
  }
}

class LifeEventTemplate {
  String id;
  String name;
  Duration offsetFromWakeUp; // 相对于起床时间的偏移
  bool isEditable;           // 是否可编辑(起床和入睡时间不可编辑)

  LifeEventTemplate({
    required this.id,
    required this.name,
    required this.offsetFromWakeUp,
    this.isEditable = true,
  });

  factory LifeEventTemplate.wakeUp() {
    return LifeEventTemplate(
      id: 'wake_up',
      name: '起床',
      offsetFromWakeUp: const Duration(hours: 0),
      isEditable: false,
    );
  }

  factory LifeEventTemplate.sleep() {
    return LifeEventTemplate(
      id: 'sleep',
      name: '入睡',
      offsetFromWakeUp: const Duration(hours: 16),
      isEditable: false,
    );
  }
}