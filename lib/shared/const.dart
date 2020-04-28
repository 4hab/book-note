

import 'package:flutter/material.dart';

List<Color> colors = [
  Color(0xff599776),
  Color(0xff37875B),
  Color(0xff147641),
  Color(0xff0F5630),
  Color(0xff0C4125),
];

ThemeData myThemeData=ThemeData(
  textTheme: TextTheme(
    title: TextStyle(
      fontFamily: 'Cairo',
      fontSize: 16,
      fontWeight: FontWeight.bold,
    )
  )
);

BoxDecoration boxDecoration = BoxDecoration(
  image: DecorationImage(
    image: AssetImage('images/bg.jpg'),
    fit: BoxFit.cover,
  ),
);