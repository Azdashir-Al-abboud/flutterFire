import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firstflutterfireproject/categories/edit.dart';
import 'package:firstflutterfireproject/note/add.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class NoteView extends StatefulWidget {
  final String categoryid;
  const NoteView({super.key, required this.categoryid});

  @override
  State<NoteView> createState() => _NoteView();
}

class _NoteView extends State<NoteView> {
  List<QueryDocumentSnapshot> data = [];

  bool isLoading = true;

  getData() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("categories")
        .doc(widget.categoryid)
        .collection("note")
        .get();
    data.addAll(querySnapshot.docs);
    isLoading = false;
    setState(() {});
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => AddNotes(docid: widget.categoryid),
        )),
        child: Icon(Icons.add),
        backgroundColor: Colors.orange,
      ),
      appBar: AppBar(
        title: Text("Notes"),
        actions: [
          IconButton(
            onPressed: () async {
              GoogleSignIn googleSignIn = GoogleSignIn();
              try {
                await googleSignIn.disconnect();
                await FirebaseAuth.instance.signOut();
                Navigator.of(context)
                    .pushNamedAndRemoveUntil("login", (route) => false);
              } catch (e) {
                print(e);
              }
            },
            icon: Icon(Icons.exit_to_app),
          ),
        ],
      ),
      body: PopScope(
        canPop: true,
        onPopInvoked: (didPop) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushNamedAndRemoveUntil(
                context, "homepage", (route) => false);
          });
        },
        child: isLoading == true
            ? Center(
                child: CircularProgressIndicator(),
              )
            : GridView.builder(
                itemCount: data.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, mainAxisExtent: 170),
                itemBuilder: (BuildContext context, int index) {
                  return InkWell(
                    onLongPress: () {
                      AwesomeDialog(
                        context: context,
                        dialogType: DialogType.warning,
                        animType: AnimType.rightSlide,
                        title: 'Warning',
                        desc: 'Delete Category?',
                        btnOkText: "Update",
                        btnOkOnPress: () {
                          // Navigator.of(context).push(MaterialPageRoute(
                          //   builder: (context) => Editcategory(
                          //       docid: data[index].id,
                          //       oldName: data[index]["name"]),
                          // ));
                        },
                        btnCancelText: "Delete",
                        btnCancelOnPress: () async {
                          // await FirebaseFirestore.instance
                          //     .collection("categories")
                          //     .doc(data[index].id)
                          //     .delete();
                          // Navigator.of(context).pushReplacementNamed("NoteView");
                        },
                      ).show();
                    },
                    child: Card(
                      child: Container(
                        padding: EdgeInsets.all(15),
                        child: Column(
                          children: [
                            Text("${data[index]["note"]}"),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
