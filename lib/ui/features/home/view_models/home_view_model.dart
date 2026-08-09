import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:queens/data/repositories/progress_repository.dart';
import 'package:queens/domain/models/user_progress.dart';
import 'package:queens/domain/use_cases/level_generator.dart';

class HomeViewModelState {
  const HomeViewModelState({
    this.progress,
    this.isLoading = false,
  });

  final UserProgress? progress;
  final bool isLoading;

  HomeViewModelState copyWith({
    UserProgress? progress,
    bool? isLoading,
  }) {
    return HomeViewModelState(
      progress: progress ?? this.progress,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class HomeViewModel extends StateNotifier<HomeViewModelState> {
  HomeViewModel({
    required this.progressRepository,
    required this.levelGenerator,
  }) : super(const HomeViewModelState()) {
    progressRepository.addListener(_onProgressChanged);
  }

  final ProgressRepository progressRepository;
  final LevelGenerator levelGenerator;

  void _onProgressChanged() {
    loadProgress();
  }

  @override
  void dispose() {
    progressRepository.removeListener(_onProgressChanged);
    super.dispose();
  }

  Future<void> loadProgress() async {
    state = state.copyWith(isLoading: true);
    try {
      final progress = await progressRepository.getProgress();
      state = state.copyWith(progress: progress, isLoading: false);
      levelGenerator.pregenerateAround(progress.currentLevel, range: 1);
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> resetProgress() async {
    await progressRepository.resetProgress();
    state = const HomeViewModelState(progress: UserProgress());
  }
}
