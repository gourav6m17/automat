import 'dart:developer';

import 'package:automat/Constant/const.dart';
import 'package:automat/services/automat_services.dart';
import 'package:automat/ui/basic/dp_count.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class FilterConfiguration extends StatefulWidget {
  final String deviceId;
  const FilterConfiguration({Key? key, required this.deviceId})
      : super(key: key);

  @override
  State<FilterConfiguration> createState() => _FilterConfigurationState();
}

class _FilterConfigurationState extends State<FilterConfiguration> {
  GlobalKey<ScaffoldState> globalKey = GlobalKey<ScaffoldState>();
  final automatServices = AutomatServices();
  List<int> saveList = [];
  String initalDurationMin = '';
  String initalDurationSec = '';
  String initalIntervalHr = '';
  String initalIntervalMin = '';
  bool isLoading = false;
  bool showPasswordRequired = false;
  //bool _showPasswordIncorrect = true;

  flushingMode() async {
    final mode = await automatServices.readFlushingMode(widget.deviceId);
    log("----flush---------" + mode);
    if (mode == '1') {
      WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
        setState(() {
          showDpOnly = true;
          showDpTime = false;
        });
      });
    } else if (mode == '2') {
      WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
        setState(() {
          showDpTime = true;
          showDpOnly = false;
        });
      });
    }

    //return mode;
  }

  readFlushingDuration() async {
    final duration =
        await automatServices.readFlushingDuration(widget.deviceId);
    final durationList = duration.split('');
    final sec = duration
        .split('')
        .getRange(durationList.length - 2, durationList.length);
    final min = duration.split('').take(durationList.length - 2);
    log("duration min--------------" + removeBracket(min.toList()));
    log("duration sec--------------" + removeBracket(sec.toList()));
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      setState(() {
        durationMinController.text = removeBracket(min.toList());
        durationSecController.text = removeBracket(sec.toList());
      });
    });
  }

  readFlushingInterval() async {
    final duration =
        await automatServices.readFlushingInterval(widget.deviceId);
    final durationList = duration.split('');
    final min = duration
        .split('')
        .getRange(durationList.length - 2, durationList.length);
    final hr = duration.split('').take(durationList.length - 2);
    log("interval min--------------" + removeBracket(min.toList()));
    log("interval hr--------------" + removeBracket(hr.toList()));
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      setState(() {
        intervalMinController.text = removeBracket(min.toList());
        intervalHrController.text = removeBracket(hr.toList());
      });
    });
  }

  readDpDelay() async {
    final dpDelay = await automatServices.readDpDelay(widget.deviceId);
    log("dpdelay---------$dpDelay");
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      setState(() {
        dpDelaySecController.text = dpDelay;
      });
    });
  }

  readLoopingCycle() async {
    final loopingCycle =
        await automatServices.readLoopingCycle(widget.deviceId);
    log("looping----------$loopingCycle");
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      setState(() {
        loopingCycleCountController.text = loopingCycle;
      });
    });
  }

  operationMode() async {
    log("enter");
    final mode = await automatServices.readOperationMode(widget.deviceId);
    log("-----operation--------" + mode);
    if (mode == '1') {
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        setState(() {
          showStandAlone = true;
          showBattery = false;
        });
      });
    } else if (mode == '2') {
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        setState(() {
          showBattery = true;
          showStandAlone = false;
        });
      });
    }

    //return mode;
  }

  getModes() {
    intervalHrController.clear();
    intervalMinController.clear();
    durationMinController.clear();
    durationSecController.clear();
    dpDelaySecController.clear();
    loopingCycleCountController.clear();
    technicianPassword.clear();
    operationMode();
    flushingMode();
    readFlushingDuration();
    readFlushingInterval();
    readDpDelay();
    readLoopingCycle();
  }

  final intervalHrController = TextEditingController();
  final intervalMinController = TextEditingController();
  final durationMinController = TextEditingController();
  final durationSecController = TextEditingController();
  final dpDelaySecController = TextEditingController();
  final loopingCycleCountController = TextEditingController();
  final technicianPassword = TextEditingController();

  sendDataFunction() async {
    saveList.clear();
    if (showDpOnly == null && showDpTime == null) {
      showDialog(
          context: context,
          builder: (_) {
            return AlertDialog(
              actions: [
                Text("select_flushing_mode".tr),
                ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.resolveWith(
                            (states) => kPrimaryColor)),
                    onPressed: () {
                      Navigator.of(_).pop();
                    },
                    child: Text("ok".tr))
              ],
            );
          });
    }
    if (showDpOnly == true && showDpTime == false) {
      await operationModeValue();
      await flushingModeValue();
      await flushingDurationMinute();
      await flushingDurationSecond();
      await dpDelay();
      await loopingCycle();
      log("list--dp only--------------" + saveList.toList().toString());
    } else if (showDpOnly == false && showDpTime == true) {
      log("enter in dp time-----------");
      await operationModeValue();
      await flushingModeValue();
      await flushingIntervalHr();
      await flushingIntervalMin();
      await flushingDurationMinute();
      await flushingDurationSecond();
      await dpDelay();
      await loopingCycle();
      log("list--dp time--------------" + saveList.toList().toString());
    }
  }

  operationModeValue() {
    log("1");
    if (showStandAlone == true && showBattery == false) {
      saveList.add(49);
    } else if (showStandAlone == false && showBattery == true) {
      saveList.add(50);
    }
  }

  flushingModeValue() {
    log("2");
    if (showDpOnly == true && showDpTime == false) {
      saveList.add(49);
    } else if (showDpOnly == false && showDpTime == true) {
      saveList.add(50);
    }
  }

  flushingIntervalHr() {
    log("3");
    for (int i = 0; i < intervalHrController.text.trim().length; i++) {
      saveList.add(intervalHrController.text.trim().codeUnitAt(i));
    }
  }

  flushingIntervalMin() {
    log("4");
    for (int i = 0; i < intervalMinController.text.trim().length; i++) {
      saveList.add(intervalMinController.text.trim().codeUnitAt(i));
    }
  }

  flushingDurationMinute() {
    log("5");
    for (int i = 0; i < durationMinController.text.trim().length; i++) {
      saveList.add(durationMinController.text.trim().codeUnitAt(i));
    }
  }

  flushingDurationSecond() {
    log("6");
    for (int i = 0; i < durationSecController.text.trim().length; i++) {
      saveList.add(durationSecController.text.trim().codeUnitAt(i));
    }
  }

  dpDelay() {
    log("7");
    for (int i = 0; i < dpDelaySecController.text.trim().length; i++) {
      saveList.add(dpDelaySecController.text.trim().codeUnitAt(i));
    }
  }

  loopingCycle() {
    log("8");
    for (int i = 0; i < loopingCycleCountController.text.trim().length; i++) {
      saveList.add(loopingCycleCountController.text.trim().codeUnitAt(i));
    }
  }

  showPassword() {
    EasyLoading.show(status: "Password is required", dismissOnTap: true);
  }

  _showDialog(BuildContext context, Function()? function, String value) {
    return showDialog(
        context: context,
        builder: (c) {
          return StatefulBuilder(builder: (_, state) {
            return AlertDialog(
              actions: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Text(
                        "enter_techinician_password".tr,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      // Text(
                      //   "(Device Name here)",
                      //   style: TextStyle(color: Colors.grey),
                      // ),
                    ],
                  ),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                      controller: technicianPassword,
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
                showPasswordRequired == true
                    ? Text(
                        "password_required".tr,
                        style: const TextStyle(color: Colors.red),
                      )
                    : Container(),
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
                              getModes();
                              Navigator.of(c).pop();
                            },
                            child: Text("cancel".tr)),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                          child: ElevatedButton.icon(
                              style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.resolveWith(
                                          (states) => kPrimaryColor)),
                              onPressed: function,
                              icon: isLoading == false
                                  ? const Icon(Icons.done)
                                  : Container(
                                      width: 24,
                                      height: 24,
                                      padding: const EdgeInsets.all(2.0),
                                      child: const CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 3,
                                      ),
                                    ),
                              label: Text("save".tr)))
                    ],
                  ),
                ),
              ],
            );
          });
        });
  }

  var initialIndex = 0;
  bool? showDpOnly;
  bool? showBattery;
  bool? showStandAlone;
  bool? showDpTime;
  String passwordValue = '';
  @override
  void initState() {
    getModes();

    super.initState();
  }

  @override
  void dispose() {
    getModes();
    technicianPassword.dispose();
    intervalHrController.dispose();
    intervalMinController.dispose();
    durationMinController.dispose();
    durationSecController.dispose();
    dpDelaySecController.dispose();
    loopingCycleCountController.dispose();
    technicianPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // log("show dp only-------" + showDpOnly.toString());
    // log("show timeand dp ------- " + showDpTime.toString());
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: width,
            child: Row(
              children: [
                Expanded(
                  child: StreamProvider<String>(
                    create: (_) =>
                        automatServices.readPassword(widget.deviceId),
                    initialData: '3',
                    updateShouldNotify: (_, __) => true,
                    child: Consumer<String>(
                      builder: (context, value, child) {
                        log("pass read----------" + value);
                        WidgetsBinding.instance!
                            .addPostFrameCallback((timeStamp) {
                          setState(() {
                            passwordValue = value;
                          });
                        });
                        return SizedBox(
                          height: height * 0.07,
                          child: ElevatedButton(
                              style: ButtonStyle(
                                  shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                      const RoundedRectangleBorder(
                                          side: BorderSide(
                                              color: kPrimaryColor))),
                                  backgroundColor:
                                      MaterialStateProperty.resolveWith(
                                          (states) => kPrimaryColor)),
                              onPressed: () async {
                                technicianPassword.clear();

                                //[53, 50, 57, 56, 53, 51, 55]
                                showDialog(
                                    context: context,
                                    builder: (_) => ShowPopUp(
                                        c: context,
                                        showPasswordRequired:
                                            showPasswordRequired,
                                        technicianPassword: technicianPassword,
                                        function: () async {
                                          setState(
                                            () {
                                              isLoading = true;
                                            },
                                          );
                                          List<int> password = [];

                                          for (int i = 0;
                                              i <
                                                  technicianPassword.text
                                                      .trim()
                                                      .length;
                                              i++) {
                                            password.add(technicianPassword.text
                                                .trim()
                                                .codeUnitAt(i));
                                            log("pas---------" +
                                                password.toString());
                                          }
                                          await automatServices.writePassword(
                                              widget.deviceId, password);

                                          await Future.delayed(
                                              const Duration(seconds: 2),
                                              () async {
                                            if (passwordValue == "1") {
                                              log("enter here-------");
                                              WidgetsFlutterBinding
                                                      .ensureInitialized()
                                                  .addPostFrameCallback(
                                                      (timeStamp) {
                                                setState(() {
                                                  isLoading = false;
                                                });
                                              });
                                              await automatServices
                                                  .writeRestore(widget.deviceId)
                                                  .whenComplete(() =>
                                                      Navigator.of(context,
                                                              rootNavigator:
                                                                  true)
                                                          .pop());
                                              getModes();
                                              log("outs here-------");
                                            } else {
                                              log("enter here---2----");
                                              showDialog(
                                                  context: context,
                                                  builder: (_) => AlertDialog(
                                                        actions: [
                                                          Center(
                                                              child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Text(
                                                              "wrong_password"
                                                                  .tr,
                                                              style:
                                                                  const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          )),
                                                          ElevatedButton(
                                                              style: ButtonStyle(
                                                                  backgroundColor:
                                                                      MaterialStateProperty.resolveWith(
                                                                          (states) =>
                                                                              kPrimaryColor)),
                                                              onPressed: () {
                                                                Navigator.of(_)
                                                                    .pop();
                                                              },
                                                              child:
                                                                  Text("ok".tr))
                                                        ],
                                                      ));
                                            }
                                          });
                                        },
                                        isLoading: isLoading));

                                // _showDialog(context, () async {
                                //   WidgetsBinding.instance!
                                //       .addPostFrameCallback((timeStamp) {
                                //     setState(() {
                                //       isLoading = true;
                                //     });
                                //   });
                                //   List<int> password = [];

                                //   for (int i = 0;
                                //       i < technicianPassword.text.trim().length;
                                //       i++) {
                                //     password.add(technicianPassword.text
                                //         .trim()
                                //         .codeUnitAt(i));
                                //     log("pas---------" + password.toString());
                                //   }
                                //   await automatServices.writePassword(
                                //       widget.deviceId, password);

                                //   await Future.delayed(Duration(seconds: 2),
                                //       () async {
                                //     if (passwordValue == "1") {
                                //       log("enter here-------");
                                //       WidgetsFlutterBinding.ensureInitialized()
                                //           .addPostFrameCallback((timeStamp) {
                                //         setState(() {
                                //           isLoading = false;
                                //         });
                                //       });
                                //       await automatServices
                                //           .writeRestore(widget.deviceId)
                                //           .whenComplete(() => Navigator.of(
                                //                   context,
                                //                   rootNavigator: true)
                                //               .pop());
                                //       getModes();

                                //       log("outs here-------");
                                //     } else {
                                //       log("enter here---2----");
                                //       EasyLoading.showToast(
                                //           "Password Incorrect");
                                //     }
                                //   });
                                // }, value);
                              },
                              child: Text(
                                'restore'.tr,
                                style: const TextStyle(
                                  color: kWhiteColor,
                                  fontSize: 20,
                                ),
                              )),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: StreamProvider<String>(
                    create: (_) =>
                        automatServices.readPassword(widget.deviceId),
                    initialData: '3',
                    updateShouldNotify: (_, __) => true,
                    child: Consumer<String>(builder: (context, value, child) {
                      log("pass savebutton----------" + value);
                      WidgetsBinding.instance!
                          .addPostFrameCallback((timeStamp) {
                        setState(() {
                          passwordValue = value;
                        });
                      });
                      return SizedBox(
                        height: height * 0.07,
                        child: ElevatedButton(
                          style: ButtonStyle(
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  const RoundedRectangleBorder(
                                      side: BorderSide(color: kPrimaryColor))),
                              backgroundColor:
                                  MaterialStateProperty.resolveWith(
                                      (states) => kPrimaryColor)),
                          onPressed: () async {
                            technicianPassword.clear();

                            showDialog(
                                context: context,
                                builder: (_) => ShowPopUp(
                                    showPasswordRequired: showPasswordRequired,
                                    technicianPassword: technicianPassword,
                                    function: () async {
                                      await sendDataFunction();
                                      if (saveList.length < 14 &&
                                          (showDpOnly == false &&
                                              showDpTime == true)) {
                                        showDialog(
                                            context: context,
                                            builder: (_) => AlertDialog(
                                                  actions: [
                                                    Center(
                                                        child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Text(
                                                        "choose_configurtion_correctly"
                                                            .tr,
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    )),
                                                    ElevatedButton(
                                                        style: ButtonStyle(
                                                            backgroundColor:
                                                                MaterialStateProperty
                                                                    .resolveWith(
                                                                        (states) =>
                                                                            kPrimaryColor)),
                                                        onPressed: () {
                                                          Navigator.of(_).pop();
                                                        },
                                                        child: Text("ok".tr))
                                                  ],
                                                ));
                                      } else {
                                        List<int> password = [];
                                        for (int i = 0;
                                            i <
                                                technicianPassword.text
                                                    .trim()
                                                    .length;
                                            i++) {
                                          password.add(technicianPassword.text
                                              .trim()
                                              .codeUnitAt(i));
                                          print("pas---------" +
                                              password.toString());
                                        }

                                        await automatServices.writePassword(
                                            widget.deviceId, password);
                                        await Future.delayed(
                                          const Duration(seconds: 1),
                                          () async {
                                            if (passwordValue == "1") {
                                              log("save -------- enter");
                                              WidgetsFlutterBinding
                                                      .ensureInitialized()
                                                  .addPostFrameCallback(
                                                      (timeStamp) {
                                                setState(() {
                                                  isLoading = false;
                                                });
                                              });
                                              await automatServices
                                                  .writeSave(
                                                      widget.deviceId, saveList)
                                                  .whenComplete(() =>
                                                      Navigator.of(context,
                                                              rootNavigator:
                                                                  true)
                                                          .pop());

                                              // Future.delayed(Duration(seconds: 1),
                                              //     () async {
                                              //   await
                                              getModes();
                                              // });
                                              log("out taa-------- ");
                                            } else {
                                              log("wrong--------");
                                              showDialog(
                                                  context: context,
                                                  builder: (_) => AlertDialog(
                                                        actions: [
                                                          Center(
                                                              child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Text(
                                                              "wrong_password"
                                                                  .tr,
                                                              style:
                                                                  const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          )),
                                                          ElevatedButton(
                                                              style: ButtonStyle(
                                                                  backgroundColor:
                                                                      MaterialStateProperty.resolveWith(
                                                                          (states) =>
                                                                              kPrimaryColor)),
                                                              onPressed: () {
                                                                Navigator.of(_)
                                                                    .pop();
                                                              },
                                                              child:
                                                                  Text("ok".tr))
                                                        ],
                                                      ));
                                            }
                                          },
                                        );
                                      }
                                    },
                                    isLoading: isLoading,
                                    c: context));

                            // _showDialog(context, () async {
                            //   sendDataFunction();
                            //   List<int> password = [];
                            //   for (int i = 0;
                            //       i < technicianPassword.text.trim().length;
                            //       i++) {
                            //     password.add(technicianPassword.text
                            //         .trim()
                            //         .codeUnitAt(i));
                            //     print("pas---------" + password.toString());
                            //   }

                            //   await automatServices.writePassword(
                            //       widget.deviceId, password);
                            //   Future.delayed(const Duration(seconds: 2),
                            //       () async {
                            //     if (value == "1") {
                            //       WidgetsFlutterBinding.ensureInitialized()
                            //           .addPostFrameCallback((timeStamp) {
                            //         setState(() {
                            //           isLoading = false;
                            //         });
                            //       });
                            //       await automatServices.writeSave(
                            //           widget.deviceId, saveList);
                            //       Navigator.of(context).pop();
                            //     } else {
                            //       EasyLoading.showToast("Password Incorrect");
                            //     }
                            //   });
                            // }, value);
                            // setState(() {});
                          },
                          child: Text(
                            'save'.tr,
                            style: const TextStyle(
                              color: kWhiteColor,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),
        appBar: AppBar(
            backgroundColor: const Color.fromARGB(255, 77, 221, 101),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              tooltip: "Back",
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            centerTitle: true,
            title: Text(
              'filter_configuration'.tr,
            )),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: SizedBox(
              height: height * 0.8,
              width: width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: height * 0.6,
                    width: width,
                    child: SizedBox(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Padding(
                          //   padding: EdgeInsets.all(8.0),
                          //   child: Center(
                          //       child: Text(
                          //     'filter_configuration'.tr,
                          //     style: TextStyle(
                          //         color: Colors.black,
                          //         fontSize: 20,
                          //         fontWeight: FontWeight.bold),
                          //   )),
                          // ),
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Container(
                                  // height: height * 0.14,
                                  width: width * 0.9,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(10)),
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.grey.shade400,
                                            blurRadius: 2,
                                            offset: Offset.zero)
                                      ]),
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          'operation_mode'.tr,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20),
                                        ),
                                      ),
                                      // FutureProvider<String>(
                                      //   create: (_) => automatServices
                                      //       .readOperationMode(widget.deviceId),
                                      //   initialData: '1',
                                      //   child: Consumer<String>(
                                      //     builder: (context, value, child) {
                                      //       //log("flu-------" + value);
                                      //       if (value == '1') {
                                      //         WidgetsBinding.instance!
                                      //             .addPostFrameCallback((_) {
                                      //           setState(() {
                                      //             showStandAlone = true;
                                      //             showBattery = false;
                                      //           });
                                      //         });
                                      //       } else if (value == '2') {
                                      //         WidgetsBinding.instance!
                                      //             .addPostFrameCallback((_) {
                                      //           setState(() {
                                      //             showBattery = true;
                                      //             showStandAlone = false;
                                      //           });
                                      //         });
                                      //       }
                                      //       return
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              child: ElevatedButton(
                                                  style: ButtonStyle(
                                                      shape: MaterialStateProperty.all<
                                                              RoundedRectangleBorder>(
                                                          RoundedRectangleBorder(
                                                              side: (showStandAlone == true &&
                                                                      showBattery ==
                                                                          false)
                                                                  ? BorderSide
                                                                      .none
                                                                  : const BorderSide(
                                                                      color:
                                                                          kPrimaryColor))),
                                                      backgroundColor: MaterialStateProperty.resolveWith(
                                                          (states) => (showStandAlone ==
                                                                      true &&
                                                                  showBattery == false)
                                                              ? kPrimaryColor
                                                              : kWhiteColor)),
                                                  onPressed: () {
                                                    setState(() {
                                                      showBattery = false;
                                                      showStandAlone = true;
                                                    });
                                                  },
                                                  child: Text(
                                                    'stand_alone'.tr,
                                                    style: TextStyle(
                                                      color: (showStandAlone ==
                                                                  true &&
                                                              showBattery ==
                                                                  false)
                                                          ? kWhiteColor
                                                          : kPrimaryColor,
                                                    ),
                                                  )),
                                            ),
                                            Expanded(
                                              child: ElevatedButton(
                                                  style: ButtonStyle(
                                                      shape: MaterialStateProperty.all<
                                                              RoundedRectangleBorder>(
                                                          RoundedRectangleBorder(
                                                              side: (showBattery ==
                                                                          true &&
                                                                      showStandAlone ==
                                                                          false)
                                                                  ? BorderSide
                                                                      .none
                                                                  : const BorderSide(
                                                                      color:
                                                                          kPrimaryColor))),
                                                      backgroundColor: MaterialStateProperty.resolveWith(
                                                          (states) => (showBattery == true &&
                                                                  showStandAlone == false)
                                                              ? kPrimaryColor
                                                              : kWhiteColor)),
                                                  onPressed: () {
                                                    setState(() {
                                                      showBattery = true;
                                                      showStandAlone = false;
                                                    });
                                                  },
                                                  child: Text(
                                                    'battery_of_filters'.tr,
                                                    style: TextStyle(
                                                      color: (showBattery ==
                                                                  true &&
                                                              showStandAlone ==
                                                                  false)
                                                          ? kWhiteColor
                                                          : kPrimaryColor,
                                                    ),
                                                  )),
                                            ),
                                          ],
                                        ),
                                      ),
                                      //     },
                                      //   ),
                                      // ),
                                    ],
                                  )),
                            ),
                          ),
                          // FutureProvider<String>(
                          //   updateShouldNotify: (_, __) => false,
                          //   create: (_) =>
                          //       automatServices.readFlushingMode(widget.deviceId),
                          //   initialData: '0',
                          //   child: Consumer<String>(
                          //     builder: (context, value, child) {
                          //       if (value == '1') {
                          //         WidgetsBinding.instance!
                          //             .addPostFrameCallback((timeStamp) {
                          //           setState(() {
                          //             showDpOnly = true;
                          //             showDpTime = false;
                          //           });
                          //         });
                          //       } else if (value == '2') {
                          //         WidgetsBinding.instance!
                          //             .addPostFrameCallback((timeStamp) {
                          //           setState(() {
                          //             showDpTime = true;
                          //             showDpOnly = false;
                          //           });
                          //         });
                          //       }
                          //       //log("flu-------" + value);
                          //       return
                          Padding(
                            padding: const EdgeInsets.all(4),
                            child: Container(
                                //height: height * 0.14,
                                width: width * 0.9,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10)),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.grey.shade400,
                                          blurRadius: 2,
                                          offset: Offset.zero)
                                    ]),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        'flushing_mode'.tr,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: ElevatedButton(
                                                style: ButtonStyle(
                                                    shape: MaterialStateProperty.all<
                                                            RoundedRectangleBorder>(
                                                        RoundedRectangleBorder(
                                                            side: (showDpOnly ==
                                                                        true &&
                                                                    showDpTime ==
                                                                        false)
                                                                ? BorderSide
                                                                    .none
                                                                : const BorderSide(
                                                                    color:
                                                                        kPrimaryColor))),
                                                    backgroundColor: MaterialStateProperty
                                                        .resolveWith((states) =>
                                                            showDpOnly == true
                                                                ? kPrimaryColor
                                                                : kWhiteColor)),
                                                onPressed: () {
                                                  setState(() {
                                                    showDpTime = false;
                                                    showDpOnly = true;
                                                  });
                                                },
                                                child: Text(
                                                  'dp_only'.tr,
                                                  style: TextStyle(
                                                    color: showDpOnly == true
                                                        ? kWhiteColor
                                                        : kPrimaryColor,
                                                  ),
                                                )),
                                          ),
                                          Expanded(
                                            child: ElevatedButton(
                                                style: ButtonStyle(
                                                    shape: MaterialStateProperty.all<
                                                            RoundedRectangleBorder>(
                                                        RoundedRectangleBorder(
                                                            side: (showDpTime ==
                                                                        false &&
                                                                    showDpOnly ==
                                                                        false)
                                                                ? const BorderSide(
                                                                    color:
                                                                        kPrimaryColor)
                                                                : BorderSide
                                                                    .none)),
                                                    backgroundColor: MaterialStateProperty
                                                        .resolveWith((states) =>
                                                            showDpTime == false
                                                                ? kWhiteColor
                                                                : kPrimaryColor)),
                                                onPressed: () {
                                                  setState(() {
                                                    showDpTime = true;
                                                    showDpOnly = false;
                                                  });
                                                },
                                                child: Text(
                                                  'dp&time'.tr,
                                                  style: TextStyle(
                                                    color: showDpTime == true
                                                        ? kWhiteColor
                                                        : kPrimaryColor,
                                                  ),
                                                )),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )),
                          ),
                          //     },
                          //   ),
                          // ),

                          Padding(
                            padding: const EdgeInsets.all(4),
                            child: Container(
                                height: height * 0.10,
                                width: width * 0.9,
                                decoration: BoxDecoration(
                                    color: (showDpOnly == true &&
                                            showDpTime == false)
                                        ? kGreyColor.withOpacity(0.1)
                                        : Colors.white,
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10)),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.grey.shade400,
                                          blurRadius: 2,
                                          offset: Offset.zero)
                                    ]),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        'flushing_interval'.tr,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20),
                                      ),
                                    ),
                                    Center(
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                height: height * 0.04,
                                                width: width * 0.15,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade100,
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(10)),
                                                ),
                                                child: TextField(
                                                  controller:
                                                      intervalHrController,
                                                  enabled: (showDpOnly == true)
                                                      ? false
                                                      : true,
                                                  keyboardType:
                                                      TextInputType.phone,
                                                  inputFormatters: [
                                                    LengthLimitingTextInputFormatter(
                                                        2),
                                                    FilteringTextInputFormatter
                                                        .allow(RegExp("[0-9]")),
                                                  ],
                                                  textAlign: TextAlign.center,
                                                  decoration:
                                                      const InputDecoration(
                                                          border:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius.all(
                                                                    Radius.circular(
                                                                        50.0)),
                                                          ),
                                                          //  border: InputBorder.none,
                                                          focusedBorder:
                                                              InputBorder.none,
                                                          enabledBorder:
                                                              InputBorder.none,
                                                          errorBorder:
                                                              InputBorder.none,
                                                          disabledBorder:
                                                              InputBorder.none,
                                                          //hintText: 'hr'.tr,
                                                          //suffixText: 'hr'.tr,
                                                          //suffix: Text('hr'.tr),
                                                          contentPadding:
                                                              EdgeInsets.all(
                                                                  12),
                                                          hintTextDirection:
                                                              TextDirection
                                                                  .rtl),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(4.0),
                                                child: Text('hr'.tr),
                                              ),
                                            ],
                                          ),
                                          SizedBox(width: width * 0.2),
                                          Row(
                                            children: [
                                              Container(
                                                height: height * 0.04,
                                                width: width * 0.15,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade100,
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(10)),
                                                ),
                                                child: TextField(
                                                  controller:
                                                      intervalMinController,
                                                  enabled: (showDpOnly == true)
                                                      ? false
                                                      : true,
                                                  keyboardType:
                                                      TextInputType.phone,
                                                  inputFormatters: [
                                                    LengthLimitingTextInputFormatter(
                                                        2),
                                                    FilteringTextInputFormatter
                                                        .allow(RegExp("[0-9]")),
                                                  ],
                                                  textAlign: TextAlign.center,
                                                  decoration:
                                                      const InputDecoration(
                                                          border:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius.all(
                                                                    Radius.circular(
                                                                        30.0)),
                                                          ),
                                                          //  border: InputBorder.none,
                                                          focusedBorder:
                                                              InputBorder.none,
                                                          enabledBorder:
                                                              InputBorder.none,
                                                          errorBorder:
                                                              InputBorder.none,
                                                          disabledBorder:
                                                              InputBorder.none,
                                                          //hintText 'min'.tr,
                                                          //suffixText: 'min'.tr,
                                                          //suffix: Text('min'.tr),
                                                          contentPadding:
                                                              EdgeInsets.all(
                                                                  12),
                                                          hintTextDirection:
                                                              TextDirection
                                                                  .rtl),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(4.0),
                                                child: Text('min'.tr),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                )),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(4),
                            child: Container(
                                height: height * 0.10,
                                width: width * 0.9,
                                decoration: BoxDecoration(
                                    color: (showDpTime == false &&
                                            showDpOnly == false)
                                        ? kGreyColor.withOpacity(0.1)
                                        : Colors.white,
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10)),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.grey.shade400,
                                          blurRadius: 2,
                                          offset: Offset.zero)
                                    ]),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        'flushing_duration'.tr,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20),
                                      ),
                                    ),
                                    Center(
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                height: height * 0.04,
                                                width: width * 0.15,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade100,
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(10)),
                                                ),
                                                child: TextField(
                                                  controller:
                                                      durationMinController,
                                                  keyboardType:
                                                      TextInputType.phone,
                                                  inputFormatters: [
                                                    LengthLimitingTextInputFormatter(
                                                        2),
                                                    FilteringTextInputFormatter
                                                        .allow(RegExp("[0-9]")),
                                                  ],
                                                  textAlign: TextAlign.center,
                                                  decoration:
                                                      const InputDecoration(
                                                          border:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius.all(
                                                                    Radius.circular(
                                                                        30.0)),
                                                          ),
                                                          //  border: InputBorder.none,
                                                          focusedBorder:
                                                              InputBorder.none,
                                                          enabledBorder:
                                                              InputBorder.none,
                                                          errorBorder:
                                                              InputBorder.none,
                                                          disabledBorder:
                                                              InputBorder.none,
                                                          //hintText 'min'.tr,
                                                          //suffixText: 'min'.tr,
                                                          //suffix: Text('min'.tr),
                                                          contentPadding:
                                                              EdgeInsets.all(
                                                                  12),
                                                          hintTextDirection:
                                                              TextDirection
                                                                  .rtl),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(4.0),
                                                child: Text('min'.tr),
                                              ),
                                            ],
                                          ),
                                          SizedBox(width: width * 0.2),
                                          Row(
                                            children: [
                                              Container(
                                                height: height * 0.04,
                                                width: width * 0.15,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade100,
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(10)),
                                                ),
                                                child: TextField(
                                                  controller:
                                                      durationSecController,
                                                  keyboardType:
                                                      TextInputType.phone,
                                                  inputFormatters: [
                                                    LengthLimitingTextInputFormatter(
                                                        2),
                                                    FilteringTextInputFormatter
                                                        .allow(RegExp("[0-9]")),
                                                  ],
                                                  // enabled: (showDpTime == false &&
                                                  //         showDpOnly == false)
                                                  //     ? true
                                                  //     : false,
                                                  textAlign: TextAlign.center,
                                                  decoration:
                                                      const InputDecoration(
                                                          border:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius.all(
                                                                    Radius.circular(
                                                                        30.0)),
                                                          ),
                                                          //  border: InputBorder.none,
                                                          focusedBorder:
                                                              InputBorder.none,
                                                          enabledBorder:
                                                              InputBorder.none,
                                                          errorBorder:
                                                              InputBorder.none,
                                                          disabledBorder:
                                                              InputBorder.none,
                                                          //hintText 'sec'.tr,
                                                          //suffixText: 'sec'.tr,
                                                          //suffix: Text('sec'.tr),
                                                          // contentPadding:
                                                          //     EdgeInsets.all(12),
                                                          hintTextDirection:
                                                              TextDirection
                                                                  .rtl),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(4.0),
                                                child: Text('sec'.tr),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                )),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Flexible(
                    //flex: 1,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(4),
                          child: Container(
                              height: height * 0.06,
                              width: width * 0.9,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(10)),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.grey.shade400,
                                        blurRadius: 2,
                                        offset: Offset.zero)
                                  ]),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'dp_delay'.tr,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        height: height * 0.04,
                                        width: width * 0.15,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(10)),
                                        ),
                                        child: TextField(
                                          controller: dpDelaySecController,
                                          keyboardType: TextInputType.phone,
                                          inputFormatters: [
                                            LengthLimitingTextInputFormatter(2),
                                            FilteringTextInputFormatter.allow(
                                                RegExp("[0-9]")),
                                          ],
                                          decoration: const InputDecoration(
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(30.0)),
                                              ),
                                              focusedBorder: InputBorder.none,
                                              enabledBorder: InputBorder.none,
                                              errorBorder: InputBorder.none,
                                              disabledBorder: InputBorder.none,
                                              //hintText 'sec'.tr,
                                              //suffixText: ,
                                              //suffix: Text('sec'.tr),
                                              contentPadding:
                                                  EdgeInsets.all(12),
                                              hintTextDirection:
                                                  TextDirection.rtl),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Text('sec'.tr),
                                      )
                                    ],
                                  ),
                                ],
                              )),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4),
                          child: Container(
                              height: height * 0.06,
                              width: width * 0.9,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(10)),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.grey.shade400,
                                        blurRadius: 2,
                                        offset: Offset.zero)
                                  ]),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'looping_cycle'.tr,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                  ),
                                  //const Spacer(),
                                  Row(
                                    children: [
                                      Container(
                                        height: height * 0.04,
                                        width: width * 0.15,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(10)),
                                        ),
                                        child: Center(
                                          child: TextField(
                                            controller:
                                                loopingCycleCountController,
                                            keyboardType: TextInputType.phone,
                                            inputFormatters: [
                                              LengthLimitingTextInputFormatter(
                                                  2),
                                              FilteringTextInputFormatter.allow(
                                                  RegExp("[0-9]")),
                                            ],
                                            textAlign: TextAlign.center,
                                            decoration: const InputDecoration(
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(
                                                              30.0)),
                                                ),

                                                //  border: InputBorder.none,
                                                focusedBorder: InputBorder.none,
                                                enabledBorder: InputBorder.none,
                                                errorBorder: InputBorder.none,
                                                disabledBorder:
                                                    InputBorder.none,
                                                //hintText 'count'.tr,
                                                //suffixText: 'count'.tr,
                                                //suffix: Text('count'.tr),
                                                contentPadding:
                                                    EdgeInsets.all(12),
                                                hintTextDirection:
                                                    TextDirection.rtl),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Text('count'.tr),
                                      ),
                                    ],
                                  ),
                                ],
                              )),
                        ),
                      ],
                    ),
                  ),

                  // Padding(
                  //   padding: const EdgeInsets.all(4),
                  //   child:
                  //   Padding(
                  //     padding: const EdgeInsets.all(8.0),
                  //     child: Row(
                  //       crossAxisAlignment: CrossAxisAlignment.center,
                  //       mainAxisAlignment: MainAxisAlignment.center,
                  //       children: [
                  //         Expanded(
                  //           child: ElevatedButton(
                  //               style: ButtonStyle(
                  //                   shape: MaterialStateProperty.all<
                  //                           RoundedRectangleBorder>(
                  //                       const RoundedRectangleBorder(
                  //                           side: BorderSide(
                  //                               color: kPrimaryColor))),
                  //                   backgroundColor:
                  //                       MaterialStateProperty.resolveWith(
                  //                           (states) => kPrimaryColor)),
                  //               onPressed: () {},
                  //               child: const Text(
                  //                 'Restore',
                  //                 style: const TextStyle(
                  //                   color: kWhiteColor,
                  //                 ),
                  //               )),
                  //         ),
                  //         const Spacer(),
                  //         Expanded(
                  //           child: ElevatedButton(
                  //               style: ButtonStyle(
                  //                   shape: MaterialStateProperty.all<
                  //                           RoundedRectangleBorder>(
                  //                       const RoundedRectangleBorder(
                  //                           side: const BorderSide(
                  //                               color: kPrimaryColor))),
                  //                   backgroundColor:
                  //                       MaterialStateProperty.resolveWith(
                  //                           (states) => kPrimaryColor)),
                  //               onPressed: () {
                  //                 setState(() {});
                  //               },
                  //               child: const Text(
                  //                 'Save',
                  //                 style: TextStyle(
                  //                   color: kWhiteColor,
                  //                 ),
                  //               )),
                  //         ),
                  //       ],
                  //     ),
                  //   ),

                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget popUp(Function() function) {
    return StatefulBuilder(builder: (context, setState) {
      return AlertDialog(
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text(
                  "enter_techinician_password".tr,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
                controller: technicianPassword,
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
          showPasswordRequired == true
              ? Text(
                  "password_required".tr,
                  style: const TextStyle(color: Colors.red),
                )
              : Container(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.resolveWith(
                              (states) => kPrimaryColor)),
                      onPressed: () {
                        getModes();
                        Navigator.of(context).pop();
                      },
                      child: Text("cancel".tr)),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                    child: ElevatedButton.icon(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.resolveWith(
                                (states) => kPrimaryColor)),
                        onPressed: function,
                        icon: isLoading == false
                            ? const Icon(Icons.done)
                            : Container(
                                width: 24,
                                height: 24,
                                padding: const EdgeInsets.all(2.0),
                                child: const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 3,
                                ),
                              ),
                        label: Text("save".tr)))
              ],
            ),
          ),
        ],
      );
    });
  }
}

class ShowPopUp extends StatefulWidget {
  final bool showPasswordRequired;
  final TextEditingController technicianPassword;
  final Function()? getModes;
  final Function() function;
  final bool isLoading;
  final BuildContext c;
  const ShowPopUp(
      {Key? key,
      required this.showPasswordRequired,
      required this.technicianPassword,
      this.getModes,
      required this.function,
      required this.isLoading,
      required this.c})
      : super(key: key);

  @override
  State<ShowPopUp> createState() => _ShowPopUpState();
}

class _ShowPopUpState extends State<ShowPopUp> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Text(
                "enter_techinician_password".tr,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
              controller: widget.technicianPassword,
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
        widget.showPasswordRequired == true
            ? Text(
                "password_required".tr,
                style: const TextStyle(color: Colors.red),
              )
            : Container(),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.resolveWith(
                            (states) => kPrimaryColor)),
                    onPressed: () {
                      widget.getModes!();
                      Navigator.of(widget.c, rootNavigator: true).pop();
                    },
                    child: Text("cancel".tr)),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                  child: ElevatedButton.icon(
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.resolveWith(
                              (states) => kPrimaryColor)),
                      onPressed: widget.function,
                      icon:
                          // widget.isLoading == false
                          //     ?
                          const Icon(Icons.done),
                      // : Container(
                      //     width: 24,
                      //     height: 24,
                      //     padding: const EdgeInsets.all(2.0),
                      //     child: const CircularProgressIndicator(
                      //       color: Colors.white,
                      //       strokeWidth: 3,
                      //     ),
                      //   ),
                      label: Text("save".tr)))
            ],
          ),
        ),
      ],
    );
  }
}
