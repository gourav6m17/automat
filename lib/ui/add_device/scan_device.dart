import 'package:automat/Constant/const.dart';
import 'package:automat/ui/add_device/add_device.dart';
import 'package:automat/ui/basic/language_selection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ScanDevices extends StatefulWidget {
  const ScanDevices({Key? key}) : super(key: key);

  @override
  State<ScanDevices> createState() => _ScanDevicesState();
}

class _ScanDevicesState extends State<ScanDevices> {
  GlobalKey<ScaffoldState> globalKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SafeArea(
        child: Scaffold(
          bottomNavigationBar: Container(
            height: height * 0.17,
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
                    child: Container(
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
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => const AddDevice()));
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                CupertinoIcons.add,
                                color: Colors.white,
                              ),
                              Text(
                                'Add Device',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18),
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
                          'Instruction manual',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        )),
                  ),
                )
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
                            "Scanning",
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                          Text(
                            "0 Device Found",
                            style: TextStyle(),
                          ),
                        ],
                      )
                    ],
                  ),
                  const Divider(),
                ],
              ),
              ListView.builder(
                shrinkWrap: true,
                itemCount: 10,
                itemBuilder: (context, position) {
                  return Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Container(
                      height: height * 0.1,
                      width: width,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
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
                            child: Image.asset('assets/device.jpg'),
                          ),
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                'Automate devices',
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                          ),
                          Icon(Icons.more_vert_sharp),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
