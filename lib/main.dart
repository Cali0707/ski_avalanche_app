import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:groovin_widgets/groovin_widgets.dart';
import 'package:ndialog/ndialog.dart';

//TODO: Add google maps and place_picker widget into page
//TODO: Find a better way of displaying trigger event
//TODO: Test
//TODO: Build for deployment

void main(){
  runApp(SpeechApp());
}

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
  String _previousText = '';
  bool buttonVal = false;
  String lastError = '';
  String lastStatus = '';
  String lastKeyword = '';
  String _currentLocaleId = '';
  int resultListened = 0;
  SpeechToText _speech = SpeechToText();
  double confidence = 1.0;
  List<LocaleName> _localeNames = [];
  final SpeechToText speech = SpeechToText();
  List<Color> buttonColors = [Colors.grey, Colors.red];

  @override
  void initState() {
    super.initState();
    initSpeechState();
  }

  Future<void> initSpeechState() async {
    var hasSpeech = await speech.initialize(
        onError: errorListener,
        onStatus: statusListener,
        debugLogging: false,
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
            if(_text.endsWith(lastKeyword)){
              buttonVal = true;
              _isListening = false;
              _speech.stop();
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20))),
            title: Text("Avalanche Safety App"),
          ),
        ),
        body: Column(children: [
          Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[

              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12.0),
            child: GroovinExpansionTile(
              defaultTrailingIconColor: Colors.white,
              boxDecoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(15.0)
              ),
              title: Text(
                (lastKeyword != '') ? "Your trigger word is: $lastKeyword" : "Record a trigger word",
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              maintainState: true,
              children: [
                Container(
                  child: Column(
                    children: [
                      Text(
                          "Record a trigger word:",
                        style: TextStyle(color: Colors.white),

                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Colors.white, // background
                              onPrimary: Colors.red, // foreground
                            ),
                            child: Text('Start'),
                            onPressed: !_hasSpeech || speech.isListening
                                ? null
                                : listenForKeyword,
                            // onPressed: (){
                            //   if(speech.isAvailable && speech.isNotListening){
                            //     listenForKeyword();
                            //   }
                            //   return null;
                            // },
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Colors.white, // background
                              onPrimary: Colors.red, // foreground
                            ),
                            child: Text('Stop'),
                            onPressed: speech.isListening ? stopListening : null,
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Colors.white, // background
                              onPrimary: Colors.red, // foreground
                            ),
                            child: Text('Cancel'),
                            onPressed: speech.isListening ? cancelListening : null,
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Divider(height: 1, color: Colors.white, thickness: 1,),
                      ),
                      Text("Change Speech Recognition Language:", style: TextStyle(color: Colors.white),),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            fillColor: Colors.red,
                            filled: true,
                            labelStyle: TextStyle(color: Colors.white),
                            enabledBorder: InputBorder.none
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton(
                              icon: Icon(Icons.keyboard_arrow_down, color: Colors.white,),
                              elevation: 0,
                              isExpanded: true,
                              style: TextStyle(color: Colors.white),
                              dropdownColor: Colors.red,
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
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          // Expanded(
          //   flex: 4,
          //   child: Column(
          //     children: <Widget>[
          //       Padding(
          //         padding: const EdgeInsets.all(12.0),
          //         child: Center(
          //           child: Container(
          //             height: 150,
          //             width: 150,
          //             child: FittedBox(
          //               child: FloatingActionButton(
          //                 child: Icon(
          //                   Ionicons.power,
          //                   color: buttonColors[buttonVal],
          //                 ),
          //                 onPressed: (){
          //                   if(buttonVal == 1){
          //                     setState(() {
          //                       buttonVal = 0;
          //                     });
          //                   }
          //                 },
          //                 backgroundColor: Colors.white,
          //               ),
          //             ),
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          ElevatedButton(
              onPressed: (){
                _listen();
              },
              child: Text(
                "Start Skiing!"
              )),
          CheckboxListTile(
              value: buttonVal,
              onChanged: (val){
                if(buttonVal == true){
                  setState(() {
                    buttonVal = false;
                  });
                }
              },
            title: Text(
              "System triggered?"
            ),
          )
        ]),
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
  }
}