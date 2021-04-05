import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:highlight_text/highlight_text.dart';
import 'package:ionicons/ionicons.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:highlight_text/highlight_text.dart';


class SpeechApp extends StatefulWidget {
  @override
  _SpeechAppState createState() => _SpeechAppState();
}

class _SpeechAppState extends State<SpeechApp> {
  bool _hasSpeech = false;
  bool _isListening = false;
  double level = 0.0;
  double minSoundLevel = 50000;
  double maxSoundLevel = -50000;
  String _text = '';
  int buttonVal = 0;
  String lastError = '';
  String lastStatus = '';
  String lastKeyword = '';
  String _currentLocaleId = '';
  int resultListened = 0;
  SpeechToText _speech = SpeechToText();
  double confidence = 1.0;
  List<LocaleName> _localeNames = [];
  final SpeechToText speech = SpeechToText();
  List<Color> buttonColors = [Colors.grey, Colors.green];
  // Map<String, HighlightedWord>? _highlights = {"Test": HighlightedWord(onTap: (){}, textStyle: TextStyle(color: Colors.red))};

  @override
  void initState() {
    super.initState();
    initSpeechState();
  }

  Future<void> initSpeechState() async {
    var hasSpeech = await speech.initialize(
        onError: errorListener,
        onStatus: statusListener,
        debugLogging: true,
        finalTimeout: Duration(milliseconds: 0));
    if (hasSpeech) {
      _localeNames = await speech.locales();

      var systemLocale = await speech.systemLocale();
      _currentLocaleId = systemLocale!.localeId;
    }

    if (!mounted) return;

    setState(() {
      _hasSpeech = hasSpeech;
    });
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _text = val.recognizedWords.toLowerCase();
            print("$_text\n");
            if(_text.contains(lastKeyword)){
              buttonVal = 1;
            }
            if(val.hasConfidenceRating && val.confidence > 0.0){
              confidence = val.confidence;
            }
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(75),
          child: AppBar(
            backgroundColor: Colors.red,
            elevation: 12,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text("Avalanche Safety App"),
          ),
        ),
        body: Column(children: [
          Container(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Center(
                    child: Text(
                      "Your keyword is: $lastKeyword",
                      style: TextStyle(
                        fontSize: 16
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    ElevatedButton(
                      child: Text('Start'),
                      onPressed: !_hasSpeech || speech.isListening
                          ? null
                          : listenForKeyword,
                    ),
                    ElevatedButton(
                      child: Text('Stop'),
                      onPressed: speech.isListening ? stopListening : null,
                    ),
                    ElevatedButton(
                      child: Text('Cancel'),
                      onPressed: speech.isListening ? cancelListening : null,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    DropdownButton(
                      onChanged: (selectedVal) => _switchLang(selectedVal),
                      value: _currentLocaleId,
                      items: _localeNames
                          .map(
                            (localeName) => DropdownMenuItem(
                          value: localeName.localeId,
                          child: Text(localeName.name),
                        ),
                      )
                          .toList(),
                    ),
                  ],
                )
              ],
            ),
          ),
          Expanded(
            flex: 4,
            child: Column(
              children: <Widget>[
                Center(
                  child: Text(
                    "Confidence: ${(confidence * 100.0).toStringAsFixed(1)}%"
                  )
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Center(
                    child: Container(
                      height: 150,
                      width: 150,
                      child: FittedBox(
                        child: FloatingActionButton(
                          child: Icon(
                            Ionicons.power,
                            color: buttonColors[buttonVal],
                          ),
                          onPressed: (){},
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ]),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: AvatarGlow(
          animate: _isListening,
          glowColor: Colors.red,
          endRadius: 75.0,
          duration: const Duration(milliseconds: 2000),
          repeatPauseDuration: const Duration(milliseconds: 100),
          repeat: true,
          child: FloatingActionButton(
            onPressed: _listen,
            child: Icon(_isListening ? Icons.mic : Icons.mic_none, color: Colors.white,),
          ),
        ),
      ),
    );
  }


  void stopListening() {
    speech.stop();
    setState(() {
      level = 0.0;
    });
  }

  void cancelListening() {
    speech.cancel();
    setState(() {
      level = 0.0;
    });
  }


  void soundLevelListener(double level) {
    minSoundLevel = min(minSoundLevel, level);
    maxSoundLevel = max(maxSoundLevel, level);
    setState(() {
      this.level = level;
    });
  }

  void errorListener(SpeechRecognitionError error) {
    setState(() {
      lastError = '${error.errorMsg} - ${error.permanent}';
    });
  }

  void statusListener(String status) {
    setState(() {
      lastStatus = '$status';
    });
  }

  void keywordListener(SpeechRecognitionResult result){
    if(result.recognizedWords != "") {
      setState(() {
        lastKeyword = '${result.recognizedWords}'.toLowerCase();
        // _highlights = {"$result": HighlightedWord(
        //     onTap: () => print("$result"),
        //     textStyle: const TextStyle(
        //         color: Colors.red,
        //         fontWeight: FontWeight.bold
        //     )
        // )};
      });
    }
  }

  void listenForKeyword(){
    lastError = '';
    speech.listen(
        onResult: keywordListener,
        listenFor: Duration(seconds: 5),
        pauseFor: Duration(seconds: 5),
        partialResults: false,
        localeId: _currentLocaleId,
        onSoundLevelChange: soundLevelListener,
        cancelOnError: true,
        listenMode: ListenMode.confirmation);
    setState(() {});
  }

  void _switchLang(selectedVal) {
    setState(() {
      _currentLocaleId = selectedVal;
    });
    print(selectedVal);
  }
}

