import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ScoreState(),
      child: MaterialApp(
        title: 'KickerCounter',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.grey),
          useMaterial3: true,
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

class Winner {
  static const none = Winner._('None');
  static const left = Winner._('Left');
  static const right = Winner._('Right');

  final String _value;

  const Winner._(this._value);

  @override
  String toString() => _value;
}

class WinnerPopup extends StatelessWidget {
  final String winner;
  final int scoreLeft;
  final int scoreRight;

  WinnerPopup(
      {required this.winner,
      required this.scoreLeft,
      required this.scoreRight});

  @override
  Widget build(BuildContext context) {
    var scoreState = context.watch<ScoreState>();
    return AlertDialog(
      title: const Center(
        child: Text("Winner!"),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$winner is the winner!'),
          SizedBox(height: 20),
          Text(
            '$scoreLeft - $scoreRight',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            scoreState.resetScore();
            scoreState.calculateScore(context);
          },
          child: const Align(
            alignment: Alignment.center,
            child: Text("Next Game"),
          ),
        ),
      ],
    );
  }
}

class ScoreState extends ChangeNotifier {
  int scoreLeft = 0;
  int scoreRight = 0;
  int totalScoreLeft = 0;
  int totalScoreRight = 0;
  final scoreDifference = 2;

  void calculateScore(BuildContext context) {
    if (scoreLeft >= 10 && scoreRight >= 10) {
      if ((scoreLeft - scoreRight).abs() >= scoreDifference) {
        final winner = scoreLeft > scoreRight ? Winner.left : Winner.right;
        _showWinnerPopup(context, winner);
        _updateTotalScores(winner);
      }
    } else if (scoreLeft == 11 && scoreRight < 10) {
      _showWinnerPopup(context, Winner.left);
      _updateTotalScores(Winner.left);
    } else if (scoreRight == 11 && scoreLeft < 10) {
      _showWinnerPopup(context, Winner.right);
      _updateTotalScores(Winner.right);
    }
    notifyListeners();
  }

  void _showWinnerPopup(BuildContext context, Winner winner) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return WinnerPopup(
          winner: winner.toString(),
          scoreLeft: scoreLeft,
          scoreRight: scoreRight,
        );
      },
    );
  }

  void _updateTotalScores(Winner winner) {
    if (winner == Winner.left) {
      totalScoreLeft++;
    } else if (winner == Winner.right) {
      totalScoreRight++;
    }
  }

  void switchScores() {
    final temp = totalScoreRight;
    totalScoreRight = totalScoreLeft;
    totalScoreLeft = temp;

    final scoreTemp = scoreRight;
    scoreRight = scoreLeft;
    scoreLeft = scoreTemp;
  }

  void resetScore() {
    scoreLeft = 0;
    scoreRight = 0;
  }

  void hardResetScore() {
    totalScoreLeft = 0;
    totalScoreRight = 0;
    resetScore();
  }

  void incrementScoreLeft() {
    scoreLeft++;
  }

  void incrementScoreRight() {
    scoreRight++;
  }

  void reduceScoreLeft() {
    if (scoreLeft > 0) {
      scoreLeft--;
    }
  }

  void reduceScoreRight() {
    if (scoreRight > 0) {
      scoreRight--;
    }
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.normal,
      fontSize: 96,
    );
    const gameStyle = TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.w300,
      fontSize: 24,
    );

    final scoreState = context.watch<ScoreState>();
    final totalScoreLeft = scoreState.totalScoreLeft;
    final totalScoreRight = scoreState.totalScoreRight;

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          scoreState.incrementScoreLeft();
                          scoreState.calculateScore(context);
                        },
                        onLongPress: () {
                          scoreState.reduceScoreLeft();
                          scoreState.calculateScore(context);
                        },
                        child: Container(
                          color: Colors.red,
                          child: Center(
                            child: Text(
                              scoreState.scoreLeft.toString(),
                              style: style,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          scoreState.incrementScoreRight();
                          scoreState.calculateScore(context);
                        },
                        onLongPress: () {
                          scoreState.reduceScoreRight();
                          scoreState.calculateScore(context);
                        },
                        child: Container(
                          color: Colors.blue,
                          child: Center(
                            child: Text(
                              scoreState.scoreRight.toString(),
                              style: style,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SafeArea(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      height: 100,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '$totalScoreLeft',
                                  style: gameStyle,
                                ),
                                SizedBox(width: 10),
                                IconButton(
                                  onPressed: () {
                                    scoreState.hardResetScore();
                                    scoreState.calculateScore(context);
                                  },
                                  icon: Icon(
                                    Icons.stop,
                                    color: Colors.grey,
                                  ),
                                  iconSize: 20,
                                ),
                                IconButton(
                                  onPressed: () {
                                    scoreState.switchScores();
                                    scoreState.calculateScore(context);
                                  },
                                  icon: Icon(Icons.swap_horiz,
                                      color: Colors.grey),
                                  iconSize: 20,
                                ),
                                IconButton(
                                  onPressed: () {
                                    scoreState.resetScore();
                                    scoreState.calculateScore(context);
                                  },
                                  icon:
                                      Icon(Icons.autorenew, color: Colors.grey),
                                  iconSize: 20,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  '$totalScoreRight',
                                  style: gameStyle,
                                ),
                              ],
                            ),
                          ),
                        ],
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
