import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firstflutterfireproject/components/custombuttonauth.dart';
import 'package:firstflutterfireproject/components/customtextfieldadd.dart';
import 'package:firstflutterfireproject/note/view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  AddNotes() async {
    CollectionReference noteCollection = FirebaseFirestore.instance
        .collection('categories')
        .doc(widget.docid)
        .collection("note");
    // Call the user's CollectionReference to add a new user

    if (formState.currentState!.validate()) {
      try {
        isLoading = true;
        setState(() {});
        DocumentReference response = await noteCollection.add({
          "note": note.text,
        });

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
                  CustomButtonAuth(
                    title: "Add",
                    onPressed: () {
                      AddNotes();
                    },
                  )
                ],
              ),
      ),
    );
  }
}
