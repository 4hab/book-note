import 'dart:io';

class MyImage{
  String path;
  int id,noteId,bookId,sectionId;

  MyImage();

  Map<String,dynamic> toMap(){
    return {
      'id':id,
      'path':path,
      'section_id':sectionId,
      'book_id':bookId,
      'note_id':noteId,
    };
  }

  MyImage.fromMap(Map<String,dynamic> data){
    id=data['id'];
    path=data['path'];
    noteId=data['note_id'];
    sectionId=data['section_id'];
    bookId=data['book_id'];
  }

  static getName(String path){
    var p = path.split('/');
    return p[p.length-1];
  }

  static delete(String path){
    if(path==null)
      return;
    File img = File(path);
    img.delete();
  }
}