import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../reusable_widgets/chart.dart';
import '../../utils/color_utils.dart';

class ShowExpenses extends StatefulWidget {
  const ShowExpenses({Key? key}) : super(key: key);

  @override
  State<ShowExpenses> createState() => _ShowExpensesState();
}

class _ShowExpensesState extends State<ShowExpenses> {
  List option = ['Category Wise','Payment Wise'];
  int indexcolor = 0;
  List catoption = ['Personal','Business','Food'];
  int catindexcolor = 0;
  List payoption = ['Cash','Card','Online'];
  int payindexcolor = 0;
  List sets = ['Category','Pay_Method'];
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
                height: 388,
                decoration: const BoxDecoration(
                    color: Colors.lightBlueAccent,
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(15),
                        bottomRight: Radius.circular(15))),
              ),
              Column(
                children: [
                  const SizedBox(
                    height: 12,
                  ),
                  const Text(
                    'Statistics',
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
                                  indexcolor = index;
                                  selectedButtonSet=sets[index];
                                  payindexcolor=0;
                                  catindexcolor=0;
                                });
                              },
                              child: Container(
                                height: indexcolor == index ? 50 : 40,
                                width: indexcolor == index ? 170 : 130,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: indexcolor == index
                                      ? Colors.deepPurple
                                      : Colors.deepPurple.shade300,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  option[index],
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: indexcolor == index ? 18 : 16,
                                      fontWeight: indexcolor == index
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
                  if (selectedButtonSet=="Category") categoryButtons() else paymentButtons(),
                  const SizedBox(
                    height: 10,
                  ),
                  Chart(method: sets[indexcolor], sortby: (indexcolor==0) ? catoption[catindexcolor] : payoption[payindexcolor]),
                  const SizedBox(
                    height: 8,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Top Amount',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          onPressed: _toggleSortOrder,
                          icon: const Icon(
                            Icons.swap_vert,
                            size: 25,
                            color: Color(0xFFFFFFCC),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SizedBox(
                      width: double.infinity,
                      child: transactions()
                    ),
                  )
                ],
              ),
            ])),
      ),
    );
  }

  Widget transactions() {
    final CollectionReference expenses = FirebaseFirestore.instance.collection('users').doc(user.uid).collection('expenses');
    return StreamBuilder(
      stream: expenses.orderBy('Amount', descending: _descending).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text("Something Went Wrong! ${snapshot.error}"));
        } else if (snapshot.hasData) {
          final expenses = snapshot.data!;

          if (expenses.docs.isEmpty){
            return const Center(
              child: Text(
                "No Transaction added yet!",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            );
          }

          else{
            return ListView.builder(
              itemCount: expenses.docs.length,
              itemBuilder: (BuildContext context, int index) {
                final DocumentSnapshot transaction = expenses.docs[index];

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10,vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: ListTile(

                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                    textColor: Colors.black,
                    leading: Image.asset(
                        "assets/images/${transaction["Pay_Method"]}.png", height: 40),
                    title: Text(
                      transaction['Note'],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'For ${transaction['Category']}',
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 12
                          ),
                        ),
                        Text(
                          DateFormat('dd/MM/yyyy').format(transaction['Date'].toDate().toLocal()),
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    trailing: Text(
                      '\$ ${transaction["Amount"]}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 19,
                        color: Colors.red,
                      ),
                    ),
                  ),
                );
              },
            );
          }
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  void _toggleSortOrder() {
    setState(() {
      _descending = !_descending;
    });
  }

  Widget categoryButtons(){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ...List.generate(3, (index) {
            return GestureDetector(
                onTap: () {
                  setState(() {
                    catindexcolor = index;
                  });
                },
                child: Container(
                  height: catindexcolor == index ? 40 : 30,
                  width: catindexcolor == index ? 90 : 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: catindexcolor == index
                        ? Colors.indigo
                        : Colors.blueGrey,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    catoption[index],
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: catindexcolor == index ? 16 : 14,
                        fontWeight: catindexcolor == index
                            ? FontWeight.w700
                            : FontWeight.w500),
                  ),
                ));
          })
        ],
      ),
    );
  }

  Widget paymentButtons(){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ...List.generate(3, (index) {
            return GestureDetector(
                onTap: () {
                  setState(() {
                    payindexcolor = index;
                  });
                },
                child: Container(
                  height: payindexcolor == index ? 40 : 30,
                  width: payindexcolor == index ? 90 : 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: payindexcolor == index
                        ? Colors.indigo
                        : Colors.blueGrey,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    payoption[index],
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: payindexcolor == index ? 16 : 14,
                        fontWeight: payindexcolor == index
                            ? FontWeight.w700
                            : FontWeight.w500),
                  ),
                ));
          })
        ],
      ),
    );
  }

}
