import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class Chart extends StatefulWidget {
  final String method;
  final String sortBy;
  const Chart({Key? key, required this.method, required this.sortBy})
      : super(key: key);

  @override
  State<Chart> createState() => _ChartState();
}

class _ChartState extends State<Chart> {
  final user = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    final CollectionReference expensesRef = FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("expenses");
    return StreamBuilder(
        stream: expensesRef
            .where(widget.method, isEqualTo: widget.sortBy)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
                child: Text("Something Went Wrong! ${snapshot.error}"));
          } else if (snapshot.hasData) {
            final transactions = snapshot.data!;
            if (transactions.docs.isEmpty) {
              return const SizedBox(
                height: 220,
                width: double.infinity,
                child: Center(
                  child: Text(
                    "No Transactions of this kind yet!",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            } else {
              // List<ExpensesData> transactions = expenses.docs.map((doc) => ExpensesData(DateFormat('dd/MM/yyyy').format(doc['Date'].toDate().toLocal()),doc['Amount'])).toList();
              List<ExpensesData> income = [];
              List<ExpensesData> expenses = [];

              for (var doc in transactions.docs) {
                if (doc['Payment_Type'] == "Income") {
                  income.add(ExpensesData(
                      DateFormat('dd/MM/yy')
                          .format(doc['Date'].toDate().toLocal()),
                      doc['Amount']));
                } else {
                  expenses.add(ExpensesData(
                      DateFormat('dd/MM/yy')
                          .format(doc['Date'].toDate().toLocal()),
                      doc['Amount']));
                }
              }
              expenses.sort((a, b) => a.date.compareTo(b.date));
              income.sort((a, b) => a.date.compareTo(b.date));

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: SizedBox(
                  width: double.infinity,
                  height: 220,
                  child: SfCartesianChart(
                    margin: const EdgeInsets.fromLTRB(2, 6, 2, 0),
                    backgroundColor: Colors.white,
                    primaryXAxis: CategoryAxis(
                        title: AxisTitle(
                            text: "Date",
                            textStyle: const TextStyle(
                                fontSize: 10, fontWeight: FontWeight.bold))),
                    primaryYAxis: NumericAxis(
                        title: AxisTitle(
                            text: "Amount ( In \u{20B9} )",
                            textStyle: const TextStyle(
                                fontSize: 10, fontWeight: FontWeight.bold))),
                    series: <LineSeries<ExpensesData, String>>[
                      LineSeries<ExpensesData, String>(
                        name: 'Income',
                        color: Colors.green,
                        width: 3,
                        dataSource: income,
                        xValueMapper: (ExpensesData sales, _) => sales.date,
                        yValueMapper: (ExpensesData sales, _) => sales.amount,
                        markerSettings: const MarkerSettings(
                            isVisible: true,
                            color: Colors
                                .greenAccent // set this to 'true' to hide the marker
                            ),
                      ),
                      LineSeries<ExpensesData, String>(
                        name: 'Expenses',
                        color: Colors.red,
                        width: 3,
                        dataSource: expenses,
                        xValueMapper: (ExpensesData sales, _) => sales.date,
                        yValueMapper: (ExpensesData sales, _) => sales.amount,
                        markerSettings: const MarkerSettings(
                            isVisible: true,
                            color: Colors
                                .amber // set this to 'true' to hide the marker
                            ),
                      )
                    ],
                    legend: const Legend(
                      isVisible: true,
                      position: LegendPosition.top,
                    ),
                  ),
                ),
              );
            }
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }
}

class ExpensesData {
  ExpensesData(this.date, this.amount);
  String date;
  double amount;
}
