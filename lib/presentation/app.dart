import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quickmarket/core/constants/app_strings.dart';
import 'package:quickmarket/core/theme/app_theme.dart';
import 'package:quickmarket/presentation/router/app_router.dart';

/// Raíz Material 3 con `ProviderScope` externo en `main.dart`.
class QuickMarketApp extends ConsumerWidget {
  const QuickMarketApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    return MaterialApp.router(
      title: AppStrings.appName,
      theme: AppTheme.light(),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
