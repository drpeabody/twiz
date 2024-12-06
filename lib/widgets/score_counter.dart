import 'package:flutter/material.dart';

class ScoreCounter extends StatefulWidget {
  const ScoreCounter({
    super.key,
    this.initialValue = 0,
    this.stepValue = 1,
    this.onChanged,
    this.direction = Axis.horizontal,
    this.colorScheme,
    this.textTheme,
  });

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

class _ScoreCounterState extends State<ScoreCounter>
    with SingleTickerProviderStateMixin {
  late int _value;
  bool _increased = false;

  late Tween<Offset> _inOffsetTween;
  late Tween<Offset> _outOffsetTween;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;

    if (widget.direction == Axis.horizontal) {
      _inOffsetTween = Tween(begin: Offset(0.0, -2.0), end: Offset.zero);
      _outOffsetTween = Tween(begin: Offset(0.0, 2.0), end: Offset.zero);
    } else {
      _inOffsetTween = Tween(begin: Offset(2.0, 0.0), end: Offset.zero);
      _outOffsetTween = Tween(begin: Offset(-2.0, 0.0), end: Offset.zero);
    }
  }

  @override
  Widget build(BuildContext context) {
    var textTheme = widget.textTheme ?? Theme.of(context).textTheme;
    var colorScheme = widget.colorScheme ?? Theme.of(context).colorScheme;
    return FittedBox(
      child: Container(
        width: widget.direction == Axis.horizontal ? 210.0 : 85.0,
        height: widget.direction == Axis.horizontal ? 85.0 : 210.0,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              clipBehavior: Clip.antiAlias,
              decoration: ShapeDecoration(
                shape: StadiumBorder(),
                color: colorScheme.primaryContainer,
              ),
              margin: widget.direction == Axis.horizontal
                  ? EdgeInsets.symmetric(vertical: 10.0)
                  : EdgeInsets.symmetric(horizontal: 10.0),
              child: Flex(
                direction: widget.direction,
                verticalDirection: VerticalDirection.up,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  IconButton(
                    icon: Icon(Icons.remove),
                    iconSize: 40.0,
                    color: colorScheme.onPrimaryContainer,
                    padding: EdgeInsets.all(10.0),
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
                    iconSize: 40.0,
                    color: colorScheme.onPrimaryContainer,
                    padding: EdgeInsets.all(10.0),
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
              color: colorScheme.primary,
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
                    style: textTheme.headlineMedium!
                        .copyWith(color: colorScheme.onPrimary),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
