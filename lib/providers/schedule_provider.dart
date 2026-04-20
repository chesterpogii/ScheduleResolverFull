import 'package:flutter/material.dart';
import '../models/task_model.dart';

class ScheduleProvider extends ChangeNotifier {
  final List<TaskModel> _tasks = [];

  List<TaskModel> get task => _tasks;

  void addTask({
    required String title,
    required String category,
    required DateTime date,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required int urgency,
    required int importance,
    required double estimatedEffortHours,
    required String energyLevel,
  }) {
    _tasks.add(TaskModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      category: category,
      date: date,
      startTime: startTime,
      endTime: endTime,
      urgency: urgency,
      importance: importance,
      estimatedEffortHours: estimatedEffortHours,
      energyLevel: energyLevel,
    ));
    notifyListeners();
  }

  void removeTask(String id) {
    _tasks.removeWhere((task) => task.id == id);
    notifyListeners();
  }

  void clearTasks() {
    _tasks.clear();
    notifyListeners();
  }
}