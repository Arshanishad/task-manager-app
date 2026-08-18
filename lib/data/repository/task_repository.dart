import 'package:task_manager/data/local/task_local_data_source.dart';
import 'package:task_manager/data/remote/task_remote_datasource.dart';
import '../../models/task_model.dart';


class TaskRepository {
  final TaskLocalDataSource local;
  final TaskRemoteDataSource remote;

  TaskRepository({
    required this.local,
    required this.remote,
  });

  List<TaskModel> getLocalTasks() {
    return local.getTasks();
  }

  List<TaskModel> getAllLocalTasks() {
    return local.getAllTasks();
  }

  Future<void> saveLocalTask(TaskModel task) async {
    await local.saveTask(task);
  }

  Future<List<TaskModel>> getRemoteTasks() async {
    return remote.getTasks();
  }

  Future<void> createRemoteTask(
    TaskModel task,
  ) async {
    await remote.createTask(task);
  }

  Future<void> updateRemoteTask(
    TaskModel task,
  ) async {
    await remote.updateTask(task);
  }

  Future<void> deleteRemoteTask(
    String id,
  ) async {
    await remote.deleteTask(id);
  }

  Future<void> sync() async {
    final localTasks = local.getAllTasks();
    for (final task in localTasks) {
      if (!task.syncPending) {
        continue;
      }

      try {
        if (task.isDeleted) {
          await remote.deleteTask(task.id);

          await local.deleteTask(task.id);
        } else {
          final remoteTasks =
              await remote.getTasks();

          final exists = remoteTasks.any(
            (item) => item.id == task.id,
          );

          if (exists) {
            await remote.updateTask(task);
          } else {
            await remote.createTask(task);
          }

          await local.saveTask(
            task.copyWith(
              syncPending: false,
            ),
          );
        }
      } catch (_) {
      }
    }
    try {
      final remoteTasks =
          await remote.getTasks();

      final currentLocal =
          local.getAllTasks();
      final pendingIds = currentLocal
          .where((task) => task.syncPending)
          .map((task) => task.id)
          .toSet();

      for (final remoteTask in remoteTasks) {
        if (pendingIds.contains(remoteTask.id)) {
          continue;
        }

        await local.saveTask(
          remoteTask.copyWith(
            syncPending: false,
            isDeleted: false,
          ),
        );
      }
      final remoteIds =
          remoteTasks.map((task) => task.id).toSet();

      for (final localTask in currentLocal) {
        if (!localTask.syncPending &&
            !localTask.isDeleted &&
            !remoteIds.contains(localTask.id)) {
          await local.deleteTask(localTask.id);
        }
      }
    } catch (_) {

    }
  }

  Future<void> markDeleted(String id) async {
    final task = local.getAllTasks()
        .where((task) => task.id == id)
        .firstOrNull;

    if (task == null) {
      return;
    }

    await local.saveTask(
      task.copyWith(
        syncPending: true,
        isDeleted: true,
      ),
    );
  }
}