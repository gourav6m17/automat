import 'dart:developer' as log;
import 'package:automat/main.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as ble;

import 'package:automat/Constant/const.dart';
import 'package:automat/model/devices_model.dart';
import 'package:automat/plugins/reactive_ble/ble/ble_logger.dart';
import 'package:automat/plugins/reactive_ble/ble/ble_status_monitor.dart';
import 'package:automat/ui/add_device/add_device.dart';
import 'package:automat/ui/basic/change_language.dart';
import 'package:automat/ui/basic/dp_count.dart';
import 'package:automat/ui/basic/dp_count_view.dart';
import 'package:automat/ui/basic/notification.dart';
import 'package:bluetooth_enable_fork/bluetooth_enable_fork.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_ble_lib_ios_15/flutter_ble_lib.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as bluePlus;

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  GlobalKey<ScaffoldState> globalKey = GlobalKey<ScaffoldState>();
  chechOn() async {
    final on = await bluePlus.FlutterBluePlus.instance.isOn;
    if (on == false) {
      bluePlus.FlutterBluePlus.instance.turnOn();
    }
  }

  Box? automatDevicesDb;
  openBox() async {
    final db = await Hive.openBox<DevicesModelDB>(dbName);
    setState(() {
      automatDevicesDb = db;
    });
  }

  Future<void> customEnableBT(BuildContext context) async {
    String dialogTitle = "Hey! Please give me permission to use Bluetooth!";
    bool displayDialogContent = true;
    String dialogContent = "This app requires Bluetooth to connect to device.";
    //or
    // bool displayDialogContent = false;
    // String dialogContent = "";
    String cancelBtnText = "Nope";
    String acceptBtnText = "Sure";
    double dialogRadius = 10.0;
    bool barrierDismissible = true; //

    BluetoothEnable.customBluetoothRequest(
            context,
            dialogTitle,
            displayDialogContent,
            dialogContent,
            cancelBtnText,
            acceptBtnText,
            dialogRadius,
            barrierDismissible)
        .then((value) {
      print(value);
    });
  }

  getLocationStatus() async {
    await Permission.bluetoothScan
        .request()
        .then((value) => log.log("---scan----" + value.name));
    await Permission.bluetoothConnect
        .request()
        .then((value) => log.log("---connect----" + value.name));
    await Permission.location.request();
    ble.FlutterBluePlus.instance.scan(scanMode: ble.ScanMode.lowLatency);
    await ble.FlutterBluePlus.instance.turnOn();
    await Permission.bluetooth.request();
    final loc = await Permission.locationWhenInUse.serviceStatus.isEnabled;
    // setState(() {
    //   locStatus = loc;
    // });
    log.log(loc.toString());
  }

  checkPerm() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();
    statuses;
    // await Permission.bluetoothScan.request();
    await Permission.bluetoothConnect.request();
    // await bluePlus.FlutterBluePlus.instance.turnOn();

    bluePlus.FlutterBluePlus.instance.isOn.then((value) {
      log.log(value.toString());
      if (value == false) {
        bluePlus.FlutterBluePlus.instance.turnOn();
      }
    });
    var status = await Permission.bluetooth.status;
    log.log(status.name);
/*
    if (status.isDenied) {
      await Permission.bluetooth.request();
    } else if (status.isGranted) {
      await Permission.bluetooth.request();
    } else if (status.isLimited) {
      await Permission.bluetooth.request();
    } else {
      await Permission.bluetooth.request();
    }
*/
    if (await Permission.bluetooth.status.isPermanentlyDenied) {
      openAppSettings();
    }

    loc.Location location = loc.Location();

    bool _serviceEnabled;
    loc.PermissionStatus _permissionGranted;
    loc.LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
  }

  @override
  void initState() {
    //log.log(box.getAt(0)!.deviceList[0].discoveredDevice.name.toString());
    getLocationStatus();
    // openBox();
    checkPerm();
    super.initState();
    /*
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      customEnableBT(context);
    });

     */
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          bottomNavigationBar: Container(
            height: height * 0.17,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade500,
                  blurRadius: 1,
                ),
              ],
            ),
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
                          onPressed: () async {
                            await checkPerm();
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => const AddDevice()));
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                CupertinoIcons.add,
                                color: Colors.white,
                              ),
                              Text(
                                'add_device'.tr,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          )),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: height * 0.06,
                    width: width * 0.9,
                    child: ElevatedButton(
                        style: ButtonStyle(
                            shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10))),
                            backgroundColor: MaterialStateProperty.resolveWith(
                                (states) => kPrimaryColor)),
                        onPressed: () {},
                        child: Text(
                          'instruction_manual'.tr,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 18),
                        )),
                  ),
                )
              ],
            ),
          ),
          drawer: const CustomDrawer(),
          appBar: AppBar(
            backgroundColor: kPrimaryColor,
            centerTitle: true,
            title: Image.asset(automatLogo,
                fit: BoxFit.fill, height: height * 0.07),
            actions: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const NotificationScreen()));
                },
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.notifications_active),
                ),
              ),
            ],
          ),
          body: ValueListenableBuilder(
              valueListenable: Hive.box<DevicesModelDB>(dbName).listenable(),
              builder: (context, Box<DevicesModelDB> box, _) {
                log.log(box.length.toString());
                box.toMap().forEach((key, value) {
                  log.log("--key---- $key");
                  value.deviceList.forEach((element) {
                    log.log("---value-------" +
                        element.discoveredDevice.id.toString());
                  });
                });

                //log.log(box.getAt(0)!.deviceList[0].discoveredDevice.name);

                // Consumer<DiscoveredDevice>(
                //   builder: (context, value, child) {
                //     log(value.id);
                //     return
                return box.isEmpty
                    ? Container()
                    : SafeArea(
                        child: GridView.count(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 10,
                          shrinkWrap: true,

                          //childAspectRatio: 0.9,
                          children: List.generate(
                            box.length,
                            (index) {
                              return GridView.builder(
                                  gridDelegate:
                                      SliverGridDelegateWithMaxCrossAxisExtent(
                                          maxCrossAxisExtent: 2),
                                  itemBuilder: (context, i) {
                                    return Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).push(MaterialPageRoute(
                                              builder: (_) => DpCountView(
                                                      device: DiscoveredDevice(
                                                          id: box
                                                              .getAt(index)!
                                                              .deviceList[index]
                                                              .discoveredDevice
                                                              .id!,
                                                          manufacturerData: box
                                                              .getAt(index)!
                                                              .deviceList[index]
                                                              .discoveredDevice
                                                              .manufacturerData!,
                                                          name: box
                                                              .getAt(index)!
                                                              .deviceList[index]
                                                              .discoveredDevice
                                                              .name!,
                                                          rssi: box
                                                              .getAt(index)!
                                                              .deviceList[index]
                                                              .discoveredDevice
                                                              .rssi!,
                                                          serviceData: box
                                                              .getAt(index)!
                                                              .deviceList[index]
                                                              .discoveredDevice
                                                              .serviceData!,
                                                          serviceUuids: [
                                                        Uuid.parse(
                                                            "f3641523-00b0-4240-ba50-05ca45bf8abc")
                                                      ]))));
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(10)),
                                              boxShadow: [
                                                BoxShadow(
                                                    color: Colors.grey.shade400,
                                                    blurRadius: 2,
                                                    spreadRadius: 0.5,
                                                    offset: Offset.zero)
                                              ]),
                                          child: Stack(
                                            children: [
                                              Column(
                                                children: [
                                                  Expanded(
                                                    flex: 3,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              4),
                                                      child: Image.asset(
                                                          'assets/logo/filtermachine.png'),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 2,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              4),
                                                      child: Row(
                                                        children: [
                                                          Flexible(
                                                            child: Text(
                                                              box
                                                                  .getAt(index)!
                                                                  .deviceList[
                                                                      index]
                                                                  .discoveredDevice
                                                                  .name!,
                                                              //'Automate devices',
                                                              softWrap: true,
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      height *
                                                                          0.016,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .fade,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                          ),
                                                          // const Spacer(),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              // CircleAvatar(
                                              //     radius: 16,
                                              //     child: Icon(Icons.notifications_active)),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(4.0),
                                                child: Align(
                                                  alignment: Alignment.topRight,
                                                  child: PopupMenuButton(
                                                    itemBuilder: (context) => [
                                                      PopupMenuItem(
                                                        child: Text(
                                                          "change_name".tr,
                                                          style: const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        // value: 1,
                                                      ),
                                                      PopupMenuItem(
                                                        child: Text(
                                                          "change_password".tr,
                                                          style: const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        // value: 2,
                                                      ),
                                                      PopupMenuItem(
                                                        child: Text(
                                                          "remove".tr,
                                                          style: const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        // value: 3,
                                                      ),
                                                    ],
                                                    child: const Icon(
                                                      Icons.more_vert_sharp,
                                                      color: kBlackColor,
                                                      size: 28,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const Padding(
                                                padding: EdgeInsets.only(
                                                    left: 4,
                                                    right: 0.0,
                                                    top: 4),
                                                child: CircleAvatar(
                                                  radius: 6,
                                                  backgroundColor: Colors.red,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  });
                            },
                          ),
                        ),
                      );
              })),

      // })),
    );
  }
}

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({
    Key? key,
  }) : super(key: key);
  void _launchURL(String url) async {
    if (!await launchUrl(Uri.parse(url))) throw 'Could not launch $url';
  }

  @override
  Widget build(BuildContext context) {
    final kSocialIconsMobile = [
      "assets/icons/facebook.png",
      "assets/icons/instagram.png",
      "assets/icons/youtube.png",
      "assets/icons/linkedin.png",
    ];
    final kSocialLinks = [
      "https://www.facebook.com/automatindustries",
      "https://www.instagram.com/automatirrigation/",
      "https://www.youtube.com/user/automatindustries",
      "https://www.linkedin.com/company/automat-industries-pvt--ltd-/",
    ];
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Drawer(
        child: Column(
      children: [
        Flexible(
          child: SizedBox(
            width: width,
            child: DrawerHeader(
                decoration: const BoxDecoration(color: kPrimaryColor),
                child: Column(
                  children: [
                    Image.asset(
                      automatLogo,
                      height: height * 0.12,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Image.asset(
                      turboLogo,
                      height: height * 0.04,
                    )
                  ],
                )),
          ),
        ),
        Flexible(
          child: Column(
            children: [
              ListTile(
                onTap: () {
                  Navigator.of(context).pop();
                },
                title: Text(
                  "home".tr,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(thickness: 1),
              ListTile(
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const ChangeLanguage()));
                },
                title: Text(
                  "language".tr,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(thickness: 1),
              ListTile(
                onTap: () {
                  _launchURL(websiteUrl);
                },
                title: Text(
                  "contact_us".tr,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(thickness: 1),
              SizedBox(
                height: height * 0.1,
                width: width,
                child: Row(
                  children: [
                    ListView.builder(
                        shrinkWrap: true,
                        padding: const EdgeInsets.all(0),
                        itemCount: kSocialIconsMobile.length,
                        physics: const NeverScrollableScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, i) {
                          return GestureDetector(
                            onTap: () {
                              _launchURL(kSocialLinks[i]);
                            },
                            child: Image.asset(
                              kSocialIconsMobile[i],
                              height: height * 0.08,
                              width: width * 0.15,
                            ),
                          );
                        }),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(top: 90.0),
          child: Text("Maintained By: VLTRONICS"),
        )
      ],
    ));
  }
}
