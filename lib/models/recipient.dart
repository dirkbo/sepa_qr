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

  String get cleanedIBAN {
    return iban.trim().replaceAll(' ', '');
  }

  String get prettyIBAN {
    String prettyIn = cleanedIBAN;
    String prettyOut = '';
    for(int i=0;i<prettyIn.length; i++) {
      if (i==0)
        prettyOut = prettyIn[0];
      else if (i%4==0)
        prettyOut = "$prettyOut ${prettyIn[i]}";
      else
        prettyOut = "$prettyOut${prettyIn[i]}";
    }
    return prettyOut;
  }

}