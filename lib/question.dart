import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
 
enum QuestionDisplayState {
  EMPTY,
  SHOW_CLUE1,
  SHOW_CLUE2,
}
 
class QuestionState extends ChangeNotifier {
  var _displayState = QuestionDisplayState.EMPTY;
 
  void doRevealClue1() {
    if (_displayState != QuestionDisplayState.SHOW_CLUE1) {
      _displayState = QuestionDisplayState.SHOW_CLUE1;
      notifyListeners();
    }
  }
 
  void doRevealClue2() {
    if (_displayState != QuestionDisplayState.SHOW_CLUE2) {
      _displayState = QuestionDisplayState.SHOW_CLUE2;
      notifyListeners();
    }
  }
 
  QuestionDisplayState getDisplayState() {
    return _displayState;
  }
}
 
class QuestionDisplayWidget extends StatelessWidget {
  const QuestionDisplayWidget();
 
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => QuestionState(),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              flex: 3,
              child: QuestionTitleWidget(),
            ),
            Expanded(flex: 6, child: ClueGridWidget()),
          ]),
    );
  }
}
 
class QuestionTitleWidget extends StatelessWidget {
  const QuestionTitleWidget({
    super.key,
  });
 
  @override
  Widget build(BuildContext context) {
    var question_state = context.watch<QuestionState>();
    return Row(children: [
      Expanded(
        flex: 19,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(flex: 1, child: Text("Question Title here")),
            Expanded(flex: 1, child: Text("Question description here")),
          ],
        ),
      ),
      Expanded(
        flex: 1,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton.filledTonal(
              onPressed: () {
                question_state.doRevealClue1();
              },
              icon: Icon(Icons.favorite),
            ),
            IconButton.filledTonal(
              onPressed: () {
                question_state.doRevealClue2();
              },
              icon: Icon(Icons.favorite),
            ),
          ],
        ),
      ),
    ]);
  }
}
 
class ClueGridWidget extends StatelessWidget {
  const ClueGridWidget({super.key});
 
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: GridView.count(
          crossAxisCount: 3,
          physics: NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(8),
          childAspectRatio:
              (6.0 / 3.0) * (constraints.maxWidth / constraints.maxHeight),
          children: List.generate(18, (idx) => buildClueButton(context, idx),
              growable: false),
        ),
      );
    });
  }
 
  Widget buildClueButton(BuildContext context, int index) {
    if (index < 3) {
      return Container(
        margin: const EdgeInsets.all(12.0),
        decoration: clueButtonShapeDecoration(Theme.of(context).colorScheme),
        alignment: Alignment.center,
        child: ClueScoreText(columnIndex: index),
      );
    } else {
      var clueIdx = index - 3;
      clueIdx = 5 * (clueIdx % 3) + (clueIdx ~/ 3);
      return ClueButtonWidget(index: clueIdx);
    }
  }
}
 
const CLUE1_SCORES = [20, 30, 40];
const CLUE2_SCORES = [10, 15, 20];
 
class ClueScoreText extends StatelessWidget {
  const ClueScoreText({super.key, required this.columnIndex});
 
  final int columnIndex;
 
  @override
  Widget build(BuildContext context) {
    var question_state = context.watch<QuestionState>();
    var score_text = switch (question_state.getDisplayState()) {
      QuestionDisplayState.EMPTY => "-",
      QuestionDisplayState.SHOW_CLUE1 => "${CLUE1_SCORES[columnIndex]} points",
      QuestionDisplayState.SHOW_CLUE2 => "${CLUE2_SCORES[columnIndex]} points",
    };
 
    return Text(score_text);
  }
}
 
class ClueButtonWidget extends StatefulWidget {
  const ClueButtonWidget({super.key, required this.index});
 
  final int index;
 
  @override
  State<ClueButtonWidget> createState() => _ClueButtonWidgetState();
}
 
class _ClueButtonWidgetState extends State<ClueButtonWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12.0),
      decoration: clueButtonShapeDecoration(Theme.of(context).colorScheme),
      alignment: Alignment.center,
      child: Text("Clue ${widget.index} goes here"),
    );
  }
}
 
ShapeDecoration clueButtonShapeDecoration(ColorScheme colorScheme) {
  return ShapeDecoration(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(48.0),
    ),
    gradient: RadialGradient(
      colors: [colorScheme.primaryContainer, colorScheme.secondaryContainer],
    ),
  );
}
 
