import 'package:flutter/material.dart';
import 'package:local_hero/local_hero.dart';
import 'package:provider/provider.dart';

enum CategoryStatus {
  HIDDEN,
  REVEALED,
  EXHAUSTED,
}

class CategoryConfig {
  CategoryConfig({required this.title, required this.status});

  String title;
  CategoryStatus status;
}

class _CategoriesState extends ChangeNotifier {
  List<CategoryConfig> categoriesList = [
    CategoryConfig(title: "Science", status: CategoryStatus.HIDDEN),
    CategoryConfig(title: "Art", status: CategoryStatus.HIDDEN),
    CategoryConfig(title: "History", status: CategoryStatus.HIDDEN),
    CategoryConfig(title: "Pop Music", status: CategoryStatus.HIDDEN),
    CategoryConfig(title: "Science2", status: CategoryStatus.HIDDEN),
    CategoryConfig(title: "Art2", status: CategoryStatus.HIDDEN),
    CategoryConfig(title: "History2", status: CategoryStatus.HIDDEN),
    CategoryConfig(title: "Culture", status: CategoryStatus.HIDDEN),
    CategoryConfig(title: "Television", status: CategoryStatus.HIDDEN),
  ];

  String? getCategoryTitle(int index) {
    final config = categoriesList[index];
    if (config.status == CategoryStatus.HIDDEN) {
      return "Category ${index + 1}";
    } else {
      return config.title;
    }
  }

  CategoryStatus? getCategoryStatus(int index) {
    return categoriesList[index].status;
  }

  void doStatusUpdate(int index) {
    if (categoriesList[index].status == CategoryStatus.EXHAUSTED) {
      return;
    }

    CategoryStatus newStatus = switch (categoriesList[index].status) {
      CategoryStatus.HIDDEN => CategoryStatus.REVEALED,
      CategoryStatus.REVEALED => CategoryStatus.EXHAUSTED,
      CategoryStatus.EXHAUSTED => CategoryStatus.EXHAUSTED,
    };
    categoriesList[index].status = newStatus;
    notifyListeners();
  }
}

class Categories extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => _CategoriesState(),
      child: CategoriesBoard(),
    );
  }
}

class CategoriesBoard extends StatelessWidget {
  CategoriesBoard({Key? super.key});

    Widget makeCategorySection(BuildContext context, List<Widget> widgetList, String sectionTitle) {
        return Column(
            children: <Widget>[
                Text(sectionTitle, style: Theme.of(context).textTheme.headlineLarge?.apply(
                        fontSizeFactor: 1.2,
                        heightDelta: 3.0,
                        fontWeightDelta: 300,
                        color: Theme.of(context).colorScheme.onSurface
                    )
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: widgetList
                )
            ]
        );
    }

  @override
  Widget build(BuildContext context) {
    var categoriesState = context.watch<_CategoriesState>();

    var hiddenCategoriesList = <Widget>[];
    var revealedCategoriesList = <Widget>[];
    var exhaustedCategoriesList = <Widget>[];

    for (final (index, config) in categoriesState.categoriesList.indexed) {
      final statusList = switch (config.status) {
        CategoryStatus.HIDDEN => hiddenCategoriesList,
        CategoryStatus.REVEALED => revealedCategoriesList,
        CategoryStatus.EXHAUSTED => exhaustedCategoriesList,
      };
      statusList.add(
        Flexible(
          key: ValueKey(("${config.title}-${config.status}")),
          child: LocalHero(
            tag: config.title,
            child: ChangeNotifierProvider.value(
                value: categoriesState,
                child: _CategoriesWidget(index: index)
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
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                ),
                child: makeCategorySection(context, hiddenCategoriesList, "Hidden Categories")),
          ),
          Spacer(),
          Expanded(
            flex: 10,
            child: Container(
                decoration: ShapeDecoration(
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                  color: Theme.of(context).colorScheme.surfaceContainer,
                ),
                child: makeCategorySection(context, revealedCategoriesList, "Revealed Categories")),
          ),
          Spacer(),
          Expanded(
            flex: 10,
            child: Container(
                decoration: ShapeDecoration(
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                ),
                child: makeCategorySection(context, exhaustedCategoriesList, "Exhausted Categories")),
          ),
        ],
      ),
    );
  }
}

typedef OnPressedHandler = void Function();

class _CategoriesWidget extends StatelessWidget {
  final int index;

  _CategoriesWidget({required this.index, Key? super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Figure out how to make this work. Suggestion: https://stackoverflow.com/a/69470439
    var state = context.watch<_CategoriesState>();
    var titleString = state.getCategoryTitle(this.index)!;
    print("Index: ${this.index + 1}; current title: ${titleString} Build function called");

    return Container(
        child: Center(
            child: Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: FilledButton.tonal(
                    child: Padding(
                        padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                        child: Text(
                            titleString,
                            style: Theme.of(context).textTheme.headlineLarge?.apply(
                                fontSizeFactor: 2.0
                            ),
                            textAlign: TextAlign.center
                        )
                    ),
                    onPressed: state.getCategoryStatus(this.index) == CategoryStatus.EXHAUSTED 
                        ? null 
                        : () => state.doStatusUpdate(this.index),
                ),
            )
        ),
    );
  }
}
