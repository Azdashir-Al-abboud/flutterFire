import 'dart:io';
import 'package:path/path.dart';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firstflutterfireproject/components/custombuttonauth.dart';
import 'package:firstflutterfireproject/components/customtextfieldadd.dart';
import 'package:firstflutterfireproject/note/view.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class AddNotes extends StatefulWidget {
  final String docid;

  const AddNotes({super.key, required this.docid});

  @override
  State<StatefulWidget> createState() => _AddNotes();
}

class _AddNotes extends State<AddNotes> {
  GlobalKey<FormState> formState = GlobalKey<FormState>();

  TextEditingController note = TextEditingController();

  bool isLoading = false;

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

  AddNotes(context) async {
    CollectionReference noteCollection = FirebaseFirestore.instance
        .collection('categories')
        .doc(widget.docid)
        .collection("note");
    // Call the user's CollectionReference to add a new user

    if (formState.currentState!.validate()) {
      try {
        isLoading = true;
        setState(() {});
        DocumentReference response =
            await noteCollection.add({"note": note.text, "url": url ?? "none"});
        //Called also null operator. This operator returns expression on its left,
        //except if it is null, and if so, it returns right expression:
        // for more information visit :https://jelenaaa.medium.com/what-are-in-dart-df1f11706dd6

        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (context) => NoteView(categoryid: widget.docid)),
        );
      } catch (e) {
        isLoading = false;
        setState(() {});
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.rightSlide,
          title: 'Error',
          desc: 'Somethig went wrong please try again later.',
        ).show();
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    note.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Note"),
      ),
      body: Form(
        key: formState,
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(20),
                    child: CustomTextFieldAdd(
                      hinttext: "Enter Your Note",
                      mycontroller: note,
                      validator: (val) {
                        if (val == "") {
                          return "Can't be Empty";
                        }
                        return null;
                      },
                    ),
                  ),
                  CustomButtonUpload(
                    title: "Upload Image",
                    isSelected: url == null ? false : true,
                    onPressed: () {
                      getimage();
                    },
                  ),
                  CustomButtonAuth(
                    title: "Add",
                    onPressed: () {
                      AddNotes(context);
                    },
                  )
                ],
              ),
      ),
    );
  }
}
