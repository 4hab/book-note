
class Section{
  String name;
  int id,bookId;
  Section(this.name,this.bookId);

  Map<String,dynamic> toMap(){
    return {
      'name':name,
      'book_id': bookId,
    };
  }

  Section.fromMap(Map<String,dynamic> data){
    name=data['name'];
    id=data['id'];
    bookId=data['book_id'];
  }

}

Section section1 = Section('Stories',1);