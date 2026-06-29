import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:queens/data/services/hive_service.dart';
import 'package:queens/ui/core/theme/app_theme.dart';
import 'package:queens/ui/providers.dart';
import 'package:queens/ui/features/home/views/home_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final hiveService = HiveService();
  await hiveService.init();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));

  runApp(
    ProviderScope(
      overrides: [
        hiveServiceProvider.overrideWithValue(hiveService),
      ],
      child: const QueensApp(),
    ),
  );
}

class QueensApp extends StatelessWidget {
  const QueensApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Queens',
      theme: AppTheme.light,
      home: const HomeView(),
      debugShowCheckedModeBanner: false,
    );
  }
}
