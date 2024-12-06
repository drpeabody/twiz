import 'package:flutter/material.dart';

import 'score_counter.dart';

final List<(ColorScheme, String)> _scoreboardConfig = [
  (Colors.red, "This is a long team name 1"),
  (Colors.purple, "This is a long team name 2"),
  (Colors.blue, "This is a long team name 3"),
  (Colors.green, "This is a long team name 4"),
  (Colors.yellow, "This is a long team name 5"),
].map(_deriveConfig).toList(growable: false);

(ColorScheme, String) _deriveConfig((Color, String) elem) {
  return (
    ColorScheme.fromSeed(
        seedColor: elem.$1, dynamicSchemeVariant: DynamicSchemeVariant.vibrant),
    elem.$2
  );
}

class ScoreBoard extends StatefulWidget {
  const ScoreBoard.Scoreboard();

  @override
  State<ScoreBoard> createState() => _ScoreboardState();
}

class _ScoreboardState extends State<ScoreBoard> {
  var _scores = List.filled(/* length = */ 5, /* value = */ 0);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showDialog<String>(
        context: context,
        builder: _scorecardDialogBuilder,
      ),
      child: Container(
        decoration: ShapeDecoration(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20))),
          // color: Theme.of(context).colorScheme.primaryContainer,
        ),
        padding: EdgeInsets.all(20),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: List.generate(9, (int index) {
            if (index % 2 != 0) {
              return Spacer(flex: 1);
            } else {
              return Expanded(
                  flex: 10, child: _buildScoreTile(context, index ~/ 2));
            }
          }),
        ),
      ),
    );
  }

  Widget _buildScoreTile(BuildContext context, int idx) {
    final theme = Theme.of(context);
    return Container(
      decoration: ShapeDecoration(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20))),
        color: _scoreboardConfig[idx].$1.primary,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Container(
            decoration: ShapeDecoration(shape: const CircleBorder(), color: _scoreboardConfig[idx].$1.onPrimary),
            padding: const EdgeInsets.all(10),
            alignment: Alignment.center,
            constraints: BoxConstraints(minWidth: 60, minHeight: 60),
            child: Text(this._scores[idx].toString(),
                style: theme.textTheme.headlineSmall!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _scoreboardConfig[idx].$1.primary)),
          ),
          Spacer(flex: 1),
          Expanded(
            flex: 30,
            child: Text(_scoreboardConfig[idx].$2,
                style: theme.textTheme.headlineMedium!
                    .copyWith(color: _scoreboardConfig[idx].$1.onPrimary)),
          ),
        ],
      ),
    );
  }

  AlertDialog _scorecardDialogBuilder(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          'Scorecard',
          style: theme.textTheme.displayLarge!.copyWith(
              color: theme.colorScheme.primary,
              fontSize: theme.textTheme.displayLarge!.fontSize! * 2),
          textAlign: TextAlign.center,
        ),
      ),
      content: _ScoreBoardFull(
          onValueChanged: (index, newValue) => setState(() {
                this._scores[index] = newValue;
              })),
    );
  }
}

class _ScoreBoardFull extends StatelessWidget {
  const _ScoreBoardFull({required this.onValueChanged});

  final onValueChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1800,
      height: 900,
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildScoreCounter(0),
              _buildScoreCounter(1),
              _buildScoreCounter(2),
            ],
          ),
          Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildScoreCounter(3),
              _buildScoreCounter(4),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCounter(int idx) {
    final config = _scoreboardConfig[idx];
    return ScoreCounter(
        name: config.$2,
        stepValue: 5,
        colorScheme: config.$1,
        onChanged: (value) => this.onValueChanged(idx, value));
  }
}
