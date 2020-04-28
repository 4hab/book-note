class Note{
  String title,content;
  int pageNum,id,bookId,sectionId;
  Note();

  Map<String,dynamic> toMap(){
    return {
      'title':title,
      'page_num': pageNum,
      'content': content,
      'book_id':bookId,
      'section_id':sectionId,
    };
  }

  Note.fromMap(Map<String,dynamic> data){
    id=data['id'];
    bookId=data['book_id'];
    sectionId=data['section_id'];
    pageNum=data['page_num'];
    title=data['title'];
    content=data['content'];
  }


}

Note note1 = Note.fromMap({
  'title':'Note 1',
});

Note note2=Note.fromMap({'title': 'Note 2'});

