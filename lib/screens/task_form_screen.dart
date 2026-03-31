import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/task.dart';
import '../providers/task_provider.dart';

class TaskFormScreen extends ConsumerStatefulWidget {
  const TaskFormScreen({super.key});

  @override
  ConsumerState<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends ConsumerState<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  DateTime? selectedDate;
  TaskStatus status = TaskStatus.todo;
  int? blockedByTaskId;

  bool isLoading = false;
  bool showDateError = false;

  /// 🔹 STORAGE KEYS
  static const _titleKey = 'draft_title';
  static const _descKey = 'draft_desc';
  static const _dateKey = 'draft_date';
  static const _statusKey = 'draft_status';

  @override
  void initState() {
    super.initState();
    _loadDraft();
  }

  /// 🔹 LOAD DRAFT
  Future<void> _loadDraft() async {
    final prefs = await SharedPreferences.getInstance();

    titleController.text = prefs.getString(_titleKey) ?? '';
    descriptionController.text = prefs.getString(_descKey) ?? '';

    final dateString = prefs.getString(_dateKey);
    if (dateString != null) {
      selectedDate = DateTime.tryParse(dateString);
    }

    final statusIndex = prefs.getInt(_statusKey);
    if (statusIndex != null) {
      status = TaskStatus.values[statusIndex];
    }

    setState(() {});
  }

  /// 🔹 SAVE DRAFT
  Future<void> _saveDraft() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_titleKey, titleController.text);
    await prefs.setString(_descKey, descriptionController.text);

    if (selectedDate != null) {
      await prefs.setString(_dateKey, selectedDate!.toIso8601String());
    }

    await prefs.setInt(_statusKey, status.index);
  }

  /// 🔹 CLEAR DRAFT
  Future<void> _clearDraft() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_titleKey);
    await prefs.remove(_descKey);
    await prefs.remove(_dateKey);
    await prefs.remove(_statusKey);
  }

  /// 🔹 SAVE TASK
  Future<void> _saveTask() async {
    final isValid = _formKey.currentState!.validate();

    if (!isValid || selectedDate == null) {
      setState(() => showDateError = selectedDate == null);
      return;
    }

    setState(() => isLoading = true);

    await Future.delayed(const Duration(seconds: 2));

    final task = Task(
      title: titleController.text.trim(),
      description: descriptionController.text.trim(),
      status: status,
      dueDate: selectedDate!,
      blockedByTaskId: blockedByTaskId,
    );

    await ref.read(taskProvider.notifier).addTask(task);

    await _clearDraft(); // ✅ clear after success

    if (!mounted) return;

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(taskProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Create Task')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 🔹 TITLE
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title *',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => _saveDraft(),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Title is required';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                /// 🔹 DESCRIPTION
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => _saveDraft(),
                ),

                const SizedBox(height: 16),

                /// 🔹 DATE
                const Text('Due Date *'),
                Row(
                  children: [
                    Text(
                      selectedDate == null
                          ? 'No date selected'
                          : selectedDate!.toString().split(' ')[0],
                      style: TextStyle(
                        color:
                            selectedDate == null ? Colors.red : Colors.black,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                          initialDate: DateTime.now(),
                        );

                        if (picked != null) {
                          setState(() => selectedDate = picked);
                          _saveDraft();
                        }
                      },
                      child: const Text('Select'),
                    ),
                  ],
                ),

                if (showDateError)
                  const Text(
                    'Due date is required',
                    style: TextStyle(color: Colors.red),
                  ),

                const SizedBox(height: 16),

                /// 🔹 STATUS
                DropdownButtonFormField<TaskStatus>(
                  initialValue: status,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                  ),
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
                      setState(() => status = val);
                      _saveDraft();
                    }
                  },
                ),

                const SizedBox(height: 16),

                /// 🔹 BLOCKED BY
                DropdownButtonFormField<int?>(
                  initialValue: blockedByTaskId,
                  decoration: const InputDecoration(
                    labelText: 'Blocked By',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('None'),
                    ),
                    ...tasks.map(
                      (t) => DropdownMenuItem(
                        value: t.id,
                        child: Text(t.title),
                      ),
                    ),
                  ],
                  onChanged: (val) {
                    setState(() => blockedByTaskId = val);
                    _saveDraft();
                  },
                ),

                const SizedBox(height: 24),

                /// 🔹 SAVE BUTTON
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _saveTask,
                    child: isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Save Task'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}