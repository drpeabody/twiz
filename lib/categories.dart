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
    CategoryConfig(title: "Category 4", status: CategoryStatus.HIDDEN),
    CategoryConfig(title: "Science2", status: CategoryStatus.HIDDEN),
    CategoryConfig(title: "Art2", status: CategoryStatus.HIDDEN),
    CategoryConfig(title: "History2", status: CategoryStatus.HIDDEN),
    CategoryConfig(title: "Category 8", status: CategoryStatus.HIDDEN),
    CategoryConfig(title: "Category 9", status: CategoryStatus.HIDDEN),
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

  @override
  Widget build(BuildContext context) {
    var state = context.watch<_CategoriesState>();

    var hiddenCategoriesList = <Widget>[];
    var revealedCategoriesList = <Widget>[];
    var exhaustedCategoriesList = <Widget>[];

    for (final (index, config) in state.categoriesList.indexed) {
      final statusList = switch (config.status) {
        CategoryStatus.HIDDEN => hiddenCategoriesList,
        CategoryStatus.REVEALED => revealedCategoriesList,
        CategoryStatus.EXHAUSTED => exhaustedCategoriesList,
      };
      final isDisabled = config == CategoryStatus.EXHAUSTED;
      statusList.add(
        Flexible(
          key: ValueKey(("${config.title}-${config.status}")),
          child: LocalHero(
            tag: config.title,
            flightShuttleBuilder: (context, animation, child) {
              // TODO: Figure out how to make this work. Suggestion: https://stackoverflow.com/a/69470439
              // var state = context.watch<_CategoriesState>();
              child = child as CategoriesWidget;
              int index = child.index;
              print(
                  "Child name: ${child.title} and index: ${index + 1} should be called ${state.getCategoryTitle(index)}");
              return child;
            },
            child: CategoriesWidget(
              index: index,
              title: state.getCategoryTitle(index)!,
              onPressed: isDisabled ? null : () => state.doStatusUpdate(index),
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
                  color: Colors.white,
                ),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: hiddenCategoriesList)),
          ),
          Spacer(),
          Expanded(
            flex: 10,
            child: Container(
                decoration: ShapeDecoration(
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                  color: Colors.blue,
                ),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: revealedCategoriesList)),
          ),
          Spacer(),
          Expanded(
            flex: 10,
            child: Container(
                decoration: ShapeDecoration(
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                  color: Colors.blueGrey,
                ),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: exhaustedCategoriesList)),
          ),
        ],
      ),
    );
  }
}

typedef OnPressedHandler = void Function();

class CategoriesWidget extends StatefulWidget {
  String title;
  final int index;
  final OnPressedHandler? onPressed;

  CategoriesWidget(
      {required this.title,
      required this.index,
      this.onPressed,
      Key? super.key});

  @override
  State<CategoriesWidget> createState() => _CategoriesWidgetState();
}

class _CategoriesWidgetState extends State<CategoriesWidget> {
  @override
  Widget build(BuildContext context) {
    // TODO: Figure out how to make this work. Suggestion: https://stackoverflow.com/a/69470439
    // var state = context.watch<_CategoriesState>();
    print(
        "Index: ${this.widget.index + 1}; current title: ${this.widget.title} Build function called");
    return Container(
      child: Center(
        child: FilledButton.tonal(
          child: Text(this.widget.title,
              style: Theme.of(context).textTheme.headlineLarge),
          onPressed: this.widget.onPressed,
        ),
      ),
    );
  }
}
