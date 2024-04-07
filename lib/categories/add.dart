import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firstflutterfireproject/components/custombuttonauth.dart';
import 'package:firstflutterfireproject/components/customtextfieldadd.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddCategory extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AddCategory();
}

class _AddCategory extends State<AddCategory> {
  GlobalKey<FormState> formState = GlobalKey<FormState>();

  TextEditingController name = TextEditingController();

  CollectionReference categories =
      FirebaseFirestore.instance.collection('categories');

  // Call the user's CollectionReference to add a new user
  bool isLoading = false;

  // Future<void> addCategory() {
  //   return categories
  //       .add({
  //         'name': name.text,
  //         'id': FirebaseAuth.instance.currentUser!.uid,
  //       })
  //       .then((value) => print("User Added"))
  //       .catchError((error) => AwesomeDialog(
  //             context: context,
  //             dialogType: DialogType.error,
  //             animType: AnimType.rightSlide,
  //             title: 'Error',
  //             desc: 'Somethig went wrong please try again later.',
  //           ).show());
  // }

  addCategory() async {
    if (formState.currentState!.validate()) {
      try {
        isLoading = true;
        setState(() {});
        DocumentReference response = await categories.add({
          "name": name.text,
          'id': FirebaseAuth.instance.currentUser!.uid,
        });

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
                    title: "Add",
                    onPressed: () {
                      addCategory();
                    },
                  )
                ],
              ),
      ),
    );
  }
}
