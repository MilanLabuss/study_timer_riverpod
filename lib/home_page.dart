import 'dart:async';
import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:study_app/Counts.dart';

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key});

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) return;

    final isBackground = state == AppLifecycleState.paused;
//app either in background or the screen is locked
    if (isBackground) {
      ref.read(countsProvider.notifier).iteratecount();
      //Pausing the timer if the app is in the background
      //  stopTimer(reset: false);
      //Probably best then topkeep the timer going but punishing the user for leaving the app
    }
  }

  //defining the seconds of the timer
  int maxSeconds = 30;
  late int seconds = maxSeconds;

  Timer? timer;

  //method for starting the Timer
  //Here I could watch a Riverpod Timer and have all of the methods in that provider to call from here
  void startTimer({bool reset = true}) {
    //if the parameter is passed as true it means we want to reset the Timer before starting it
    if (reset) {
      resetTimer();
    }
    timer = Timer.periodic(Duration(seconds: 1), (_) {
      if (seconds > 0) {
        setState(() {
          seconds--;
        });
      } else {
        stopTimer(reset: false);
      }
    });
  }

//Reset the timer we have paused it has to be done like this because we want to see the time remaining before resetting
  void resetTimer() => setState(() {
        seconds = maxSeconds;
      });

//When Pause Button is Clicked (Takes a reset property to know if its a pause or reset)
  void stopTimer({bool reset = true}) {
    if (reset) {
      resetTimer();
    }
    setState(() {
      timer?.cancel();
    });
  }

  void setTime() {}

//Number input controller
  final myController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    //if the timer is null return false else its active using the built in Method

    final countValue = ref.watch(countsProvider);
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextField(),
            Container(
              height: 50,
              width: 50,
              child: TextField(
                controller: myController,
                decoration: InputDecoration(labelText: "Enter your number"),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ], // Only numbers can be entered
              ),
            ),
            ElevatedButton(
                onPressed: () {
                  setState(() {
                    maxSeconds = int.parse(myController.text);
                    seconds = maxSeconds;
                  });
                },
                child: Text('Set Time')),
            BuildTimer(),
            theButton(),
            Text(
              'closed app: $countValue times',
              style: TextStyle(fontSize: 30),
            ),
          ],
        ),
      ),
    );
  }

//the widget displaying the timer
  Widget BuildTimer() {
    bool changeColor = false;
    if (seconds < 10) {
      changeColor = true;
    }
    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(fit: StackFit.expand, children: [
        CircularProgressIndicator(
          value: seconds / maxSeconds,
          valueColor:
              AlwaysStoppedAnimation(changeColor ? Colors.blue : Colors.green),
          strokeWidth: 10,
          //backgroundColor: Colors.green,
        ),
        Center(child: Text('$seconds', style: TextStyle(fontSize: 50))),
      ]),
    );
  }

//will dynamically return different buttons depending on if its running or not
  Widget theButton() {
    final isRunning = timer == null ? false : timer!.isActive;
    //if the timer has reset(back to maxseconds) or completed(zero seconds) this returns true
    final isCompleted = seconds == maxSeconds || seconds == 0;
    //if its running or not completed return pause button and cancel button
    final pausebtntxt = isRunning ? "Pause" : "Resume";
    return isRunning || !isCompleted
        ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                  onPressed: () {
                    //false because we are pausing it not resetting it
                    //the reset will let us know if we want to pause it or reset it
                    if (pausebtntxt == 'Pause') {
                      stopTimer(reset: false);
                    } else {
                      startTimer(reset: false);
                    }
                  },
                  child: Text(pausebtntxt)),
              const SizedBox(
                width: 12,
              ),
              ElevatedButton(
                  onPressed: () {
                    stopTimer();
                  },
                  child: const Text('Cancel')),
            ],
          )
        :
        //but if it is completed then we want to return the start Button
        ElevatedButton(
            onPressed: () {
              startTimer();
            },
            child: const Text('START'));
  }
}
