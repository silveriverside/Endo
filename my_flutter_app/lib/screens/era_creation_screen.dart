import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/sleep_service.dart';
import '../models/custom_calendar.dart';
import 'home_screen.dart';

class EraCreationScreen extends StatefulWidget {
  const EraCreationScreen({Key? key}) : super(key: key);

  @override
  _EraCreationScreenState createState() => _EraCreationScreenState();
}

class _EraCreationScreenState extends State<EraCreationScreen> {
  final _eraNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  List<CustomPeriod> _periods = [
    CustomPeriod(name: '云', duration: 1),
    CustomPeriod(name: '星', duration: 3),
    CustomPeriod(name: '摇光', duration: 12),
  ];

  @override
  void dispose() {
    _eraNameController.dispose();
    super.dispose();
  }

  void _addPeriod() {
    showDialog(
      context: context,
      builder: (context) {
        final nameController = TextEditingController();
        final durationController = TextEditingController();

        return AlertDialog(
          title: const Text('添加新周期'),
          content: Form(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: '周期名称',
                    hintText: '如: 流光、MOON',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入周期名称';
                    }
                    if (!CustomPeriod.isValidPeriodName(value)) {
                      return '名称不合法(10个汉字或20个英文字母)';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: durationController,
                  decoration: const InputDecoration(
                    labelText: '周期天数',
                    hintText: '输入该周期包含的天数',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入周期天数';
                    }
                    final duration = int.tryParse(value);
                    if (duration == null || duration <= 0) {
                      return '请输入有效的天数';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  setState(() {
                    _periods.add(CustomPeriod(
                      name: nameController.text.trim(),
                      duration: int.parse(durationController.text),
                    ));
                    Navigator.of(context).pop();
                  });
                }
              },
              child: const Text('添加'),
            ),
          ],
        );
      },
    );
  }

  void _removePeriod(CustomPeriod period) {
    // 保留至少3个默认周期
    if (_periods.length > 3) {
      setState(() {
        _periods.remove(period);
      });
    }
  }

  void _createEra() {
    if (_formKey.currentState?.validate() ?? false) {
      final sleepService = Provider.of<SleepService>(context, listen: false);
      
      try {
        // 创建纪元
        sleepService.createEra(_eraNameController.text.trim());
        
        // 自定义周期
        sleepService.customizePeriods(_periods);

        // 跳转到主界面
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('创建纪元失败: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('创建新纪元'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              '欢迎使用健康作息助手!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              '请创建您的第一个纪元。纪元是您个人生活周期的开始。',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _eraNameController,
              decoration: const InputDecoration(
                labelText: '纪元名称',
                hintText: '给您的纪元起一个名字(10个汉字或20个英文字母)',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入纪元名称';
                }
                if (!CustomPeriod.isValidPeriodName(value)) {
                  return '名称不合法(10个汉字或20个英文字母)';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '生活周期设置',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addPeriod,
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...(_periods.map((period) => ListTile(
              title: Text('${period.name} (${period.duration}天)'),
              trailing: _periods.length > 3
                  ? IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _removePeriod(period),
                    )
                  : null,
            ))),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _createEra,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                '开始我的生活周期',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}