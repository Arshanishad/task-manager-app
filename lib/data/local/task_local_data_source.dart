import 'package:hive_flutter/hive_flutter.dart';

import '../../models/task_model.dart';

class TaskLocalDataSource {
  static const String boxName = 'tasks';

  late Box _box;

  Future<void> init() async {
    await Hive.initFlutter();

    _box = await Hive.openBox(boxName);
  }

  List<TaskModel> getTasks() {
    return _box.values
        .map(
          (value) => TaskModel.fromHiveMap(
            Map<dynamic, dynamic>.from(value),
          ),
        )
        .where((task) => !task.isDeleted)
        .toList();
  }

  List<TaskModel> getAllTasks() {
    return _box.values
        .map(
          (value) => TaskModel.fromHiveMap(
            Map<dynamic, dynamic>.from(value),
          ),
        )
        .toList();
  }

  Future<void> saveTask(TaskModel task) async {
    await _box.put(
      task.id,
      task.toHiveMap(),
    );
  }

  Future<void> deleteTask(String id) async {
    await _box.delete(id);
  }

  Future<void> clear() async {
    await _box.clear();
  }
}