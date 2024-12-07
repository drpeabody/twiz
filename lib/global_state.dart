import 'package:flutter/material.dart';

const ScoreboardLength = 5;

final List<(ColorScheme, String)> ScoreboardConfig = () {
  final list = [
    (Colors.red, "This is a long team name 1"),
    (Colors.purple, "This is a long team name 2"),
    (Colors.blue, "This is a long team name 3"),
    (Colors.green, "This is a long team name 4"),
    (Colors.yellow, "This is a long team name 5"),
  ].map(_deriveConfig).toList(growable: false);
  assert(list.length == ScoreboardLength);
  return list;
}();

(ColorScheme, String) _deriveConfig((Color, String) elem) {
  return (
    ColorScheme.fromSeed(
        seedColor: elem.$1, dynamicSchemeVariant: DynamicSchemeVariant.vibrant),
    elem.$2
  );
}

class GlobalScoreboard extends ChangeNotifier {
  var _scores = List.filled(ScoreboardConfig.length, /* value = */ 0);

  void updateScore(int index, int newScore) {
    this._scores[index] = newScore;
    notifyListeners();
  }

    int getScore(int index) {
    return this._scores[index];
  }
}
