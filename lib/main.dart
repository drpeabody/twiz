import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twiz/global_state.dart';

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
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blueGrey,
            dynamicSchemeVariant: DynamicSchemeVariant.vibrant),
      ),
      home: Scaffold(
        body: ChangeNotifierProvider(
          create: (_) => GlobalScoreboard(),
          child: QuestionDisplayWidget(),
        ),
      ),
    );
  }
}
