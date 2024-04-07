import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firstflutterfireproject/components/custombuttonauth.dart';
import 'package:firstflutterfireproject/components/customlogoauth.dart';
import 'package:firstflutterfireproject/components/textformfield.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  TextEditingController username = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  GlobalKey<FormState> formstate = GlobalKey<FormState>();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    username.dispose();
    email.dispose();
    password.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(20),
        child: ListView(children: [
          Form(
            key: formstate,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 50),
                const CustomLogoAuth(),
                Container(height: 20),
                const Text("SignUp",
                    style:
                        TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                Container(height: 10),
                const Text("SignUp To Continue Using The App",
                    style: TextStyle(color: Colors.grey)),
                Container(height: 20),
                const Text(
                  "username",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Container(height: 10),
                CustomTextForm(
                    hinttext: "ُEnter Your username",
                    mycontroller: username,
                    validator: (val) {
                      if (val == "") {
                        return "Can't be empty";
                      }
                      return null;
                    }),
                Container(height: 20),
                const Text(
                  "Email",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Container(height: 10),
                CustomTextForm(
                    hinttext: "ُEnter Your Email",
                    mycontroller: email,
                    validator: (val) {
                      if (val == "") {
                        return "Can't be empty";
                      }
                      return null;
                    }),
                Container(height: 10),
                const Text(
                  "Password",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Container(height: 10),
                CustomTextForm(
                    hinttext: "ُEnter Your Password",
                    mycontroller: password,
                    validator: (val) {
                      if (val == "") {
                        return "Can't be empty";
                      }
                      return null;
                    }),
                Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 20),
                  alignment: Alignment.topRight,
                  child: const Text(
                    "Forgot Password ?",
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          CustomButtonAuth(
              title: "SignUp",
              onPressed: () async {
                if (formstate.currentState!.validate()) {
                  showDialog(
                    context: context,
                    builder: (context) => Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                  try {
                    // ignore: unused_local_variable
                    final credential = await FirebaseAuth.instance
                        .createUserWithEmailAndPassword(
                      email: email.text,
                      password: password.text,
                    );
                    FirebaseAuth.instance.currentUser!.sendEmailVerification();
                    AwesomeDialog(
                      context: context,
                      dialogType: DialogType.error,
                      animType: AnimType.rightSlide,
                      title: 'Error',
                      desc: 'verification link sent to your email.',
                      // btnCancelOnPress: () {},
                      // btnOkOnPress: () {},
                    ).show();
                    Navigator.pop(context);
                    Navigator.of(context).pushReplacementNamed("login");
                  } on FirebaseAuthException catch (e) {
                    Navigator.pop(context);
                    if (e.code == 'weak-password') {
                      AwesomeDialog(
                        context: context,
                        dialogType: DialogType.error,
                        animType: AnimType.rightSlide,
                        title: 'Error',
                        desc: 'The password provided is too weak.',
                        // btnCancelOnPress: () {},
                        // btnOkOnPress: () {},
                      ).show();
                    } else if (e.code == 'email-already-in-use') {
                      Navigator.pop(context);
                      AwesomeDialog(
                        context: context,
                        dialogType: DialogType.error,
                        animType: AnimType.rightSlide,
                        title: 'Error',
                        desc: 'The account already exists for that email.',
                        // btnCancelOnPress: () {},
                        // btnOkOnPress: () {},
                      ).show();
                    } else {
                      AwesomeDialog(
                        context: context,
                        dialogType: DialogType.error,
                        animType: AnimType.rightSlide,
                        title: 'Error',
                        desc: 'Somthing went wrong please try again later.',
                        // btnCancelOnPress: () {},
                        // btnOkOnPress: () {},
                      ).show();
                    }
                  }
                }
              }),
          Container(height: 20),

          Container(height: 20),
          // Text("Don't Have An Account ? Resister" , textAlign: TextAlign.center,)
          InkWell(
            onTap: () {
              Navigator.of(context).pushNamed("login");
            },
            child: const Center(
              child: Text.rich(TextSpan(children: [
                TextSpan(
                  text: "Have An Account ? ",
                ),
                TextSpan(
                    text: "Login",
                    style: TextStyle(
                        color: Colors.orange, fontWeight: FontWeight.bold)),
              ])),
            ),
          )
        ]),
      ),
    );
  }
}
