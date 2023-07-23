import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
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
        ));
  }
}

class WinnerPopup extends StatelessWidget {
  final String winner;

  const WinnerPopup({required this.winner});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Center(
        child: Text("Winner!"),
      ),
      content: Text('$winner is the winner!'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Align(
            alignment: Alignment.center,
            child: (Text("Next Game")),
          ),
        ),
      ],
    );
  }
}

class ScoreState extends ChangeNotifier {
  var scoreLeft = 0;
  var scoreRight = 0;
  var winner = '';
  final scoreDifference = 2;

  void calculateScore(BuildContext context) {
    if (scoreLeft == 11 && scoreRight < 10) {
      winner = 'Left';
      _showWinnerPopup(context, winner);
    } else if (scoreRight == 11 && scoreLeft < 10) {
      winner = 'Right';
      _showWinnerPopup(context, winner);
    } else if (scoreLeft >= 10 && scoreRight >= 10) {
      if ((scoreLeft - scoreRight).abs() >= scoreDifference) {
        winner = scoreLeft > scoreRight ? 'Left' : 'Right';
        _showWinnerPopup(context, winner);
      } else {
        winner = '';
      }
    }
    notifyListeners();
  }

  void _showWinnerPopup(BuildContext context, String winner) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return WinnerPopup(winner: winner);
      },
    );
    resetScore();
  }

  void resetScore() {
    scoreLeft = 0;
    scoreRight = 0;
  }

  void switchScores() {
    var temp = scoreLeft;
    scoreLeft = scoreRight;
    scoreRight = temp;
  }

  void incrementScoreLeft() {
    scoreLeft++;
  }

  void incrementScoreRight() {
    scoreRight++;
  }

  void reduceScoreLeft() {
    scoreLeft--;
  }

  void reduceScoreRight() {
    scoreRight--;
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    var scoreState = context.watch<ScoreState>();
    const style = TextStyle(
        color: Colors.white, fontWeight: FontWeight.normal, fontSize: 96);

    return Scaffold(
      body: Stack(
        children: [
          // Row containing the GestureDetector widgets
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
          // Pill-shaped container floating above the Row
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 100,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              color: Colors.grey[900],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('${scoreState.scoreLeft}',
                            style: TextStyle(color: Colors.black)),
                        SizedBox(width: 10,),
                        IconButton(onPressed: () {
                          scoreState.switchScores();
                          scoreState.calculateScore(context);
                        }, 
                        icon: Icon(Icons.swap_horiz, color: Colors.black),
                        ),
                        SizedBox(width: 10,),
                        Text('${scoreState.scoreRight}',
                            style: TextStyle(color: Colors.black)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          scoreState.resetScore();
          scoreState.calculateScore(context);
        },
        child: const Icon(Icons.autorenew),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
