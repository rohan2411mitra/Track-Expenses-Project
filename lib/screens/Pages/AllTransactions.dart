import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:track_exp/reusable_widgets/reuse.dart';
import '../../utils/color_utils.dart';

class Transactions extends StatefulWidget {
  const Transactions({Key? key}) : super(key: key);

  @override
  State<Transactions> createState() => _TransactionsState();
}

class _TransactionsState extends State<Transactions> {
  final user = FirebaseAuth.instance.currentUser!;
  bool _descending = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          "All Transactions",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            FocusScope.of(context).unfocus();
            Navigator.maybePop(context);
          },
        ),
      ),
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
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 5, 8, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'All Transactions Till Date',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                        color: Colors.white70,
                      ),
                    ),
                    IconButton(
                      onPressed: _toggleSortOrder,
                      icon: const Icon(
                        Icons.swap_vert,
                        size: 26,
                        color: Color(0xFFFFFFCC),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SizedBox(
                  width: double.infinity,
                  child: transactions(
                      FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.uid)
                          .collection('expenses'),
                      "Date",
                      _descending,
                      condition: false),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _toggleSortOrder() {
    setState(() {
      _descending = !_descending;
    });
  }
}
