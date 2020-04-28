import 'package:booknote/database.dart';
import 'package:booknote/models/book.dart';
import 'package:booknote/models/image.dart';
import 'package:booknote/models/note.dart';
import 'package:booknote/models/section.dart';
import 'package:booknote/screens/new_note.dart';
import 'package:booknote/screens/note_viewer.dart';
import 'package:booknote/shared/confirm_dialog.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:booknote/shared/const.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'new_section_form.dart';

class BookViewerScreen extends StatefulWidget {
  final Book book;

  BookViewerScreen({this.book});

  @override
  _BookViewerScreenState createState() => _BookViewerScreenState(book);
}

class _BookViewerScreenState extends State<BookViewerScreen> {
  final Book book;
  bool _editMode = false;
  File _newImage;
  Map<int, String> sections = Map<int, String>();
  final db = DatabaseService();

  _BookViewerScreenState(this.book);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: boxDecoration,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: colors[4],
          title: Text('BookNote'),
          actions: _editMode
              ? [
                  IconButton(
                    icon: Icon(Icons.check),
                    onPressed: _confirmEditClick,
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: _cancelEditClick,
                  ),
                ]
              : [
                  _bookPopupMenu(),
                ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      flex: 2,
                      child: Container(
                        height: 150,
                        decoration: BoxDecoration(
                          boxShadow: [BoxShadow(spreadRadius: .5, blurRadius: 4)],
                          image: DecorationImage(
                            image: _editMode
                                ? _newImage == null
                                    ? book.coverPath == null
                                        ? AssetImage('images/cover'
                                            '.jpg')
                                        : FileImage(File(book.coverPath))
                                    : FileImage(_newImage)
                                : book.coverPath == null
                                    ? AssetImage('images/cover.jpg')
                                    : FileImage(File(book.coverPath)),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: _editMode ? _editImageButton() : null,
                      ),
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      flex: 3,
                      child: _editMode
                          ? _editTitleForm()
                          : Text(
                              book.name,
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              ),
                            ),
                    )
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: RaisedButton(
                color: colors[3],
                textColor: Colors.white,
                child: Text('Note +',style: TextStyle(fontSize: 17,),),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NewNoteScreen(
                        bookId: book.id,
                      ),
                    ),
                  );
                },
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  border: Border(top: BorderSide()),
                ),
                child: FutureBuilder(
                  future: db.getSections(book.id),
                  builder: (context,snapshot){
                    if(snapshot.hasData){
                      List<Section> sections = snapshot.data;
                      if(sections.length>0){
                        return ListView.builder(
                          itemBuilder: (context,index){
                            return _expansionSection(sections[index]);
                          },
                          itemCount: sections.length,
                        );
                      }
                      return Container(
                        color: colors[3],
                        constraints: BoxConstraints.expand(),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(Icons.note_add,size: 160,color: colors[2],),
                            Text('No notes yet',style: TextStyle(color: colors[2],
                                fontSize: 30,fontWeight: FontWeight.bold),)
                          ],
                        )
                      );
                    }
                    return Container();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _expansionSection(Section section) {
    return FutureBuilder(
        future: db.getNotesOf(book.id,section.id),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Note> notes = snapshot.data;
            return Container(
              color: colors[3],
              child: Theme(
                data: ThemeData(accentColor: Colors.white,fontFamily: 'Cairo'),
                child: ExpansionTile(
                  backgroundColor: colors[3],
                  title: Text(section.name.toString(),style: TextStyle(color: Colors.white),),
                  children: notes.map((note){
                    return Container(
                      color: Colors.grey[200],
                      padding: EdgeInsets.only(left: 25),
                      child: ListTile(
                        title: Text(note.title,style: TextStyle(color: colors[4]),),
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context)
                          =>NoteViewerScreen(note)));
                        },
                        trailing: Text('Page: '+note.pageNum.toString()),
                      ),
                    );
                  }).toList(),
                  trailing: _sectionPopupMenu(section),
                ),
              ),
            );
          }
          return Container();
        });
  }

  Widget _sectionPopupMenu(Section section) {
    return _popupMenu(color:Colors.white,onSelected: (val) async {
      if (val == 'edit') {
        showDialog<String>(
          context:context,
          builder: (context)=>NewSectionForm(sectionName: section.name,)
        ).then((newSectionName)async{
          if(newSectionName==null)return;
          section.name=newSectionName;
          await db.update('sections', section.id, section);
          setState(() {

          });
        });
      } else {
        showDialog<bool>(
          context: context,
          builder: (context) => ConfirmDialog(
            message: 'If you delete this section all its notes will be deleted also, ar '
                'you sure?',
          ),
        ).then((answer) async {
          if (answer) {
            await db.delete('sections', section.id);
            setState(() {

            });
          }
        });
      }
    });
  }

  Widget _popupMenu({Color color,@required Function onSelected}) {
    return PopupMenuButton(
      icon: Icon(Icons.more_vert,color: color),
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
      onSelected: onSelected,
    );
  }
  Widget _bookPopupMenu() {
    return _popupMenu(onSelected: (val){
      if (val == 'edit') {
        setState(() {
          _editMode = true;
        });
      } else {
        showDialog<bool>(
          context: context,
          builder: (context) => ConfirmDialog(
            message: 'Are you sure you want to delete this book?',
          ),
        ).then((answer) async {
          if (answer) {
            await db.delete('books', book.id);
            Navigator.pop(context);
          }
        });
      }
    });
  }
  Widget _editImageButton() {
    return Align(
      alignment: AlignmentDirectional.bottomCenter,
      child: GestureDetector(
        child: Container(
          height: 40,
          width: MediaQuery.of(context).size.width,
          color: Colors.black.withOpacity(.4),
          child: Center(
            child: Text(
              'Change',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
        onTap: () async {
          _newImage = await FilePicker.getFile(type: FileType.image);
          setState(() {});
        },
      ),
    );
  }

  void _cancelEditClick() {
    showDialog<bool>(
        context: context,
        builder: (context) => ConfirmDialog(
              message: 'Do you really want to discard edit?',
            )).then((answer) {
      setState(() {
        _editMode = !answer;
      });
    });
  }

  void _confirmEditClick() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      if (_newImage != null) {
        await File(book.coverPath).delete();
        final directory = await getApplicationDocumentsDirectory();
        book.coverPath = directory.path + '/' + MyImage.getName(_newImage.path);
        await _newImage.copy(book.coverPath);
      }
      await db.update('books', book.id, book);
    }
    setState(() {
      _editMode = false;
    });
  }

  final _formKey = GlobalKey<FormState>();

  Widget _editTitleForm() {
    return Form(
      key: _formKey,
      child: TextFormField(
        decoration: InputDecoration(
          border: InputBorder.none,
          filled: true,
          fillColor: colors[0].withOpacity(.3),
        ),
        initialValue: book.name,
        validator: (val) => val.isEmpty ? 'Enter the name of the book!' : null,
        onSaved: (val) => book.name = val,
      ),
    );
  }
}
