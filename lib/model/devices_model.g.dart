// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'devices_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DevicesModelDBAdapter extends TypeAdapter<DevicesModelDB> {
  @override
  final int typeId = 1;

  @override
  DevicesModelDB read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DevicesModelDB(
      deviceList: (fields[0] as List).cast<DeviceListModelDB>(),
    );
  }

  @override
  void write(BinaryWriter writer, DevicesModelDB obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.deviceList);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DevicesModelDBAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DeviceListModelDBAdapter extends TypeAdapter<DeviceListModelDB> {
  @override
  final int typeId = 2;

  @override
  DeviceListModelDB read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DeviceListModelDB(
      discoveredDevice: fields[0] as DiscoveredDeviceModel,
    );
  }

  @override
  void write(BinaryWriter writer, DeviceListModelDB obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.discoveredDevice);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeviceListModelDBAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DiscoveredDeviceModelAdapter extends TypeAdapter<DiscoveredDeviceModel> {
  @override
  final int typeId = 3;

  @override
  DiscoveredDeviceModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DiscoveredDeviceModel(
      id: fields[0] as String?,
      name: fields[1] as String?,
      serviceData: (fields[2] as Map?)
          ?.map((dynamic k, dynamic v) => MapEntry(k as Uuid, v as Uint8List)),
      manufacturerData: fields[4] as Uint8List?,
      rssi: fields[5] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, DiscoveredDeviceModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.serviceData)
      ..writeByte(4)
      ..write(obj.manufacturerData)
      ..writeByte(5)
      ..write(obj.rssi);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiscoveredDeviceModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
