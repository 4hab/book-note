import 'package:flutter/material.dart';

class ConfirmDialog extends StatefulWidget {
  final String message;

  ConfirmDialog({@required this.message});

  @override
  _ConfirmDialogState createState() => _ConfirmDialogState(message);
}

class _ConfirmDialogState extends State<ConfirmDialog> {
  String message;

  _ConfirmDialogState(this.message);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            message,
            style: TextStyle(fontWeight: FontWeight.bold,),
            textAlign: TextAlign.center,
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              RaisedButton(
                textColor: Colors.white,
                color: Colors.green,
                child: Text('No'),
                onPressed: () {
                  Navigator.pop(context, false);
                },
              ),
              RaisedButton(
                textColor: Colors.white,
                color: Colors.red,
                child: Text('Yes'),
                onPressed: () {
                  Navigator.pop(context, true);
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}
