import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firstflutterfireproject/components/custombuttonauth.dart';
import 'package:firstflutterfireproject/components/customtextfieldadd.dart';
import 'package:firstflutterfireproject/note/view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditNotes extends StatefulWidget {
  final String notedocid;
  final String categoryid;

  const EditNotes(
      {super.key, required this.notedocid, required this.categoryid});

  @override
  State<StatefulWidget> createState() => _EditNotes();
}

class _EditNotes extends State<EditNotes> {
  GlobalKey<FormState> formState = GlobalKey<FormState>();

  TextEditingController note = TextEditingController();

  bool isLoading = false;

  editNotes() async {
    CollectionReference noteCollection = FirebaseFirestore.instance
        .collection('categories')
        .doc(widget.notedocid)
        .collection("note");
    // Call the user's CollectionReference to add a new user

    if (formState.currentState!.validate()) {
      try {
        isLoading = true;
        setState(() {});

        await noteCollection.doc().update({"name": note.text});

        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (context) => NoteView(categoryid: widget.categoryid)),
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
                  CustomButtonAuth(
                    title: "Add",
                    onPressed: () {
                      editNotes();
                    },
                  )
                ],
              ),
      ),
    );
  }
}
