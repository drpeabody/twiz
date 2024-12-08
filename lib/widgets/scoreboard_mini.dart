import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../display.dart';
import '../global_state.dart';
import 'scoreboard_full.dart';

class ScoreBoardMiniWidget extends StatelessWidget {
  const ScoreBoardMiniWidget();

  @override
  Widget build(BuildContext context) {
    final scoreboardState = context.watch<GlobalScoreboard>();
    var displayCharacterstics = context.read<DisplayCharacterstics>();
    final padding = displayCharacterstics.paddingRaw;

    return Padding(
      padding: displayCharacterstics.fullPadding / 2,
      child: TextButton(
        onPressed: () => showDialog<String>(
          context: context,
          builder: (context) => _fullScoreboardDialogBuilder(
              context, scoreboardState, displayCharacterstics),
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

  AlertDialog _fullScoreboardDialogBuilder(
      BuildContext context,
      GlobalScoreboard scoreboardState,
      DisplayCharacterstics displayCharacterstics) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Padding(
        padding: displayCharacterstics.fullPadding / 2,
        child: Text(
          'Scoreboard',
          style: theme.textTheme.displayLarge!.copyWith(
              color: theme.colorScheme.primary, fontWeight: FontWeight.w600),
          textScaler: displayCharacterstics.textScaler,
          textAlign: TextAlign.center,
        ),
      ),
      content: MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: scoreboardState),
          Provider.value(value: displayCharacterstics),
        ],
        child: ScoreBoardFullWidget(),
      ),
    );
  }
}
