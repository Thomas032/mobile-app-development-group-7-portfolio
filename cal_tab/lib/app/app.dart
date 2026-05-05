import 'package:cal_tab/app/router.dart';
import 'package:cal_tab/app/theme.dart';
import 'package:flutter/material.dart';

class CalTabApp extends StatelessWidget {
  const CalTabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'CalTab',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
