import 'package:flutter/material.dart';

class Categories extends StatelessWidget {
    const Categories({super.key});

    // This widget is the root of your application.
    @override
    Widget build(BuildContext context) {
        return MaterialApp(
            title: 'Flutter Demo',
            theme: ThemeData.from(
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple, dynamicSchemeVariant: DynamicSchemeVariant.vibrant),
                // useMaterial3: true,
            ),
            home: Container(child: CategoriesBoard())
        );
    }
}


class CategoriesBoard extends StatefulWidget {
    
    CategoriesBoard ({Key? key}): super(key: key);

    @override
    State<CategoriesBoard> createState() => _CategoriesBoardState();

}

class _CategoriesBoardState extends State<CategoriesBoard> {
    
    final keysList = <GlobalKey<_CategoriesWidgetState>>[
        GlobalKey<_CategoriesWidgetState>(),
        GlobalKey<_CategoriesWidgetState>(),
        GlobalKey<_CategoriesWidgetState>()
    ];

    Map<CategoriesWidget, GlobalKey<_CategoriesWidgetState>>? categoriesToKeysMap;

    @override
    initState() {
        categoriesToKeysMap = {
            CategoriesWidget(categoryTitle: "Science", key: keysList[0]) : keysList[0], 
            CategoriesWidget(categoryTitle: "Art", key: keysList[1])     : keysList[1], 
            CategoriesWidget(categoryTitle: "History", key: keysList[2]) : keysList[2]
        };
    }

    @override
    Widget build(BuildContext context) {

        final hiddenCategoriesList = <CategoriesWidget>[];
        final revealedCategoriesList = <CategoriesWidget>[];
        final exhaustedCategoriesList = <CategoriesWidget>[];

        if(categoriesToKeysMap == null) {
            initState();
        }

        print('Building Categories board');
        categoriesToKeysMap?.forEach((categoryWidget, key) {
            print('Adding $categoryWidget');
            if(key.currentState?.getStatus() == CategoryStatus.HIDDEN) {
                print('Hidden Category added');
                hiddenCategoriesList.add(categoryWidget);
            }

            else if(key.currentState?.getStatus() == CategoryStatus.REVEALED) {
                print('REVEALED Category added');
                revealedCategoriesList.add(categoryWidget);
            }

            else if(key.currentState?.getStatus() == CategoryStatus.EXHAUSTED) {
                print('EXHAUSTED Category added');
                exhaustedCategoriesList.add(categoryWidget);
            }
            else {
                print('Hidden Category added because key.currentState is null');
                hiddenCategoriesList.add(categoryWidget);
            }
        });
        

        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
                Row(children: hiddenCategoriesList), 
                Row(children: revealedCategoriesList),
                Row(children: exhaustedCategoriesList),
            ],
        );
    }
}


enum CategoryStatus {
  HIDDEN,
  REVEALED,
  EXHAUSTED,
}

class CategoriesWidget extends StatefulWidget {
    String categoryTitle = "Unnamed";
    
    CategoriesWidget ({required this.categoryTitle, Key? key}): super(key: key);

    @override
    State<CategoriesWidget> createState() => _CategoriesWidgetState();
}

class _CategoriesWidgetState extends State<CategoriesWidget> {
    bool favorite = false;
    CategoryStatus status = CategoryStatus.HIDDEN;

    CategoryStatus getStatus() {
        return this.status;
    }

    @override
    initState() {
        status = CategoryStatus.HIDDEN;
    }

    void doReveal() {
        print('_CategoriesWidgetState.doReveal(): ${this.widget.categoryTitle}');
        this.status = CategoryStatus.REVEALED;
    }

    void doExhaust() {
        print('_CategoriesWidgetState.doExhaust(): ${this.widget.categoryTitle}');
        this.status = CategoryStatus.EXHAUSTED;
    }

    @override
    Widget build(BuildContext context) {
        return Container(
            child: Center(
                child: ActionChip(
                avatar: Icon(this.favorite ? Icons.favorite : Icons.favorite_border),
                label: Text(this.widget.categoryTitle),
                onPressed: () {
                    setState(() {
                        this.favorite = !this.favorite;
                        if(this.status == CategoryStatus.HIDDEN) doReveal();
                        if(this.status == CategoryStatus.REVEALED) doExhaust();
                    });
                }), 
            ),
        );
    }
}