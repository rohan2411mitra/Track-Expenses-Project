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
            .orderBy("Date", descending: false)
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
                      doc['Date'].toDate().toLocal(), doc['Amount']));
                } else {
                  expenses.add(ExpensesData(
                      doc['Date'].toDate().toLocal(), doc['Amount']));
                }
              }

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: SizedBox(
                  width: double.infinity,
                  height: 220,
                  child: SfCartesianChart(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    backgroundColor: Colors.white70,
                    borderColor: Colors.black,
                    borderWidth: 1.4,
                    primaryXAxis: DateTimeAxis(
                        rangePadding: ChartRangePadding.round,
                        majorGridLines:
                            const MajorGridLines(color: Colors.blueGrey),
                        maximumLabels: 2,
                        dateFormat: DateFormat('dd, MMM, yy'),
                        desiredIntervals: 5,
                        edgeLabelPlacement: EdgeLabelPlacement.shift),
                    primaryYAxis: NumericAxis(
                        rangePadding: ChartRangePadding.auto,
                        majorGridLines:
                            const MajorGridLines(color: Colors.blueGrey),
                        labelFormat: '\u{20B9} {value}'),
                    series: <LineSeries<ExpensesData, DateTime>>[
                      LineSeries<ExpensesData, DateTime>(
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
                      LineSeries<ExpensesData, DateTime>(
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
  DateTime date;
  double amount;
}
