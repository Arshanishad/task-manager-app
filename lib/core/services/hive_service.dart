import 'package:hive_flutter/hive_flutter.dart';
import '../../features/task/models/task_model.dart';

class TaskAdapter extends TypeAdapter<TaskModel> {
  @override
  final int typeId = 1;

  @override
  TaskModel read(BinaryReader reader) {
    final data = reader.readMap();

    return TaskModel(
      id: data['id'],
      title: data['title'],
      description: data['description'],
      priority: data['priority'],
      dueDate: DateTime.parse(data['dueDate']),
      isCompleted: data['isCompleted'],
      createdDate: DateTime.parse(data['createdDate']),
      syncPending: data['syncPending'],
      isDeleted: data['isDeleted'],
    );
  }

  @override
  void write(BinaryWriter writer, TaskModel obj) {
    writer.writeMap({
      'id': obj.id,
      'title': obj.title,
      'description': obj.description,
      'priority': obj.priority,
      'dueDate': obj.dueDate.toIso8601String(),
      'isCompleted': obj.isCompleted,
      'createdDate': obj.createdDate.toIso8601String(),
      'syncPending': obj.syncPending,
      'isDeleted': obj.isDeleted,
    });
  }
}

class HiveService {
  static const String boxName = 'tasks';

  static Future<void> init() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(TaskAdapter());
    }

    await Hive.openBox<TaskModel>(boxName);
  }

  static Box<TaskModel> get box => Hive.box<TaskModel>(boxName);

  static Future<void> saveTask(TaskModel task) async {
    await box.put(task.id, task);
  }

  static Future<void> deleteTask(String id) async {
    await box.delete(id);
  }

  static List<TaskModel> getTasks() {
    return box.values
        .where((task) => !task.isDeleted)
        .toList();
  }

  static List<TaskModel> getAllTasksIncludingDeleted() {
    return box.values.toList();
  }
}