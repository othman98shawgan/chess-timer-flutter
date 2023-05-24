import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:chess_timer/resources/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import 'package:wakelock/wakelock.dart';
import 'package:numberpicker/numberpicker.dart';

enum Player { first, seccond }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Stopwatch _stopwatch1 = Stopwatch();
  Duration _duration1 = const Duration(minutes: 10);
  bool _isTimerRunning1 = false;

  final Stopwatch _stopwatch2 = Stopwatch();
  Duration _duration2 = const Duration(minutes: 10);
  bool _isTimerRunning2 = false;

  var timerColor1 = colorOff;
  var timerColor2 = colorOff;

  var smallFontSize = 112.0;
  var bigFontSize = 124.0;
  var currFontSize = 112.0;

  bool gameFinished = false;
  bool gameStarted = false;
  late Player winner;

  //audio
  final player = AudioPlayer();

  List<int> _currentTimeValue1 = [0, 0, 0];
  List<int> _currentTimeValue2 = [0, 0, 0];

  void gameOver(Player gameWinner) async {
    await player.play(AssetSource('game_over.mp3'));
    Vibration.vibrate(pattern: [0, 100, 200, 400, 200, 600]);
    winner = gameWinner;
    _stopwatch1.stop();
    _stopwatch2.stop();
    gameFinished = true;
    gameStarted = false;
  }

  Color getEndGameColor(Player player) {
    if (player == winner) {
      return colorWinner;
    }
    return colorLoser;
  }

  String formatDuration(Duration duration) {
    if (duration.isNegative) {
      return '00.0';
    }
    int hoursInt = duration.inHours;
    int minutesInt = duration.inMinutes % 60 + hoursInt * 60;
    String minutes = minutesInt.toString().padLeft(2, '0');
    String seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    String milliseconds = ((duration.inMilliseconds % 1000) ~/ 100).toString();
    if (minutes.length == 3) {
      currFontSize = smallFontSize;
    } else {
      currFontSize = bigFontSize;
    }
    if (minutesInt > 0) {
      return '$minutes:$seconds';
    }
    return '$seconds.$milliseconds';
  }

  void startTimer1() {
    if (!_isTimerRunning1 && !gameFinished) {
      gameStarted = true;
      _stopwatch1.start();
      setState(() {
        _isTimerRunning1 = true;
      });
      _startCountdown1();
    }
  }

  void _startCountdown1() {
    Timer.periodic(const Duration(milliseconds: 10), (timer) {
      if (_stopwatch1.elapsed >= _duration1) {
        timer.cancel();
        gameOver(Player.seccond);
        setState(() {
          _isTimerRunning1 = false;
        });
      }
      setState(() {});
    });
  }

  void pauseTimer1() {
    if (_isTimerRunning1) {
      _stopwatch1.stop();
      setState(() {
        _isTimerRunning1 = false;
      });
    }
  }

  void resetTimer1() {
    _stopwatch1.stop();
    _stopwatch1.reset();
    setState(() {
      _isTimerRunning1 = false;
    });
  }

  void startTimer2() {
    if (!_isTimerRunning2 && !gameFinished) {
      gameStarted = true;
      _stopwatch2.start();
      setState(() {
        _isTimerRunning2 = true;
      });
      _startCountdown2();
    }
  }

  void _startCountdown2() {
    Timer.periodic(const Duration(milliseconds: 10), (timer) {
      if (_stopwatch2.elapsed >= _duration2) {
        timer.cancel();
        gameOver(Player.first);
        setState(() {
          _isTimerRunning2 = false;
        });
      }
      setState(() {});
    });
  }

  void pauseTimer2() {
    if (_isTimerRunning2) {
      _stopwatch2.stop();
      setState(() {
        _isTimerRunning2 = false;
      });
    }
  }

  void resetTimer2() {
    _stopwatch2.stop();
    _stopwatch2.reset();
    setState(() {
      _isTimerRunning2 = false;
    });
  }

  void swtichToOne() async {
    await player.play(AssetSource('tick.mp3'));
    startTimer1();
    pauseTimer2();
  }

  void swtichToTwo() async {
    await player.play(AssetSource('tick.mp3'));
    startTimer2();
    pauseTimer1();
  }

  void startStopTimer(Player timer) {
    if (!_isTimerRunning1 && !_isTimerRunning2) {
      timer == Player.first ? swtichToTwo() : swtichToOne();
    } else if (_isTimerRunning1 && timer == Player.first) {
      swtichToTwo();
    } else if (_isTimerRunning2 && timer == Player.seccond) {
      swtichToOne();
    }
  }

  @override
  void initState() {
    Wakelock.enable();
    super.initState();
  }

  @override
  void dispose() {
    _stopwatch1.stop();
    _stopwatch2.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

    return Scaffold(
      backgroundColor: colorBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: height * 0.0125,
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(25.0)),
                color: gameFinished
                    ? getEndGameColor(Player.first)
                    : _isTimerRunning1
                        ? colorOn
                        : colorOff,
              ),
              height: height * 0.4125,
              width: width * 0.95,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  startStopTimer(Player.first);
                },
                child: RotatedBox(
                  quarterTurns: 2,
                  child: Column(
                    children: [
                      SizedBox(
                        height: height * 0.05,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 8, left: 8),
                              child: Text(
                                !gameStarted ? 'Player 2' : '',
                                style: const TextStyle(color: Colors.black87),
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: height * 0.3125,
                        child: Center(
                          child: Text(
                            formatDuration(_duration1 - _stopwatch1.elapsed),
                            style: TextStyle(
                                fontSize: currFontSize,
                                color: Colors.black,
                                fontWeight: FontWeight.w300),
                          ),
                        ),
                      ),
                      SizedBox(height: height * 0.05),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: height * 0.15,
              width: width * 0.95,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    color: Colors.black87,
                    tooltip: 'Set timers',
                    iconSize: 80,
                    onPressed: () {
                      showSetTimerDialog(context);
                    },
                    icon: const Icon(Icons.settings),
                  ),
                  IconButton(
                    tooltip: 'Pause',
                    color: Colors.black87,
                    iconSize: 80,
                    onPressed: () {
                      pauseTimer1();
                      pauseTimer2();
                    },
                    icon: const Icon(Icons.pause),
                  ),
                  IconButton(
                    tooltip: 'Restart',
                    color: Colors.black87,
                    iconSize: 80,
                    onPressed: () {
                      gameFinished = false;
                      gameStarted = false;
                      resetTimer1();
                      resetTimer2();
                    },
                    icon: const Icon(Icons.restore_rounded),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(25.0)),
                color: gameFinished
                    ? getEndGameColor(Player.seccond)
                    : _isTimerRunning2
                        ? colorOn
                        : colorOff,
              ),
              height: height * 0.4125,
              width: width * 0.95,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  startStopTimer(Player.seccond);
                },
                child: Column(
                  children: [
                    SizedBox(
                      height: height * 0.05,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 8, left: 8),
                            child: Text(
                              !gameStarted ? 'Player 1' : '',
                              style: const TextStyle(color: Colors.black87),
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: height * 0.3125,
                      child: Center(
                        child: Text(
                          formatDuration(_duration2 - _stopwatch2.elapsed),
                          style: TextStyle(
                              fontSize: currFontSize,
                              color: Colors.black,
                              fontWeight: FontWeight.w300),
                        ),
                      ),
                    ),
                    SizedBox(height: height * 0.05),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: height * 0.0125,
            ),
          ],
        ),
      ),
    );
  }

  Widget setTimer(
      List<int> _currentTimeValue, StateSetter SBsetState, int index, int min, int max) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        NumberPicker(
            value: _currentTimeValue[index],
            zeroPad: false,
            textStyle: const TextStyle(fontSize: 18, color: Color.fromARGB(200, 189, 189, 189)),
            textMapper: (numberText) {
              return numberText.padLeft(2, '0');
            },
            selectedTextStyle: const TextStyle(fontSize: 28),
            minValue: min,
            maxValue: max,
            infiniteLoop: true,
            onChanged: (value) {
              setState(() => _currentTimeValue[index] = value); // to change on widget level state
              SBsetState(() => _currentTimeValue[index] = value); //* to change on dialog state
            }),
      ],
    );
  }

  showSetTimerDialog(BuildContext context) {
    _currentTimeValue1 = [0, 0, 0];
    _currentTimeValue2 = [0, 0, 0];
    bool? checkboxStatus = true;

    var confirmMethod = (() {
      if (checkboxStatus == true) {
        if (_currentTimeValue1[0] == 0 && _currentTimeValue1[1] == 0) {
          return;
        }
        var newDuration = Duration(
          minutes: _currentTimeValue1[1],
          seconds: _currentTimeValue1[0],
        );
        setState(() {
          _duration1 = newDuration;
          resetTimer1();
          _duration2 = newDuration;
          resetTimer2();
        });
      } else {
        if ((_currentTimeValue1[0] == 0 && _currentTimeValue1[1] == 0) ||
            _currentTimeValue2[0] == 0 && _currentTimeValue2[1] == 0) {
          return;
        }
        var newDuration1 = Duration(
          minutes: _currentTimeValue1[1],
          seconds: _currentTimeValue1[0],
        );
        var newDuration2 = Duration(
          minutes: _currentTimeValue2[1],
          seconds: _currentTimeValue2[0],
        );

        setState(() {
          _duration1 = newDuration1;
          resetTimer1();
          _duration2 = newDuration2;
          resetTimer2();
        });
      }
      Navigator.pop(context);
    });

    var textButton = TextButton(
      onPressed: confirmMethod,
      child: const Text('Confirm'),
    );

    AlertDialog alert = AlertDialog(
      title: const Text("Set Timers"),
      contentPadding: const EdgeInsets.only(top: 16),
      insetPadding: EdgeInsets.zero,
      content: StatefulBuilder(
        builder: (BuildContext context, StateSetter SBsetState) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Checkbox(
                      value: checkboxStatus,
                      onChanged: (((value) {
                        SBsetState(() {
                          checkboxStatus = value;
                        });
                        setState(() {
                          checkboxStatus = value;
                        });
                      }))),
                  const Text('Both Timers identical'),
                ],
              ),
              checkboxStatus == false
                  ? Row(
                      children: const [
                        Padding(
                          padding: EdgeInsets.only(top: 8, left: 16, bottom: 16),
                          child: Text(
                            'Player 1:',
                            style: TextStyle(
                              fontWeight: FontWeight.w300,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        )
                      ],
                    )
                  : Container(),
              Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                  color: Colors.black54,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    setTimer(_currentTimeValue1, SBsetState, 1, 0, 120),
                    const Text(':'),
                    setTimer(_currentTimeValue1, SBsetState, 0, 0, 59),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              checkboxStatus == false
                  ? (Column(
                      children: [
                        const Divider(
                          thickness: 2,
                        ),
                        Row(
                          children: const [
                            Padding(
                              padding: EdgeInsets.only(top: 8, left: 16, bottom: 16),
                              child: Text(
                                'Player 2:',
                                style: TextStyle(
                                  fontWeight: FontWeight.w300,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            )
                          ],
                        ),
                        Container(
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(25.0)),
                            color: Colors.black54,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              setTimer(_currentTimeValue2, SBsetState, 1, 0, 120),
                              const Text(':'),
                              setTimer(_currentTimeValue2, SBsetState, 0, 0, 59),
                            ],
                          ),
                        ),
                        // Text(
                        //   '${_currentTimeValue2[1].toString().padLeft(2, '0')}:${_currentTimeValue2[0].toString().padLeft(2, '0')}',
                        //   style: const TextStyle(fontSize: 24),
                        // ),
                        const SizedBox(height: 16),
                      ],
                    ))
                  : Container(),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                        onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                    const SizedBox(width: 8),
                    textButton,
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
