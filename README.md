# ski_avalanche_app

A Flutter application to connect with a button for avalanche airbag triggering. This was part of a larger design project
for the University of Toronto Engineering Science second semester design course. You can read more about this project [here](https://www.calummurray.ca/projects/avalanche-airbag-trigger-system).

## Running this Project

This project is split into two parts, both of which are in this repo. First, there is the arduino code, which is in the ```arduino``` directory and was 
written with the Arduino MKR 1010 board in mind, however it should theoretically work for any board which has BLE, provided the code in ```lib/main.dart```
is updated to check for the correct device name when searching for bluetooth devices. The second part is the Flutter code, which is in the rest of the directories
here. To run this, you will need to ensure that the correct platform permissions are enabled for your app, as described [here](https://pub.dev/packages/speech_to_text), and [here](https://pub.dev/packages/flutter_blue). These should be enabled by default if you clone this repository, but if not open the XCode project and update them as necessary. 
