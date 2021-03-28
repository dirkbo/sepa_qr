import 'package:flutter/cupertino.dart';

class PaymentRecipient {
  String iban;
  String bic;
  String name;
  String currency;

  PaymentRecipient({
    @required this.iban,
    @required this.bic,
    @required this.name,
    this.currency : "EUR"
  });

}