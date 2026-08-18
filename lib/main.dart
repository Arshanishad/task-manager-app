import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_manager/features/task/data/local/task_local_data_source.dart';
import 'core/providers/providers.dart';
import 'firebase_options.dart';
import 'features/task/screens/task_list_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final localDataSource = TaskLocalDataSource();

  await localDataSource.init();

  runApp(
    ProviderScope(
      overrides: [
        taskLocalDataSourceProvider.overrideWithValue(localDataSource),
      ],
      child: const TaskManagerApp(),
    ),
  );
}

class TaskManagerApp extends StatelessWidget {
  const TaskManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Task Manager',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xffF7F8FC),
      ),
      home: const TaskListScreen(),
    );
  }
}
