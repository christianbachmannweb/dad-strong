import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/routes/app_router.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';

final _router = AppRouter();

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Dad Strong',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        textTheme: TextTheme(bodyMedium: AppTypography.bodyMedium),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      routerConfig: _router.config(),
    );
  }
}
