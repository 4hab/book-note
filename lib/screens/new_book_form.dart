import 'dart:io';
import 'package:booknote/models/book.dart';
import 'package:booknote/models/image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class NewBookForm extends StatefulWidget {
  @override
  _NewBookFormState createState() => _NewBookFormState();
}

Book book = Book();

class _NewBookFormState extends State<NewBookForm> {
  final _formKey = GlobalKey<FormState>();
  String _imgName;
  File _img;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextFormField(
              initialValue: book.name,
              style: TextStyle(),
              decoration: InputDecoration(
                hintText: 'Book name',
              ),
              validator: (val) => val.isEmpty ? 'Book name can not be empty' : null,
              onSaved: (val) => book.name = val,
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              'Book cover (optional)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(_imgName ?? 'Choose Image'),
            SizedBox(
              height: 20,
            ),
            Center(
              child: FlatButton(
                color: Colors.blue,
                child: Icon(
                  Icons.file_upload,
                  color: Colors.white,
                ),
                onPressed: _onPressed,
              ),
            )
          ],
        ),
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context, null);
          },
        ),
        IconButton(
          icon: Icon(Icons.check),
          onPressed: () async {
            if (_formKey.currentState.validate()) {
              _formKey.currentState.save();
              book.userId = 1;
              if (_img != null) {
                String newPath =
                    (await getApplicationDocumentsDirectory()).path + '/' + _imgName;
                book.coverPath = newPath;
                _img.copy(newPath);
              }
              Navigator.pop(context, book);
            }
          },
        ),
      ],
    );
  }

  void _onPressed() async {
    _img = await FilePicker.getFile(type: FileType.image);
    if (_img != null) {
      setState(() {
        _imgName = MyImage.getName(_img.path);
      });
    }
  }
}
