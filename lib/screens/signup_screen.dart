import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:track_exp/utils/color_utils.dart';
import 'package:track_exp/reusable_widgets/reuse.dart';
import 'package:track_exp/screens/home_screen.dart';
import '../main.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final formKey = GlobalKey<FormState>();
  final _userNameTextController = TextEditingController();
  final _emailTextController = TextEditingController();
  final _passwordTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.black54,
          elevation: 0,
          title: const Text(
            "Sign Up",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                hexStringToColor("333333"),
                hexStringToColor("444444"),
                hexStringToColor("555555")
              ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                  20, MediaQuery.of(context).size.height * 0.18, 20, 0),
              child: Form(
                key: formKey,
                child: Column(
                  children: <Widget>[
                    logoWidget("assets/images/Person.png"),
                    const SizedBox(
                      height: 20,
                    ),
                    reusableTextField("Enter Username", Icons.person_outline, false,
                        _userNameTextController, isName: true),
                    const SizedBox(
                      height: 20,
                    ),
                    reusableTextField("Enter Email Id", Icons.person_outline, false,
                        _emailTextController),
                    const SizedBox(
                      height: 20,
                    ),
                    reusableTextField("Enter Password", Icons.lock, true,
                        _passwordTextController),
                    const SizedBox(
                      height: 20,
                    ),
                    signInSignUpButton(context, false, () {
                      final isValid = formKey.currentState!.validate();
                      if (!isValid) return;

                      showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context)=> Center(child: CircularProgressIndicator())
                      );

                      FirebaseAuth.instance.createUserWithEmailAndPassword(email: _emailTextController.text.trim(), password: _passwordTextController.text.trim())
                          .then((value) {
                            value.user!.updateDisplayName(_userNameTextController.text.trim()).then((_) {
                              DocumentReference userPayRef = FirebaseFirestore.instance.collection('users').doc(value.user!.uid);
                              Map<String, dynamic> balance = {
                                'Income' : 0,
                                'Expense' : 0
                              };
                              userPayRef.set(balance).then((value) {
                                print("Created New Account");
                                Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen()));
                              }).catchError((error) {
                                print("Error: ${error.toString()}");
                              });
                            }).catchError((error) {
                              print("Error: ${error.toString()}");
                            });
                          }
                      ).onError((error, stackTrace) {
                        String errorMessage = error.toString().split(']').last;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(errorMessage, textAlign: TextAlign.center),
                            duration: Duration(seconds: 5),
                            backgroundColor: Colors.red,
                          ),
                        );
                        print("Error ${error.toString()}");
                        navigatorKey.currentState!.popUntil((route)=>route.isFirst);
                      });

                    })
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
