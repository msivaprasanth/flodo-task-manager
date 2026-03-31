import 'package:isar/isar.dart';

// This file will be generated automatically later
part '../task.g.dart'; 

@collection
class Task {
  Id id = Isar.autoIncrement; // Primary Key

  late String title;
  late String description;
  
  @enumerated // Tells Isar to store the enum index
  late TaskStatus status;

  late DateTime dueDate;

  // For the "Blocked By" logic: stores the ID of the task that blocks this one
  int? blockedByTaskId;

  // We add a constructor for easy creation
  Task({
    this.id = Isar.autoIncrement,
    required this.title,
    required this.description,
    required this.status,
    required this.dueDate,
    this.blockedByTaskId,
  });

  // The copyWith pattern: essential for updating tasks in Riverpod
  Task copyWith({
    Id? id,
    String? title,
    String? description,
    TaskStatus? status,
    DateTime? dueDate,
    int? blockedByTaskId,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      blockedByTaskId: blockedByTaskId ?? this.blockedByTaskId,
    );
  }
}

enum TaskStatus { todo, inProgress, done }