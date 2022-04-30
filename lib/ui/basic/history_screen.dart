import 'package:automat/Constant/const.dart';
import 'package:automat/plugins/reactive_ble/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../plugins/reactive_ble/ble/ble_logger.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Consumer<BleLogger>(
        builder: (context, logger, _) => _DeviceLogTab(
          messages: logger.messages,
        ),
      );
}

class _DeviceLogTab extends StatefulWidget {
  final List<String> messages;
  const _DeviceLogTab({Key? key, required this.messages}) : super(key: key);

  @override
  State<_DeviceLogTab> createState() => _DeviceLogTabState();
}

class _DeviceLogTabState extends State<_DeviceLogTab> {
  List<HistoryModel> kMockUp = [
    HistoryModel(
      date: "02-03-2022",
      time: "15:12",
      taskName: "DP Flushing",
      valueCount: "3523",
    ),
    HistoryModel(
      date: "02-03-2022",
      time: "19:48",
      taskName: "Time Flushing",
      valueCount: "3523",
    ),
    HistoryModel(
      date: "03-03-2022",
      time: "10:28",
      taskName: "Manual Flushing",
      valueCount: "3523",
    ),
    HistoryModel(
      date: "02-03-2022",
      time: "15:12",
      taskName: "Power On",
      valueCount: "3523",
    ),
    HistoryModel(
      date: "02-03-2022",
      time: "15:12",
      taskName: "Power Off",
      valueCount: "3523",
    ),
    HistoryModel(
      date: "02-03-2022",
      time: "15:12",
      taskName: "Looping Error",
      valueCount: "3523",
    ),
  ];
  @override
  void initState() {
    log(widget.messages.toList().toString());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<HistoryModel> kMockUp = [
      HistoryModel(
        date: "02-03-2022",
        time: "15:12",
        taskName: "DP Flushing",
        valueCount: "3523",
      ),
      HistoryModel(
        date: "02-03-2022",
        time: "19:48",
        taskName: "Time Flushing",
        valueCount: "1426",
      ),
      HistoryModel(
        date: "03-03-2022",
        time: "10:28",
        taskName: "Manual Flushing",
        valueCount: "2445",
      ),
      HistoryModel(
        date: "03-03-2022",
        time: "18:39",
        taskName: "Power On",
        valueCount: "----",
      ),
      HistoryModel(
        date: "03-03-2022",
        time: "10:33",
        taskName: "Power Off",
        valueCount: "----",
      ),
      HistoryModel(
        date: "04-03-2022",
        time: "19:52",
        taskName: "Looping Error",
        valueCount: "----",
      ),
    ];

    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          tooltip: "Back",
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: kPrimaryColor,
        centerTitle: true,
        title:
            Image.asset(automatLogo, fit: BoxFit.fill, height: height * 0.07),
      ),
      body: SafeArea(
        child: DataTable(
            horizontalMargin: 5,
            columnSpacing: 26,
            // border: TableBorder.symmetric(
            //     inside: BorderSide(style: BorderStyle.solid, width: 2)),
            columns: const [
              DataColumn(
                  label: Text('S.No.',
                      style: TextStyle(
                          fontSize: 16,
                          color: kPrimaryColor,
                          fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Date',
                      style: TextStyle(
                          fontSize: 16,
                          color: kPrimaryColor,
                          fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Time',
                      style: TextStyle(
                          fontSize: 16,
                          color: kPrimaryColor,
                          fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Task Name',
                      style: TextStyle(
                          fontSize: 16,
                          color: kPrimaryColor,
                          fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Value',
                      style: TextStyle(
                          fontSize: 16,
                          color: kPrimaryColor,
                          fontWeight: FontWeight.bold))),
            ],
            rows: List.generate(
                kMockUp.length,
                (index) => DataRow(cells: [
                      DataCell(Text((index + 1).toString() + ".")),
                      DataCell(Text(kMockUp[index].date)),
                      DataCell(Text(kMockUp[index].time)),
                      DataCell(Text(kMockUp[index].taskName)),
                      DataCell(Text(kMockUp[index].valueCount)),
                    ]))

            // [
            //   DataRow(
            //       cells: [
            //         ]),
            // ],
            ),
      ),
    );
  }
}

class HistoryModel {
  final String date;
  final String time;
  final String taskName;
  final String valueCount;

  HistoryModel(
      {required this.date,
      required this.time,
      required this.taskName,
      required this.valueCount});
}
