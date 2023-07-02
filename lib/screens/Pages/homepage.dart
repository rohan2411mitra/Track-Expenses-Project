import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../reusable_widgets/reuse.dart';
import '../../utils/color_utils.dart';
import 'AllTransactions.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser!;

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
              SizedBox(
                height: 326,
                child: welcome(),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Latest Transactions',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                        color: Colors.white70,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Transactions()));
                      },
                      child: const Text(
                        'See all',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Color(0xFFFFFFCC),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5,),
              Expanded(
                child: SizedBox(
                  width: double.infinity,
                  child: transactions(
                      FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.uid)
                          .collection('expenses'),
                      "Date",
                      true),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget balance() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text("Something Went Wrong! ${snapshot.error}"));
        } else if (snapshot.hasData) {
          final incExp = snapshot.data!;
          final inc = incExp['Income'];
          final exp = incExp['Expense'];
          return Column(
            children: [
              const SizedBox(
                height: 12,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Total Balance',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 24,
                          color: Colors.orangeAccent,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      (inc != null && exp != null)
                          ? '\u{20B9} ${(inc - exp).toStringAsFixed(2)}'
                          : "NA",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 26,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 24,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          "Income",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 22,
                            color: Colors.lime,
                          ),
                        ),
                        SizedBox(width: 7),
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: Colors.green,
                          child: Icon(
                            Icons.arrow_downward,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: Colors.red,
                          child: Icon(
                            Icons.arrow_upward,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        SizedBox(width: 7),
                        Text(
                          "Expenses",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 22,
                            color: Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 6,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: SizedBox(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            inc != null ? "\u{20B9} ${inc.toStringAsFixed(2)}" : "NA",
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 17.6,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            exp != null ? "\u{20B9} ${exp.toStringAsFixed(2)}" : "NA",
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 17.6,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  Widget welcome() {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 215,
          decoration: const BoxDecoration(
              color: Colors.purpleAccent,
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20))),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              const Text(
                "Here is your summary",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 31.6,
                    color: Colors.white70),
              ),
              Text(
                FirebaseAuth.instance.currentUser?.displayName ?? "Unknown",
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30.0,
                    color: Colors.white70),
              )
            ],
          ),
        ),
        Positioned(
          top: 135,
          left: 36,
          child: Container(
            height: 175,
            width: 320,
            decoration: BoxDecoration(
                color: Colors.purple, borderRadius: BorderRadius.circular(14)),
            child: balance(),
          ),
        ),
      ],
    );
  }
}
