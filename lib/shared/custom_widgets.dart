import 'package:flutter/material.dart';
import 'const.dart';

class InputContainer extends StatelessWidget {
  final Color color;
  final Widget child;
  InputContainer({@required this.child, @required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: color,
        border: Border.all(color: colors[0]),
      ),

      child: child,
    );
  }
}
