import 'package:flutter/material.dart';

const ScoreboardLength = 5;

const CLUE1_SCORES = [20, 30, 40];
const CLUE2_SCORES = [10, 15, 20];
final CLUE_COLORS = [
  Color(0xFF4C9BBA),
  Color(0xFF007256),
  Color(0xFFA70043),
].map(_deriveColorScheme).toList(growable: false);

ColorScheme _deriveColorScheme(Color color) {
  return ColorScheme.fromSeed(
      seedColor: color, dynamicSchemeVariant: DynamicSchemeVariant.vibrant);
}

class GlobalScoreboard extends ChangeNotifier {
  final _colors = List.generate(
      ScoreboardLength, (idx) => _deriveColorScheme(_defaultColors[idx]));
  final _names = List.generate(
      ScoreboardLength, (idx) => "This is a long team name ${idx + 1}");
  var _scores = List.filled(ScoreboardLength, /* value = */ 0);

  static const List<Color> _defaultColors = [
    Colors.red,
    Colors.purple,
    Colors.blue,
    Colors.green,
    // Colors.yellow,
    Color(0xFFF0B03F),
  ];

  void updateScore(int index, int newScore) {
    this._scores[index] = newScore;
    notifyListeners();
  }

  int getScore(int index) {
    return this._scores[index];
  }

  ColorScheme getColorScheme(int index) {
    return this._colors[index];
  }

  String getTeamName(int index) {
    return this._names[index];
  }
}
