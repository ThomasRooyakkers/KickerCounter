import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
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
          title: 'UWU',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
            useMaterial3: true,
          ),
          home: const MyHomePage(),
        ));
  }
}

class ScoreState extends ChangeNotifier {
  var scoreLeft = 0;
  var scoreRight = 0;
  final scoreDifference = 2;

  void calculateScore() {
    if (scoreLeft >= 10 && scoreRight >= 10) {
      if ((scoreLeft - scoreRight).abs() >= scoreDifference) {
        print('youre de winnare');
      }
    }
    notifyListeners();
  }

  void incrementscoreLeft() {
    scoreLeft++;
  }

  void incrementScoreRight() {
    scoreRight++;
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    var scoreState = context.watch<ScoreState>();
    const style = TextStyle(
        color: Colors.white, fontWeight: FontWeight.normal, fontSize: 64);
    return Scaffold(
        body: Row(children: [
      Expanded(
          child: GestureDetector(
              onTap: () {
                scoreState.incrementscoreLeft();
                scoreState.calculateScore();
              },
              child: Container(
                color: Colors.red,
                child: Center(
                  child: Text(
                    scoreState.scoreLeft.toString(),
                    style: style,
                  ),
                ),
              ))),
      Expanded(
          child: GestureDetector(
        onTap: () {
          scoreState.incrementScoreRight();
          scoreState.calculateScore();
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
      )),
    ]));
  }
}
