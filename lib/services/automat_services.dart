import 'dart:async';

import 'package:automat/Constant/service_ids.dart';
import 'package:automat/plugins/reactive_ble/ble/reactive_state.dart';
import 'package:automat/plugins/reactive_ble/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'dart:developer' as logg;

class AutomatServices
//implements ReactiveState<QualifiedCharacteristic>
{
  AutomatServices();

  @override
  Stream<QualifiedCharacteristic> get state => throw UnimplementedError();
  FlutterReactiveBle flutterReactiveBle = FlutterReactiveBle();

  Stream<String> readDpCycleSTream(String deviceId) async* {
    List<int> list = [];

    Timer.periodic(const Duration(milliseconds: 500), (_) async {
      list.addAll(await flutterReactiveBle.readCharacteristic(
          qualifiedChar(Uuid.parse(ServiceIds.DP_CYCLE_COUNT), deviceId)));
      log("---dp cycle-----" + list.toList().toString());
    });
    // await Future.delayed(const Duration(milliseconds: 500), () async {
    //   list.addAll(await flutterReactiveBle.readCharacteristic(
    //       qualifiedChar(Uuid.parse(ServiceIds.DP_CYCLE_COUNT), deviceId)));
    //   log("---dp cycle-----" + list.toList().toString());
    // });

    yield convertAscii(list).toString();
  }

  Stream<String> readDpCycle(String deviceId) async* {
    List<int> list = [];
    while (deviceId.isNotEmpty) {
      await Future.delayed(
        const Duration(seconds: 2),
        () async {
          list.clear();
          list.addAll(await flutterReactiveBle.readCharacteristic(
              qualifiedChar(Uuid.parse(ServiceIds.DP_CYCLE_COUNT), deviceId)));
          log("---dp cycle-----" + list.toList().toString());
        },
      );
      yield convertAscii(list).toString();
    }
  }

  //[46,76,34,57]
  Stream<String> readTimeCycle(String deviceId) async* {
    List<int> list = [];
    while (deviceId.isNotEmpty) {
      await Future.delayed(
        const Duration(seconds: 2),
        () async {
          list.clear();
          list.addAll(await flutterReactiveBle.readCharacteristic(qualifiedChar(
              Uuid.parse(ServiceIds.TIME_CYCLE_COUNT), deviceId)));
          log("---time cycle-----" + list.toList().toString());
        },
      );
      yield convertAscii(list).toString();
    }
  }

  Stream<String> readManualCycle(String deviceId) async* {
    List<int> list = [];
    while (deviceId.isNotEmpty) {
      await Future.delayed(
        const Duration(seconds: 2),
        () async {
          list.clear();
          list.addAll(await flutterReactiveBle.readCharacteristic(qualifiedChar(
              Uuid.parse(ServiceIds.MANUAL_CYCLE_COUNT), deviceId)));
          log("----manual cycle----" + list.toList().toString());
        },
      );
      yield convertAscii(list).toString();
    }
  }

  Stream<String> readOperationModeStream(String deviceId) async* {
    List<int> list = [];
    while (deviceId.isNotEmpty) {
      await Future.delayed(
        const Duration(seconds: 2),
        () async {
          list.clear();
          list.addAll(await flutterReactiveBle.readCharacteristic(
              qualifiedChar(Uuid.parse(ServiceIds.OPERATION_MODE), deviceId)));
          log("---op mode-----" + list.toList().toString());
        },
      );
      yield convertAscii(list).toString();
    }
  }

  Future<String> readOperationMode(String deviceId) async {
    List<int> list = [];
    list.clear();
    list.addAll(await flutterReactiveBle.readCharacteristic(
        qualifiedChar(Uuid.parse(ServiceIds.OPERATION_MODE), deviceId)));
    log("---op mode-----" + list.toList().toString());

    return convertAscii(list).toString();
  }

  Future<String> readFlushingMode(String deviceId) async {
    List<int> list = [];

    list.addAll(await flutterReactiveBle.readCharacteristic(
        qualifiedChar(Uuid.parse(ServiceIds.FLUSHING_MODE), deviceId)));
    log("--flsh mode------" + list.toList().toString());

    return convertAscii(list).toString();
  }

  Stream<String> readFlushingModeAsStream(String deviceId) async* {
    List<int> list = [];
    while (deviceId.isNotEmpty) {
      await Future.delayed(
        const Duration(seconds: 2),
        () async {
          list.clear();
          list.addAll(await flutterReactiveBle.readCharacteristic(
              qualifiedChar(Uuid.parse(ServiceIds.FLUSHING_MODE), deviceId)));
          log("--flsh mode------" + list.toList().toString());
        },
      );
      yield convertAscii(list).toString();
    }
  }

  Future<String> readFlushingInterval(String deviceId) async {
    List<int> list = [];
    list.clear();
    list.addAll(await flutterReactiveBle.readCharacteristic(
        qualifiedChar(Uuid.parse(ServiceIds.FLUSHING_INTERVAL), deviceId)));
    log("---flu int-----" + list.toList().toString());
    return convertAscii(list).toString();
    // while (deviceId.isNotEmpty) {
    //   await Future.delayed(
    //     const Duration(seconds: 2),
    //     () async {
    //       list.clear();
    //       list.addAll(await flutterReactiveBle.readCharacteristic(qualifiedChar(
    //           Uuid.parse(ServiceIds.FLUSHING_INTERVAL), deviceId)));
    //       log("---flu int-----" + list.toList().toString());
    //     },
    //   );
    //   yield convertAscii(list).toString();
    // }
  }
  // Stream<String> readFlushingInterval(String deviceId) async* {
  //   List<int> list = [];
  //   await Future.delayed(const Duration(milliseconds: 500), () async {
  //     list.addAll(await flutterReactiveBle.readCharacteristic(
  //         qualifiedChar(Uuid.parse(ServiceIds.FLUSHING_INTERVAL), deviceId)));
  //     log("---flu int-----" + list.toList().toString());
  //   });

  //   yield convertAscii(list).toString();
  // }
  Future<String> readFlushingDuration(String deviceId) async {
    List<int> list = [];
    list.clear();
    list.addAll(await flutterReactiveBle.readCharacteristic(
        qualifiedChar(Uuid.parse(ServiceIds.FLUSHING_DURATION), deviceId)));
    log("---flu dur-----" + list.toList().toString());
    return convertAscii(list).toString();
    // while (deviceId.isNotEmpty) {
    //   await Future.delayed(
    //     const Duration(seconds: 2),
    //     () async {
    //       list.clear();
    //       list.addAll(await flutterReactiveBle.readCharacteristic(qualifiedChar(
    //           Uuid.parse(ServiceIds.FLUSHING_DURATION), deviceId)));
    //       log("---flu dur-----" + list.toList().toString());
    //     },
    //   );
    //   yield convertAscii(list).toString();
    // }
  }

  // Stream<String> readFlushingDuration(String deviceId) async* {
  //   List<int> list = [];
  //   await Future.delayed(const Duration(milliseconds: 500), () async {
  //     list.addAll(await flutterReactiveBle.readCharacteristic(
  //         qualifiedChar(Uuid.parse(ServiceIds.FLUSHING_DURATION), deviceId)));
  //     log("---flu dur-----" + list.toList().toString());
  //   });

  //   yield convertAscii(list).toString();
  // }
  Future<String> readDpDelay(String deviceId) async {
    List<int> list = [];
    list.clear();
    list.addAll(await flutterReactiveBle.readCharacteristic(
        qualifiedChar(Uuid.parse(ServiceIds.DP_DELAY), deviceId)));
    log("---dp delay-----" + list.toList().toString());
    return convertAscii(list).toString();
    // while (deviceId.isNotEmpty) {
    //   await Future.delayed(
    //     const Duration(seconds: 2),
    //     () async {
    //       list.clear();
    //       list.addAll(await flutterReactiveBle.readCharacteristic(
    //           qualifiedChar(Uuid.parse(ServiceIds.DP_DELAY), deviceId)));
    //       log("---dp delay-----" + list.toList().toString());
    //     },
    //   );
    //   yield convertAscii(list).toString();
    // }
  }
  // Stream<String> readDpDelay(String deviceId) async* {
  //   List<int> list = [];
  //   await Future.delayed(const Duration(milliseconds: 500), () async {
  //     list.addAll(await flutterReactiveBle.readCharacteristic(
  //         qualifiedChar(Uuid.parse(ServiceIds.DP_DELAY), deviceId)));
  //     log("---dp delay-----" + list.toList().toString());
  //   });

  //   yield convertAscii(list).toString();
  // }
  Future<String> readLoopingCycle(String deviceId) async {
    List<int> list = [];
    list.clear();
    list.addAll(await flutterReactiveBle.readCharacteristic(
        qualifiedChar(Uuid.parse(ServiceIds.LOOPING_CYCLE), deviceId)));
    log("----loop cycle----" + list.toList().toString());

    return convertAscii(list).toString();
    // while (deviceId.isNotEmpty) {
    //   await Future.delayed(
    //     const Duration(seconds: 2),
    //     () async {

    //     },
    //   );
    //   yield convertAscii(list).toString();
    // }
  }
  // Stream<String> readLoopingCycle(String deviceId) async* {
  //   List<int> list = [];
  //   await Future.delayed(const Duration(milliseconds: 500), () async {
  //     list.addAll(await flutterReactiveBle.readCharacteristic(
  //         qualifiedChar(Uuid.parse(ServiceIds.LOOPING_CYCLE), deviceId)));
  //     log("----loop cycle----" + list.toList().toString());
  //   });

  //   yield convertAscii(list).toString();
  // }
  Stream<String> readRemainingFlushingInterval(String deviceId) async* {
    List<int> list = [];
    while (deviceId.isNotEmpty) {
      await Future.delayed(
        const Duration(milliseconds: 500),
        () async {
          list.clear();
          list.addAll(await flutterReactiveBle.readCharacteristic(qualifiedChar(
              Uuid.parse(ServiceIds.REMAINING_FLUSHING_INTERVAL), deviceId)));
          log("---flu inter-----" + list.toList().toString());
        },
      );
      yield convertAscii(list).toString();
    }
  }
  // Stream<String> readRemainingFlushingInterval(String deviceId) async* {
  //   List<int> list = [];
  //   await Future.delayed(const Duration(milliseconds: 500), () async {
  //     list.addAll(await flutterReactiveBle.readCharacteristic(qualifiedChar(
  //         Uuid.parse(ServiceIds.REMAINING_FLUSHING_INTERVAL), deviceId)));
  //     log("---flu inter-----" + list.toList().toString());
  //   });

  //   yield convertAscii(list).toString();
  // }
  Stream<String> readRemainingFlushingDuration(String deviceId) async* {
    List<int> list = [];
    while (deviceId.isNotEmpty) {
      await Future.delayed(
        const Duration(milliseconds: 500),
        () async {
          list.clear();
          list.addAll(await flutterReactiveBle.readCharacteristic(qualifiedChar(
              Uuid.parse(ServiceIds.REMAINING_FLUSHING_DURATION), deviceId)));
          log("---flu duration-----" + list.toList().toString());
          logg.log("--convert--" + convertAscii(list).toString());
        },
      );
      yield convertAscii(list).toString();
    }
  }
  // Stream<String> readRemainingFlushingDuration(String deviceId) async* {
  //   List<int> list = [];
  //   await Future.delayed(const Duration(milliseconds: 500), () async {
  //     list.addAll(await flutterReactiveBle.readCharacteristic(qualifiedChar(
  //         Uuid.parse(ServiceIds.REMAINING_FLUSHING_DURATION), deviceId)));
  //     log("---flu duration-----" + list.toList().toString());
  //   });

  //   yield convertAscii(list).toString();
  // }

  Stream<String> readSaveButton(String deviceId) async* {
    List<int> list = [];
    await Future.delayed(const Duration(milliseconds: 500), () async {
      list.addAll(await flutterReactiveBle.readCharacteristic(
          qualifiedChar(Uuid.parse(ServiceIds.SAVE_BUTTON), deviceId)));
      log("---save butn-----" + list.toList().toString());
    });

    yield convertAscii(list).toString();
  }

  Stream<String> readRestoreDefaultData(String deviceId) async* {
    List<int> list = [];
    await Future.delayed(const Duration(milliseconds: 500), () async {
      list.addAll(await flutterReactiveBle.readCharacteristic(qualifiedChar(
          Uuid.parse(ServiceIds.RESTORE_DEFAULT_DATA), deviceId)));
      log("---defult res-----" + list.toList().toString());
    });

    yield convertAscii(list).toString();
  }

  Stream<String> readManualButton(String deviceId) async* {
    List<int> list = [];
    while (deviceId.isNotEmpty) {
      await Future.delayed(
        const Duration(milliseconds: 500),
        () async {
          list.clear();
          list.addAll(await flutterReactiveBle.readCharacteristic(
              qualifiedChar(Uuid.parse(ServiceIds.MANUAL_BUTTON), deviceId)));
          log("----manul butn----" + list.toList().toString());
        },
      );
      yield convertAscii(list).toString();
    }
  }
  // Stream<String> readManualButton(String deviceId) async* {
  //   List<int> list = [];
  //   await Future.delayed(const Duration(milliseconds: 500), () async {
  //     list.addAll(await flutterReactiveBle.readCharacteristic(
  //         qualifiedChar(Uuid.parse(ServiceIds.MANUAL_BUTTON), deviceId)));
  //     log("----manul butn----" + list.toList().toString());
  //   });

  //   yield convertAscii(list).toString();
  // }

  Stream<String> readBuzzerOffButton(String deviceId) async* {
    List<int> list = [];
    while (deviceId.isNotEmpty) {
      await Future.delayed(
        const Duration(seconds: 2),
        () async {
          list.clear();
          list.addAll(await flutterReactiveBle.readCharacteristic(
              qualifiedChar(Uuid.parse(ServiceIds.BUZZER_OFF), deviceId)));
          log("----buzz off----" + list.toList().toString());
        },
      );
      yield convertAscii(list).toString();
    }
  }
  // Stream<String> readBuzzerOffButton(String deviceId) async* {
  //   List<int> list = [];
  //   await Future.delayed(const Duration(milliseconds: 500), () async {
  //     list.addAll(await flutterReactiveBle.readCharacteristic(
  //         qualifiedChar(Uuid.parse(ServiceIds.BUZZER_OFF), deviceId)));
  //     log("----buzz off----" + list.toList().toString());
  //   });

  //   yield convertAscii(list).toString();
  // }
  Stream<String> readResetButton(String deviceId) async* {
    List<int> list = [];
    while (deviceId.isNotEmpty) {
      await Future.delayed(
        const Duration(seconds: 2),
        () async {
          list.clear();
          list.addAll(await flutterReactiveBle.readCharacteristic(
              qualifiedChar(Uuid.parse(ServiceIds.BUZZER_OFF), deviceId)));
          log("----buzz off----" + list.toList().toString());
        },
      );
      yield convertAscii(list).toString();
    }
  }

  Stream<String> readPassword(String deviceId) async* {
    List<int> list = [];
    while (deviceId.isNotEmpty) {
      await Future.delayed(
        const Duration(seconds: 2),
        () async {
          list.clear();
          list.addAll(await flutterReactiveBle.readCharacteristic(qualifiedChar(
              Uuid.parse(ServiceIds.SAVE_PASSWORD_READ), deviceId)));
          log("----pass word read----" + list.toList().toString());
        },
      );
      yield convertAscii(list).toString();
    }
  }
  // Stream<String> readResetButton(String deviceId) async* {
  //   List<int> list = [];
  //   await Future.delayed(const Duration(milliseconds: 500), () async {
  //     list.addAll(await flutterReactiveBle.readCharacteristic(
  //         qualifiedChar(Uuid.parse(ServiceIds.RESET), deviceId)));
  //     log("---reset btn-----" + list.toList().toString());
  //   });

  //   yield convertAscii(list).toString();
  // }

  // Stream<String> readRTCDate(String deviceId) async* {
  //   List<int> list = [];
  //   await Future.delayed(const Duration(milliseconds: 500), () async {
  //     list.addAll(await flutterReactiveBle.readCharacteristic(
  //         qualifiedChar(Uuid.parse(ServiceIds.RTC_DATE), deviceId)));
  //     log("----rtc date----" + list.toList().toString());
  //   });

  //   yield convertAscii(list).toString();
  // }

  // Stream<String> readRTCTime(String deviceId) async* {
  //   List<int> list = [];
  //   await Future.delayed(const Duration(milliseconds: 500), () async {
  //     list.addAll(await flutterReactiveBle.readCharacteristic(
  //         qualifiedChar(Uuid.parse(ServiceIds.RTC_TIME), deviceId)));
  //     log("----rtc time----" + list.toList().toString());
  //   });

  //   yield convertAscii(list).toString();
  // }

  Stream<String> readMachineStatus(String deviceId) async* {
    List<int> list = [];
    // flutterReactiveBle
    //     .subscribeToCharacteristic(
    //         qualifiedChar(Uuid.parse(ServiceIds.MACHINE_STATUS), deviceId))
    //     .listen((event) {
    //   list.clear();
    //   list.addAll(event);
    //   log("----machine status----" + convertAscii(list).toString());
    // },onError: (dynamic error) {
    //  log(error.toString())
    // });
    // yield convertAscii(list).toString();
    while (deviceId.isNotEmpty) {
      await Future.delayed(
        const Duration(milliseconds: 500),
        () async {
          list.clear();
          list.addAll(await flutterReactiveBle.readCharacteristic(
            qualifiedChar(Uuid.parse(ServiceIds.MACHINE_STATUS), deviceId),
          ));
          logg.log("----machine status----" + convertAscii(list).toString());
        },
      );
      yield convertAscii(list).toString();
    }
  }

  Future<void> writeMachineStatus(String deviceId, List<int> value) async {
    try {
      await flutterReactiveBle.writeCharacteristicWithoutResponse(
          qualifiedChar(Uuid.parse(ServiceIds.MACHINE_STATUS), deviceId),
          value: value);
      log("done--------");
    } catch (e) {
      log("error-------" + e.toString());
    }
  }

  Future<void> writeManual(String deviceId, List<int> value) async {
    try {
      await flutterReactiveBle.writeCharacteristicWithoutResponse(
          qualifiedChar(Uuid.parse(ServiceIds.MANUAL_BUTTON), deviceId),
          value: value);
      log("done--------");
    } catch (e) {
      log("error-------" + e.toString());
    }
  }

  Future<void> writeBuzzer(String deviceId, List<int> value) async {
    try {
      await flutterReactiveBle.writeCharacteristicWithoutResponse(
          qualifiedChar(Uuid.parse(ServiceIds.BUZZER_OFF), deviceId),
          value: value);
      log("done--------");
    } catch (e) {
      log("error-------" + e.toString());
    }
  }

  Future<void> writePassword(String deviceId, List<int> value) async {
    try {
      await flutterReactiveBle.writeCharacteristicWithoutResponse(
          qualifiedChar(Uuid.parse(ServiceIds.SAVE_PASSWORD_WRITE), deviceId),
          value: value);
      log("done--------");
    } catch (e) {
      log("error-------" + e.toString());
    }
  }

  Future<void> writeReset(
    String deviceId,
  ) async {
    try {
      await flutterReactiveBle.writeCharacteristicWithResponse(
          qualifiedChar(Uuid.parse(ServiceIds.RESET), deviceId),
          value: [49]);
      log("done--------");
    } catch (e) {
      log("error-------" + e.toString());
    }
  }

  Future<void> writeRestore(
    String deviceId,
  ) async {
    try {
      await flutterReactiveBle.writeCharacteristicWithResponse(
          qualifiedChar(Uuid.parse(ServiceIds.RESTORE_DEFAULT_DATA), deviceId),
          value: [49]);
      log("done--------");
    } catch (e) {
      log("error-------" + e.toString());
    }
  }

  Future<void> writeSave(String deviceId, List<int> value) async {
    try {
      await flutterReactiveBle.writeCharacteristicWithResponse(
          qualifiedChar(Uuid.parse(ServiceIds.SAVE_BUTTON_2), deviceId),
          value: value);
      log("done--------");
    } catch (e) {
      log("error-------" + e.toString());
    }
  }

  Future<void> writeRTCDate(String deviceId, List<int> value) async {
    try {
      await flutterReactiveBle.writeCharacteristicWithoutResponse(
          qualifiedChar(Uuid.parse(ServiceIds.RTC_DATE), deviceId),
          value: value);
      log("done--------");
    } catch (e) {
      log("error-------" + e.toString());
    }
  }

  Future<void> writeRTCTime(String deviceId, List<int> value) async {
    try {
      await flutterReactiveBle.writeCharacteristicWithoutResponse(
          qualifiedChar(Uuid.parse(ServiceIds.RTC_TIME), deviceId),
          value: value);
      log("done--------");
    } catch (e) {
      log("error-------" + e.toString());
    }
  }

  //  writePassword(){
  //    flutterReactiveBle.subscribeToCharacteristic(qualifiedChar(characteristicId, deviceId)).listen((data) {
  //     // code to handle incoming data
  //   }, onError: (dynamic error) {
  //     // code to handle errors
  //   });
  //  }
}

QualifiedCharacteristic qualifiedChar(Uuid characteristicId, String deviceId) {
  final qual = QualifiedCharacteristic(
      characteristicId: characteristicId,
      serviceId: Uuid.parse(ServiceIds.ServiceUUID),
      deviceId: deviceId);

  return qual;
}

String convertAscii(List<int> a) {
  // log(a.toList().toString());
  String f = String.fromCharCodes(a);
  // logg.log(f);
  // final s = int.parse(f);
  return f;
}
// @immutable
// class AutomatServices {
//   AutomatServices();
// }
