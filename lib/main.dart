import 'package:flutter/material.dart';

import 'question.dart';
import 'categories.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey, dynamicSchemeVariant: DynamicSchemeVariant.vibrant),
        // useMaterial3: true,
      ),
      home: Scaffold(body: Categories()),
    );
  }
}
