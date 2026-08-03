import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: EgoractiveApp()));
}

class EgoractiveApp extends StatelessWidget {
  const EgoractiveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Egoractive',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF05A6FA),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const _HelloEgoractivePanel(),
    );
  }
}

class _HelloEgoractivePanel extends StatelessWidget {
  const _HelloEgoractivePanel();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Hello Egoractive',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
