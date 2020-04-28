import 'dart:io';
import 'package:booknote/database.dart';
import 'package:booknote/models/image.dart';
import 'package:booknote/screens/book_viewer.dart';
import 'package:booknote/screens/new_book_form.dart';
import 'package:booknote/shared/confirm_dialog.dart';
import 'package:booknote/shared/const.dart';
import 'package:flutter/material.dart';
import 'package:booknote/models/book.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DatabaseService db = DatabaseService();
  bool _listView = false;
  bool _searching = false;
  String _searchWord = '';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: boxDecoration,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: colors[4],
          title: Text('BookNote'),
          actions: _actions(),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: colors[2],
          child: Icon(Icons.add),
          onPressed: () {
            showDialog<Book>(context: context, builder: (context) => NewBookForm())
                .then((book) async {
              if (book != null) {
                await db.insert('books', book);
                setState(() {});
              }
            });
          },
        ),
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.view_headline,
                    color: _listView ? colors[4] : Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _listView = true;
                    });
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.apps,
                    color: _listView ? Colors.grey : colors[4],
                  ),
                  onPressed: () {
                    setState(() {
                      _listView = false;
                    });
                  },
                )
              ],
            ),
            FutureBuilder(
              future: _searching && _searchWord.isNotEmpty
                  ? db.searchBook(_searchWord)
                  : db.getBooks(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return _booksGrid(snapshot.data);
                }
                return Center(
                  child: Text('You have no books'),
                );
              },
            )
          ],
        ),
      ),
    );
  }

  Widget _booksGrid(List<Book> books) {
    return books.isNotEmpty
        ? Expanded(
            child: Container(
              child: GridView.count(
                padding: EdgeInsets.symmetric(horizontal: 20),
                crossAxisCount: _listView ? 1 : 2,
                scrollDirection: Axis.vertical,
                crossAxisSpacing: 18,
                mainAxisSpacing: 18,
                childAspectRatio: _listView ? 2.5 : 1,
                children: books.map((book) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookViewerScreen(
                              book: book,
                            ),
                          ));
                    },
                    child: _listView
                        ? _largeBook(book)
                        : _smallBook(
                            book,
                          ),
                  );
                }).toList(),
              ),
            ),
          )
        : Center(child: Text('You have no books!'));
  }

  Widget _smallBook(Book book) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(color: Colors.grey, blurRadius: 6, offset: Offset(1, 3)),
        ],
        image: book.coverPath != null
            ? DecorationImage(
                image: FileImage(File(book.coverPath)),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: book.coverPath == null
          ? Center(
              child: Text(
                book.name,
                maxLines: 3,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            )
          : null,
    );
  }

  Widget _largeBook(Book book) {
    return Container(
      //padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(color: Colors.grey, blurRadius: 6, offset: Offset(1, 3)),
        ],
        border: Border.all(color: Colors.grey[400]),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            flex: 5,
            child: Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                    image: book.coverPath == null
                        ? AssetImage('images/cover.jpg')
                        : FileImage(File(book.coverPath)),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(6)),
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
            flex: 6,
            child: Center(
              child: Text(
                book.name,
                style: myThemeData.textTheme.title,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: Colors.red[300],
                  ),
                  onPressed: () {
                    showDialog<bool>(
                        context: context,
                        builder: (context) => ConfirmDialog(
                              message: 'Are you '
                                  'sure?',
                            )).then((val) async {
                      if (val) {
                        MyImage.delete(book.coverPath);
                        await db.delete('books', book.id);
                        setState(() {});
                      }
                    });
                  },
                ),
                Padding(
                  padding: const EdgeInsets.all(7.0),
                  child: Icon(Icons.arrow_forward),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  List<Widget> _actions() {
    return [
      _searching
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: 250,
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child: TextFormField(
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Entere book name',
                    ),
                    cursorColor: Colors.black,
                    onChanged: (val) {
                      setState(() {
                        _searchWord = val;
                      });
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _searching = false;
                    });
                  },
                )
              ],
            )
          : IconButton(
              icon: Icon(
                Icons.search,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _searching = true;
                });
              },
            )
    ];
  }
}
