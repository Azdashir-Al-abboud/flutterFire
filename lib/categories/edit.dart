import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firstflutterfireproject/components/custombuttonauth.dart';
import 'package:firstflutterfireproject/components/customtextfieldadd.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Editcategory extends StatefulWidget {
  final String docid;
  final String oldName;
  const Editcategory({super.key, required this.docid, required this.oldName});
  @override
  State<StatefulWidget> createState() => _Editcategory();
}

class _Editcategory extends State<Editcategory> {
  GlobalKey<FormState> formState = GlobalKey<FormState>();

  TextEditingController name = TextEditingController();

  CollectionReference categories =
      FirebaseFirestore.instance.collection('categories');

  bool isLoading = false;

  editcategory() async {
    if (formState.currentState!.validate()) {
      try {
        isLoading = true;
        setState(() {});
        await categories.doc(widget.docid).update({"name": name.text});

        /**
         * Set: have two function
         * 1- update {merge = false or merge =true}
         * 2- add if document wasn't found
         * 
         * Ex:
           await categories.doc("14691561").set(
            {"name": name.text, "id": FirebaseAuth.instance.currentUser!.uid});
            or:
            await categories.doc("14691561").set({"name": name.text},SetOptions(merge: true));
            SetOptions(merge: true) : don't remove any document

         */

        Navigator.of(context).pushNamedAndRemoveUntil(
          "homepage",
          (route) => false,
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
    name.text = widget.oldName;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    name.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Category"),
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
                      hinttext: "Enter Name",
                      mycontroller: name,
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
                      editcategory();
                    },
                  )
                ],
              ),
      ),
    );
  }
}
