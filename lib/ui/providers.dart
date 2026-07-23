import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:queens/data/repositories/progress_repository.dart';
import 'package:queens/data/services/hive_service.dart';
import 'package:queens/data/services/settings_service.dart';
import 'package:queens/domain/models/app_settings.dart';
import 'package:queens/domain/use_cases/level_generator.dart';
import 'package:queens/ui/features/game/view_models/game_view_model.dart';
import 'package:queens/ui/features/home/view_models/home_view_model.dart';
import 'package:queens/ui/features/settings/view_models/settings_view_model.dart';

final hiveServiceProvider = Provider<HiveService>((ref) {
  throw UnimplementedError('Must be overridden in main');
});

final settingsServiceProvider = Provider<SettingsService>((ref) {
  throw UnimplementedError('Must be overridden in main');
});

final progressRepositoryProvider = ChangeNotifierProvider<ProgressRepository>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return ProgressRepository(hiveService: hiveService);
});

final levelGeneratorProvider = Provider<LevelGenerator>((ref) {
  return LevelGenerator();
});

final homeViewModelProvider =
    StateNotifierProvider<HomeViewModel, HomeViewModelState>((ref) {
      final progressRepository = ref.read(progressRepositoryProvider);
      return HomeViewModel(progressRepository: progressRepository);
    });

final gameViewModelProvider =
    StateNotifierProvider.autoDispose<GameViewModel, GameViewModelState>((ref) {
      final progressRepository = ref.read(progressRepositoryProvider);
      final levelGenerator = ref.read(levelGeneratorProvider);
      return GameViewModel(
        progressRepository: progressRepository,
        levelGenerator: levelGenerator,
      );
    });

final settingsProvider =
    StateNotifierProvider<SettingsViewModel, AppSettings>((ref) {
      final settingsService = ref.watch(settingsServiceProvider);
      return SettingsViewModel(settingsService: settingsService);
    });
