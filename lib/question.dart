import 'dart:math';

import 'package:animated_switcher_transitions/animated_switcher_transitions.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'global_state.dart';
import 'widgets/scoreboard_mini.dart';

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
  static const route = "/question"; 

  const QuestionDisplayWidget();

  @override
  Widget build(BuildContext context) {
    final questionData = ModalRoute.of(context)!.settings.arguments as QuestionData?;

    return MultiProvider(providers: [
      ChangeNotifierProvider(create: (_) => QuestionState()),
      Provider.value(value: questionData ?? QuestionData.sample()),
    ], builder: _buildSubtree);
  }

  Widget _buildSubtree(BuildContext context, _child) {
    var questionState = context.watch<QuestionState>();
    var questionData = context.read<QuestionData>();
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(questionData.title),
        titleTextStyle: textTheme.displayLarge!.copyWith(
          color: colorScheme.primary,
          fontWeight: FontWeight.w900,
        ),
        toolbarHeight: kToolbarHeight * 2,
        elevation: 4,
        leading: IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: Icon(Icons.arrow_back),
          color: colorScheme.secondary,
          iconSize: QUESTION_DISPLAY_PADDING * 1.5,
          padding: EdgeInsets.all(QUESTION_DISPLAY_PADDING / 2),
        ),
        leadingWidth: QUESTION_DISPLAY_PADDING * 3,
        actions: [
          IconButton.filledTonal(
            onPressed: () {
              questionState.doRevealClue1();
            },
            icon: Icon(Icons.favorite_border),
            iconSize: QUESTION_DISPLAY_PADDING,
            padding: EdgeInsets.all(QUESTION_DISPLAY_PADDING / 2),
          ),
          SizedBox.square(dimension: QUESTION_DISPLAY_PADDING),
          IconButton.filledTonal(
            onPressed: () {
              questionState.doRevealClue2();
            },
            icon: Icon(Icons.favorite),
            iconSize: QUESTION_DISPLAY_PADDING,
            padding: EdgeInsets.all(QUESTION_DISPLAY_PADDING / 2),
          ),
          SizedBox.square(dimension: QUESTION_DISPLAY_PADDING / 2),
          ScoreBoardMiniWidget(
            padding: QUESTION_DISPLAY_PADDING,
          ),
          SizedBox.square(dimension: QUESTION_DISPLAY_PADDING / 2),
        ],
      ),
      body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(flex: 6, child: QuestionTitleWidget()),
            Expanded(flex: 17, child: ClueGridWidget()),
            Spacer(flex: 1),
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
    var questionData = context.read<QuestionData>();
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(QUESTION_DISPLAY_PADDING),
      child: AutoSizeText(questionData.description,
          maxLines: 3,
          minFontSize: textTheme.headlineLarge?.fontSize ?? 12,
          overflow: TextOverflow.ellipsis,
          style:
              textTheme.displayMedium!.copyWith(color: colorScheme.secondary)),
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
    var questionData = context.read<QuestionData>();
    if (index < 3) {
      return _ClueScoreDisplayWidget(columnIndex: index);
    } else {
      var clueIdx = index - 3;
      clueIdx = 5 * (clueIdx % 3) + (clueIdx ~/ 3);
      return Provider.value(
          value: questionData.clues[clueIdx],
          child: ClueDisplayWidget(index: clueIdx));
    }
  }
}

class _ClueScoreDisplayWidget extends StatelessWidget {
  const _ClueScoreDisplayWidget({super.key, required this.columnIndex});

  final int columnIndex;

  @override
  Widget build(BuildContext context) {
    var questionState = context.watch<QuestionState>();
    final score_text = switch (questionState.getDisplayState()) {
      QuestionDisplayState.EMPTY => "---",
      QuestionDisplayState.SHOW_CLUE1 => "${CLUE1_SCORES[columnIndex]} points",
      QuestionDisplayState.SHOW_CLUE2 => "${CLUE2_SCORES[columnIndex]} points",
    };

    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.all(12.0),
      decoration: ShapeDecoration(
        shape: StadiumBorder(),
        color: CLUE_COLORS[this.columnIndex].primary,
      ),
      alignment: Alignment.center,
      child: AutoSizeText(score_text,
          maxLines: 1,
          minFontSize: theme.textTheme.headlineMedium?.fontSize ?? 12,
          style: theme.textTheme.displayMedium?.copyWith(
              fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimary),
          overflow: TextOverflow.ellipsis),
    );
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
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(CLUE_DISPLAY_PADDING),
      child: LayoutBuilder(builder: (context, constraints) {
        final maxButtonSize = min(constraints.maxHeight, constraints.maxWidth);
        return Stack(
          alignment: Alignment.centerLeft,
          fit: StackFit.expand,
          children: [
            Positioned(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              child: ClueTextWidget(
                  index: widget.index, iconPadding: maxButtonSize),
            ),
            Positioned(
              left: 0,
              top: 0,
              child: ClueAnswerButtonWidget(
                  index: widget.index,
                  maxButtonSize: maxButtonSize,
                  maxSize: constraints.biggest),
            ),
          ],
        );
      }),
    );
  }
}

class ClueAnswerButtonWidget extends StatefulWidget {
  const ClueAnswerButtonWidget(
      {super.key,
      required this.index,
      required this.maxButtonSize,
      required this.maxSize});

  final int index;
  final double maxButtonSize;
  final Size maxSize;

  @override
  State<ClueAnswerButtonWidget> createState() => _ClueAnswerButtonWidgetState();
}

class _ClueAnswerButtonWidgetState extends State<ClueAnswerButtonWidget> {
  var answer_shown = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 200),
      transitionBuilder: AnimatedSwitcherTransitions.slideRight,
      layoutBuilder: AnimatedSwitcherLayouts.inOut,
      child: answer_shown
          ? _buildAnswerOverlay(context)
          : _buildAnswerButton(context),
    );
  }

  Widget _buildAnswerButton(BuildContext context) {
    final clueData = context.read<ClueData>();
    final theme = Theme.of(context);
    final colorScheme = CLUE_COLORS[this.widget.index ~/ 5];
    return FilledButton(
      onPressed: () => setState(() {
        answer_shown = true;
      }),
      child: AutoSizeText(clueData.idxPrompt,
          maxLines: 1,
          textScaleFactor: 1.6,
          minFontSize: theme.textTheme.headlineSmall?.fontSize ?? 12,
          style: theme.textTheme.headlineLarge
              ?.copyWith(color: colorScheme.onPrimaryContainer),
          overflow: TextOverflow.visible),
      style: FilledButton.styleFrom(
          textStyle: theme.textTheme.headlineLarge
              ?.copyWith(color: theme.colorScheme.onInverseSurface),
          fixedSize: Size.square(this.widget.maxButtonSize),
          backgroundColor: colorScheme.inversePrimary,
          elevation: 2,
          shape: const CircleBorder()),
    );
  }

  Widget _buildAnswerOverlay(BuildContext context) {
    final clueData = context.read<ClueData>();
    final theme = Theme.of(context);
    final colorScheme = CLUE_COLORS[this.widget.index ~/ 5];
    return Container(
      padding: const EdgeInsets.all(CLUE_DISPLAY_PADDING),
      width: this.widget.maxSize.width,
      height: this.widget.maxSize.height,
      alignment: Alignment.center,
      decoration: ShapeDecoration(
        shape: StadiumBorder(),
        color: colorScheme.primary,
        shadows: kElevationToShadow[4],
      ),
      child: AutoSizeText(clueData.answer,
          maxLines: 3,
          minFontSize: theme.textTheme.headlineMedium?.fontSize ?? 12,
          style: theme.textTheme.displayMedium
              ?.copyWith(color: colorScheme.onPrimary),
          overflow: TextOverflow.ellipsis),
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
    final clueData = context.read<ClueData>();
    var question_state = context.watch<QuestionState>();
    final clue_text = switch (question_state.getDisplayState()) {
      QuestionDisplayState.EMPTY => "",
      QuestionDisplayState.SHOW_CLUE1 => clueData.hint1,
      QuestionDisplayState.SHOW_CLUE2 => clueData.hint2,
    };

    final theme = Theme.of(context);
    final colorScheme = CLUE_COLORS[index ~/ 5];
    return ClipPath(
      clipper: ShapeBorderClipper(shape: StadiumBorder()),
      child: Container(
        padding: EdgeInsets.only(
            left: iconPadding + 2 * CLUE_DISPLAY_PADDING,
            right: CLUE_DISPLAY_PADDING),
        alignment: Alignment.centerLeft,
        color: colorScheme.primaryContainer,
        child: AnimatedSwitcher(
          duration: Duration(milliseconds: 800),
          transitionBuilder: AnimatedSwitcherTransitions.slideBottom,
          child: AutoSizeText(clue_text,
              maxLines: 3,
              key: ValueKey((index, question_state.getDisplayState())),
              minFontSize: theme.textTheme.headlineSmall?.fontSize ?? 12,
              style: theme.textTheme.headlineLarge
                  ?.copyWith(color: colorScheme.onPrimaryContainer),
              overflow: TextOverflow.ellipsis),
        ),
      ),
    );
  }
}
