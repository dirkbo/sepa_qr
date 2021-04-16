import 'package:flutter/cupertino.dart';
import 'package:iban/iban.dart' as IBAN;
import 'package:hive/hive.dart';

part 'recipient.g.dart';

@HiveType(typeId: 0)
class PaymentRecipient {
  @HiveField(0)
  String iban;
  @HiveField(1)
  String bic;
  @HiveField(2)
  String name;
  @HiveField(3)
  String currency;

  PaymentRecipient({
    this.iban,
    this.bic,
    this.name,
    this.currency : "EUR"
  });

  bool get valid {
    if (iban == null) return false;
    return IBAN.isValid(iban);
  }

}