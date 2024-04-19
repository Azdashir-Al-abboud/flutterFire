import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Filtering extends StatefulWidget {
  const Filtering({super.key});

  @override
  State<StatefulWidget> createState() => _Filtering();
}

class _Filtering extends State<Filtering> {
  List<QueryDocumentSnapshot> data = [];
  bool isLoading = false;

  getData() async {
    // QuerySnapshot querySnapshot = await FirebaseFirestore.instance
    //     .collection("user")
    //     .where("age", isEqualTo: 26)
    //     .get();
    //  data.addAll(querySnapshot.docs);

    CollectionReference users = FirebaseFirestore.instance.collection("user");
    QuerySnapshot userdata = await users.where("age", isNotEqualTo: 30).get();
    // await users.where("name", isEqualTo: "ali").get();
    // await users.where("lang", arrayContains: "fr").get();
    // await users.where("lang", arrayContainsAny: ["fr", "ar"]).get();
    // await users.orderBy("age", descending: false).get();
    // await users.limit(1).get();
    // await users.orderBy("age").limit(1).get();
    // await users.orderBy("age", descending: false).startAt([26]).get();  // >= 26
    // await users.orderBy("age", descending: true).startAt([26]).get();   //  <=26 reverse work
    // await users.orderBy("age", descending: false).startAfter([26]).get(); // > 26
    // await users.orderBy("age", descending: true).startAfter([26]).get(); // < 26
    // await users.orderBy("age", descending: false).endAt([26]).get(); // <= 26
    // await users.orderBy("age", descending: true).endAt([26]).get(); // >= 26
    // await users.orderBy("age", descending: false).endBefore([26]).get(); // < 26
    // await users.orderBy("age", descending: false).endBefore([26]).get(); // > 26

    userdata.docs.forEach((element) {
      data.add(element);
    });

    isLoading = false;
    setState(() {});

    /**
     * wherein:[ , , ]
     * wherenotin: [ , , ]
     * 
     * arrayContains: "any value"
     * arrayContainsAny: ["","",""]
     */
  }

  batchAdd() {
    CollectionReference users = FirebaseFirestore.instance.collection('user');
    DocumentReference doc1 =
        FirebaseFirestore.instance.collection('user').doc("doc1");
    DocumentReference doc2 =
        FirebaseFirestore.instance.collection('user').doc("doc2");
    DocumentReference doc3 =
        FirebaseFirestore.instance.collection('user').doc("doc3");
    DocumentReference doc4 =
        FirebaseFirestore.instance.collection('user').doc();

    WriteBatch batch = FirebaseFirestore.instance.batch();

    batch.set(doc1, {
      "age": 20,
      "lang": ["en"],
      "money": 5000,
      "name": "ali",
      "phone": "468498484"
    });

    batch.set(doc2, {
      "age": 23,
      "lang": ["fr"],
      "money": 300,
      "name": "suzan",
      "phone": "156164561"
    });

    batch.set(doc3, {
      "age": 29,
      "lang": ["ar"],
      "money": 2222,
      "name": "ola",
      "phone": "546464486"
    });
    batch.set(doc4, {
      "age": 29,
      "lang": ["ar"],
      "money": 2222,
      "name": "ola",
      "phone": "546464486"
    });

    // batch.delete(doc2);
    batch.commit();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Filtering"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          batchAdd();
        },
        child: Icon(Icons.add),
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        child: ListView.builder(
          itemCount: data.length,
          itemBuilder: (BuildContext context, int index) {
            return InkWell(
              onTap: () {
                // referance: https://firebase.flutter.dev/docs/firestore/usage/
                DocumentReference documentReference = FirebaseFirestore.instance
                    .collection('users')
                    .doc(data[index].id);

                FirebaseFirestore.instance.runTransaction((transaction) async {
                  // Get the document
                  DocumentSnapshot snapshot =
                      await transaction.get(documentReference);

                  if (snapshot.exists) {
                    var snapshotData = snapshot.data();
                    if (snapshotData is Map<String, dynamic>) {
                      int money = snapshotData['money'] + 100;
                      transaction.update(documentReference, {"money": money});
                    }
                  }
                }).then((value) {
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil("Filtering", (route) => false);
                });
              },
              child: Card(
                child: ListTile(
                  title: Text(
                    "${data[index]["name"]}",
                    style: TextStyle(fontSize: 26),
                  ),
                  subtitle: Text("age:  ${data[index]["age"]}"),
                  // leading: Text("${data[index]["money"]}"),
                  trailing: Text("${data[index]["money"]} \$"),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
