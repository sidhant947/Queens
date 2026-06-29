import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:queens/data/repositories/progress_repository.dart';
import 'package:queens/data/services/hive_service.dart';
import 'package:queens/domain/use_cases/level_generator.dart';
import 'package:queens/ui/features/game/view_models/game_view_model.dart';
import 'package:queens/ui/features/home/view_models/home_view_model.dart';

final hiveServiceProvider = Provider<HiveService>((ref) {
  throw UnimplementedError('Must be overridden in main');
});

final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return ProgressRepository(hiveService: hiveService);
});

final levelGeneratorProvider = Provider<LevelGenerator>((ref) {
  return LevelGenerator();
});

final homeViewModelProvider =
    StateNotifierProvider<HomeViewModel, HomeViewModelState>((ref) {
  final progressRepository = ref.watch(progressRepositoryProvider);
  return HomeViewModel(progressRepository: progressRepository);
});

final gameViewModelProvider =
    StateNotifierProvider.autoDispose<GameViewModel, GameViewModelState>((ref) {
  final progressRepository = ref.watch(progressRepositoryProvider);
  final levelGenerator = ref.watch(levelGeneratorProvider);
  return GameViewModel(
    progressRepository: progressRepository,
    levelGenerator: levelGenerator,
  );
});
