import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_manager/core/providers/providers.dart';
import 'package:task_manager/features/task/data/repository/task_repository.dart';
import 'package:task_manager/features/task/models/task_model.dart';
import 'package:uuid/uuid.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository(
    local: ref.read(taskLocalDataSourceProvider),
    remote: ref.read(taskRemoteDataSourceProvider),
  );
});

final taskProvider = StateNotifierProvider<TaskNotifier, TaskState>((ref) {
  return TaskNotifier(repository: ref.read(taskRepositoryProvider));
});

class TaskState {
  final List<TaskModel> tasks;

  final bool isLoading;

  final bool isSyncing;

  final bool isOnline;

  final String searchQuery;

  final String filter;

  final String sort;

  final String? errorMessage;

  const TaskState({
    this.tasks = const [],
    this.isLoading = false,
    this.isSyncing = false,
    this.isOnline = true,
    this.searchQuery = '',
    this.filter = 'All',
    this.sort = 'Due Date',
    this.errorMessage,
  });

  TaskState copyWith({
    List<TaskModel>? tasks,
    bool? isLoading,
    bool? isSyncing,
    bool? isOnline,
    String? searchQuery,
    String? filter,
    String? sort,
    String? errorMessage,
  }) {
    return TaskState(
      tasks: tasks ?? this.tasks,
      isLoading: isLoading ?? this.isLoading,
      isSyncing: isSyncing ?? this.isSyncing,
      isOnline: isOnline ?? this.isOnline,
      searchQuery: searchQuery ?? this.searchQuery,
      filter: filter ?? this.filter,
      sort: sort ?? this.sort,
      errorMessage: errorMessage,
    );
  }

  List<TaskModel> get filteredTasks {
    List<TaskModel> result = List<TaskModel>.from(tasks);
    if (searchQuery.trim().isNotEmpty) {
      final query = searchQuery.toLowerCase().trim();

      result = result.where((task) {
        return task.title.toLowerCase().contains(query);
      }).toList();
    }

    if (filter == 'Completed') {
      result = result.where((task) => task.isCompleted).toList();
    }

    if (filter == 'Pending') {
      result = result.where((task) => !task.isCompleted).toList();
    }

    if (sort == 'Due Date') {
      result.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    }

    if (sort == 'Priority') {
      const priorityOrder = {'High': 1, 'Medium': 2, 'Low': 3};

      result.sort((a, b) {
        final priorityA = priorityOrder[a.priority] ?? 2;

        final priorityB = priorityOrder[b.priority] ?? 2;

        return priorityA.compareTo(priorityB);
      });
    }

    return result;
  }
}

class TaskNotifier extends StateNotifier<TaskState> {
  final TaskRepository repository;

  StreamSubscription<List<ConnectivityResult>>? connectivitySubscription;

  TaskNotifier({required this.repository}) : super(const TaskState()) {
    _init();
  }



  Future<void> _init() async {
    await checkConnectivity();

    listenConnectivity();

    await loadTasks();
  }

  

  Future<void> loadTasks() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {

      final localTasks = repository.getLocalTasks();

      state = state.copyWith(tasks: localTasks, isLoading: false);
      if (state.isOnline) {
        await syncTasks();
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load tasks',
      );
    }
  }
  Future<void> createTask({
    required String title,
    required String description,
    required String priority,
    required DateTime dueDate,
  }) async {
    final task = TaskModel(
      id: const Uuid().v4(),
      title: title,
      description: description,
      priority: priority,
      dueDate: dueDate,
      isCompleted: false,
      createdDate: DateTime.now(),
      syncPending: true,
      isDeleted: false,
    );
    await repository.saveLocalTask(task);

    refreshTasks();

    if (state.isOnline) {
      await syncTasks();
    }
  }


  Future<void> updateTask({
    required TaskModel task,
    required String title,
    required String description,
    required String priority,
    required DateTime dueDate,
  }) async {
    final updatedTask = task.copyWith(
      title: title,
      description: description,
      priority: priority,
      dueDate: dueDate,

      syncPending: true,
      isDeleted: false,
    );

    await repository.saveLocalTask(updatedTask);

    refreshTasks();

    if (state.isOnline) {
      await syncTasks();
    }
  }

 
  Future<void> toggleCompleted(TaskModel task) async {
    final updatedTask = task.copyWith(
      isCompleted: !task.isCompleted,
      syncPending: true,
    );

    await repository.saveLocalTask(updatedTask);

    refreshTasks();

    if (state.isOnline) {
      await syncTasks();
    }
  }



  Future<void> deleteTask(TaskModel task) async {
    await repository.markDeleted(task.id);

    refreshTasks();

    if (state.isOnline) {
      await syncTasks();
    }
  }

 

  void search(String value) {
    state = state.copyWith(searchQuery: value);
  }

  void setFilter(String value) {
    state = state.copyWith(filter: value);
  }

  

  void setSort(String value) {
    state = state.copyWith(sort: value);
  }


  void refreshTasks() {
    state = state.copyWith(tasks: repository.getLocalTasks());
  }

  

  Future<void> syncTasks() async {
    if (!state.isOnline) {
      return;
    }

    state = state.copyWith(isSyncing: true, errorMessage: null);

    try {
      await repository.sync();

      refreshTasks();

      state = state.copyWith(isSyncing: false);
    } catch (e) {
      state = state.copyWith(
        isSyncing: false,
        errorMessage: 'Sync failed. Local data is safe.',
      );
    }
  }



  Future<void> checkConnectivity() async {
    final results = await Connectivity().checkConnectivity();

    final online = !results.contains(ConnectivityResult.none);

    state = state.copyWith(isOnline: online);
  }

 

  void listenConnectivity() {
    connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      results,
    ) async {
      final online = !results.contains(ConnectivityResult.none);

      state = state.copyWith(isOnline: online);

      if (online) {
        await syncTasks();
      }
    });
  }

  
  @override
  Future<void> dispose() async {
    await connectivitySubscription?.cancel();

    super.dispose();
  }
}

class TaskFormState {
  final String priority;
  final DateTime? dueDate;

  const TaskFormState({
    this.priority = 'Medium',
    this.dueDate,
  });

  TaskFormState copyWith({
    String? priority,
    DateTime? dueDate,
  }) {
    return TaskFormState(
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
    );
  }
}

class TaskFormNotifier extends StateNotifier<TaskFormState> {
  TaskFormNotifier(TaskModel? task)
      : super(
          TaskFormState(
            priority: task?.priority ?? 'Medium',
            dueDate: task?.dueDate,
          ),
        );

  void setPriority(String value) {
    state = state.copyWith(priority: value);
  }

  void setDueDate(DateTime value) {
    state = state.copyWith(dueDate: value);
  }
}

final taskFormProvider = StateNotifierProvider.autoDispose
    .family<TaskFormNotifier, TaskFormState, TaskModel?>(
  (ref, task) {
    return TaskFormNotifier(task);
  },
);
