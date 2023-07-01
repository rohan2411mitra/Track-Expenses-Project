import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:track_exp/reusable_widgets/reuse.dart';
import 'package:track_exp/screens/home_screen.dart';
import '../../utils/color_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddTransactions extends StatefulWidget {
  const AddTransactions({Key? key}) : super(key: key);

  @override
  State<AddTransactions> createState() => _AddTransactionsState();
}

class _AddTransactionsState extends State<AddTransactions> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _dateController = TextEditingController();
  final categories = ["Work", "Personal", "Transport", "Food"];
  final methods = ["Cash", "Card", "Online", "Bank"];
  String _selectedCategory = "Work";
  String _selectedMethod = "Cash";
  String _type = "Income";
  DateTime _enteredDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
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
              child: SingleChildScrollView(
                child: SizedBox(
                  height: 590,
                  child: Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 180,
                        decoration: const BoxDecoration(
                            color: Colors.deepOrange,
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(20),
                                bottomRight: Radius.circular(20))),
                        padding: const EdgeInsets.all(10.0),
                        child: const Center(
                          child: Text(
                            "Add Your Transaction",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 32.0,
                                color: Colors.white70),
                          ),
                        ),
                      ),
                      Positioned(top: 135, left: 14, child: form()),
                    ],
                  ),
                ),
              )),
        ),
      ),
    );
  }

  //Input Fields
  Widget form() {
    return Container(
      width: 365,
      height: 435,
      decoration: BoxDecoration(
          color: Colors.pink, borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Amount:',
                  style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                SizedBox(
                  width: 180,
                  child: TextField(
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Enter Amount',
                      hintStyle: TextStyle(color: Colors.white60),
                    ),
                    cursorColor: Colors.white,
                    controller: _amountController,
                    style: const TextStyle(fontSize: 20.0, color: Colors.white),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Type:',
                  style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                SizedBox(
                    width: 210,
                    child: Column(
                      // crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RadioListTile(
                          value: "Income",
                          groupValue: _type,
                          title: const Text(
                            "Income",
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _type = value.toString();
                            });
                          },
                          activeColor: Colors.white,
                        ),
                        RadioListTile(
                          value: "Expense",
                          groupValue: _type,
                          title: const Text(
                            "Expense",
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _type = value.toString();
                            });
                          },
                          activeColor: Colors.white,
                        ),
                      ],
                    )),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Note:',
                  style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                SizedBox(
                  width: 180,
                  child: TextField(
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Enter Note',
                      hintStyle: TextStyle(color: Colors.white60),
                    ),
                    cursorColor: Colors.white,
                    controller: _noteController,
                    style: const TextStyle(fontSize: 20.0, color: Colors.white),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Date:',
                  style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                SizedBox(
                    width: 180,
                    child: TextField(
                      decoration: InputDecoration(
                        icon: const Icon(
                          Icons.calendar_today,
                          color: Colors.white,
                        ),
                        border: InputBorder.none,
                        hintText: DateFormat('dd/MM/yy')
                            .format(DateTime.now().toLocal()),
                        hintStyle: const TextStyle(color: Colors.white70),
                      ),
                      readOnly: true,
                      onTap: datePick,
                      cursorColor: Colors.white,
                      controller: _dateController,
                      style:
                          const TextStyle(fontSize: 20.0, color: Colors.white),
                    )),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Category:',
                  style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                SizedBox(
                  width: 190,
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                    ),
                    value: _selectedCategory,
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value!;
                      });
                    },
                    dropdownColor: Colors.black,
                    items: categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(
                          category,
                          style: const TextStyle(
                            fontSize: 20.0,
                            color: Colors.white,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Payment By:',
                  style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                SizedBox(
                  width: 190,
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                    ),
                    value: _selectedMethod,
                    onChanged: (value) {
                      setState(() {
                        _selectedMethod = value!;
                      });
                    },
                    dropdownColor: Colors.black,
                    items: methods.map((method) {
                      return DropdownMenuItem(
                        value: method,
                        child: Text(
                          method,
                          style: const TextStyle(
                            fontSize: 20.0,
                            color: Colors.white,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return _buildAlertDialog(context);
                  },
                );
              },
              icon: const Icon(Icons.check),
              label: const Text("Confirm"),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  textStyle: const TextStyle(color: Colors.white70)),
            )
          ],
        ),
      ),
    );
  }

  void datePick() async {
    DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(), //get today's date
        firstDate: DateTime(
            2000), //DateTime.now() - not to allow to choose before today.
        lastDate: DateTime.now());
    if (pickedDate != null) {
      print("picked date =$pickedDate");
      setState(() {
        _dateController.text =
            DateFormat('dd/MM/yy').format(pickedDate.toLocal());
        _enteredDate = pickedDate;
      });
    }
  }

  //Alert Dialog Box
  Widget _buildAlertDialog(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Transaction'),
      content: const Text(
        'Are you sure you want to add the transaction ?',
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
          onPressed: () {
            if (double.tryParse(_amountController.text) == null) {
              snackBar(context, "Amount must be a Valid Number", "red");
              FocusScope.of(context).unfocus();
              Navigator.of(context).pop();
            } else if (_noteController.text.trim() == "") {
              snackBar(
                  context, "Please enter some Note for Transaction", "red");
              FocusScope.of(context).unfocus();
              Navigator.of(context).pop();
            } else {
              addUserExpense(
                  double.parse(_amountController.text),
                  _type,
                  _noteController.text.trim(),
                  _enteredDate,
                  _selectedCategory,
                  _selectedMethod);
            }
          },
        ),
      ],
    );
  }

  //Add data to Firebase function
  Future<void> addUserExpense(double amount, String type, String note,
      DateTime datetime, String category, String method) async {
    User? user = FirebaseAuth.instance.currentUser;
    String? uid = user?.uid;

    if (user == null || uid == null) {
      return;
    }

    // Create a new document with the user ID as the document ID
    DocumentReference expensesRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('expenses')
        .doc();

    // Set the data for the document
    await expensesRef.set({
      'Amount': double.parse(amount.toStringAsFixed(2)),
      'Payment_Type': type,
      'Date': datetime,
      'Note': note,
      'Category': category,
      'Pay_Method': method
    }).then((value) {
      DocumentReference balanceRef =
          FirebaseFirestore.instance.collection('users').doc(uid);
      balanceRef.update({
        'Income': FieldValue.increment((type == "Income") ? amount : 0),
        'Expense': FieldValue.increment((type == "Expense") ? amount : 0),
      });
      snackBar(context, "Transaction Added Successfully", "green");
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const HomeScreen()));
    });
    print("Added Expense Data");
  }
}
