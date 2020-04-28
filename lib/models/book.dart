
class Book{
  String name,coverPath;
  int id,userId;

  Book([this.name,this.userId]);
  Map<String,dynamic> toMap(){
    return {
      'name': name,
      'user_id':userId,
      'cover_path': coverPath,
    };
  }

  Book.fromMap(Map<String,dynamic> data){
    id=data['id'];
    name=data['name'];
    userId=data['user_id'];
    coverPath=data['cover_path'];
  }
}

Book book1 = Book('book name',1);