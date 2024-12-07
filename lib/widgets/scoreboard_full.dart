import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../global_state.dart';

/// Widget that displays the full scoreboard
class ScoreBoardFullWidget extends StatelessWidget {
  const ScoreBoardFullWidget({Key? super.key});

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
              _buildScoreCounter(context, 0),
              _buildScoreCounter(context, 1),
              _buildScoreCounter(context, 2),
            ],
          ),
          Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildScoreCounter(context, 3),
              _buildScoreCounter(context, 4),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCounter(BuildContext context, int idx) {
    final scoreboardState = context.watch<GlobalScoreboard>();
    final config = ScoreboardConfig[idx];
    return _ScoreCounter(
        name: config.$2,
        stepValue: 5,
        colorScheme: config.$1,
        onChanged: (value) => scoreboardState.updateScore(idx, value));
  }
}

class _ScoreCounter extends StatefulWidget {
  const _ScoreCounter({
    super.key,
    required this.name,
    this.initialValue = 0,
    this.stepValue = 1,
    this.onChanged,
    this.direction = Axis.horizontal,
    this.colorScheme,
    this.textTheme,
  });

  final String name;

  /// the orientation of the counter its horizontal or vertical
  final Axis direction;

  /// the initial value of the counter
  final int initialValue;

  /// the counter changes values in these steps
  final int stepValue;

  /// called whenever the value of the counter changed
  final ValueChanged<int>? onChanged;

  final ColorScheme? colorScheme;
  final TextTheme? textTheme;

  @override
  _ScoreCounterState createState() => _ScoreCounterState();
}

class _ScoreCounterSizes {
  const _ScoreCounterSizes({this.scale = 1.5, required this.direction});

  final double scale;
  final Axis direction;

  double get height =>
      direction == Axis.horizontal ? scale * 100.0 : scale * 250.0;
  double get width =>
      direction == Axis.horizontal ? scale * 250.0 : scale * 100.0;
  Size get size => Size(width, height);

  double get tweenEndOffset => scale * 2.5;

  double get iconSize => scale * 30;
  EdgeInsets get iconPadding => EdgeInsets.all(scale * 15);

  EdgeInsets get containerPadding => EdgeInsets.all(scale * 30.0);

  EdgeInsets get controllerMargin => direction == Axis.horizontal
      ? EdgeInsets.symmetric(vertical: scale * 20.0)
      : EdgeInsets.symmetric(horizontal: scale * 20.0);
}

class _ScoreCounterState extends State<_ScoreCounter>
    with SingleTickerProviderStateMixin {
  late int _value;
  bool _increased = false;

  late Tween<Offset> _inOffsetTween;
  late Tween<Offset> _outOffsetTween;

  late final _ScoreCounterSizes _sizes;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
    _sizes = _ScoreCounterSizes(direction: widget.direction);

    if (widget.direction == Axis.horizontal) {
      _inOffsetTween =
          Tween(begin: Offset(0.0, -_sizes.tweenEndOffset), end: Offset.zero);
      _outOffsetTween =
          Tween(begin: Offset(0.0, _sizes.tweenEndOffset), end: Offset.zero);
    } else {
      _inOffsetTween =
          Tween(begin: Offset(_sizes.tweenEndOffset, 0.0), end: Offset.zero);
      _outOffsetTween =
          Tween(begin: Offset(-_sizes.tweenEndOffset, 0.0), end: Offset.zero);
    }
  }

  @override
  Widget build(BuildContext context) {
    var textTheme = widget.textTheme ?? Theme.of(context).textTheme;
    var colorScheme = widget.colorScheme ?? Theme.of(context).colorScheme;
    return Container(
      decoration: ShapeDecoration(
        shape: ContinuousRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(100))),
        color: colorScheme.primary,
      ),
      padding: _sizes.containerPadding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints.tight(_sizes.size),
            child: Text(
              widget.name,
              textAlign: TextAlign.center,
              style: textTheme.headlineLarge!.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: textTheme.headlineLarge!.fontSize! * _sizes.scale),
            ),
          ),
          Container(
            width: _sizes.width,
            height: _sizes.height,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: ShapeDecoration(
                    shape: StadiumBorder(),
                    color: colorScheme.tertiaryContainer,
                  ),
                  margin: _sizes.controllerMargin,
                  child: Flex(
                    direction: widget.direction,
                    verticalDirection: VerticalDirection.up,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove),
                        iconSize: _sizes.iconSize,
                        color: colorScheme.onPrimaryContainer,
                        padding: _sizes.iconPadding,
                        onPressed: () {
                          setState(() {
                            this._value -= widget.stepValue;
                            this._increased = false;
                            this.widget.onChanged?.call(this._value);
                          });
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.add),
                        iconSize: _sizes.iconSize,
                        color: colorScheme.onPrimaryContainer,
                        padding: _sizes.iconPadding,
                        onPressed: () {
                          setState(() {
                            this._value += widget.stepValue;
                            this._increased = true;
                            this.widget.onChanged?.call(this._value);
                          });
                        },
                      ),
                    ],
                  ),
                ),
                Material(
                  clipBehavior: Clip.antiAlias,
                  color: colorScheme.primaryContainer,
                  shape: const CircleBorder(),
                  elevation: 10.0,
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 150),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                        if (_increased == (child.key == ValueKey(_value))) {
                          return SlideTransition(
                              key: child.key,
                              position: _inOffsetTween.animate(animation),
                              child: child);
                        } else {
                          return SlideTransition(
                              key: child.key,
                              position: _outOffsetTween.animate(animation),
                              child: child);
                        }
                      },
                      child: Text(
                        '$_value',
                        key: ValueKey(_value),
                        style: textTheme.headlineLarge!.copyWith(
                            color: colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                            fontSize: textTheme.headlineLarge!.fontSize! *
                                _sizes.scale),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
