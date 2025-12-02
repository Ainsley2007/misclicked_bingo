import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/services/auth_service.dart';
import 'package:frontend/core/di.dart';
import 'package:frontend/router/app_router.dart';
import 'package:frontend/theme/app_theme.dart';

void main() {
  usePathUrlStrategy();
  setupDi();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AuthService _authService;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authService = sl<AuthService>();
    _router = AppRouter.router(_authService);
    _authService.checkAuth();
  }

  @override
  void dispose() {
    _authService.dispose();
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Misclicked Bingo',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
