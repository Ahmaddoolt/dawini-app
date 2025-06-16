import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:alarm/alarm.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'models/static_values.dart';

class AlarmPage extends StatefulWidget {
  const AlarmPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AlarmPageState createState() => _AlarmPageState();
}

class _AlarmPageState extends State<AlarmPage> {
  late Box _alarmBox;
  TimeOfDay? _selectedTime;
  TextEditingController medicNameController = TextEditingController();
  bool _isLoading = true;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  int _selectedInterval = 3;
  final List<int> _intervalOptions = [3, 6, 9, 12, 18, 24];

  @override
  void initState() {
    super.initState();
    _initializeHiveAndAlarm();
  }

  Future<void> _initializeHiveAndAlarm() async {
    await Hive.initFlutter();
    String userId = await getCurrentUserId();
    _alarmBox = await Hive.openBox('alarms_$userId');
    await Alarm.init();
    setState(() => _isLoading = false);
  }

  Future<void> _setAlarm() async {
    if (_selectedTime == null || medicNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a time and enter a name!')),
      );
      return;
    }

    final now = DateTime.now();
    DateTime adjustedDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    if (adjustedDateTime.isBefore(now)) {
      adjustedDateTime = adjustedDateTime.add(const Duration(days: 1));
    }

    String userId = await getCurrentUserId();
    final alarmId = DateTime.now().millisecondsSinceEpoch % 2147483647;

    final alarmSettings = AlarmSettings(
      id: alarmId,
      dateTime: adjustedDateTime,
      assetAudioPath: 'assets/alarm.mp3',
      loopAudio: true,
      vibrate: true,
      fadeDuration: 3.0,
      notificationTitle: 'Alarm',
      notificationBody: '${medicNameController.text}: Time to take medicine!',
      enableNotificationOnKill: true,
    );

    try {
      await Alarm.set(alarmSettings: alarmSettings);
      await _alarmBox.put(alarmId, {
        'id': alarmId,
        'userId': userId,
        'dateTime': adjustedDateTime.toIso8601String(),
        'medicName': medicNameController.text,
        'interval': _selectedInterval,
      });

      setState(() {});
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to set alarm: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Alarm Page'.tr()),
        backgroundColor: accentColor2,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: medicNameController,
                    decoration: InputDecoration(
                      labelText: "Enter medicine name".tr(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _selectedTime != null ? Colors.green : Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () async {
                      TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      setState(() => _selectedTime = picked);
                    },
                    child: Text(
                      _selectedTime == null
                          ? 'Pick Time'.tr()
                          : 'Time: ${_selectedTime!.format(context)}',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    value: _selectedInterval,
                    decoration: InputDecoration(
                      labelText: 'Repeat every:'.tr(),
                      border: const OutlineInputBorder(),
                    ),
                    items: _intervalOptions.map((int value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Row(
                          children: [
                            Text('$value'),
                            Text('hours'.tr()),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (int? newValue) {
                      setState(() => _selectedInterval = newValue!);
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor2,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _setAlarm,
                    child: Text(
                      'Set Alarm'.tr(),
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _buildAlarmList(),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildAlarmList() {
    return ValueListenableBuilder(
      valueListenable: _alarmBox.listenable(),
      builder: (context, Box box, _) {
        if (box.isEmpty) {
          return _buildEmptyState();
        }

        final userAlarms = box.values.toList();

        return ListView.builder(
          itemCount: userAlarms.length,
          itemBuilder: (context, index) {
            final alarm = userAlarms[index];
            return Card(
              color: const Color.fromARGB(255, 224, 245, 255),
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: Text(
                  TimeOfDay.fromDateTime(DateTime.parse(alarm['dateTime']))
                      .format(context),
                ),
                subtitle: Text(
                    '${alarm['medicName']} (Repeats every ${alarm['interval']} hours)'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteAlarm(alarm['id']),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text('No alarms set'.tr(),
          style: const TextStyle(fontSize: 18, color: Colors.grey)),
    );
  }

  Future<void> _deleteAlarm(int alarmId) async {
    await _alarmBox.delete(alarmId);
    setState(() {});
  }

  Future<String> getCurrentUserId() async {
    final email = await _secureStorage.read(key: 'email');
    return email ?? 'default_user';
  }
}
