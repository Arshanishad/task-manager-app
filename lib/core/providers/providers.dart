import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_manager/features/task/data/local/task_local_data_source.dart';
import 'package:task_manager/features/task/data/remote/task_remote_datasource.dart';

final firebaseProvider = Provider<FirebaseFirestore>(
  (ref) => FirebaseFirestore.instance,
);

final taskLocalDataSourceProvider =
    Provider<TaskLocalDataSource>(
  (ref) => TaskLocalDataSource(),
);

final taskRemoteDataSourceProvider =
    Provider<TaskRemoteDataSource>(
  (ref) => TaskRemoteDataSource(
    firestore: ref.read(firebaseProvider),
  ),
);