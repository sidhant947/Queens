import 'package:hive_flutter/hive_flutter.dart';

import 'package:queens/domain/models/user_progress.dart';
import 'user_progress_adapter.dart';

class HiveService {
  static const String _progressBoxName = 'queen_user_progress';
  static const String _progressKey = 'progress';

  late Box<UserProgress> _progressBox;

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(UserProgressAdapter());
    _progressBox = await Hive.openBox<UserProgress>(_progressBoxName);
  }

  Future<UserProgress> getProgress() async {
    return _progressBox.get(_progressKey) ?? const UserProgress();
  }

  Future<void> saveProgress(UserProgress progress) async {
    await _progressBox.put(_progressKey, progress);
  }

  Future<void> clearProgress() async {
    await _progressBox.delete(_progressKey);
  }
}
