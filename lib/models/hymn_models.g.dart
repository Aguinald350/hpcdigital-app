// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hymn_models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HymnOfDayAdapter extends TypeAdapter<HymnOfDay> {
  @override
  final int typeId = 0;

  @override
  HymnOfDay read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HymnOfDay(
      id: fields[0] as String,
      numero: fields[1] as String,
      titulo: fields[2] as String,
      conteudo: fields[3] as String,
      secao: fields[4] as String,
      lingua: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, HymnOfDay obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.numero)
      ..writeByte(2)
      ..write(obj.titulo)
      ..writeByte(3)
      ..write(obj.conteudo)
      ..writeByte(4)
      ..write(obj.secao)
      ..writeByte(5)
      ..write(obj.lingua);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HymnOfDayAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
