import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twiz/global_state.dart';

import 'pages/question.dart';
import 'pages/categories.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GlobalScoreboard()),
        ChangeNotifierProvider(create: (_) => GlobalData()),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData.from(
          colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blueGrey,
              dynamicSchemeVariant: DynamicSchemeVariant.vibrant),
        ),
        routes: {
          CategoriesDisplayWidget.route: (context) =>
              ProxyProvider<GlobalData, CategoriesData>(
                  update: (_, globalData, _prevCategoriesData) =>
                      globalData.categories,
                  child: CategoriesDisplayWidget()),
          QuestionDisplayWidget.route: (context) => QuestionDisplayWidget(),
        },
        initialRoute: CategoriesDisplayWidget.route,
      ),
    );
  }
}
