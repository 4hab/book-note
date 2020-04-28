import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'dart:io';

class ImageViewer extends StatelessWidget {
  final image;

  ImageViewer(this.image);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        constraints: BoxConstraints.expand(),
        color: Colors.black,
        child: PhotoView(
          imageProvider: FileImage(File(image.path)),
          minScale: .1,
          maxScale: 4.0,
        ),
      ),
    );
  }
}
