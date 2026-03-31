import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:isar/isar.dart';

import 'models/task.dart';
import 'providers/task_provider.dart';
import 'screens/task_form_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dir = await getApplicationDocumentsDirectory();

  final isar = await Isar.open(
    [TaskSchema],
    directory: dir.path,
  );

  runApp(
    ProviderScope(
      overrides: [
        isarProvider.overrideWithValue(isar),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home: const TaskListScreen(),
    );
  }
}

class TaskListScreen extends ConsumerWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allTasks = ref.watch(taskProvider);
    final tasks = ref.watch(filteredTasksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Tasks',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),

      body: Column(
        children: [
          /// 🔍 SEARCH + FILTER
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search tasks...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) {
                    ref.read(searchQueryProvider.notifier).state = value;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<TaskStatus?>(
                  initialValue: ref.watch(statusFilterProvider),
                  decoration: const InputDecoration(
                    labelText: 'Filter by Status',
                  ),
                  items: [
                    const DropdownMenuItem(
                        value: null, child: Text('All')),
                    ...TaskStatus.values.map(
                      (status) => DropdownMenuItem(
                        value: status,
                        child: Text(status.name),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    ref.read(statusFilterProvider.notifier).state =
                        value;
                  },
                ),
              ],
            ),
          ),

          /// 📋 TASK LIST
          Expanded(
            child: tasks.isEmpty
                ? const Center(child: Text('No matching tasks'))
                : ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];

                      /// 🔍 EDGE CASE SAFE LOOKUP
                      Task? blockingTask;
                      if (task.blockedByTaskId != null) {
                        try {
                          blockingTask = allTasks.firstWhere(
                            (t) => t.id == task.blockedByTaskId,
                          );
                        } catch (_) {}
                      }

                      final isBlocked =
                          blockingTask != null &&
                              blockingTask.status != TaskStatus.done;

                      return Opacity(
                        opacity: isBlocked ? 0.5 : 1,
                        child: IgnorePointer(
                          ignoring: isBlocked,
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                              border: Border.all(
                                color: isBlocked
                                    ? Colors.red.shade200
                                    : Colors.grey.shade200,
                              ),
                            ),
                            child: InkWell(
                              borderRadius:
                                  BorderRadius.circular(16),
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (_) =>
                                      StatusUpdateDialog(task: task),
                                );
                              },
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  /// TITLE + STATUS
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          task.title,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight:
                                                FontWeight.w600,
                                            decoration: isBlocked
                                                ? TextDecoration
                                                    .lineThrough
                                                : null,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 4),
                                        decoration: BoxDecoration(
                                          color: _statusColor(
                                                  task.status)
                                              .withOpacity(0.15),
                                          borderRadius:
                                              BorderRadius.circular(
                                                  20),
                                        ),
                                        child: Text(
                                          task.status.name,
                                          style: TextStyle(
                                            color: _statusColor(
                                                task.status),
                                            fontSize: 12,
                                            fontWeight:
                                                FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 8),

                                  Text(
                                    isBlocked
                                        ? 'Blocked by: ${blockingTask.title}'
                                        : task.description,
                                    style: TextStyle(
                                      color: isBlocked
                                          ? Colors.red
                                          : Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),

      /// ➕ ADD TASK
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const TaskFormScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// 🔧 STATUS COLORS
Color _statusColor(TaskStatus status) {
  switch (status) {
    case TaskStatus.todo:
      return Colors.orange;
    case TaskStatus.inProgress:
      return Colors.blue;
    case TaskStatus.done:
      return Colors.green;
  }
}

/// 🔧 STATUS UPDATE DIALOG
class StatusUpdateDialog extends ConsumerStatefulWidget {
  final Task task;

  const StatusUpdateDialog({super.key, required this.task});

  @override
  ConsumerState<StatusUpdateDialog> createState() =>
      _StatusUpdateDialogState();
}

class _StatusUpdateDialogState
    extends ConsumerState<StatusUpdateDialog> {
  late TaskStatus selectedStatus;

  @override
  void initState() {
    super.initState();
    selectedStatus = widget.task.status;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Update Status'),
      content: DropdownButtonFormField<TaskStatus>(
        initialValue: selectedStatus,
        items: TaskStatus.values
            .map(
              (e) => DropdownMenuItem(
                value: e,
                child: Text(e.name),
              ),
            )
            .toList(),
        onChanged: (val) {
          if (val != null) {
            setState(() => selectedStatus = val);
          }
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            final updatedTask =
                widget.task.copyWith(status: selectedStatus);

            await ref
                .read(taskProvider.notifier)
                .updateTask(updatedTask);

            if (!mounted) return;

            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}