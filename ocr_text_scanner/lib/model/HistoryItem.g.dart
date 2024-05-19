// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'HistoryItem.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HistoryItemAdapter extends TypeAdapter<HistoryItem> {
  @override
  final int typeId = 0;

  @override
  HistoryItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HistoryItem(
      imagePath: fields[0] as String,
      firstLine: fields[1] as String,
      time: fields[2] as String,
      textFilePath: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, HistoryItem obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.imagePath)
      ..writeByte(1)
      ..write(obj.firstLine)
      ..writeByte(2)
      ..write(obj.time)
      ..writeByte(3)
      ..write(obj.textFilePath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HistoryItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
