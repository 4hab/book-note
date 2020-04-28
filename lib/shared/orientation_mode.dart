import 'package:flutter/services.dart';

void portraitOnly(){
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
}
void allowOrientation(){
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
}