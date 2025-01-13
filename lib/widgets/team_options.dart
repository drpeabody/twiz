import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../display.dart';
import '../global_state.dart';

/// Widget that displays the full scoreboard
class TeamOptionsPopopWidget extends StatelessWidget {
  const TeamOptionsPopopWidget({Key? super.key});

  @override
  Widget build(BuildContext context) {
    final scoreboardState = context.watch<GlobalScoreboard>();
    final displayCharacterstics = context.read<DisplayCharacterstics>();
    return Container(
      width: 1400 * displayCharacterstics.textScale,
      height: 800 * displayCharacterstics.textScale,
      padding: displayCharacterstics.fullPadding * 2,
      child: Wrap(
        direction: Axis.horizontal,
        alignment: WrapAlignment.center,
        runAlignment: WrapAlignment.center,
        spacing: displayCharacterstics.paddingRaw * 2,
        runSpacing: displayCharacterstics.paddingRaw * 2,
        children: [ _TeamIndexCounter() ],
      ),
    );
  }

//   Widget _buildScoreCounter(BuildContext context, int idx) {
//     final scoreboardState = context.watch<GlobalScoreboard>();
//     return _TeamIndexCounter(
//         name: scoreboardState.getTeamName(idx),
//         stepValue: 5,
//         initialValue: scoreboardState.getScore(idx),
//         colorScheme: scoreboardState.getColorScheme(idx),
//         onChanged: (value) => scoreboardState.updateScore(idx, value));
//   }
}

mixin TeamOptionsPopopWidgetProvider on StatelessWidget {
    Widget provideUsing(
        BuildContext context,
        GlobalScoreboard scoreboardState,
        DisplayCharacterstics displayCharacterstics) {
            final theme = Theme.of(context);
            // final size = MediaQuery.sizeOf(context);

            final teamOptionsWidget = MultiProvider(
                providers: [
                    ChangeNotifierProvider.value(value: scoreboardState),
                    Provider.value(value: displayCharacterstics),
                ],
                child: TeamOptionsPopopWidget(),
            );

            return teamOptionsWidget;
    }
}



class _TeamIndexCounter extends StatefulWidget {

    const _TeamIndexCounter({ super.key });

    @override
    __TeamIndexCounterState createState() => __TeamIndexCounterState();
}


class __TeamIndexCounterState extends State<_TeamIndexCounter> {

    late String currentName;
    // Index of the Team in the Global Score Board which gets modified
    late int _index;
    late String _currentTeamName;

    Color pickerColor = Color(0xff443a49);
    Color currentColor = Color(0xff443a49);

    // ValueChanged<Color> callback
    void changeColor(Color color) {
        setState(() => pickerColor = color);
    }

    @override
    void initState() {
        super.initState();
        _index = 1;
        _currentTeamName = "";
    }


    @override
    Widget build(BuildContext context) {

        final displayCharacterstics = context.read<DisplayCharacterstics>();
        final scoreboardState = context.watch<GlobalScoreboard>();
        final textTheme = Theme.of(context).textTheme;

        return Container(
            color: Color(0xdddddd33),
            child: SizedBox(
                width: 1000.0,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                        Text("Press the Button to apply",
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.displayMedium
                                ?.apply(color: Colors.black, fontWeightDelta: 3),
                            textScaler: displayCharacterstics.textScaler,
                            textAlign: TextAlign.center),
                        ElevatedButton(
                            child: Text("this color"),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: pickerColor
                            ),
                            onPressed: () => showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                    return AlertDialog(
                                        title: const Text('Pick a color!'),
                                        content: SingleChildScrollView(
                                        child: ColorPicker(
                                            pickerColor: pickerColor,
                                            onColorChanged: changeColor,
                                        ),
                                        // Use Material color picker:
                                        //
                                        // child: MaterialPicker(
                                        //   pickerColor: pickerColor,
                                        //   onColorChanged: changeColor,
                                        //   showLabel: true, // only on portrait mode
                                        // ),
                                        //
                                        // Use Block color picker:
                                        //
                                        // child: BlockPicker(
                                        //   pickerColor: currentColor,
                                        //   onColorChanged: changeColor,
                                        // ),
                                        //
                                        // child: MultipleChoiceBlockPicker(
                                        //   pickerColors: currentColors,
                                        //   onColorsChanged: changeColors,
                                        // ),
                                        ),
                                        actions: <Widget>[
                                            ElevatedButton(
                                                child: const Text('Got it'),
                                                onPressed: () {
                                                    setState(() => currentColor = pickerColor);
                                                    Navigator.of(context).pop();
                                                },
                                            ),
                                        ],
                                    );
                                }
                            )
                        ),
                        Text("and the Team Name",
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.displayMedium
                                ?.apply(color: Colors.black, fontWeightDelta: 3),
                            textScaler: displayCharacterstics.textScaler,
                            textAlign: TextAlign.center),
                        Material( child: SizedBox(
                            width: 500.0,
                            child: TextFormField(
                                style: TextStyle(fontSize: 40.0, height: 2.0, color: Colors.black),
                                decoration: const InputDecoration(hintText: 'Name'),
                                // validator: (value) {
                                //     if (value == '') {
                                //         return '*Required';
                                //     }
                                //     print(value?.toString());
                                //     for(int i = 0 ; i < ScoreboardLength; i++) {
                                //         print(scoreboardState.getTeamName(i));
                                //         if(scoreboardState.getTeamName(i) == value) {
                                //             return 'Name is already taken!';
                                //         }
                                //     }
                                //     return null;
                                // },
                                onChanged: (value) {
                                    setState(() {
                                        if (value != '') {
                                            _currentTeamName = value;
                                        }
                                    });
                                }
                            )
                        )),
                        Text("for the team at position ",
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.displayMedium
                                ?.apply(color: Colors.black, fontWeightDelta: 3),
                            textScaler: displayCharacterstics.textScaler,
                            textAlign: TextAlign.center),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                                const Spacer(flex: 10),
                                IconButton.filledTonal(
                                    onPressed: () {
                                        setState(() {
                                            if(_index > 0) {
                                                _index--;
                                            }
                                        });
                                    },
                                    icon: Icon(Icons.flourescent),
                                    iconSize: displayCharacterstics.iconSize,
                                    padding: displayCharacterstics.fullPadding / 2,
                                ),
                                const Spacer(flex: 1),
                                AnimatedOpacity(
                                    opacity: (ScoreboardLength + _index) / (2.0 * ScoreboardLength),
                                    duration: Duration(milliseconds: 500),
                                    child: Text(
                                        '${_index+1}',
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        style: textTheme.displayMedium
                                            ?.apply(color: Colors.black, fontWeightDelta: 3),
                                        textScaler: displayCharacterstics.textScaler,
                                        textAlign: TextAlign.center,
                                    ),
                                ),
                                const Spacer(flex: 1),
                                IconButton.filledTonal(
                                    onPressed: () {
                                        setState(() {
                                            if(_index < ScoreboardLength - 1) {
                                                _index++;
                                            }
                                        });
                                    },
                                    icon: Icon(Icons.add),
                                    iconSize: displayCharacterstics.iconSize,
                                    padding: displayCharacterstics.fullPadding / 2,
                                ),
                                const Spacer(flex: 10),
                            ]
                        ),
                        IconButton.filledTonal(
                            onPressed: () {
                                if(_index < ScoreboardLength && _index > -1) {
                                    scoreboardState.updateColor(currentColor, _index);
                                    scoreboardState.updateName(_currentTeamName, _index);
                                }
                            },
                            icon: Icon(Icons.keyboard_return),
                            iconSize: displayCharacterstics.iconSize,
                            padding: displayCharacterstics.fullPadding / 2,
                        ),
                    ],
                )
            )
        );
    }
}

