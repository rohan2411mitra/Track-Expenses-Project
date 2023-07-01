import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:track_exp/reusable_widgets/reuse.dart';
import 'package:track_exp/screens/signin_screen.dart';
import 'package:track_exp/utils/add_profile_image.dart';
import '../../utils/color_utils.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final user = FirebaseAuth.instance.currentUser!;
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
            hexStringToColor("333333"),
            hexStringToColor("444444"),
            hexStringToColor("555555")
          ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
          child: Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              profile(),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  height: 210,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: ListView(
                    physics: const NeverScrollableScrollPhysics(),
                    children: <Widget>[
                      ListTile(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)),
                        textColor: Colors.white,
                        trailing: const Icon(
                          Icons.keyboard_arrow_right,
                          color: Colors.white,
                        ),
                        title: const Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 2),
                          child: Text(
                            "Update Profile Pic",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w500),
                          ),
                        ),
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            builder: ((builder) => bottomSheet()),
                          );
                        },
                      ),
                      ListTile(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)),
                        textColor: Colors.white,
                        trailing: const Icon(
                          Icons.keyboard_arrow_right,
                          color: Colors.white,
                        ),
                        title: const Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 2),
                          child: Text(
                            "Erase All Data",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                color: Colors.red),
                          ),
                        ),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return _buildAlertDialog(context);
                            },
                          );
                        },
                      ),
                      ListTile(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)),
                        textColor: Colors.white,
                        trailing: const Icon(
                          Icons.keyboard_arrow_right,
                          color: Colors.white,
                        ),
                        title: const Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 2),
                          child: Text(
                            "Logout",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w500),
                          ),
                        ),
                        onTap: () {
                          showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => const Center(
                                  child: CircularProgressIndicator()));

                          FirebaseAuth.instance.signOut().then((value) {
                            snackBar(context, "User Logged Out Successfully",
                                "green");
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SignInScreen()),
                              (route) => false,
                            );
                          }).onError((error, stackTrace) {
                            String errorMessage =
                                error.toString().split(']').last;
                            snackBar(context, errorMessage, "red");
                            print("Error ${error.toString()}");
                            Navigator.of(context).pop();
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlertDialog(BuildContext context) {
    return AlertDialog(
      title: const Text('Erase All Data'),
      content: const Text(
        'Are you sure you want to delete all transaction history ?',
        style: TextStyle(fontSize: 20),
      ),
      actions: [
        TextButton(
          child: const Text(
            'Cancel',
            style: TextStyle(fontSize: 16),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text(
            'Confirm',
            style: TextStyle(fontSize: 16),
          ),
          onPressed: () async {
            final user = FirebaseAuth.instance.currentUser;
            final CollectionReference expensesRef = FirebaseFirestore.instance
                .collection('users')
                .doc(user!.uid)
                .collection("expenses");
            final QuerySnapshot querySnapshot = await expensesRef.get();
            final List<DocumentSnapshot> documents = querySnapshot.docs;
            for (DocumentSnapshot document in documents) {
              await document.reference.delete();
            }

            final DocumentReference balanceRef =
                FirebaseFirestore.instance.collection('users').doc(user.uid);
            await balanceRef.update({
              'Income': 0,
              'Expense': 0,
            }).then((value) {
              snackBar(context, "User Transactions Data Erased!", "green");
            });

            if (context.mounted) Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  Future<DateTime> getUserJoiningDate() async {
    DocumentSnapshot document = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    DateTime joiningDate = document['joiningDate'].toDate().toLocal();
    return joiningDate;
  }

  Widget profile() {
    return FutureBuilder(
      future: getUserJoiningDate(),
      builder: (context, snapshot) {
        DateTime joiningDate = snapshot.data ?? DateTime.now();
        if (snapshot.hasError) {
          return Center(child: Text("Something Went Wrong! ${snapshot.error}"));
        } else if (snapshot.hasData) {
          return Column(children: [
            const SizedBox(
              height: 2,
            ),
            _imageFile == null
                ? (user.photoURL == null
                    ? CircleAvatar(
                        radius: 64,
                        backgroundColor: Colors.white70,
                        child: Image.asset("assets/images/Person.png"),
                      )
                    : CircleAvatar(
                        radius: 64,
                        backgroundColor: Colors.white70,
                        backgroundImage: NetworkImage(user.photoURL!),
                      ))
                : CircleAvatar(
                    radius: 64,
                    backgroundColor: Colors.white70,
                    backgroundImage: FileImage(File(_imageFile!.path)),
                  ),
            const SizedBox(
              height: 10,
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              height: 110,
              width: double.infinity,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20), color: Colors.white),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 2),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Name :",
                              style: TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(
                              width: 15,
                            ),
                            Text(
                              user.displayName ?? "Unknown",
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w400),
                            ),
                          ]),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 2),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Email :",
                              style: TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(
                              width: 15,
                            ),
                            Text(
                              user.email ?? "---@---.com",
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w400),
                            ),
                          ]),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 2),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Joined On :",
                              style: TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(
                              width: 15,
                            ),
                            Text(
                              DateFormat('dd/MM/yyyy').format(joiningDate),
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w400),
                            ),
                          ]),
                    )
                  ],
                ),
              ),
            )
          ]);
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  Widget bottomSheet() {
    return Container(
      height: 90.0,
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 10,
      ),
      child: Column(
        children: <Widget>[
          const Text(
            "Choose Profile photo",
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
            ElevatedButton.icon(
              icon: const Icon(Icons.camera),
              onPressed: () {
                takePhoto(ImageSource.camera);
              },
              label: const Text("Camera"),
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.blueGrey),
              ),
            ),
            const SizedBox(width: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.image),
              onPressed: () {
                takePhoto(ImageSource.gallery);
              },
              label: const Text("Gallery"),
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.blueGrey),
              ),
            ),
          ])
        ],
      ),
    );
  }

  void takePhoto(ImageSource source) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()));

    final pickedFile = await _picker.pickImage(
      source: source,
    );

    setState(() {
      _imageFile = pickedFile;
    });

    if (pickedFile != null) {
      await StoreData().saveData(file: File(pickedFile.path).readAsBytesSync());
    }
    // navigatorKey.currentState!.popUntil((route) => route.isFirst);
    if (context.mounted) Navigator.of(context).pop();
    if (context.mounted) Navigator.of(context).pop();
  }
}
