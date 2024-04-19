import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firstflutterfireproject/categories/edit.dart';
import 'package:firstflutterfireproject/note/add.dart';
import 'package:firstflutterfireproject/note/edit.dart';
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
                    child: Card(
                      child: Container(
                        padding: EdgeInsets.all(15),
                        child: Column(
                          children: [
                            Text("${data[index]["note"]}"),
                            SizedBox(
                              height: 7,
                            ),
                            if (data[index]["url"] != "none")
                              Image.network(
                                data[index]["url"],
                                width: 100,
                                height: 100,
                              )
                          ],
                        ),
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => EditNotes(
                          notedocid: data[index].id,
                          categoryid: widget.categoryid,
                          oldNote: data[index]["note"],
                        ),
                      ));
                    },
                    onLongPress: () {
                      AwesomeDialog(
                        context: context,
                        dialogType: DialogType.warning,
                        animType: AnimType.rightSlide,
                        title: 'Warning',
                        desc: 'are you sure you want to delete note?',
                        btnOkText: "Delete",
                        btnOkOnPress: () async {
                          await FirebaseFirestore.instance
                              .collection("categories")
                              .doc(widget.categoryid)
                              .collection("note")
                              .doc(data[index].id)
                              .delete();

                          if (data[index]["url"] != "none") {
                            FirebaseStorage.instance
                                .refFromURL(data[index]["url"])
                                .delete();
                          }
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) =>
                                NoteView(categoryid: widget.categoryid),
                          ));
                        },
                        btnCancelText: "Cancel",
                        btnCancelOnPress: () async {},
                      ).show();
                    },
                  );
                },
              ),
      ),
    );
  }
}
