import 'package:booknote/screens/image_viewer.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:booknote/shared/const.dart';
import 'dart:io';

List<File> _images = List<File>();

List<File> getImagesFiles() => _images;

void deleteImagesFiles() => _images.clear();

class NoteImagesPicker extends StatefulWidget {
  @override
  _NoteImagesPickerState createState() => _NoteImagesPickerState();
}

class _NoteImagesPickerState extends State<NoteImagesPicker> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
      width: MediaQuery.of(context).size.width,
      height: 220,
      color: colors[3],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ButtonTheme(
                minWidth: 50,
                child: FlatButton(
                    child: Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    color: Colors.white,
                    disabledColor: Colors.grey,
                    textColor: colors[3],
                    onPressed: selectedImages.isNotEmpty
                        ? () {
                            _images.removeWhere((file) {
                              return selectedImages.contains(file);
                            });
                            selectedImages.clear();
                            setState(() {});
                          }
                        : null),
              ),
              SizedBox(
                width: 10,
              ),
              ButtonTheme(
                minWidth: 50,
                child: FlatButton(
                    child: Icon(Icons.add),
                    color: Colors.white,
                    textColor: colors[3],
                    onPressed: () async {
                      await _loadImages();
                      setState(() {});
                    }),
              ),
              SizedBox(
                width: 10,
              ),
            ],
          ),
          _images.length > 0
              ? Container(
                  height: 140,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      File img = _images[index];
                      return Row(
                        children: <Widget>[
                          GestureDetector(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: selectedImages.contains(img)
                                    ?Colors.red:Colors.white,
                                    width: 3),
                              ),
                              child: Image.file(img),
                            ),
                            onLongPress: () {
                              _onImageLongPress(img);
                            },
                            onTap: () {
                              if (selectedImages.isNotEmpty) {
                                if (selectedImages.contains(img)) {
                                  selectedImages.remove(img);
                                } else {
                                  selectedImages.add(img);
                                }
                                setState(() {});
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ImageViewer(
                                      File(img.path),
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                          SizedBox(width: 10),
                        ],
                      );
                    },
                    itemCount: _images == null ? 0 : _images.length,
                  ),
                )
              : Center(
                  child: Icon(
                    Icons.camera_alt,
                    size: 120,
                    color: Colors.green[200].withOpacity(.1),
                  ),
                ),
        ],
      ),
    );
  }

  Future<void> _loadImages() async {
    List<File> _newImages = await FilePicker.getMultiFile(type: FileType.image);
    if (_newImages == null) return;
    for (int i = 0; i < _newImages.length; i++) {
      _images.add(_newImages[i]);
    }
  }

  //List<String> selectedImages = List<String>();
  Set<File> selectedImages = Set<File>(); //todo: use map instead,
  void _onImageLongPress(File file) {
    selectedImages.add(file);
    setState(() {});
  }
}
