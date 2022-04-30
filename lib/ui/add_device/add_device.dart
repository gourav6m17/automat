import 'dart:async';
import 'package:automat/Constant/const.dart';
import 'package:automat/plugins/reactive_ble/ble/ble_scanner.dart';
import 'package:automat/plugins/reactive_ble/utils.dart';
import 'package:automat/ui/basic/dp_count.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
// import 'package:flutter_ble_lib_ios_15/flutter_ble_lib.dart' ;
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:nordic_dfu/nordic_dfu.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class AddDevice extends StatelessWidget {
  const AddDevice({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Consumer2<BleScanner, BleScannerState?>(
        builder: (_, bleScanner, bleScannerState, __) => _DeviceList(
          scannerState: bleScannerState ??
              const BleScannerState(
                discoveredDevices: [],
                scanIsInProgress: false,
              ),
          startScan: bleScanner.startScan,
          stopScan: bleScanner.stopScan,
        ),
      );
}

class _DeviceList extends StatefulWidget {
  final BleScannerState scannerState;
  final void Function(List<Uuid>) startScan;
  final VoidCallback stopScan;
  const _DeviceList({
    Key? key,
    required this.scannerState,
    required this.startScan,
    required this.stopScan,
  }) : super(key: key);

  @override
  State<_DeviceList> createState() => _DeviceListState();
}

class _DeviceListState extends State<_DeviceList> {
  GlobalKey<ScaffoldState> globalKey = GlobalKey<ScaffoldState>();
  //final FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
  StreamSubscription<ScanResult>? scanSubscription;
  List<ScanResult> scanResults = [];
  bool dfuRunning = false;
  int? dfuRunningInx;
  FlutterReactiveBle flutterReactiveBle = FlutterReactiveBle();

  final passwordController = TextEditingController();

  // BleManager bleManager = BleManager();

  startScanToCon() {
    //flutterReactiveBle.scanForDevices(withServices: ["F3641523-00B0-4240-BA50-05CA45BF8ABC"])
    // bleManager.createClient();

    // bleManager.startPeripheralScan(
    //     uuids: ["F3641523-00B0-4240-BA50-05CA45BF8ABC"]).listen((event) {
    //   scanResults.add(event);
    //   log("-------name" + event.peripheral.name.toString());
    //   // event.advertisementData.
    // });
  }

  void _startScanning() {
    widget.startScan([Uuid.parse("F3641523-00B0-4240-BA50-05CA45BF8ABC")]);
  }

  @override
  void initState() {
    _startScanning();
    //startScan();
    super.initState();
  }

  @override
  void dispose() {
    widget.stopScan();
    super.dispose();
  }

  Future<void> doDfu(String deviceId) async {
    stopScan();
    dfuRunning = true;
    try {
      var s = await NordicDfu.startDfu(
        deviceId,
        'assets/file.zip',
        fileInAsset: true,
        progressListener:
            DefaultDfuProgressListenerAdapter(onProgressChangedHandle: (
          deviceAddress,
          percent,
          speed,
          avgSpeed,
          currentPart,
          partsTotal,
        ) {
          debugPrint('deviceAddress: $deviceAddress, percent: $percent');
        }),
      );
      debugPrint(s);
      dfuRunning = false;
    } catch (e) {
      dfuRunning = false;
      debugPrint(e.toString());
    }
  }

  // void startScan() async {
  //   scanResults.clear();
  //   scanSubscription?.cancel();
  //   await flutterBlue.stopScan();
  //   setState(() {
  //     //scanResults.clear();
  //     // scanSubscription = flutterBlue.scan().listen(
  //     //   (scanResult) {
  //     //     log(scanResult.device.id.id);
  //     //     setState(() {
  //     //       /// add result to results if not added
  //     //       scanResults.add(scanResult);
  //     //       log(scanResults.length.toString());
  //     //     });

  //     //     if (scanResults.firstWhere(
  //     //           (ele) => ele.device.id == scanResult.device.id,
  //     //         ) !=
  //     //         null) {
  //     //       return;
  //     //     }
  //     //   },
  //     // );
  //   });
  // }

  void stopScan() {
    scanSubscription?.cancel();
    scanSubscription = null;
    setState(() => scanSubscription = null);
  }

  _showDialog(
    BuildContext context,
    String deviceName,
  ) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Text(
                      "password".tr,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      deviceName,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                    controller: passwordController,
                    decoration: const InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: kGreyColor)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: kGreyColor)))),
              ),
              const SizedBox(
                height: 5,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.resolveWith(
                                      (states) => kPrimaryColor)),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text("cancel".tr)),
                    ),
                    const Spacer(),
                    Expanded(
                        child: ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.resolveWith(
                                        (states) => kPrimaryColor)),
                            onPressed: () {},
                            child: Text("pair".tr)))
                  ],
                ),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    //log(widget.scannerState.scanIsInProgress.toString());
    //debugPrint(widget.scannerState.discoveredDevices.toList().toString());
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    final isScanning = scanSubscription != null;
    final hasDevice = scanResults.length > 0;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SafeArea(
        child: Scaffold(
          bottomNavigationBar: Container(
            height: height * 0.09,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(color: Colors.grey.shade500, blurRadius: 1)
                ]),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: SizedBox(
                      height: height * 0.06,
                      width: width * 0.9,
                      child: ElevatedButton(
                          style: ButtonStyle(
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10))),
                              backgroundColor:
                                  MaterialStateProperty.resolveWith(
                                      (states) => kPrimaryColor)),
                          onPressed: () {
                            _startScanning();
                            //startScan();
                            // Navigator.of(context).push(MaterialPageRoute(
                            //     builder: (_) => const AddDevice()));
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                CupertinoIcons.refresh,
                                color: Colors.white,
                              ),
                              Text(
                                'scan_again'.tr,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 18),
                              ),
                            ],
                          )),
                    ),
                  ),
                ),
              ],
            ),
          ),
          body: Column(
            children: [
              Column(
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          height: 40,
                          width: 40,
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: kWhiteColor,
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.grey,
                                    blurRadius: 1,
                                    offset: Offset(0, 1))
                              ]),
                          child: IconButton(
                              tooltip: "Back",
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              icon: const Icon(
                                CupertinoIcons.back,
                                color: kGreenColor,
                              )),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "scanning".tr,
                            style: const TextStyle(
                              fontSize: 20,
                            ),
                          ),
                          Text(
                            widget.scannerState.discoveredDevices.length
                                    .toString() +
                                " " +
                                "device_found".tr,
                            style: const TextStyle(),
                          ),
                        ],
                      )
                    ],
                  ),
                  const Divider(),
                ],
              ),
              Flexible(
                child: widget.scannerState.discoveredDevices.isEmpty
                    ? const Text("No Device Here!")
                    : ListView(
                        children: widget.scannerState.discoveredDevices
                            .map(
                              (device) => GestureDetector(
                                onTap: () {
                                  widget.stopScan();

                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (_) => DpCount(device: device)));
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    height: height * 0.1,
                                    width: width,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(10)),
                                        boxShadow: [
                                          BoxShadow(
                                              color: Colors.grey.shade100,
                                              blurRadius: 4,
                                              offset: Offset.zero)
                                        ]),
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(4),
                                          child: Image.asset(filterMachine),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Text(
                                              device.name +
                                                  device.rssi.toString(),
                                              style:
                                                  const TextStyle(fontSize: 14),
                                            ),
                                          ),
                                        ),
                                        // const Icon(Icons.more_vert_sharp),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _deviceItemBuilder(BuildContext context, int index) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    var result = scanResults[index];
    return Container(
      height: height * 0.1,
      child: DeviceItem(
        isRunningItem: (dfuRunningInx == null ? false : dfuRunningInx == index),
        scanResult: result,
        onPress: dfuRunning
            ? () async {
                await NordicDfu.abortDfu();
                setState(() {
                  dfuRunningInx = null;
                });
              }
            : () async {
                setState(() {
                  dfuRunningInx = index;
                });
                //await this.doDfu(result.peripheral.identifier);
                setState(() {
                  dfuRunningInx = null;
                });
              },
      ),
    );
  }
}

class ProgressListenerListener extends DfuProgressListenerAdapter {
  @override
  void onProgressChanged(String? deviceAddress, int? percent, double? speed,
      double? avgSpeed, int? currentPart, int? partsTotal) {
    super.onProgressChanged(
        deviceAddress, percent, speed, avgSpeed, currentPart, partsTotal);
    print('deviceAddress: $deviceAddress, percent: $percent');
  }
}

class DeviceItem extends StatelessWidget {
  final ScanResult? scanResult;

  final VoidCallback? onPress;

  final bool? isRunningItem;

  DeviceItem({this.scanResult, this.onPress, this.isRunningItem});

  @override
  Widget build(BuildContext context) {
    var name = "Unknow";
    // if (scanResult!.peripheral.name != null &&
    //     scanResult!.peripheral.name.toString().length > 0) {
    //   name = scanResult!.peripheral.name.toString();
    // }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: <Widget>[
            Icon(Icons.bluetooth),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(name),
                  // Text(scanResult!.peripheral.identifier),
                  // Text("RSSI: ${scanResult!.rssi}"),
                ],
              ),
            ),
            TextButton(
                onPressed: onPress,
                child: isRunningItem! ? Text("Abort Dfu") : Text("Connect"))
          ],
        ),
      ),
    );
  }
}
