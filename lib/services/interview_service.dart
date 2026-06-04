import 'package:hive_flutter/hive_flutter.dart';
import '../models/interview_story.dart';
import '../models/interview_story_adapter.dart';

class InterviewService {
  static const String boxName = 'interview_stories';

  static Future<void> init() async {
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(InterviewStoryAdapter());
    }
    await Hive.openBox<InterviewStory>(boxName);
  }

  static Box<InterviewStory> get _box {
    return Hive.box<InterviewStory>(boxName);
  }

  static Future<void> saveStory(InterviewStory story) async {
    await _box.put(story.id, story);
  }

  static List<InterviewStory> getAllStories() {
    final stories = _box.values.toList();
    if (stories.isEmpty) {
      return _getSampleStories();
    }
    return stories..sort((a, b) => b.lastModified.compareTo(a.lastModified));
  }

  static List<InterviewStory> _getSampleStories() {
    return [
      InterviewStory(
        id: 'sample1',
        title: 'Handling a Tight Deadline',
        situation:
            'Our team was behind on a major project delivery for a key client due to unexpected API changes.',
        task:
            'I needed to find a way to speed up the development without sacrificing the code quality or testing.',
        action:
            'I organized a "sprint focus" day, automated the regression testing suite, and re-allocated non-essential administrative tasks to the following week.',
        result:
            'We delivered the project 2 days early with zero critical bugs, which secured a contract renewal for the company.',
        lastModified: DateTime.now(),
      ),
      InterviewStory(
        id: 'sample2',
        title: 'Resolving Team Conflict',
        situation:
            'Two senior developers disagreed on the architecture of a new microservice, causing a stalemate in progress.',
        task:
            'The project was stalled, and team morale was dropping due to the tension.',
        action:
            'I facilitated a technical comparison session where we mapped the pros and cons for both approaches and discovered a hybrid solution that leveraged the strengths of both.',
        result:
            'The team morale improved significantly, and the hybrid solution actually handled 20% more load than either original proposal.',
        lastModified: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }

  static Future<void> deleteStory(String id) async {
    await _box.delete(id);
  }
}
