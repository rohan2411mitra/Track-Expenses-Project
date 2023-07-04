import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../reusable_widgets/chart.dart';
import '../../reusable_widgets/reuse.dart';
import '../../utils/color_utils.dart';

class ShowExpenses extends StatefulWidget {
  const ShowExpenses({Key? key}) : super(key: key);

  @override
  State<ShowExpenses> createState() => _ShowExpensesState();
}

class _ShowExpensesState extends State<ShowExpenses> {
  List option = ['Category Wise', 'Payment Wise'];
  int indexColor = 0;
  List catOption = ["Work", "Personal", "Transport", "Food"];
  int catIndexColor = 0;
  List payOption = ["Cash", "Card", "Online", "Bank"];
  int payIndexColor = 0;
  List sets = ['Category', 'Pay_Method'];
  String selectedButtonSet = "Category";
  final user = FirebaseAuth.instance.currentUser!;
  bool _descending = true;

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
            child: Stack(children: [
              Container(
                width: double.infinity,
                height: 408,
                decoration: const BoxDecoration(
                    color: Colors.lightBlueAccent,
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(15),
                        bottomRight: Radius.circular(15))),
              ),
              Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    'Day Wise Statistics',
                    style: TextStyle(
                        color: Color(0xFFFFFFCC),
                        fontSize: 20,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ...List.generate(2, (index) {
                          return GestureDetector(
                              onTap: () {
                                setState(() {
                                  indexColor = index;
                                  selectedButtonSet = sets[index];
                                  payIndexColor = 0;
                                  catIndexColor = 0;
                                });
                              },
                              child: Container(
                                height: indexColor == index ? 46 : 38,
                                width: indexColor == index ? 180 : 144,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: indexColor == index
                                      ? Colors.deepPurple
                                      : Colors.deepPurple.shade300,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  option[index],
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: indexColor == index ? 18 : 16,
                                      fontWeight: indexColor == index
                                          ? FontWeight.w700
                                          : FontWeight.w500),
                                ),
                              ));
                        })
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  if (selectedButtonSet == "Category")
                    categoryButtons()
                  else
                    paymentButtons(),
                  const SizedBox(
                    height: 8,
                  ),
                  Chart(
                      method: sets[indexColor],
                      sortBy: (indexColor == 0)
                          ? catOption[catIndexColor]
                          : payOption[payIndexColor]),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(15, 0, 8, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          (_descending)
                              ? 'Top 10 By Amount'
                              : "Bottom 10 By Amount",
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 20,
                              color: Colors.white70),
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
                            "Amount",
                            _descending)),
                  )
                ],
              ),
            ])),
      ),
    );
  }

  void _toggleSortOrder() {
    setState(() {
      _descending = !_descending;
    });
  }

  Widget categoryButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ...List.generate(4, (index) {
            return Flexible(
              flex: 1,
              child: GestureDetector(
                  onTap: () {
                    setState(() {
                      catIndexColor = index;
                    });
                  },
                  child: Container(
                    height: catIndexColor == index ? 38 : 30,
                    width: catIndexColor == index ? 92 : 82,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: catIndexColor == index
                          ? Colors.indigo
                          : Colors.blueGrey,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      catOption[index],
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: catIndexColor == index ? 16 : 14,
                          fontWeight: catIndexColor == index
                              ? FontWeight.w700
                              : FontWeight.w500),
                    ),
                  )),
            );
          })
        ],
      ),
    );
  }

  Widget paymentButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ...List.generate(4, (index) {
            return Flexible(
              flex: 1,
              child: GestureDetector(
                  onTap: () {
                    setState(() {
                      payIndexColor = index;
                    });
                  },
                  child: Container(
                    height: payIndexColor == index ? 38 : 30,
                    width: payIndexColor == index ? 92 : 82,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: payIndexColor == index
                          ? Colors.indigo
                          : Colors.blueGrey,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      payOption[index],
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: payIndexColor == index ? 16 : 14,
                          fontWeight: payIndexColor == index
                              ? FontWeight.w700
                              : FontWeight.w500),
                    ),
                  )),
            );
          })
        ],
      ),
    );
  }
}
