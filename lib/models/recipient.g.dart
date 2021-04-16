// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipient.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PaymentRecipientAdapter extends TypeAdapter<PaymentRecipient> {
  @override
  final int typeId = 0;

  @override
  PaymentRecipient read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PaymentRecipient(
      iban: fields[0] as String,
      bic: fields[1] as String,
      name: fields[2] as String,
      currency: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, PaymentRecipient obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.iban)
      ..writeByte(1)
      ..write(obj.bic)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.currency);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentRecipientAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
