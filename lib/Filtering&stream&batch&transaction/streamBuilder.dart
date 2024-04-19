import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Streamm extends StatefulWidget {
  const Streamm({super.key});

  @override
  State<StatefulWidget> createState() => _streamBuilder();
}

class _streamBuilder extends State<Streamm> {
  final Stream<QuerySnapshot> userStream =
      FirebaseFirestore.instance.collection('user').snapshots();

  @override
  void initState() {
    // TODO: implement initStates
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Filtering"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.add),
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        child: StreamBuilder<QuerySnapshot>(
          stream: userStream,
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Text('Something went wrong');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text("Loading");
            }

            return InkWell(
              child: ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      // referance: https://firebase.flutter.dev/docs/firestore/usage/
                      DocumentReference documentReference = FirebaseFirestore
                          .instance
                          .collection('users')
                          .doc(snapshot.data!.docs[index].id);

                      FirebaseFirestore.instance
                          .runTransaction((transaction) async {
                        // Get the document
                        DocumentSnapshot snapshot =
                            await transaction.get(documentReference);

                        if (snapshot.exists) {
                          var snapshotData = snapshot.data();
                          if (snapshotData is Map<String, dynamic>) {
                            int money = snapshotData['money'] + 100;
                            transaction
                                .update(documentReference, {"money": money});
                          }
                        }
                      });
                    },
                    child: Card(
                      child: ListTile(
                        title: Text("${snapshot.data!.docs[index]["name"]}"),
                        subtitle: Text("${snapshot.data!.docs[index]["age"]}"),
                        trailing:
                            Text("${snapshot.data!.docs[index]["money"]}\$"),
                      ),
                    ),
                  );
                },
              ),
            );
            // return ListView(
            //   children: snapshot.data!.docs.map((DocumentSnapshot document) {
            //     Map<String, dynamic> data =
            //         document.data()! as Map<String, dynamic>;
            //     return ListTile(
            //       title: Text(data["age"].toString()),
            //       subtitle: Text(data['lang'].toString()),
            //     );
            //   }).toList(),
            // );
          },
        ),
      ),
    );
  }
}
