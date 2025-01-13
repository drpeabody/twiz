import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

    const _TeamIndexCounter({
        super.key,
        this.currentIndex = 1,
    });

    // Index of the Team in the Global Score Board which gets modified
    final int currentIndex;

    @override
    __TeamIndexCounterState createState() => __TeamIndexCounterState();
}


class __TeamIndexCounterState extends State<_TeamIndexCounter> {

    late String currentName;
    late int _index;
    // late Color currentColor;

    @override
    void initState() {
        super.initState();
        _index = widget.currentIndex;
    }


    @override
    Widget build(BuildContext context) {

        final displayCharacterstics = context.read<DisplayCharacterstics>();
        // final buttonCounter = CounterScreen();

        return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
                // buttonCounter,
                // TextField(
                //     decoration: InputDecoration(
                //         border: OutlineInputBorder(),
                //         hintText: 'Enter a search term',
                //     ),
                // ),
                AnimatedOpacity(
                    opacity: _index != 0 ? 1.0 : 0.0,
                    duration: Duration(milliseconds: 500),
                    child: Text(
                        '$_index',
                        style: TextStyle(
                            fontSize: 48.0,
                            color: Colors.white,
                        ),
                    ),
                ),
                IconButton.filledTonal(
                    onPressed: () {
                        setState(() {
                        _index++;
                        });
                    },
                    icon: Icon(Icons.settings),
                    iconSize: displayCharacterstics.iconSize,
                    padding: displayCharacterstics.fullPadding / 2,
                ),
                IconButton.filledTonal(
                    onPressed: () {
                        setState(() {
                        _index--;
                        });
                    },
                    icon: Icon(Icons.settings),
                    iconSize: displayCharacterstics.iconSize,
                    padding: displayCharacterstics.fullPadding / 2,
                ),
            ],
        );
    }
}


// Copied code


// class CounterScreen extends StatefulWidget {
//   @override
//   _CounterScreenState createState() => _CounterScreenState();
// }

// class _CounterScreenState extends State<CounterScreen> {
//   int _counter = 0;

//   void _incrementCounter() {
//     setState(() {
//       _counter++;
//     });
//   }

//   void _decrementCounter() {
//     setState(() {
//       _counter--;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.purple,
//       appBar: AppBar(
//         title: Text('Aesthetic Counter'),
//         backgroundColor: Colors.blue,
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             SizedBox(height: 20.0),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 FloatingActionButton(
//                   onPressed: _decrementCounter,
//                   backgroundColor: Colors.blue,
//                   child: Icon(Icons.remove),
//                 ),
//                 SizedBox(width: 20.0),
//                 FloatingActionButton(
//                   onPressed: _incrementCounter,
//                   backgroundColor: Colors.purple,
//                   child: Icon(Icons.add),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }