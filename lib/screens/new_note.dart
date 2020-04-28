import 'package:booknote/models/image.dart';
import 'package:booknote/screens/image_picker.dart';
import 'package:booknote/screens/new_section_form.dart';
import 'package:booknote/shared/const.dart';
import 'package:booknote/shared/custom_widgets.dart';
import 'package:flutter/material.dart';
import 'package:booknote/models/section.dart';
import 'package:booknote/database.dart';
import 'package:booknote/models/note.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class NewNoteScreen extends StatefulWidget {
  final bookId;
  NewNoteScreen({this.bookId});
  @override
  _NewNoteScreenState createState() => _NewNoteScreenState(bookId);
}

Note _note = Note();

class _NewNoteScreenState extends State<NewNoteScreen> {
  final bookId;

  _NewNoteScreenState(this.bookId);

  final db = DatabaseService();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: boxDecoration,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('New Note'),
          backgroundColor: colors[4],
          actions: <Widget>[
            FlatButton(
              child: Text(
                'Save',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                _onSave();
              },
            )
          ],
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: 30,
                      ),
                      InputContainer(
                        color: Colors.white,
                        child: TextFormField(
                          initialValue: _note.title,
                          decoration: InputDecoration.collapsed(hintText: 'Note title'),
                          validator: (val) =>
                              val.isEmpty ? 'Title can\'t be empty' : null,
                          onSaved: (val) => _note.title = val,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      InputContainer(
                        color: Colors.white,
                        child: TextFormField(
                            decoration: InputDecoration.collapsed(
                                hintText: 'Description'
                                    '(optional)'),
                            maxLines: 6,
                            onSaved: (val) => _note.content = val),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      InputContainer(
                        color: Colors.white,
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration.collapsed(hintText: 'Page no.'),
                          validator: (val) => val.isEmpty ? 'Enter page number' : null,
                          onSaved: (val) => _note.pageNum = int.parse(val),
                        ),
                      ),
                      SizedBox(height: 20),
                      _sectionsMenu(),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
                NoteImagesPicker(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<DropdownMenuItem> _items(List<Section> sections) {
    List<DropdownMenuItem> items = List<DropdownMenuItem>();
    items.add(DropdownMenuItem(
      child: Text('New section'),
      value: 0,
    ));
    for (int i = 0; i < sections.length; i++) {
      items.add(DropdownMenuItem(
        child: Text(sections[i].name),
        value: sections[i].id,
      ));
    }
    return items;
  }

  Widget _sectionsMenu() {
    return Container(
      height: 40,
      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: colors[0]),
        color: Colors.white
      ),
      child: DropdownButtonHideUnderline(
        child: FutureBuilder(
          future: db.getSections(bookId),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<Section> sections = snapshot.data;
              return DropdownButton(
                items: _items(sections),
                hint: Text('Section'),
                onChanged: (val) {
                  if (val == 0) {
                    showDialog<String>(
                        context: context,
                        builder: (context) => NewSectionForm()).then((sectionName) async {
                      await db.insert(
                        'sections',
                        Section.fromMap({'book_id': bookId, 'name': sectionName}),
                      );
                      setState(() {});
                    });
                  } else {
                    _note.sectionId = val;
                  }
                  setState(() {});
                },
                value: _note.sectionId,
                //style: TextStyle(color: colors[2], fontFamily: 'Cairo'),
              );
            }
            return Container();
          },
        ),
      ),
    );
  }


  void _onSave() async {
    if (_formKey.currentState.validate()) {
      if(_note.sectionId==null){
        showDialog(context: context,builder: (context){
          return AlertDialog(content: Text('Please select section!'),);
        });
        return;
      }
      _formKey.currentState.save();
      _note.bookId = bookId;
      int noteId = await db.insert('notes', _note);
      List<File> images = getImagesFiles();
      for (int i = 0; i < images.length; i++) {
        Directory d = await getApplicationDocumentsDirectory();
        String newPath = d.path + '/' + MyImage.getName(images[i].path);
        images[i].copy(newPath);
        MyImage myImage = MyImage();
        myImage.path = newPath;
        myImage.bookId = bookId;
        myImage.sectionId = _note.sectionId;
        myImage.noteId = noteId;
        await db.insert('images', myImage);
      }
      _note=Note();
      deleteImagesFiles();
      Navigator.pop(context);
    }
  }
}
