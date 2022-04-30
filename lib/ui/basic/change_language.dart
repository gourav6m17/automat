import 'package:automat/ui/basic/home.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Constant/const.dart';

class ChangeLanguage extends StatefulWidget {
  const ChangeLanguage({Key? key}) : super(key: key);

  @override
  State<ChangeLanguage> createState() => _ChangeLanguageState();
}

class _ChangeLanguageState extends State<ChangeLanguage> {
  List languages = [
    'English',
    'हिन्दी',
  ];
  List locale = [Locale('en', 'US'), Locale('hi', 'IN')];
  String? currentItemSelected;
  String? newValueSelected;
  int isLangContainer = -1;

  @override
  Widget build(BuildContext context) {
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
      ),
      body: Container(
        width: width,
        height: height,
        decoration: const BoxDecoration(
            image: DecorationImage(
                fit: BoxFit.cover, image: AssetImage("assets/bg.png"))),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Change your language",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: height * 0.04,
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: languages.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        setState(() {
                          isLangContainer = index;
                        });
                        Get.updateLocale(locale[index]);
                      },
                      child: Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            height: height * 0.075,
                            width: width,
                            decoration: BoxDecoration(
                              color: isLangContainer == index
                                  ? kPrimaryColor
                                  : Colors.greenAccent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                                child: Text(
                              languages[index],
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500),
                            )),
                          ),
                          const SizedBox(
                            height: 10,
                          )
                        ],
                      ),
                    );
                  }),
            ),
            SizedBox(
              height: height * 0.10,
            ),
            // Container(
            //   width: width * 0.5,
            //   decoration: BoxDecoration(
            //     borderRadius: BorderRadius.circular(10),
            //     border: Border.all(
            //       color: Colors.white,
            //     ),
            //   ),
            //   child: DropdownButton(
            //     isExpanded: true,
            //     style: TextStyle(
            //       color: Colors.grey,
            //     ),
            //     iconSize: 25,
            //     iconEnabledColor: Colors.white,
            //     hint: Center(
            //       child: Text(
            //         'Select Language',
            //         textAlign: TextAlign.center,
            //         style: TextStyle(
            //             color: Colors.white,
            //             fontWeight: FontWeight.bold,
            //             fontSize: 16),
            //       ),
            //     ),
            //     value: currentItemSelected,
            //     onChanged: (String? newValueSelected) {
            //       setState(() {
            //         this.currentItemSelected = newValueSelected;
            //       });
            //     },
            //     items: languages.map((dropDownStringItem) {
            //       return DropdownMenuItem<String>(
            //         child: Padding(
            //           padding: const EdgeInsets.all(10),
            //           child: Text(
            //             dropDownStringItem,
            //             style: TextStyle(
            //               color: Colors.black,
            //             ),
            //           ),
            //         ),
            //         value: dropDownStringItem,
            //       );
            //     }).toList(),
            //   ),
            // ),
            // SizedBox(
            //   height: height * 0.10,
            // ),
            InkWell(
              onTap: () {
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const Home()));
              },
              child: const CircleAvatar(
                backgroundColor: kPrimaryColor,
                radius: 24,
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: kWhiteColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
