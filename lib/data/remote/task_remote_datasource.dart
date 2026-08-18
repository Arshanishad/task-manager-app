import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/task_model.dart';

class TaskRemoteDataSource {
  final FirebaseFirestore _firestore;

  TaskRemoteDataSource({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  CollectionReference<Map<String, dynamic>> get _tasks =>
      _firestore.collection('tasks');

  Future<List<TaskModel>> getTasks() async {
    final snapshot = await _tasks.get();

    return snapshot.docs
        .map(
          (doc) => TaskModel.fromFirestore(
            doc.data(),
          ),
        )
        .toList();
  }

  Future<void> createTask(TaskModel task) async {
    await _tasks.doc(task.id).set(
      task.toJson(),
    );
  }

  Future<void> updateTask(TaskModel task) async {
    await _tasks.doc(task.id).set(
      task.toJson(),
      SetOptions(merge: true),
    );
  }

  Future<void> deleteTask(String id) async {
    await _tasks.doc(id).delete();
  }
}