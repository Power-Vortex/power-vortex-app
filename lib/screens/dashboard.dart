import 'package:flutter/material.dart';
import '../obj/ui.dart';
import '../global.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';
import '../obj/objects.dart';
import '../database/collections.dart';

class DashBoard extends StatefulWidget {
  UIComponents ui;
  DashBoard({super.key, required this.ui});

  @override
  State<DashBoard> createState() => _DashBoardState(ui);
}

class _DashBoardState extends State<DashBoard> {
  Future runTimer() async {
    Timer.periodic(Duration(seconds: 5), (timer) async {
      //await getHomeDetails(0);
      setState(() {});
    });
  }

  void timedChecker() {
    var c = 0.0;
    Timer.periodic(Duration(seconds: 5), (timer) {
      if (c != userdetails.homes[homeIndex].totalconsumption && mounted)
        setState(() {});
      c = userdetails.homes[homeIndex].totalconsumption;
      if (!mounted) timer.cancel();
      // print(c);
    });
  }

  @override
  void initState() {
    if (userdetails.homes.isNotEmpty) {
      timedChecker();
      //temp.sort();
      temp.addAll(userdetails.homes[homeIndex].consumptionHistory);
      temp.sort();
      maxval = ((double.parse(temp.last.toString()) ~/ 100) + 1) * 100;
      print(maxval);
    }
    super.initState();

    //runTimer();
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<BarChartGroupData> _chartGroups() {
    return List.generate(
        7,
        (_index) => BarChartGroupData(x: _index, barRods: [
              BarChartRodData(
                color: ui.yellow,
                toY: userdetails.homes[homeIndex].consumptionHistory[_index] *
                    1.0,
                width: 40,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30)),
              )
            ]));
  }

  UIComponents ui = UIComponents();
  _DashBoardState(this.ui);
  double maxval = 100;
  List temp = [];
  @override
  Widget build(BuildContext context) {
    print(userdetails.homes[homeIndex].consumptionHistory);
    return SingleChildScrollView(
      child: Center(
        child: userdetails.homes.isEmpty
            ? Text('no data')
            : Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.fromLTRB(20, 20, 0, 30),
                    alignment: Alignment.centerLeft,
                    child: Text('Predicted Bill ',
                        style: TextStyle(
                          color: ui.textcolor,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        )),
                  ),
                  Container(
                    child: Text(
                        '${userdetails.homes[homeIndex].getCost().round()} ₹',
                        style: TextStyle(
                          color: ui.yellow,
                          fontSize: 66,
                          fontWeight: FontWeight.bold,
                        )),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(20, 20, 0, 30),
                    alignment: Alignment.centerLeft,
                    child: Text('This Week',
                        style: TextStyle(
                          color: ui.textcolor,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        )),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(20, 20, 20, 30),
                    height: 300,
                    child: //create a barchart using the fl_chart package
                        BarChart(
                      BarChartData(
                        maxY: maxval,
                        minY: 0,
                        barTouchData: BarTouchData(
                            touchTooltipData: BarTouchTooltipData(
                                tooltipBgColor: ui.primarySwatch,
                                getTooltipItem:
                                    (group, groupIndex, rod, rodIndex) {
                                  return BarTooltipItem(
                                      rod.toY.toString() + ' Wh',
                                      TextStyle(
                                        color: ui.textcolor,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ));
                                })),
                        barGroups: _chartGroups(),
                        borderData: FlBorderData(
                            border: Border(
                                bottom: BorderSide(color: ui.textcolor, width: 2),
                                left: BorderSide(color: ui.textcolor, width: 2))),
                        gridData: FlGridData(
                            show: true,
                            drawHorizontalLine: true,
                            drawVerticalLine: false),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(sideTitles: _bottomTitles),
                          leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                            showTitles: true,
                            interval: maxval / 5,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              return Text(value.toInt().toString(),
                                  style: TextStyle(
                                    color: ui.textcolor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ));
                            },
                          )),
                          topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  SideTitles get _bottomTitles => SideTitles(
        showTitles: true,
        getTitlesWidget: (value, meta) {
          String text = '';
          switch (value.toInt()) {
            case 0:
              text = 'Sun';
              break;
            case 1:
              text = 'Mon';
              break;
            case 2:
              text = 'Tue';
              break;
            case 3:
              text = 'Wed';
              break;
            case 4:
              text = 'Thu';
              break;
            case 5:
              text = 'Fri';
              break;
            case 6:
              text = 'Sat';
              break;
          }

          return Text(
            text,
            style: TextStyle(
              color: ui.textcolor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          );
        },
      );
}
