import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../models/task.dart';

/// 🔹 TASK NOTIFIER
class TaskNotifier extends StateNotifier<List<Task>> {
  final Isar isar;

  TaskNotifier(this.isar) : super([]) {
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final tasks = await isar.tasks.where().findAll();
    state = tasks;
  }

  Future<void> addTask(Task task) async {
    await isar.writeTxn(() async {
      await isar.tasks.put(task);
    });
    await _loadTasks();
  }

  Future<void> updateTask(Task task) async {
    await isar.writeTxn(() async {
      await isar.tasks.put(task);
    });
    await _loadTasks();
  }

  Future<void> deleteTask(int id) async {
    await isar.writeTxn(() async {
      await isar.tasks.delete(id);
    });
    await _loadTasks();
  }
}

/// 🔹 ISAR PROVIDER
final isarProvider = Provider<Isar>((ref) {
  throw UnimplementedError();
});

/// 🔹 MAIN TASK PROVIDER
final taskProvider =
    StateNotifierProvider<TaskNotifier, List<Task>>((ref) {
  final isar = ref.watch(isarProvider);
  return TaskNotifier(isar);
});

/// 🔍 SEARCH QUERY
final searchQueryProvider = StateProvider<String>((ref) => '');

/// 🎯 STATUS FILTER
final statusFilterProvider = StateProvider<TaskStatus?>((ref) => null);

/// 🔥 FILTERED TASKS (DERIVED STATE)
final filteredTasksProvider = Provider<List<Task>>((ref) {
  final tasks = ref.watch(taskProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase();
  final statusFilter = ref.watch(statusFilterProvider);

  return tasks.where((task) {
    final matchesSearch =
        task.title.toLowerCase().contains(query);

    final matchesStatus =
        statusFilter == null || task.status == statusFilter;

    return matchesSearch && matchesStatus;
  }).toList();
});