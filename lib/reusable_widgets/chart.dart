import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class Chart extends StatefulWidget {
  const Chart({Key? key}) : super(key: key);

  @override
  State<Chart> createState() => _ChartState();
}

class _ChartState extends State<Chart> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Container(
        width: double.infinity,
        height: 200,
        child: SfCartesianChart(
          backgroundColor: Colors.white,
          primaryXAxis: CategoryAxis(),
          series: <SplineSeries<ExpensesData, String>>[
            SplineSeries<ExpensesData, String>(
              color: Colors.teal,
              width: 3,
              dataSource: <ExpensesData>[
                ExpensesData('Mon', 100),
                ExpensesData('Tue', 200),
                ExpensesData('Wed', 45),
                ExpensesData('Sat', 600)
              ],
              xValueMapper: (ExpensesData sales, _) => sales.year,
              yValueMapper: (ExpensesData sales, _) => sales.amount,
            )
          ],
        ),
      ),
    );
  }
}

class ExpensesData {
  ExpensesData(this.year, this.amount);
  String year;
  int amount;
}