import 'dart:io';
import 'package:booknote/models/image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view_gallery.dart';



class Gallery extends StatelessWidget {

  final List<MyImage> images;
  final int first;
  Gallery(this.images,this.first);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints.expand(),
      child: PhotoViewGallery.builder(
        scrollPhysics: const BouncingScrollPhysics(),
        itemCount: images.length,
        builder: (context, index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: FileImage(File(images[index].path)),
            minScale: .1,
            maxScale: 3.0,
          );
        },
        pageController: PageController(initialPage: first,keepPage: true,),
        enableRotation: true,

      ),
    );
  }

}

