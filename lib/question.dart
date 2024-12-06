import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'widgets/score_counter.dart';

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

const QUESTION_DISPLAY_PADDING = 36.0;

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
            Expanded(flex: 3, child: QuestionTitleWidget()),
            Expanded(flex: 8, child: ClueGridWidget()),
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
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.all(QUESTION_DISPLAY_PADDING),
      child: Row(children: [
        Expanded(
          flex: 19,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                flex: 1,
                child: AutoSizeText("Question Title here",
                    maxLines: 1,
                    minFontSize: textTheme.headlineLarge?.fontSize ?? 12,
                    overflow: TextOverflow.fade,
                    style: textTheme.displayLarge!
                        .copyWith(color: colorScheme.primary)),
              ),
              Expanded(
                flex: 2,
                child: AutoSizeText(
                    "Question description here. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.",
                    maxLines: 3,
                    minFontSize: textTheme.headlineLarge?.fontSize ?? 12,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.displayMedium!
                        .copyWith(color: colorScheme.secondary)),
              ),
            ],
          ),
        ),
        Spacer(flex: 1),
        Expanded(
          flex: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton.filledTonal(
                onPressed: () {
                  question_state.doRevealClue1();
                },
                icon: Icon(Icons.favorite),
                iconSize: QUESTION_DISPLAY_PADDING,
                padding: EdgeInsets.all(QUESTION_DISPLAY_PADDING / 2),
              ),
              IconButton.filledTonal(
                onPressed: () {
                  question_state.doRevealClue2();
                },
                icon: Icon(Icons.favorite),
                iconSize: QUESTION_DISPLAY_PADDING,
                padding: EdgeInsets.all(QUESTION_DISPLAY_PADDING / 2),
              ),
            ],
          ),
        ),
        Container(
          child: ScoreCounter(stepValue: 5),
        ),
      ]),
    );
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
          children: List.generate(
              18, (idx) => buildClueGridWidget(context, idx),
              growable: false),
        ),
      );
    });
  }

  Widget buildClueGridWidget(BuildContext context, int index) {
    if (index < 3) {
      return Container(
        margin: const EdgeInsets.all(12.0),
        decoration: _clueButtonDecoration(Theme.of(context).colorScheme),
        alignment: Alignment.center,
        child: ClueScoreText(columnIndex: index),
      );
    } else {
      var clueIdx = index - 3;
      clueIdx = 5 * (clueIdx % 3) + (clueIdx ~/ 3);
      return ClueDisplayWidget(index: clueIdx);
    }
  }
}

ShapeDecoration _clueButtonDecoration(ColorScheme colorScheme) {
  return ShapeDecoration(
    shape: StadiumBorder(),
    color: colorScheme.primaryContainer,
  );
}

const CLUE1_SCORES = [20, 30, 40];
const CLUE2_SCORES = [10, 15, 20];

class ClueScoreText extends StatelessWidget {
  const ClueScoreText({super.key, required this.columnIndex});

  final int columnIndex;

  @override
  Widget build(BuildContext context) {
    var question_state = context.watch<QuestionState>();
    final score_text = switch (question_state.getDisplayState()) {
      QuestionDisplayState.EMPTY => "- -",
      QuestionDisplayState.SHOW_CLUE1 => "${CLUE1_SCORES[columnIndex]} points",
      QuestionDisplayState.SHOW_CLUE2 => "${CLUE2_SCORES[columnIndex]} points",
    };

    final theme = Theme.of(context);
    return AutoSizeText(score_text,
        maxLines: 1,
        minFontSize: theme.textTheme.headlineSmall?.fontSize ?? 12,
        style: theme.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onPrimaryContainer),
        overflow: TextOverflow.ellipsis);
  }
}

const CLUE_DISPLAY_PADDING = 12.0;

class ClueDisplayWidget extends StatefulWidget {
  const ClueDisplayWidget({super.key, required this.index});

  final int index;

  @override
  State<ClueDisplayWidget> createState() => _ClueDisplayWidgetState();
}

class _ClueDisplayWidgetState extends State<ClueDisplayWidget> {
  var answer_shown = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(CLUE_DISPLAY_PADDING),
      child: LayoutBuilder(builder: (context, constraints) {
        final maxIconSize = min(constraints.maxHeight, constraints.maxWidth);
        return Stack(
          alignment: Alignment.centerLeft,
          fit: StackFit.expand,
          children: [
            Positioned(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              child:
                  ClueTextWidget(index: widget.index, iconPadding: maxIconSize),
            ),
            Positioned(
              width: maxIconSize,
              height: maxIconSize,
              child: ClueButtonWidget(index: widget.index, size: maxIconSize),
            ),
          ],
        );
      }),
    );
  }
}

class ClueButtonWidget extends StatelessWidget {
  const ClueButtonWidget({super.key, required this.index, required this.size});

  final int index;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FilledButton(
      onPressed: () {},
      child: AutoSizeText("${this.index}",
          maxLines: 1,
          textScaleFactor: 1.6,
          minFontSize: theme.textTheme.headlineSmall?.fontSize ?? 12,
          style: theme.textTheme.headlineLarge?.copyWith(
              color: theme.colorScheme.onPrimaryContainer),
          overflow: TextOverflow.visible),
      style: FilledButton.styleFrom(
          textStyle: theme.textTheme.headlineLarge
              ?.copyWith(color: theme.colorScheme.onInverseSurface),
          fixedSize: Size.square(this.size),
          backgroundColor: theme.colorScheme.inversePrimary,
          elevation: 0,
          shape: const CircleBorder()),
    );
  }
}

class ClueTextWidget extends StatelessWidget {
  final int index;
  final double iconPadding;

  const ClueTextWidget(
      {super.key, required this.index, required this.iconPadding});

  @override
  Widget build(BuildContext context) {
    var question_state = context.watch<QuestionState>();
    final clue_text = switch (question_state.getDisplayState()) {
      QuestionDisplayState.EMPTY => "",
      QuestionDisplayState.SHOW_CLUE1 => "Clue ${this.index} Hint 1. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
      QuestionDisplayState.SHOW_CLUE2 => "Clue ${this.index} Hint 2. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
    };

    final theme = Theme.of(context);
    return
        // AnimatedSwitcher(
        //   duration: Duration(milliseconds: 200),
        //   transitionBuilder: __transitionBuilder,
        //   layoutBuilder: (widget, list) => Stack(children: [widget!, ...list]),
        //   switchInCurve: Curves.easeInBack,
        //   switchOutCurve: Curves.easeInBack.flipped,
        //   child:
        Container(
      padding: EdgeInsets.only(left: iconPadding + 2 * CLUE_DISPLAY_PADDING, right: CLUE_DISPLAY_PADDING),
      alignment: Alignment.centerLeft,
      decoration: _clueButtonDecoration(theme.colorScheme),
      child: AutoSizeText(clue_text,
          maxLines: 3,
          key: ValueKey(question_state.getDisplayState()),
          minFontSize: theme.textTheme.headlineSmall?.fontSize ?? 12,
          style: theme.textTheme.headlineLarge
              ?.copyWith(color: theme.colorScheme.onPrimaryContainer),
          overflow: TextOverflow.ellipsis),
      // ),
    );
  }

  // Widget __transitionBuilder(Widget widget, Animation<double> animation) {
  //   final rotateAnim = Tween(begin: pi, end: 0.0).animate(animation);
  //   return AnimatedBuilder(
  //     animation: rotateAnim,
  //     child: widget,
  //     builder: (context, widget) {
  //       final isUnder = false;
  //       final tilt = ((animation.value - 0.5).abs() - 0.5) * 0.003;
  //       tilt *= isUnder ? -1.0 : 1.0;
  //       final value =
  //           isUnder ? min(rotateAnim.value, pi / 2) : rotateAnim.value;
  //       return Transform(
  //         transform: Matrix4.rotationX(value)..setEntry(3, 0, tilt),
  //         child: widget,
  //         alignment: Alignment.center,
  //       );
  //     },
  //   );
  // }
}
