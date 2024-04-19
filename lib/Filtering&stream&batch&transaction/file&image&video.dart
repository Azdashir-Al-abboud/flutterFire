import 'dart:io';
import 'package:path/path.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class FileStorage extends StatefulWidget {
  const FileStorage({super.key});

  @override
  State<StatefulWidget> createState() => _fileStorage();
}

class _fileStorage extends State<FileStorage> {
  File? file;
  String? url;
  getimage() async {
    final ImagePicker picker = ImagePicker();
// Pick an image.
    final XFile? imageGallery =
        await picker.pickImage(source: ImageSource.gallery);
// Capture a photo.
    // final XFile? imageCamera =
    //     await picker.pickImage(source: ImageSource.camera);
    if (imageGallery != null) {
      file = File(imageGallery.path);
      var imagename = basename(imageGallery.path);

      var refStorage = FirebaseStorage.instance.ref("images").child(imagename);
      await refStorage.putFile(file!);

      url = await refStorage.getDownloadURL();
    }

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Filtering"),
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        child: Container(
          child: Column(
            children: [
              MaterialButton(
                onPressed: () {
                  getimage();
                },
                child: Text("Get Image Camera"),
              ),
              // if (file != null)
              //   Image.file(
              //     file!,
              //     width: 400,
              //     height: 400,
              //   )

              if (url != null)
                Image.network(
                  url!,
                  width: 400,
                  height: 400,
                )
            ],
          ),
        ),
      ),
    );
  }
}
