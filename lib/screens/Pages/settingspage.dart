import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:track_exp/screens/signin_screen.dart';
import '../../utils/color_utils.dart';
import './Categories.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              hexStringToColor("333333"),
              hexStringToColor("444444"),
              hexStringToColor("555555")
            ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              height: 300,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: ListView(
                physics: const NeverScrollableScrollPhysics(),
                children: <Widget>[
                  ListTile(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                      textColor: Colors.white,
                      trailing: const Icon(
                        Icons.keyboard_arrow_right,
                        color: Colors.white,
                      ),
                      title: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 5,horizontal: 2),
                        child: Text("Categories" , style: TextStyle(fontSize: 20,fontWeight: FontWeight.w500),),
                    ),
                    onTap: handleCategories,
                  ),
                  ListTile(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                      textColor: Colors.white,
                      trailing: const Icon(
                        Icons.keyboard_arrow_right,
                        color: Colors.white,
                      ),
                      title: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 5,horizontal: 2),
                        child: Text("User Details" , style: TextStyle(fontSize: 20,fontWeight: FontWeight.w500),),
                      )
                  ),
                  ListTile(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                      textColor: Colors.white,
                      trailing: const Icon(
                        Icons.keyboard_arrow_right,
                        color: Colors.white,
                      ),
                      title: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 5,horizontal: 2),
                        child: Text("Erase All Data" , style: TextStyle(fontSize: 20,fontWeight: FontWeight.w500, color: Colors.red),),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                    textColor: Colors.white,
                    trailing: const Icon(
                      Icons.keyboard_arrow_right,
                      color: Colors.white,
                    ),
                    title: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 5,horizontal: 2),
                      child: Text("Logout" , style: TextStyle(fontSize: 20,fontWeight: FontWeight.w500),),
                    ),
                    onTap: () {
                      showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context)=> Center(child: CircularProgressIndicator())
                      );

                      FirebaseAuth.instance.signOut().then((value) =>
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => SignInScreen()),
                                (route) => false,
                          )
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
                        Navigator.of(context).pop();
                      });

                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void handleCategories(){
    Navigator.push(context, MaterialPageRoute(builder: (context) => Categories()));
  }

  Widget _buildAlertDialog(BuildContext context) {
    return AlertDialog(
      title: Text('Erase All Data'),
      content: Text('Are you sure you want to delete all transaction history ?', style: TextStyle(fontSize: 20),),
      actions: [
        TextButton(
          child: const Text('Cancel', style: TextStyle(fontSize: 16),),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('Confirm', style: TextStyle(fontSize: 16),),
          onPressed: () async {
            final user = FirebaseAuth.instance.currentUser;
            final CollectionReference expensesRef = FirebaseFirestore.instance.collection('users').doc(user!.uid).collection("expenses");
            final QuerySnapshot querySnapshot = await expensesRef.get();
            final List<DocumentSnapshot> documents = querySnapshot.docs;
            for (DocumentSnapshot document in documents) {
              await document.reference.delete();
            }

            final DocumentReference balanceRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
            balanceRef.update({
              'Income' : 0,
              'Expense' : 0,
            });

            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }


}
