import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:local_hero/local_hero.dart';
import 'package:provider/provider.dart';
import 'package:twiz/global_state.dart';

import 'question.dart';
import 'widgets/scoreboard_mini.dart';

enum _CategoryStatus {
  HIDDEN,
  REVEALED,
  EXHAUSTED,
}

class _CategoriesState extends ChangeNotifier {
  _CategoriesState({required int count})
      : categoriesList = List.filled(count, _CategoryStatus.HIDDEN);

  final List<_CategoryStatus> categoriesList;

  _CategoryStatus? getCategoryStatus(int index) {
    return categoriesList[index];
  }

  _CategoryStatus doStatusUpdate(int index) {
    if (categoriesList[index] == _CategoryStatus.EXHAUSTED) {
      return _CategoryStatus.EXHAUSTED;
    }

    var newStatus = switch (categoriesList[index]) {
      _CategoryStatus.HIDDEN => _CategoryStatus.REVEALED,
      _CategoryStatus.REVEALED => _CategoryStatus.EXHAUSTED,
      _CategoryStatus.EXHAUSTED => _CategoryStatus.EXHAUSTED,
    };
    categoriesList[index] = newStatus;
    notifyListeners();

    return newStatus;
  }
}

class CategoriesDisplayWidget extends StatelessWidget {
  static const route = "/categories";

  @override
  Widget build(BuildContext context) {
    final categoriesData = context.watch<GlobalData>().categories;
    return ChangeNotifierProvider.value(
      value: _CategoriesState(count: categoriesData.getCount()),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          toolbarHeight: kToolbarHeight * 2,
          elevation: 4,
          actions: [
            _DataLoaderIcon(),
            SizedBox.square(dimension: 36),
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

class _DataLoaderIcon extends StatefulWidget {
  const _DataLoaderIcon({super.key});

  @override
  State<_DataLoaderIcon> createState() => _DataLoaderIconState();
}

class _DataLoaderIconState extends State<_DataLoaderIcon> {
  late Future<void> dataFuture;

  @override
  void initState() {
    super.initState();

    dataFuture = Future.sync(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: dataFuture,
        builder: (context, snapshot) {
          final globalData = context.watch<GlobalData>();
          if (snapshot.hasError) {
            print("Dataset loading Error: ${snapshot.error}");
            return _buildIconButton(context, child: Icon(Icons.report));
          } else if (snapshot.connectionState == ConnectionState.done) {
            return _buildIconButton(
              context,
              child: Icon(Icons.refresh),
              onPressed: () => setState(() {
                this.dataFuture = globalData
                    .readJson(DefaultAssetBundle.of(context))
                    .then((_) =>
                        Future.delayed(Duration(milliseconds: 1000), () {}));
              }),
            );
          } else {
            return _buildIconButton(context,
                child: CircularProgressIndicator(strokeWidth: 6));
          }
        });
  }

  Widget _buildIconButton(
    BuildContext context, {
    required Widget child,
    OnPressedHandler? onPressed,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return IconButton(
      onPressed: onPressed,
      icon: child,
      color: colorScheme.secondary,
      iconSize: QUESTION_DISPLAY_PADDING * 1.5,
      padding: EdgeInsets.all(QUESTION_DISPLAY_PADDING / 2),
    );
  }
}

class _CategoriesBoard extends StatelessWidget {
  _CategoriesBoard({Key? super.key});

  @override
  Widget build(BuildContext context) {
    var categoriesState = context.watch<_CategoriesState>();
    final categoriesData = context.read<CategoriesData>();

    var hiddenCategoriesList = <Widget>[];
    var revealedCategoriesList = <Widget>[];
    var exhaustedCategoriesList = <Widget>[];

    for (final (index, status) in categoriesState.categoriesList.indexed) {
      final categoryName = categoriesData.getCategoryName(index);
      final statusList = switch (status) {
        _CategoryStatus.HIDDEN => hiddenCategoriesList,
        _CategoryStatus.REVEALED => revealedCategoriesList,
        _CategoryStatus.EXHAUSTED => exhaustedCategoriesList,
      };
      statusList.add(
        Align(
          alignment: Alignment.center,
          widthFactor: 1,
          heightFactor: 1,
          key: ValueKey((categoriesData.hashCode, categoryName, status)),
          child: LocalHero(
            tag: categoryName,
            child: MultiProvider(
              providers: [
                Provider.value(value: categoriesData),
                ChangeNotifierProvider.value(value: categoriesState),
              ],
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
        crossAxisAlignment: CrossAxisAlignment.center,
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
        // Expanded(flex: 2, child:
        Center(
          child: AutoSizeText(
            sectionTitle,
            textScaleFactor: 1.2,
            style: Theme.of(context).textTheme.headlineLarge?.apply(
                heightDelta: 3.0,
                fontWeightDelta: 300,
                color: Theme.of(context).colorScheme.onPrimaryFixedVariant),
          ),
        ),
        // ),
        // Expanded(flex: 2, child:
        Wrap(
          direction: Axis.horizontal,
          alignment: WrapAlignment.center,
          runAlignment: WrapAlignment.center,
          spacing: 20,
          runSpacing: 20,
          children: widgetList,
        ),
        // ),
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
    final categoryStatus = state.getCategoryStatus(index);
    final titleString = context.read<CategoriesData>().getCategoryName(
        this.index,
        hidden: categoryStatus == _CategoryStatus.HIDDEN);

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
          child: AutoSizeText(titleString,
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
      final questionData =
          context.read<CategoriesData>().getCategoryQuestion(this.index);
      Future.delayed(Duration(milliseconds: 600), () {
        navigator.pushNamed(QuestionDisplayWidget.route,
            arguments: questionData);
      });
    }
  }
}
