import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'view/home_page.dart';
import 'view/styles.dart';
import 'viewmodel/todo_viewmodel.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TodoViewModel(),
      child: MaterialApp(
        title: 'To‑Do App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
          scaffoldBackgroundColor: AppColors.bg,
        ),
        home: const HomePage(),
      ),
    );
  }
}
