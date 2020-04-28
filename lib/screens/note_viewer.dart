import 'dart:io';
import 'package:booknote/database.dart';
import 'package:booknote/models/image.dart';
import 'package:booknote/models/section.dart';
import 'package:booknote/screens/galler.dart';
import 'package:booknote/screens/new_section_form.dart';
import 'package:booknote/shared/const.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:booknote/models/note.dart';
import 'package:booknote/shared/confirm_dialog.dart';

class NoteViewerScreen extends StatefulWidget {
  final note;

  NoteViewerScreen(this.note);

  @override
  _NoteViewerScreenState createState() => _NoteViewerScreenState(note);
}

class _NoteViewerScreenState extends State<NoteViewerScreen> {
  final db = DatabaseService();
  Note note;
  bool _edit = false;
  final _formKey = GlobalKey<FormState>();
  int sectionId;
  Offset _position;

  _NoteViewerScreenState(this.note) {
    sectionId = note.sectionId;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: boxDecoration,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('BookNote'),
          backgroundColor: colors[4],
          actions: _edit
              ? [
                  IconButton(
                    icon: Icon(Icons.check),
                    onPressed: _confirmEditClick,
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: _cancelEditClick,
                  )
                ]
              : [
                  _popUpMenu(),
                ],
        ), //Drawer
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: colors[4],
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey[700],
                      offset: Offset(0, 0),
                      blurRadius: 4,
                      spreadRadius: 2,
                    ),
                  ],
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(35)),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _title(),
                      SizedBox(height: 7),
                      _pageNum(),
                      SizedBox(height: 7),
                      _description(),
                      note.content.isNotEmpty && !_edit
                          ? Align(
                              alignment: Alignment.bottomRight,
                              child: FlatButton(
                                child: Text(
                                  'View all',
                                  style: TextStyle(
                                    color: Colors.white,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          content: Container(
                                            child: SingleChildScrollView(
                                              child: Text(
                                                note.content,
                                                style: TextStyle(fontSize: 14),
                                              ),
                                            ),
                                            height: 400,
                                          ),
                                        );
                                      });
                                },
                              ),
                            )
                          : Container(),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30),
              FutureBuilder(
                future: db.getImages(note.id),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data.isNotEmpty) {
                    return _imagesSection(snapshot.data);
                  }
                  return Icon(
                    Icons.camera_alt,
                    size: 150,
                    color: Colors.green[200].withOpacity(.4),
                  );
                },
              ),
              SizedBox(
                height: 20,
              ),
              RaisedButton(
                child: Text('+Image'),
                color: colors[4],
                textColor: Colors.white,
                onPressed: () async {
                  await _addImageClick();
                  setState(() {});
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  //end of build function

  void _cancelEditClick() {
    showDialog(
      context: context,
      builder: (context) => ConfirmDialog(
        message: 'Discard edit?',
      ),
    ).then((answer) {
      if (answer)
        setState(() {
          _edit = false;
        });
    });
  }

  void _confirmEditClick() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      note.sectionId = sectionId;
      await db.update('notes', note.id, note);
      setState(() {
        _edit = false;
      });
    }
  }

  Widget _title() {
    return _edit
        ? TextFormField(
            initialValue: note.title,
            validator: (val) => val.isEmpty ? 'Title can\'t be empty' : null,
            onSaved: (val) => note.title = val,
            decoration: InputDecoration(
              prefix: Text(
                'Title   ',
                style: TextStyle(
                  color: colors[0],
                ),
              ),
              border: InputBorder.none,
              filled: true,
            ),
            style: TextStyle(color: Colors.white),
          )
        : Text(
            note.title,
            style: TextStyle(
              color: Colors.yellow,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          );
  }

  Widget _pageNum() {
    return _edit
        ? Row(
            children: <Widget>[
              Container(
                width: 130,
                child: TextFormField(
                  initialValue: note.pageNum.toString(),
                  keyboardType: TextInputType.number,
                  validator: (val) => val.isEmpty ? 'Enter page number' : null,
                  onSaved: (val) => note.pageNum = int.parse(val),
                  decoration: InputDecoration(
                    prefix: Text(
                      'Page no.   ',
                      style: TextStyle(
                        color: colors[0],
                      ),
                    ),
                    border: InputBorder.none,
                    filled: true,
                  ),
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(
                width: 10,
              ),
              _sectionsMenu(),
            ],
          )
        : Text(
            'Page ' + note.pageNum.toString(),
            style: TextStyle(color: colors[0]),
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
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      color: Colors.white,
      child: DropdownButtonHideUnderline(
        child: FutureBuilder(
          future: db.getSections(note.bookId),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<Section> sections = snapshot.data;
              return DropdownButton(
                items: _items(sections),
                onChanged: (val) {
                  if (val == 0) {
                    showDialog<String>(
                        context: context,
                        builder: (context) => NewSectionForm()).then((sectionName) async {
                      await db.insert(
                        'sections',
                        Section.fromMap({'book_id': note.bookId, 'name': sectionName}),
                      );
                    });
                  } else {
                    sectionId = val;
                  }
                  setState(() {});
                },
                value: sectionId,
                style: TextStyle(color: colors[2], fontFamily: 'Cairo'),
              );
            }
            return Container();
          },
        ),
      ),
    );
  }

  Widget _description() {
    return Container(
      height: 100,
      width: MediaQuery.of(context).size.width,
      child: _edit
          ? TextFormField(
              initialValue: note.content,
              decoration: InputDecoration(
                border: InputBorder.none,
                filled: true,
                hintText: 'Description',
                hintStyle: TextStyle(color: colors[0]),
              ),
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
              maxLines: 3,
              onSaved: (val) => note.content = val,
            )
          : Text(
              note.content,
              style: TextStyle(
                color: Colors.grey[400],
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
    );
  }

  Widget _imagesSection(List<MyImage> images) {
    return Column(
      children: <Widget>[
        Align(
          alignment: AlignmentDirectional.topStart,
          child: Text(
            '   Images:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        Container(
          height: 180,
          width: MediaQuery.of(context).size.width,
          child: ListView.builder(
            padding: EdgeInsets.all(10),
            scrollDirection: Axis.horizontal,
            itemCount: images.length,
            itemBuilder: (context, index) {
              return Row(
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(boxShadow: [
                      BoxShadow(blurRadius: 3, offset: Offset(0, 2)),
                    ]),
                    child: GestureDetector(
                      child: Image.file(
                        File(images[index].path),
                        height: 150,
                        fit: BoxFit.cover,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Gallery(images, index),
                          ),
                        );
                      },
                      onTapDown: (d) => _position = d.globalPosition,
                      onLongPress: () {
                        _onLongPressImage(images[index].id);
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  void _onLongPressImage(int id) {
    print(_position);
    showMenu(
      context: context,
      items: [
        PopupMenuItem(
          value: id,
          child: FlatButton(
            child: Text('Delete'),
            onPressed: () async {
              await db.delete('images', id);
              setState(() {});
              Navigator.pop(context);
            },
          ),
        ),
      ],
      position: RelativeRect.fromLTRB(
        _position.dx,
        _position.dy,
        _position.dx,
        _position.dy,
      ),
    );
  }

  Future _addImageClick() async {
    List<File> images = await FilePicker.getMultiFile(type: FileType.image);
    for (int i = 0; i < images.length; i++) {
      MyImage img = MyImage.fromMap({
        'book_id': note.bookId,
        'section_id': note.sectionId,
        'note_id': note.id,
        'path': images[i].path,
      });
      await db.insert('images', img);
    }
  }

  Widget _popUpMenu() {
    return PopupMenuButton(
      itemBuilder: (context) {
        return [
          PopupMenuItem(
            child: Text('Edit'),
            value: 'edit',
          ),
          PopupMenuItem(
            child: Text('Delete'),
            value: 'delete',
          )
        ];
      },
      onSelected: (val) async {
        if (val == 'edit') {
          setState(() {
            _edit = true;
          });
        } else {
          showDialog<bool>(
            context: context,
            builder: (context) => ConfirmDialog(
              message: 'Are you sure you want to delete this note?',
            ),
          ).then((answer) async {
            if (answer) {
              await db.delete('notes', note.id);
              Navigator.pop(context);
            }
          });
        }
      },
    );
  }

}
