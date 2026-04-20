import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/task_model.dart';
import '../models/schedule_analysis.dart';

class AiScheduleService extends ChangeNotifier {

  ScheduleAnalysis? _currentAnalysis;
  bool _isLoading = false;
  String? _errorMessage;

  String _apikey = 'AIzaSyAHeYHYiAAgS0a0rsg1acww5GT-PLp4fDo';

  ScheduleAnalysis? get currentAnalysis => _currentAnalysis;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void setApiKey(String apiKey) {
    _apikey = apiKey;
    notifyListeners();
  }

  Future<void> analyzeSchedule(List<TaskModel> task) async {
    if (_apikey.isEmpty || task.isEmpty) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: _apikey);
      final taskJson = jsonEncode(task.map((t) => t.toJson()).toList());

      final prompt = '''
You are an expert student scheduling assistant. The user has provided the following tasks for their day in JSON format:

$taskJson

Please provide exactly 4 sections of markdown text:
1. ### Detected Conflicts
List any scheduling conflicts or state that there are none.
2. ### Ranked Tasks
Rank which tasks need attention first.
3. ### Recommended Schedule
Provide a revised daily timeline view adjusting the task times.
4. ### Explanation
Explain why this recommendation was made.
''';

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      _currentAnalysis = _parseResponse(response.text ?? '');
    } catch (e) {

      _errorMessage = 'Failed: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  ScheduleAnalysis _parseResponse(String fullText) {
    print('Raw AI Response: $fullText');
    
    String conflicts = "No conflicts detected.",
        rankedTask = "No tasks ranked.",
        recommendedSchedule = "No schedule recommendations.",
        explanation = "No explanation provided.";

    final sections = fullText.split('###');
    for (var section in sections) {
      final trimmed = section.trim();
      if (trimmed.startsWith('Detected Conflicts')) {
        conflicts = trimmed.replaceFirst('Detected Conflicts', '').trim();
      } else if (trimmed.startsWith('Ranked Tasks')) {
        rankedTask = trimmed.replaceFirst('Ranked Tasks', '').trim();
      } else if (trimmed.startsWith('Recommended Schedule')) {
        recommendedSchedule = trimmed.replaceFirst('Recommended Schedule', '').trim();
      } else if (trimmed.startsWith('Explanation')) {
        explanation = trimmed.replaceFirst('Explanation', '').trim();
      }
    }
    
    print('Parsed - Conflicts: $conflicts');
    print('Parsed - Ranked: $rankedTask');
    print('Parsed - Schedule: $recommendedSchedule');
    print('Parsed - Explanation: $explanation');
    
    return ScheduleAnalysis(
        conflicts: conflicts.isEmpty ? "No conflicts detected." : conflicts,
        rankedTasks: rankedTask.isEmpty ? "No tasks ranked." : rankedTask,
        recommendedSchedule: recommendedSchedule.isEmpty ? "No schedule recommendations." : recommendedSchedule,
        explanation: explanation.isEmpty ? "No explanation provided." : explanation
    );
  }
}