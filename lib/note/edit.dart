import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firstflutterfireproject/components/custombuttonauth.dart';
import 'package:firstflutterfireproject/components/customtextfieldadd.dart';
import 'package:firstflutterfireproject/note/view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditNotes extends StatefulWidget {
  final String categoryid;
  final String notedocid;
  final String oldNote;

  const EditNotes(
      {super.key,
      required this.categoryid,
      required this.notedocid,
      required this.oldNote});

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
        .doc(widget.categoryid)
        .collection("note");
    // Call the user's CollectionReference to add a new user

    if (formState.currentState!.validate()) {
      try {
        isLoading = true;
        setState(() {});
        // print("===============================");
        // print(widget.notedocid);
        await noteCollection.doc(widget.notedocid).update({"note": note.text});

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
  void initState() {
    super.initState();
    note.text = widget.oldNote;
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
        title: Text("Edit Note"),
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
                    title: "Save",
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
