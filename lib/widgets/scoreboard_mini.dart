import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../global_state.dart';
import 'scoreboard_full.dart';

class ScoreBoardMiniWidget extends StatelessWidget {
  const ScoreBoardMiniWidget({required this.padding});

  final double padding;

  @override
  Widget build(BuildContext context) {
    final scoreboardState = context.watch<GlobalScoreboard>();
    return Padding(
      padding: EdgeInsets.symmetric(vertical: this.padding / 2),
      child: TextButton(
        onPressed: () => showDialog<String>(
          context: context,
          builder: (context) =>
              _scorecardDialogBuilder(context, scoreboardState),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: List.generate((ScoreboardLength * 2 + 1), (int index) {
            if (index % 2 == 0) {
              return SizedBox.square(dimension: padding / 4);
            } else {
              return _buildScoreTile(context, index ~/ 2);
            }
          }),
        ),
      ),
    );
  }

  Widget _buildScoreTile(BuildContext context, int idx) {
    final scoreboardState = context.watch<GlobalScoreboard>();
    final theme = Theme.of(context);
    final scoreboardTeamColorScheme = scoreboardState.getColorScheme(idx);
    return Container(
      decoration: ShapeDecoration(
        shape: const CircleBorder(),
        color: scoreboardTeamColorScheme.primary,
      ),
      padding: const EdgeInsets.all(10),
      alignment: Alignment.center,
      constraints: BoxConstraints(minWidth: 60, minHeight: 60),
      child: Text(
        scoreboardState.getScore(idx).toString(),
        style: theme.textTheme.headlineSmall!.copyWith(
            fontWeight: FontWeight.bold,
            color: scoreboardTeamColorScheme.onPrimary),
      ),
    );
  }

  AlertDialog _scorecardDialogBuilder(
      BuildContext context, GlobalScoreboard scoreboardState) {
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
      content: ChangeNotifierProvider.value(
        value: scoreboardState,
        child: ScoreBoardFullWidget(),
      ),
    );
  }
}
