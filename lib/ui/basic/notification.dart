import 'package:automat/ui/basic/dp_count.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 77, 221, 101),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            tooltip: "Back",
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: Text("notification".tr),
        ),
        body: Column(
          children: [
            GestureDetector(
              onTap: () {
                // Navigator.of(context)
                //     .push(MaterialPageRoute(builder: (_) => DpCount()));
              },
              child: Card(
                elevation: 5,
                child: ListTile(
                  trailing: CircleAvatar(
                      backgroundColor: Colors.red,
                      child: Text(
                        "error".tr,
                        style: TextStyle(color: Colors.white),
                      )),
                  subtitle: Text("5A:36:2d:3d"),
                  title: Text(
                    "Automatic Device",
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}
