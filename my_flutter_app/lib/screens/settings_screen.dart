import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/sleep_service.dart';
import '../models/custom_calendar.dart';
import '../models/user_settings.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SleepService>(
      builder: (context, sleepService, child) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildCircadianRhythmSetting(context, sleepService),
            const SizedBox(height: 16),
            _buildLifeEventTemplates(context, sleepService),
            const SizedBox(height: 16),
            _buildCalendarSettings(context, sleepService),
            const SizedBox(height: 16),
            _buildAboutSection(context),
          ],
        );
      },
    );
  }

  Future<void> _showCircadianRhythmDialog(
    BuildContext context,
    SleepService sleepService,
  ) async {
    final controller = TextEditingController(
      text: sleepService.settings.circadianRhythm.toString(),
    );

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('设置生物钟周期'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: '周期(小时)',
            hintText: '请输入24.0-25.0之间的数值',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              final value = double.tryParse(controller.text);
              if (value != null && value >= 24.0 && value <= 25.0) {
                sleepService.updateCircadianRhythm(value);
                Navigator.pop(context);
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddEventDialog(
    BuildContext context,
    SleepService sleepService,
  ) async {
    final nameController = TextEditingController();
    final hoursController = TextEditingController(text: '0');
    final minutesController = TextEditingController(text: '0');

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加生活事件'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: '事件名称',
                hintText: '例如: 运动',
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: hoursController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '小时',
                      hintText: '起床后的小时数',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: minutesController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '分钟',
                      hintText: '额外的分钟数',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              final name = nameController.text.trim();
              final hours = int.tryParse(hoursController.text) ?? 0;
              final minutes = int.tryParse(minutesController.text) ?? 0;
              
              if (name.isNotEmpty) {
                final template = LifeEventTemplate(
                  id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
                  name: name,
                  offsetFromWakeUp: Duration(
                    hours: hours,
                    minutes: minutes,
                  ),
                );
                sleepService.addLifeEventTemplate(template);
                Navigator.pop(context);
              }
            },
            child: const Text('添加'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditEventDialog(
    BuildContext context,
    SleepService sleepService,
    LifeEventTemplate template,
  ) async {
    final nameController = TextEditingController(text: template.name);
    final hoursController = TextEditingController(
      text: template.offsetFromWakeUp.inHours.toString(),
    );
    final minutesController = TextEditingController(
      text: (template.offsetFromWakeUp.inMinutes % 60).toString(),
    );

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('编辑生活事件'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: '事件名称',
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: hoursController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '小时',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: minutesController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '分钟',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              final name = nameController.text.trim();
              final hours = int.tryParse(hoursController.text) ?? 0;
              final minutes = int.tryParse(minutesController.text) ?? 0;
              
              if (name.isNotEmpty) {
                final newTemplate = LifeEventTemplate(
                  id: template.id,
                  name: name,
                  offsetFromWakeUp: Duration(
                    hours: hours,
                    minutes: minutes,
                  ),
                );
                sleepService.updateLifeEventTemplate(template.id, newTemplate);
                Navigator.pop(context);
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  Future<void> _showCreateEraDialog(
    BuildContext context,
    SleepService sleepService,
  ) async {
    final nameController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('创建新纪元'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: '纪元名称',
            hintText: '输入新纪元的名称(10个汉字或20个英文字母)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                try {
                  sleepService.createEra(name);
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('创建纪元失败: $e')),
                  );
                }
              }
            },
            child: const Text('创建'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditPeriodDialog(
    BuildContext context,
    SleepService sleepService,
    CustomPeriod period,
  ) async {
    final nameController = TextEditingController(text: period.name);
    final durationController = TextEditingController(text: period.duration.toString());

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('编辑周期'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: '周期名称',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: durationController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '天数',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              try {
                final newPeriod = CustomPeriod(
                  name: nameController.text.trim(),
                  duration: int.parse(durationController.text),
                );

                // 更新周期列表
                final currentEra = sleepService.settings.currentEra;
                if (currentEra != null) {
                  final updatedPeriods = currentEra.periods.map((p) {
                    return p.name == period.name ? newPeriod : p;
                  }).toList();

                  sleepService.customizePeriods(updatedPeriods);
                }
                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('编辑周期失败: $e')),
                );
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  Future<void> _showCustomizePeriodDialog(
    BuildContext context,
    SleepService sleepService,
  ) async {
    final currentEra = sleepService.settings.currentEra;
    if (currentEra == null) return;

    final List<TextEditingController> nameControllers = [];
    final List<TextEditingController> durationControllers = [];

    // 初始化控制器
    for (var period in currentEra.periods) {
      nameControllers.add(TextEditingController(text: period.name));
      durationControllers.add(TextEditingController(text: period.duration.toString()));
    }

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('自定义周期'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(currentEra.periods.length, (index) {
              return Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: nameControllers[index],
                      decoration: const InputDecoration(
                        labelText: '周期名称',
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: durationControllers[index],
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: '天数',
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              try {
                final newPeriods = List.generate(currentEra.periods.length, (index) {
                  return CustomPeriod(
                    name: nameControllers[index].text.trim(),
                    duration: int.parse(durationControllers[index].text),
                  );
                });

                sleepService.customizePeriods(newPeriods);
                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('自定义周期失败: $e')),
                );
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  Widget _buildCircadianRhythmSetting(
    BuildContext context,
    SleepService sleepService,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '生物钟设置',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '生物钟周期: ${sleepService.settings.circadianRhythm.toStringAsFixed(1)}小时',
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showCircadianRhythmDialog(
                    context,
                    sleepService,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '理想睡眠时长: ${(sleepService.settings.circadianRhythm / 3).toStringAsFixed(1)}小时',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLifeEventTemplates(
    BuildContext context,
    SleepService sleepService,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '生活事件模板',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _showAddEventDialog(context, sleepService),
                ),
              ],
            ),
            const Divider(),
            ...sleepService.settings.lifeEventTemplates.map((template) {
              final hours = template.offsetFromWakeUp.inHours;
              final minutes = template.offsetFromWakeUp.inMinutes % 60;
              return ListTile(
                title: Text(template.name),
                subtitle: Text('起床后 $hours小时 $minutes分钟'),
                trailing: template.isEditable
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showEditEventDialog(
                              context,
                              sleepService,
                              template,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              sleepService.removeLifeEventTemplate(template.id);
                            },
                          ),
                        ],
                      )
                    : null,
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarSettings(
    BuildContext context,
    SleepService sleepService,
  ) {
    final currentEra = sleepService.settings.currentEra;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '历法设置',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            if (currentEra != null) ...[
              Text('当前纪元: ${currentEra.name}'),
              const SizedBox(height: 8),
              const Text('周期设置:'),
              ...currentEra.periods.map((period) => ListTile(
                title: Text('${period.name} (${period.duration}天)'),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showEditPeriodDialog(
                    context,
                    sleepService,
                    period,
                  ),
                ),
              )).toList(),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _showCreateEraDialog(context, sleepService),
                  icon: const Icon(Icons.add),
                  label: const Text('创建新纪元'),
                ),
                if (currentEra != null)
                  ElevatedButton.icon(
                    onPressed: () => _showCustomizePeriodDialog(context, sleepService),
                    icon: const Icon(Icons.settings),
                    label: const Text('自定义周期'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '关于',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            const Text(
              '应用名称: 司辰',
              style: TextStyle(fontSize: 16),
            ),
            const Text(
              '版本: v0.0.1',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              '作者信息:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              '作者: SkyJoik',
              style: TextStyle(fontSize: 16),
            ),
            const Text(
              '联系方式: 微信 Sky_Joik',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}