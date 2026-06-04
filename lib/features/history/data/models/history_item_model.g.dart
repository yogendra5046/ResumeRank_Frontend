// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_item_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HistoryItemModelAdapter extends TypeAdapter<HistoryItemModel> {
  @override
  final int typeId = 0;

  @override
  HistoryItemModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HistoryItemModel(
      id: fields[0] as String,
      fileName: fields[1] as String,
      score: fields[2] as int,
      date: fields[3] as DateTime,
      missingKeywords: (fields[4] as List).cast<String>(),
      suggestions: (fields[5] as List).cast<String>(),
      percentile: fields[6] as int,
      fullResultJson: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, HistoryItemModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.fileName)
      ..writeByte(2)
      ..write(obj.score)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.missingKeywords)
      ..writeByte(5)
      ..write(obj.suggestions)
      ..writeByte(6)
      ..write(obj.percentile)
      ..writeByte(7)
      ..write(obj.fullResultJson);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HistoryItemModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
