import 'package:flutter/material.dart';
import 'package:booknote/shared/custom_widgets.dart';

class NewSectionForm extends StatelessWidget {

  String sectionName;
  NewSectionForm({this.sectionName});
  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    return AlertDialog(
      
      content: Form(
        key: _formKey,
        child: InputContainer(
          child: TextFormField(
            initialValue: sectionName,
            decoration: InputDecoration.collapsed(hintText: 'Section name'),
            validator: (val) =>
            val.isEmpty ? 'Section name can\'t be empty' : null,
            onSaved: (val) => sectionName = val,
          ),
          color: Colors.grey[200],
        ),
      ),
      actions: <Widget>[
        RaisedButton(
          textColor: Colors.white,
          child: Text('Cancel'),
          color: Colors.red[400],
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        RaisedButton(
          textColor: Colors.white,
          child: Text('Ok'),
          color: Colors.green,
          onPressed: () {
            if (_formKey.currentState.validate()) {
              _formKey.currentState.save();
              Navigator.pop(context, sectionName);
            }
          },
        )
      ],
    );
  }
}
