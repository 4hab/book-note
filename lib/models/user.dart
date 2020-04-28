class User {
  String name,email,password;
  int id;

  User() {
    name = 'username';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
    };
  }
}
