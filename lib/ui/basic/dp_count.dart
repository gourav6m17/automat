import 'dart:convert';

import 'package:automat/Constant/const.dart';
import 'package:automat/Constant/service_ids.dart';
import 'package:automat/filter_configuration.dart';
import 'package:automat/model/devices_model.dart';
import 'package:automat/plugins/reactive_ble/ble/ble_device_connector.dart';
import 'package:automat/plugins/reactive_ble/ble/ble_logger.dart';
import 'package:automat/plugins/reactive_ble/ui/device_detail/device_interaction_tab.dart';
import 'package:automat/plugins/reactive_ble/utils.dart';
import 'package:automat/plugins/src/radial_gauge/annotation/gauge_annotation.dart';
import 'package:automat/plugins/src/radial_gauge/axis/radial_axis.dart';
import 'package:automat/plugins/src/radial_gauge/gauge/radial_gauge.dart';
import 'package:automat/plugins/src/radial_gauge/pointers/gauge_pointer.dart';
import 'package:automat/plugins/src/radial_gauge/pointers/marker_pointer.dart';
import 'package:automat/plugins/src/radial_gauge/pointers/range_pointer.dart';
import 'package:automat/plugins/src/radial_gauge/styles/radial_tick_style.dart';
import 'package:automat/plugins/src/radial_gauge/title/radial_title.dart';
import 'package:automat/plugins/src/radial_gauge/utils/enum.dart';
import 'package:automat/services/automat_services.dart';
import 'package:automat/ui/add_device/add_device.dart';
import 'package:automat/ui/basic/history_screen.dart';
import 'package:automat/ui/basic/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:functional_data/functional_data.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as log;
import '../../plugins/reactive_ble/ble/ble_device_interactor.dart';
import 'package:automat/model/devices_model.dart' as model;
// import 'package:reactive_ble_platform_interface/src/model/discovered_device.dart'
//     as pluginModel;
// part 'device_interaction_tab.g.dart';

final flutterBle = FlutterReactiveBle();

class DpCount extends StatelessWidget {
  final DiscoveredDevice device;
  const DpCount({required this.device, Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => Consumer5<
          BleDeviceConnector,
          ConnectionStateUpdate,
          BleDeviceInteractor,
          BleLogger,
          BleDeviceInteractor>(
        builder: (_, deviceConnector, connectionStateUpdate, serviceDiscoverer,
                bleLogger, interactor, __) =>
            _DeviceDetail(
          bleLogger: bleLogger,
          interactor: interactor,
          viewModel: DeviceInteractionViewModel(
              deviceId: device.id,
              connectionStatus: connectionStateUpdate.connectionState,
              deviceConnector: deviceConnector,
              discoverServices: () =>
                  serviceDiscoverer.discoverServices(device.id)),
          device: device,
          disconnect: deviceConnector.disconnect,
        ),
      );
}

@immutable
@FunctionalData()
class DeviceInteractionViewModel extends $DeviceInteractionViewModel {
  const DeviceInteractionViewModel({
    required this.deviceId,
    required this.connectionStatus,
    required this.deviceConnector,
    required this.discoverServices,
  });

  final String deviceId;
  final DeviceConnectionState connectionStatus;
  final BleDeviceConnector deviceConnector;

  @CustomEquality(Ignore())
  final Future<List<DiscoveredService>> Function() discoverServices;

  bool get deviceConnected =>
      connectionStatus == DeviceConnectionState.connected;

  void connect() {
    deviceConnector.connect(deviceId);
  }

  void disconnect() {
    deviceConnector.disconnect(deviceId);
  }
}

class _DeviceDetail extends StatefulWidget {
  final DeviceInteractionViewModel viewModel;
  final BleDeviceInteractor interactor;
  final DiscoveredDevice device;
  final BleLogger bleLogger;
  final void Function(String deviceId) disconnect;
  const _DeviceDetail({
    Key? key,
    required this.interactor,
    required this.device,
    required this.disconnect,
    required this.viewModel,
    required this.bleLogger,
  }) : super(key: key);

  @override
  State<_DeviceDetail> createState() => _DeviceDetailState();
}

class _DeviceDetailState extends State<_DeviceDetail> {
  GlobalKey<ScaffoldState> globalKey = GlobalKey<ScaffoldState>();

  var progressValue = 9999.0;
  bool isStart = false;
  bool isManual = true;
  bool buzzerStatus = true;
  List<DiscoveredService> discoveredServiceList = [];

  String manualCycle = '0';

  String dpCycle = '0';

  String timeCycle = '0';
  List<String> hoursFromInterval = [];
  List<String> minuteFromInterval = [];
  List<String> minuteFromDuration = [];
  List<String> secondsFromDuration = [];

  bool? showDpOnly;

  bool? showDpTime;

  final flutterReactiveBle = FlutterReactiveBle();

  List<int> list = [];

  List<int> getTime() {
    List<int> time = [];
    DateTime dateTime = DateTime.now();
    String timeString = dateTime.hour.toString() +
        dateTime.minute.toString() +
        dateTime.second.toString();
    log.log("date------" + timeString);
    for (int i = 0; i < timeString.length; i++) {
      time.add(timeString.codeUnitAt(i));
      print(time);
    }
    return time;
    //log.log(dateTime.)
    //automatServices.writeRTCTime(widget.device.id, value);
  }

  addDeviceToDb() async {
    final box = Hive.box<DevicesModelDB>('automatDevices');

    DevicesModelDB? devicesModelDB = DevicesModelDB(deviceList: [
      DeviceListModelDB(
        discoveredDevice: DiscoveredDeviceModel(
          id: widget.device.id,
          manufacturerData: widget.device.manufacturerData,
          name: widget.device.name,
          rssi: widget.device.rssi,
          serviceData: widget.device.serviceData,
          serviceUuids: widget.device.serviceUuids,
        ),
      ),
    ]);

    final rs = await box.add(devicesModelDB);
    final r = box.toMap();
    log.log("--------${rs.toString()}--------" + r.toString());
  }

  List<int> getDate() {
    List<int> date = [];
    DateTime dateTime = DateTime.now();
    String dateString = dateTime.day.toString() +
        dateTime.month.toString() +
        dateTime.year.toString();
    log.log("date------" + dateString);
    for (int i = 0; i < dateString.length; i++) {
      date.add(dateString.codeUnitAt(i));
      print(date);
    }
    return date;
  }

  writeDateTime() async {
    await automatServices.writeRTCTime(widget.device.id, getTime());
    await automatServices.writeRTCDate(widget.device.id, getDate());
    await addDeviceToDb();
  }

  @override
  void initState() {
    widget.viewModel.connect();

    Future.delayed(const Duration(seconds: 5), () {
      discoverServices();
      writeDateTime();
    });

    super.initState();
  }

  @override
  void dispose() {
    widget.disconnect(widget.device.id);
    super.dispose();
  }

  Future<void> discoverServices() async {
    if (widget.viewModel.deviceConnected == true) {
      final result = await widget.viewModel.discoverServices();
      setState(() {
        discoveredServiceList = result;
      });
      log.log(discoveredServiceList.toList().toString());
    }
  }

  List<int> _parseInput(String text) => text
      .split(',')
      .map(
        int.parse,
      )
      .toList();

  _showResetDialog(BuildContext context) {
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
                      "do_you_want_reset_counts".tr,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
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
                                      (states) => kWhiteColor)),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            "no".tr,
                            style: const TextStyle(color: kBlackColor),
                          )),
                    ),
                    const Spacer(),
                    Expanded(
                        child: ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.resolveWith(
                                        (states) => kPrimaryColor)),
                            onPressed: () async {
                              EasyLoading.show(
                                  status: 'apply'.tr,
                                  dismissOnTap: true,
                                  maskType: EasyLoadingMaskType.black);
                              await automatServices
                                  .writeReset(widget.device.id);
                              Navigator.of(context).pop();
                              //await EasyLoading.dismiss();
                            },
                            child: Text("yes".tr)))
                  ],
                ),
              ),
            ],
          );
        });
  }

  showPopUpMenu() {
    return PopupMenuButton(
        child: const Icon(Icons.more_vert_outlined),
        itemBuilder: (context) {
          return [
            PopupMenuItem(
              onTap: () {
                widget.viewModel.connect();
              },
              child: Text(
                "connect".tr,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            PopupMenuItem(
              onTap: () {
                widget.disconnect(widget.device.id);
              },
              child: Text(
                "disconnect".tr,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            )
          ];
        });
  }

  final automatServices = AutomatServices();
  Future<bool> _willPopCallback() async {
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (_) => Home()));
    return true; // return true if the route to be popped
  }

  @override
  Widget build(BuildContext context) {
    //addDeviceToDb();
    if (isStart == true) {
      EasyLoading.dismiss();
    } else if (isStart == false) {
      EasyLoading.dismiss();
    }
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: _willPopCallback,
      child: FlutterEasyLoading(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            bottomNavigationBar: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: SizedBox(
                height: height * 0.08,
                width: width,
                child: ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.resolveWith(
                            (states) => kPrimaryColor)),
                    onPressed: () async {
                      await discoverServices();
                      // log.log("--id---" + widget.device.id);
                      // log.log("---service id------" +
                      //     discoveredServiceList[0].serviceId.toString());
                      // log.log("-char id-----" +
                      //     discoveredServiceList[2]
                      //         .characteristicIds
                      //         .toList()
                      //         .toString());

                      log.log(discoveredServiceList.toList().toString());
                      addDeviceToDb();
                      // Navigator.of(context).push(
                      //     MaterialPageRoute(builder: (_) => const HistoryScreen()));
                    },
                    child: Text(
                      "history".tr,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    )),
              ),
            ),
            appBar: AppBar(
              backgroundColor: const Color.fromARGB(255, 77, 221, 101),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                tooltip: "Back",
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => Home()));
                },
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    (widget.viewModel.connectionStatus.name == "connected")
                        ? "connected".tr
                        : (widget.viewModel.connectionStatus.name ==
                                "connecting")
                            ? "connecting".tr
                            : "disconnected".tr,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                showPopUpMenu(),
              ],
            ),
            body: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Expanded(
                  //   flex: 4,
                  //   child:
                  SizedBox(
                    height: height * 0.65,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  widget.device.name,
                                  style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: kDarkGreen),
                                ),
                              ),
                            ),
                            const Spacer(),
                            InkWell(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (_) => FilterConfiguration(
                                          deviceId: widget.device.id,
                                        )));
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(4.0),
                                child: Icon(Icons.settings, size: 28),
                              ),
                            )
                          ],
                        ),
                        FutureProvider<String>(
                            create: (_) => automatServices
                                .readOperationMode(widget.device.id),
                            initialData: '0',
                            updateShouldNotify: (_, __) => true,
                            child: Consumer<String>(
                                builder: (context, value, child) {
                              // log.log("flu-------" + value);
                              return Padding(
                                padding: const EdgeInsets.all(4),
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 8.0, right: 8.0),
                                      child: Text(
                                        "device_status".tr + ":",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: height * 0.025),
                                      ),
                                    ),
                                    Expanded(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          buzzerStatus == true
                                              ? Container(
                                                  // height: height * 0.05,
                                                  // width: width * 0.20,
                                                  child: ElevatedButton(
                                                      style: ButtonStyle(
                                                          shape: MaterialStateProperty.all<
                                                                  RoundedRectangleBorder>(
                                                              RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10))),
                                                          backgroundColor:
                                                              MaterialStateProperty
                                                                  .resolveWith(
                                                                      (states) =>
                                                                          Colors
                                                                              .red)),
                                                      onPressed: () {
                                                        Navigator.of(context).push(
                                                            MaterialPageRoute(
                                                                builder: (_) =>
                                                                    const AddDevice()));
                                                      },
                                                      child: Text(
                                                        'flushing_error'.tr,
                                                        style: const TextStyle(
                                                            color: kWhiteColor,
                                                            fontSize: 12),
                                                      )),
                                                )
                                              : StreamProvider<String>(
                                                  create: (_) => automatServices
                                                      .readFlushingModeAsStream(
                                                          widget.device.id),
                                                  initialData: '0',
                                                  updateShouldNotify: (_, __) =>
                                                      true,
                                                  child: Consumer<String>(
                                                      builder: (context, value,
                                                          child) {
                                                    if (value == '1') {
                                                      WidgetsBinding.instance!
                                                          .addPostFrameCallback(
                                                              (timeStamp) {
                                                        setState(() {
                                                          showDpOnly = true;
                                                          showDpTime = false;
                                                        });
                                                      });
                                                    } else if (value == '2') {
                                                      WidgetsBinding.instance!
                                                          .addPostFrameCallback(
                                                              (timeStamp) {
                                                        setState(() {
                                                          showDpTime = true;
                                                          showDpOnly = false;
                                                        });
                                                      });
                                                    }
                                                    WidgetsBinding.instance!
                                                        .addPostFrameCallback(
                                                            (_) {
                                                      setState(() {
                                                        dpCycle = value;
                                                      });
                                                    });

                                                    return Row(
                                                      children: [
                                                        (showDpOnly == true &&
                                                                showDpTime ==
                                                                    false)
                                                            ? ElevatedButton(
                                                                style: ButtonStyle(
                                                                    shape: MaterialStateProperty.all<
                                                                            RoundedRectangleBorder>(
                                                                        RoundedRectangleBorder(
                                                                            borderRadius: BorderRadius.circular(
                                                                                10))),
                                                                    backgroundColor:
                                                                        MaterialStateProperty.resolveWith((states) =>
                                                                            kPrimaryColor)),
                                                                onPressed:
                                                                    () {},
                                                                child: Text(
                                                                  'flushing_in_dp_mode'
                                                                      .tr,
                                                                  style: const TextStyle(
                                                                      color:
                                                                          kWhiteColor,
                                                                      fontSize:
                                                                          16),
                                                                ),
                                                              )
                                                            : ElevatedButton(
                                                                style: ButtonStyle(
                                                                    shape: MaterialStateProperty.all<
                                                                            RoundedRectangleBorder>(
                                                                        RoundedRectangleBorder(
                                                                            borderRadius: BorderRadius.circular(
                                                                                10))),
                                                                    backgroundColor:
                                                                        MaterialStateProperty.resolveWith((states) =>
                                                                            kPrimaryColor)),
                                                                onPressed:
                                                                    () {},
                                                                child: Text(
                                                                  'flushing_in_dp_&_time_mode'
                                                                      .tr,
                                                                  style: TextStyle(
                                                                      color:
                                                                          kWhiteColor,
                                                                      fontSize:
                                                                          12),
                                                                ),
                                                              ),
                                                      ],
                                                    );
                                                  })),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            })),
                        Row(
                          children: [
                            Expanded(
                              child: StreamProvider<String>(
                                create: (_) => automatServices
                                    .readDpCycle(widget.device.id),
                                initialData: '0',
                                updateShouldNotify: (_, __) => true,
                                child: Consumer<String>(
                                    builder: (context, value, child) {
                                  WidgetsBinding.instance!
                                      .addPostFrameCallback((_) {
                                    setState(() {
                                      dpCycle = value;
                                    });
                                  });

                                  return CustomGauge(
                                    progressValue: double.parse(value),
                                    title: "dp_cycle_count".tr,
                                  );
                                }),
                              ),
                            ),
                            Expanded(
                              child: StreamProvider<String>(
                                create: (_) => automatServices
                                    .readTimeCycle(widget.device.id),
                                initialData: '0',
                                updateShouldNotify: (_, __) => true,
                                child: Consumer<String>(
                                    builder: (context, value, child) {
                                  WidgetsBinding.instance!
                                      .addPostFrameCallback((_) {
                                    setState(() {
                                      timeCycle = value;
                                    });
                                  });

                                  return CustomGauge(
                                    progressValue: double.parse(value),
                                    title: "time_cycle_count".tr,
                                  );
                                }),
                              ),
                            ),
                            Expanded(
                                child: StreamProvider<String>(
                              create: (_) => automatServices
                                  .readManualCycle(widget.device.id),
                              initialData: '0',
                              updateShouldNotify: (_, __) => true,
                              child: Consumer<String>(
                                  builder: (context, value, child) {
                                WidgetsBinding.instance!
                                    .addPostFrameCallback((_) {
                                  setState(() {
                                    manualCycle = value;
                                  });
                                });

                                return CustomGauge(
                                  progressValue: double.parse(value),
                                  title: "manual_cycle_count".tr,
                                );
                              }),
                            ))
                          ],
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      "total_count".tr,
                                      style: TextStyle(
                                          fontSize: height * 0.025,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(color: kGreyColor),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 4, vertical: 4),
                                        child: Text(
                                          (int.parse(dpCycle) +
                                                  int.parse(timeCycle) +
                                                  int.parse(manualCycle))
                                              .toString(),
                                          style: TextStyle(
                                              fontSize: height * 0.025,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: height * 0.01,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      "flushing_interval_time_left".tr,
                                      style: TextStyle(
                                          fontSize: height * 0.025,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Expanded(
                                      child: StreamProvider<String>(
                                          create: (_) => automatServices
                                              .readRemainingFlushingInterval(
                                                  widget.device.id),
                                          initialData: '0',
                                          updateShouldNotify: (_, __) => true,
                                          child: Consumer<String>(
                                              builder: (context, value, child) {
                                            if (value.split("").isNotEmpty) {
                                              final v = value.split('');
                                              final minutes = v.getRange(
                                                  v.length - 2, v.length);
                                              final hours =
                                                  v.take(v.length - 2);
                                              WidgetsBinding.instance!
                                                  .addPostFrameCallback(
                                                      (timeStamp) {
                                                setState(() {
                                                  minuteFromInterval =
                                                      minutes.toList();
                                                  hoursFromInterval =
                                                      hours.toList();
                                                });
                                              });
                                            }

                                            return Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: kGreyColor),
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 4,
                                                        vertical: 4),
                                                child: Text(
                                                  removeBracket(
                                                          hoursFromInterval) +
                                                      "hr".tr +
                                                      " " +
                                                      removeBracket(
                                                          minuteFromInterval) +
                                                      "min".tr,
                                                  style: TextStyle(
                                                      fontSize: height * 0.022,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                              ),
                                            );
                                          }))),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: height * 0.01,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      "flushing_duration_time_left".tr,
                                      style: TextStyle(
                                        fontSize: height * 0.025,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  // const Spacer(),
                                  Expanded(
                                      child: StreamProvider<String>(
                                          create: (_) => automatServices
                                              .readRemainingFlushingDuration(
                                                  widget.device.id),
                                          initialData: '0',
                                          updateShouldNotify: (_, __) => true,
                                          child: Consumer<String>(
                                              builder: (context, value, child) {
                                            WidgetsBinding.instance!
                                                .addPostFrameCallback((_) {});
                                            if (value.split("").isNotEmpty) {
                                              final v = value.split('');

                                              final seconds = v.getRange(
                                                  v.length - 2, v.length);

                                              final minutes =
                                                  v.take(v.length - 2);
                                              WidgetsBinding.instance!
                                                  .addPostFrameCallback(
                                                      (timeStamp) {
                                                secondsFromDuration =
                                                    seconds.toList();
                                                minuteFromDuration =
                                                    minutes.toList();
                                              });
                                            }

                                            return Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: kGreyColor),
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 2,
                                                        vertical: 4),
                                                child: Text(
                                                  removeBracket(
                                                          minuteFromDuration) +
                                                      "min".tr +
                                                      " " +
                                                      removeBracket(
                                                          secondsFromDuration) +
                                                      'sec'.tr,
                                                  style: TextStyle(
                                                      fontSize: height * 0.022,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                              ),
                                            );
                                          }))),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // ),
                  Flexible(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            SizedBox(
                                height: height * 0.08,
                                child: StreamProvider<String>(
                                  create: (_) => automatServices
                                      .readManualButton(widget.device.id),
                                  initialData: '0',
                                  updateShouldNotify: (_, __) => true,
                                  child: Consumer<String>(
                                    builder: (context, value, child) {
                                      //log.log("manual-----" + value);
                                      if (value == '0') {
                                        WidgetsBinding.instance!
                                            .addPostFrameCallback((_) {
                                          setState(() {
                                            isManual = false;
                                          });
                                        });
                                      } else if (value == '1') {
                                        WidgetsBinding.instance!
                                            .addPostFrameCallback((_) {
                                          setState(() {
                                            isManual = true;
                                          });
                                        });
                                      }

                                      return ElevatedButton(
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty
                                                    .resolveWith(
                                              (states) => isManual == false
                                                  ? kWhiteColor
                                                  : Colors.blue.shade900,
                                            ),
                                          ),
                                          onPressed: () async {
                                            if (widget.viewModel
                                                    .connectionStatus.name ==
                                                "connected") {
                                              if (isStart == true) {
                                                if (isManual == true) {
                                                  automatServices.writeManual(
                                                      widget.device.id, [48]);
                                                } else {
                                                  automatServices.writeManual(
                                                      widget.device.id, [49]);
                                                }
                                              } else {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(const SnackBar(
                                                        duration: Duration(
                                                            seconds: 5),
                                                        content: Text(
                                                            "Device is in idle condition")));
                                              }
                                            } else {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(const SnackBar(
                                                      content: Text(
                                                          "Device is not connected")));
                                            }
                                          },
                                          child: Text(
                                            "M",
                                            style: TextStyle(
                                                color: isManual == true
                                                    ? kWhiteColor
                                                    : Colors.black,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16),
                                          ));
                                    },
                                  ),
                                )),
                            const SizedBox(
                              height: 5,
                            ),
                            Text("manual".tr)
                          ],
                        ),
                        StreamProvider<String>(
                            create: (_) => automatServices
                                .readBuzzerOffButton(widget.device.id),
                            initialData: '0',
                            updateShouldNotify: (_, __) => true,
                            child: Consumer<String>(
                                builder: (context, value, child) {
                              //log.log("buzeer-------" + value);
                              if (value == '0') {
                                WidgetsBinding.instance!
                                    .addPostFrameCallback((timeStamp) {
                                  setState(() {
                                    buzzerStatus = false;
                                  });
                                });
                              } else if (value == '1') {
                                WidgetsBinding.instance!
                                    .addPostFrameCallback((timeStamp) {
                                  setState(() {
                                    buzzerStatus = true;
                                  });
                                });
                              }
                              return Column(
                                children: [
                                  SizedBox(
                                    height: height * 0.08,
                                    child: ElevatedButton(
                                        style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty
                                                    .resolveWith((states) =>
                                                        kWhiteColor)),
                                        onPressed: () {
                                          if (widget.viewModel.connectionStatus
                                                  .name ==
                                              "connected") {
                                            if (buzzerStatus == true) {
                                              automatServices.writeBuzzer(
                                                  widget.device.id, [48]);
                                            } else {}
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(const SnackBar(
                                                    content: Text(
                                                        "Device is not connected")));
                                          }
                                        },
                                        child: Icon(
                                          buzzerStatus == false
                                              ? Icons.notifications_active
                                              : Icons
                                                  .notifications_off_outlined,
                                          color: Colors.black,
                                        )),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Text(buzzerStatus == false
                                      ? "buzzer_on".tr
                                      : "buzzer_off".tr)
                                ],
                              );
                            })),
                        // StreamProvider<String>(
                        //     create: (_) =>
                        //         automatServices.readResetButton(widget.device.id),
                        //     initialData: '0',
                        //     updateShouldNotify: (_, __) => true,
                        //     child:
                        //         Consumer<String>(builder: (context, value, child) {
                        //       //log.log("flu-------" + value);
                        //       return
                        Column(
                          children: [
                            SizedBox(
                              height: height * 0.08,
                              child: ElevatedButton(
                                style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.resolveWith(
                                            (states) => kWhiteColor)),
                                onPressed: () {
                                  if (widget.viewModel.connectionStatus.name ==
                                      "connected") {
                                    _showResetDialog(context);
                                  } else {
                                    EasyLoading.showToast(
                                        "Device is not connected",
                                        duration: Duration(seconds: 5));
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(const SnackBar(
                                      content: Text("Device is not connected"),
                                    ));
                                  }
                                },
                                child: const Icon(
                                  Icons.restore,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text("reset".tr)
                          ],
                        ),
                        // })),
                        StreamProvider<String>(
                            create: (_) => automatServices
                                .readMachineStatus(widget.device.id),
                            initialData: '0',
                            updateShouldNotify: (_, __) => true,
                            child: Consumer<String>(
                                builder: (context, value, child) {
                              if (value == '0') {
                                WidgetsBinding.instance!
                                    .addPostFrameCallback((_) {
                                  setState(() {
                                    isStart = false;
                                  });
                                  EasyLoading.dismiss();
                                });
                              } else if (value == '1') {
                                WidgetsBinding.instance!
                                    .addPostFrameCallback((_) {
                                  setState(() {
                                    isStart = true;
                                  });
                                  EasyLoading.dismiss();
                                });
                              }

                              return Column(
                                children: [
                                  SizedBox(
                                    height: height * 0.08,
                                    child: ElevatedButton(
                                      style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.resolveWith(
                                                  (states) => kWhiteColor)),
                                      onPressed: () async {
                                        if (widget.viewModel.connectionStatus
                                                .name ==
                                            "connected") {
                                          if (isStart == true) {
                                            // setState(() {
                                            //   isStart = false;
                                            // });
                                            if (isStart == true) {
                                              EasyLoading.show(
                                                  status: "apply".tr);
                                              EasyLoading.dismiss();
                                            }
                                            //stop machine
                                            await widget.interactor
                                                .writeCharacterisiticWithResponse(
                                                    qualifiedChar(
                                                        Uuid.parse(ServiceIds
                                                            .MACHINE_STATUS),
                                                        widget.device.id),
                                                    [48]);
                                            log.log("added");

                                            // log.log("readd--------" +
                                            //     rs.toList().toString());
                                            if (isStart == false) {
                                              EasyLoading.dismiss();
                                            }
                                          } else {
                                            // setState(() {
                                            //   isStart = false;
                                            // });
                                            if (isStart == false) {
                                              EasyLoading.show(
                                                  status: "apply".tr);
                                              EasyLoading.dismiss();
                                            }
                                            //start machine
                                            await widget.interactor
                                                .writeCharacterisiticWithResponse(
                                                    qualifiedChar(
                                                        Uuid.parse(ServiceIds
                                                            .MACHINE_STATUS),
                                                        widget.device.id),
                                                    [49]);
                                            log.log("added");
                                          }
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                                  content: Text(
                                                      "Device is not connected")));
                                        }
                                      },
                                      child: Icon(
                                        isStart == true
                                            ? Icons.stop
                                            : Icons.power_settings_new_rounded,
                                        color: isStart == true
                                            ? Colors.red
                                            : Colors.black,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Text(isStart == true ? "stop".tr : "start".tr)
                                ],
                              );
                            }))
                      ],
                    ),
                  ),
                ]),
          ),
        ),
      ),
    );
    //);
    //);
  }
}

class CustomGauge extends StatelessWidget {
  const CustomGauge({
    Key? key,
    required this.progressValue,
    required this.title,
  }) : super(key: key);

  final double progressValue;
  final String title;

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return SizedBox(
      height: height * 0.23,
      width: width * 0.15,
      child: SfRadialGauge(
        axes: <RadialAxis>[
          RadialAxis(
              minimum: 0,
              maximum: 4999,
              showLabels: false,
              showTicks: false,
              radiusFactor: 0.8,
              startAngle: 270,
              endAngle: 270,
              axisLineStyle: const AxisLineStyle(
                thickness: 0.1,
                color: Color.fromARGB(30, 1, 0, 0),
                thicknessUnit: GaugeSizeUnit.factor,
                cornerStyle: CornerStyle.startCurve,
              ),
              pointers: <GaugePointer>[
                RangePointer(
                  cornerStyle: CornerStyle.startCurve,
                  value: progressValue,
                  width: 0.2,
                  enableAnimation: true,
                  sizeUnit: GaugeSizeUnit.factor,
                  gradient: const SweepGradient(
                    colors: <Color>[
                      Color(0xff0000FF),
                      Color(0xff00FF00),
                      Color(0xffFFFF00),
                      Color.fromARGB(255, 229, 229, 92),
                      Color(0xffFF7F00),
                      Color.fromARGB(255, 240, 50, 50),
                    ],
                  ),
                ),
                MarkerPointer(
                  value: progressValue,
                  markerType: MarkerType.invertedTriangle,
                  color: const Color.fromARGB(255, 0, 0, 0),
                ),
              ],
              annotations: <GaugeAnnotation>[
                GaugeAnnotation(
                    positionFactor: 0,
                    widget: Text(
                      progressValue.toStringAsFixed(0),
                      style: TextStyle(
                          fontSize: height * 0.03, fontWeight: FontWeight.bold),
                    ))
              ]),
        ],
        title: GaugeTitle(
          text: title,
          textStyle: const TextStyle(
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

QualifiedCharacteristic qualifiedChar(Uuid characteristicId, String deviceId) {
  final qual = QualifiedCharacteristic(
      characteristicId: characteristicId,
      serviceId: Uuid.parse(ServiceIds.ServiceUUID),
      deviceId: deviceId);

  return qual;
}

// remove brackets
removeBracket(List<String> a) {
  String removedBrackets = a.reduce((value, element) {
    return value + element;
  });
  return removedBrackets;
}
