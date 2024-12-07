import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../global_state.dart';
import 'scoreboard_full.dart';

class ScoreBoardMiniWidget extends StatelessWidget {
  const ScoreBoardMiniWidget.Scoreboard();

  @override
  Widget build(BuildContext context) {
    final scoreboardState = context.watch<GlobalScoreboard>();
    return GestureDetector(
      onTap: () => showDialog<String>(
        context: context,
        builder: (context) => _scorecardDialogBuilder(context, scoreboardState),
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
          children: List.generate((ScoreboardLength * 2 - 1), (int index) {
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
    final scoreboardState = context.watch<GlobalScoreboard>();
    final theme = Theme.of(context);
    return Container(
      decoration: ShapeDecoration(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20))),
        color: ScoreboardConfig[idx].$1.primary,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Container(
            decoration: ShapeDecoration(
                shape: const CircleBorder(),
                color: ScoreboardConfig[idx].$1.onPrimary),
            padding: const EdgeInsets.all(10),
            alignment: Alignment.center,
            constraints: BoxConstraints(minWidth: 60, minHeight: 60),
            child: Text(scoreboardState.getScore(idx).toString(),
                style: theme.textTheme.headlineSmall!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: ScoreboardConfig[idx].$1.primary)),
          ),
          Spacer(flex: 1),
          Expanded(
            flex: 30,
            child: Text(ScoreboardConfig[idx].$2,
                style: theme.textTheme.headlineMedium!
                    .copyWith(color: ScoreboardConfig[idx].$1.onPrimary)),
          ),
        ],
      ),
    );
  }

  AlertDialog _scorecardDialogBuilder(BuildContext context, GlobalScoreboard scoreboardState) {
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
