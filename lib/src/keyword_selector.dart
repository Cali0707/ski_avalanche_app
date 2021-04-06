import 'dart:math';

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class KeywordListener extends StatefulWidget {
  final ValueNotifier valueNotifier;
  /// speech must be initialized before being passed to [KeywordListener]
  final SpeechToText speech;
  final String currentLocaleId;
  final GlobalKey key;

  KeywordListener({
    required this.valueNotifier,
    required this.speech,
    required this.currentLocaleId,
    required this.key
  }): super(key: key);

  @override
  KeywordListenerState createState() => KeywordListenerState();
}

class KeywordListenerState extends State<KeywordListener> {
  String keyword = "";
  String currentLocaleId = "";
  String lastError = "";
  String lastStatus = "";
  double level = 0.0;
  double minSoundLevel = 50000;
  double maxSoundLevel = -50000;
  

  void initState(){
    super.initState();
    currentLocaleId = widget.currentLocaleId;
    if(!widget.speech.isAvailable){
      initSpeechState();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.white, // background
                onPrimary: Colors.red, // foreground
              ),
              child: Text('Start'),
              onPressed: !widget.speech.isAvailable || widget.speech.isListening
                  ? null
                  : listenForKeyword,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.white, // background
                onPrimary: Colors.red, // foreground
              ),
              child: Text('Stop'),
              onPressed: widget.speech.isListening ? stopListening : null,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.white, // background
                onPrimary: Colors.red, // foreground
              ),
              child: Text('Cancel'),
              onPressed: widget.speech.isListening ? cancelListening : null,
            ),
          ],
        ),
        (keyword != "") ? Text(keyword) : Container()
      ],
    );
  }

  Future<void> initSpeechState() async {
    var hasSpeech = await widget.speech.initialize(
        onError: errorListener,
        onStatus: statusListener,
        debugLogging: true,
        finalTimeout: Duration(milliseconds: 0));
    if (hasSpeech) {
      var systemLocale = await widget.speech.systemLocale();
      currentLocaleId = systemLocale!.localeId;
    }
    if (!mounted) return;
  }

  void listenForKeyword(){
    lastError = '';
    widget.speech.listen(
        onResult: keywordListener,
        listenFor: Duration(seconds: 5),
        pauseFor: Duration(seconds: 5),
        partialResults: false,
        localeId: currentLocaleId,
        onSoundLevelChange: soundLevelListener,
        cancelOnError: true,
        listenMode: ListenMode.confirmation);
    setState(() {});
  }
  void keywordListener(SpeechRecognitionResult result){
    print("did something");
    if(result.recognizedWords != "") {
      setState(() {
        keyword = '${result.recognizedWords}'.toLowerCase();
        widget.valueNotifier.value = keyword;
        print(widget.valueNotifier.value);
      });
    }
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
  void stopListening() {
    widget.speech.stop();
    setState(() {
      level = 0.0;
    });
  }

  void cancelListening() {
    widget.speech.cancel();
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
}



