import 'package:flutter/material.dart';
import 'package:local_hero/local_hero.dart';
import 'package:provider/provider.dart';

import 'question.dart';
import 'widgets/scoreboard_mini.dart';

enum _CategoryStatus {
  HIDDEN,
  REVEALED,
  EXHAUSTED,
}

class _CategoryConfig {
  _CategoryConfig({required this.title, required this.status});

  String title;
  _CategoryStatus status;
}

class _CategoriesState extends ChangeNotifier {
  List<_CategoryConfig> categoriesList = [
    _CategoryConfig(title: "Science", status: _CategoryStatus.HIDDEN),
    _CategoryConfig(title: "Art", status: _CategoryStatus.HIDDEN),
    _CategoryConfig(title: "History", status: _CategoryStatus.HIDDEN),
    _CategoryConfig(title: "Pop Music", status: _CategoryStatus.HIDDEN),
    _CategoryConfig(title: "Science2", status: _CategoryStatus.HIDDEN),
    _CategoryConfig(title: "Art2", status: _CategoryStatus.HIDDEN),
    _CategoryConfig(title: "History2", status: _CategoryStatus.HIDDEN),
    _CategoryConfig(title: "Culture", status: _CategoryStatus.HIDDEN),
    _CategoryConfig(title: "Television", status: _CategoryStatus.HIDDEN),
  ];

  String? getCategoryTitle(int index) {
    final config = categoriesList[index];
    if (config.status == _CategoryStatus.HIDDEN) {
      return "Category ${index + 1}";
    } else {
      return config.title;
    }
  }

  _CategoryStatus? getCategoryStatus(int index) {
    return categoriesList[index].status;
  }

  _CategoryStatus doStatusUpdate(int index) {
    if (categoriesList[index].status == _CategoryStatus.EXHAUSTED) {
      return _CategoryStatus.EXHAUSTED;
    }

    _CategoryStatus newStatus = switch (categoriesList[index].status) {
      _CategoryStatus.HIDDEN => _CategoryStatus.REVEALED,
      _CategoryStatus.REVEALED => _CategoryStatus.EXHAUSTED,
      _CategoryStatus.EXHAUSTED => _CategoryStatus.EXHAUSTED,
    };
    categoriesList[index].status = newStatus;
    notifyListeners();

    return newStatus;
  }
}

class CategoriesDisplayWidget extends StatelessWidget {
  static const route = "/categories";

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => _CategoriesState(),
      child: Scaffold(
        appBar: AppBar(
          leading: null,
          toolbarHeight: kToolbarHeight * 2,
          elevation: 4,
          actions: [
            ScoreBoardMiniWidget(
              padding: 36.0,
            ),
          ],
        ),
        body: _CategoriesBoard(),
      ),
    );
  }
}

class _CategoriesBoard extends StatelessWidget {
  _CategoriesBoard({Key? super.key});

  @override
  Widget build(BuildContext context) {
    var categoriesState = context.watch<_CategoriesState>();

    var hiddenCategoriesList = <Widget>[];
    var revealedCategoriesList = <Widget>[];
    var exhaustedCategoriesList = <Widget>[];

    for (final (index, config) in categoriesState.categoriesList.indexed) {
      final statusList = switch (config.status) {
        _CategoryStatus.HIDDEN => hiddenCategoriesList,
        _CategoryStatus.REVEALED => revealedCategoriesList,
        _CategoryStatus.EXHAUSTED => exhaustedCategoriesList,
      };
      statusList.add(
        Align(
          alignment: Alignment.center,
          widthFactor: 1,
          heightFactor: 1,
          key: ValueKey(("${config.title}-${config.status}")),
          child: LocalHero(
            tag: config.title,
            child: ChangeNotifierProvider.value(
              value: categoriesState,
              child: _CategoriesWidget(index: index),
            ),
          ),
        ),
      );
    }

    return LocalHeroScope(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            flex: 10,
            child: Container(
                decoration: ShapeDecoration(
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                  color: Theme.of(context).colorScheme.secondaryContainer,
                ),
                child: _makeCategorySection(
                    context, hiddenCategoriesList, "Hidden Categories")),
          ),
          Spacer(),
          Expanded(
            flex: 10,
            child: Container(
                decoration: ShapeDecoration(
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                  color: Theme.of(context).colorScheme.primaryContainer,
                ),
                child: _makeCategorySection(
                    context, revealedCategoriesList, "Revealed Categories")),
          ),
          Spacer(),
          Expanded(
            flex: 10,
            child: Container(
                decoration: ShapeDecoration(
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                child: _makeCategorySection(
                    context, exhaustedCategoriesList, "Exhausted Categories")),
          ),
        ],
      ),
    );
  }

  Widget _makeCategorySection(
      BuildContext context, List<Widget> widgetList, String sectionTitle) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Text(
            sectionTitle,
            style: Theme.of(context).textTheme.headlineLarge?.apply(
                fontSizeFactor: 1.2,
                heightDelta: 3.0,
                fontWeightDelta: 300,
                color: Theme.of(context).colorScheme.onPrimaryFixedVariant),
          ),
        ),
        Wrap(
          direction: Axis.horizontal,
          alignment: WrapAlignment.center,
          runAlignment: WrapAlignment.center,
          spacing: 20,
          runSpacing: 20,
          children: widgetList,
        ),
      ],
    );
  }
}

typedef OnPressedHandler = void Function();

class _CategoriesWidget extends StatelessWidget {
  final int index;

  _CategoriesWidget({required this.index, Key? super.key});

  @override
  Widget build(BuildContext context) {
    var state = context.watch<_CategoriesState>();
    final titleString = state.getCategoryTitle(this.index)!;
    final categoryStatus = state.getCategoryStatus(index);

    final theme = Theme.of(context);
    final (textColor, buttonColor) = switch (categoryStatus!) {
      _CategoryStatus.HIDDEN => (
          theme.colorScheme.onSecondary,
          theme.colorScheme.secondary
        ),
      _CategoryStatus.REVEALED => (
          theme.colorScheme.onPrimary,
          theme.colorScheme.primary
        ),
      _CategoryStatus.EXHAUSTED => (theme.colorScheme.surface, null),
    };

    return Center(
      widthFactor: 1.2,
      heightFactor: 1.15,
      child: FilledButton(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(titleString,
              style: theme.textTheme.headlineLarge
                  ?.apply(fontSizeFactor: 2.0, color: textColor),
              textAlign: TextAlign.center),
        ),
        style: FilledButton.styleFrom(backgroundColor: buttonColor),
        onPressed: categoryStatus == _CategoryStatus.EXHAUSTED
            ? null
            : () => _onPressed(context, state),
      ),
    );
  }

  void _onPressed(BuildContext context, _CategoriesState state) {
    final newStatus = state.doStatusUpdate(this.index);
    if (newStatus == _CategoryStatus.EXHAUSTED) {
      final navigator = Navigator.of(context);
      print("Scheduling the future");
      Future.delayed(Duration(milliseconds: 600), () {
        print("Executing the future");
        navigator.pushNamed(QuestionDisplayWidget.route);
      });
    }
  }
}
