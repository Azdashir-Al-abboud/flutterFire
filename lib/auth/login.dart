import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firstflutterfireproject/homepage.dart';
import 'package:flutter/material.dart';
import 'package:firstflutterfireproject/components/custombuttonauth.dart';
import 'package:firstflutterfireproject/components/customlogoauth.dart';
import 'package:firstflutterfireproject/components/textformfield.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  GlobalKey<FormState> formstate = GlobalKey<FormState>();

  bool isLoading = false;

  Future signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    if (googleUser == null) {
      return;
    }
    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    await FirebaseAuth.instance.signInWithCredential(credential);

    Navigator.of(context).pushReplacementNamed("homepage");
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    email.dispose();
    password.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading == true
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Container(
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
                      const Text("Login",
                          style: TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold)),
                      Container(height: 10),
                      const Text("Login To Continue Using The App",
                          style: TextStyle(color: Colors.grey)),
                      Container(height: 20),
                      const Text(
                        "Email",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      Container(height: 10),
                      CustomTextForm(
                          hinttext: "Enter Your Email",
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
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
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
                      InkWell(
                        onTap: () async {
                          if (email.text == "") {
                            AwesomeDialog(
                              context: context,
                              dialogType: DialogType.error,
                              animType: AnimType.rightSlide,
                              title: 'Error',
                              desc: 'Please enter your email',
                            ).show();
                            return;
                          }
                          try {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return Center(
                                      child: CircularProgressIndicator());
                                });
                            await FirebaseAuth.instance
                                .sendPasswordResetEmail(email: email.text);
                            Navigator.pop(context);
                            AwesomeDialog(
                              context: context,
                              dialogType: DialogType.success,
                              animType: AnimType.rightSlide,
                              title: 'Success',
                              desc:
                                  'Please click on the password reset link that was sent to your email.',
                            ).show();
                          } catch (e) {
                            AwesomeDialog(
                              context: context,
                              dialogType: DialogType.info,
                              animType: AnimType.rightSlide,
                              title: 'Info',
                              desc:
                                  'There is no user record corresponding to this identifier.',
                            ).show();
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.only(top: 10, bottom: 20),
                          alignment: Alignment.topRight,
                          child: const Text(
                            "Forgot Password ?",
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                CustomButtonAuth(
                    title: "login",
                    onPressed: () async {
                      if (formstate.currentState!.validate()) {
                        //The validate() method is a part of the FormState class. Every text field in the form has its validator() function called when the validate() method is invoked. The validate() method returns true if all is in order.

                        /**
                         * two ways to show loading
                         * 1. showdialog() as shown below
                         * 2. with boolean variable and invoke setstate()
                         */

                        showDialog(
                          context: context,
                          builder: (context) => Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                        try {
                          // isLoading == true;
                          // setState(() {});
                          final credential = await FirebaseAuth.instance
                              .signInWithEmailAndPassword(
                            email: email.text,
                            password: password.text,
                          );
                          // isLoading == false;
                          // setState(() {});
                          Navigator.pop(context);
                          if (credential.user!.emailVerified) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => HomePage(),
                              ),
                            );
                          } else {
                            AwesomeDialog(
                              context: context,
                              dialogType: DialogType.error,
                              animType: AnimType.rightSlide,
                              title: 'Error',
                              desc:
                                  'Please click on the verification link that was sent to your email.',
                              // autoHide: Duration(seconds: 3)
                              // btnCancelOnPress: () {},
                              // btnOkOnPress: () {},
                            ).show();
                          }
                          // Navigator.of(context).pushReplacementNamed("homepage");
                        } on FirebaseAuthException catch (e) {
                          /* =========================
                  (firebase auth)يوجد الكثير من الأكواد يمكن قرائتها من وصف الحزمة
                  أو فحص الأكواد عن طريق طباعة الكود والعمل بناء على ذلك
                  لأن الأكواد في حالة تحديث مستمر
                  print("============= ${e.code}");
                  ==========================*/

                          if (e.code == 'user-not-found') {
                            Navigator.pop(context);
                            print('No user found for that email.');
                            AwesomeDialog(
                              context: context,
                              dialogType: DialogType.error,
                              animType: AnimType.rightSlide,
                              title: 'Error',
                              desc: 'No user found for that email.',
                              // autoHide: Duration(seconds: 3)
                              // btnCancelOnPress: () {},
                              // btnOkOnPress: () {},
                            ).show();
                          } else if (e.code == 'wrong-password') {
                            Navigator.pop(context);
                            print('Wrong password provided for that user.');
                            AwesomeDialog(
                              context: context,
                              dialogType: DialogType.error,
                              animType: AnimType.rightSlide,
                              title: 'Error',
                              desc: 'Wrong password provided for that user.',
                              // btnCancelOnPress: () {},
                              // btnOkOnPress: () {},
                            ).show();
                          } else if (e.code == 'INVALID_LOGIN_CREDENTIALS') {
                            Navigator.pop(context);
                            AwesomeDialog(
                              context: context,
                              dialogType: DialogType.error,
                              animType: AnimType.rightSlide,
                              title: 'Error',
                              desc: 'Invalid login credentials.',
                              btnCancelOnPress: () {},
                              btnOkOnPress: () {},
                            ).show();
                          }
                        }
                        // Navigator.pop(context);
                      } else {
                        print("Not Valid.");
                      }
                    }),
                Container(height: 20),

                MaterialButton(
                    height: 40,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    color: Colors.red[700],
                    textColor: Colors.white,
                    onPressed: () {
                      signInWithGoogle();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Login With Google  "),
                        Image.asset(
                          "images/4.png",
                          width: 20,
                        )
                      ],
                    )),
                Container(height: 20),
                // Text("Don't Have An Account ? Resister" , textAlign: TextAlign.center,)
                InkWell(
                  onTap: () {
                    Navigator.of(context).pushReplacementNamed("signup");
                  },
                  child: const Center(
                    child: Text.rich(TextSpan(children: [
                      TextSpan(
                        text: "Don't Have An Account ? ",
                      ),
                      TextSpan(
                          text: "Register",
                          style: TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold)),
                    ])),
                  ),
                )
              ]),
            ),
    );
  }
}
