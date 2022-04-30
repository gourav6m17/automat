import 'dart:typed_data';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:hive/hive.dart';
part 'devices_model.g.dart';

@HiveType(typeId: 1)
class DevicesModelDB extends HiveObject {
  @HiveField(0)
  late List<DeviceListModelDB> deviceList;
  DevicesModelDB({required this.deviceList});

  // factory DevicesModelDB.fromJson(Map<String, dynamic> json) => DevicesModelDB(
  //       deviceList: List<DeviceListModelDB>.from(
  //           json["deviceList"].map((x) => DeviceListModelDB.fromJson(x))),
  //     );

  // Map<String, dynamic> toJson() => {
  //       "deviceList": List<dynamic>.from(deviceList.map((x) => x.toJson())),
  //     };
}

@HiveType(typeId: 2)
class DeviceListModelDB extends HiveObject {
  DeviceListModelDB({
    required this.discoveredDevice,
  });
  // @HiveField(0)
  // String deviceId;

  // @HiveField(1)
  // String deviceName;

  // @HiveField(2)
  // String password;

  @HiveField(0)
  DiscoveredDeviceModel discoveredDevice;
  // factory DeviceListModelDB.fromJson(Map<String, dynamic> json) =>
  //     DeviceListModelDB(
  //       deviceId: json["deviceId"],
  //       deviceName: json["deviceName"],
  //       password: json["password"],
  //     );

  // Map<String, dynamic> toJson() => {
  //       "deviceId": deviceId,
  //       "deviceName": deviceName,
  //       "password": password,
  //     };
}

@HiveType(typeId: 3)
class DiscoveredDeviceModel {
  /// The unique identifier of the device.
  String? id;
  String? name;
  Map<Uuid, Uint8List>? serviceData;

  /// Advertised services

  List<Uuid>? serviceUuids;

  /// Manufacturer specific data. The first 2 bytes are the Company Identifier Codes.

  Uint8List? manufacturerData;
  int? rssi;

  DiscoveredDeviceModel({
    this.id,
    this.name,
    this.serviceData,
    this.manufacturerData,
    this.rssi,
    this.serviceUuids,
  });
}
