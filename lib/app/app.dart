import 'package:flutter/material.dart';

import 'app_router.dart';
import 'app_theme.dart';

class ZippySumApp extends StatelessWidget {
  const ZippySumApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZippySum',
      theme: AppTheme.dark(),
      initialRoute: AppRouter.initialRoute,
      routes: AppRouter.routes,
    );
  }
}
