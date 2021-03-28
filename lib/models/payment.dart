import 'package:iban/iban.dart' as IBAN;
import 'package:shared_preferences/shared_preferences.dart';

class SepaPayment {
  String iban;
  String bic;
  String recipient;
  String message;
  String currency;
  double amount;

  SepaPayment({
    this.iban : "DE33100205000001194700",
    this.bic : "BFSWDE33BER",
    this.recipient : "Wikimedia Foerdergesellschaft",
    this.message : "Spende fuer Wikipedia",
    this.amount : 0.00,
    this.currency : "EUR"
  });

  bool get valid {
    if (iban == null) return false;
    return IBAN.isValid(iban);
  }

  static bool isValidIBAN(String iban) {
    return IBAN.isValid(iban);
  }

  Future<void> saveToPrefs() async {
    if (!valid) return;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('iban', iban);
    await prefs.setString('bic', bic);
    await prefs.setString('recipient', recipient);
    await prefs.setString('curreny', currency);
  }

  static Future<SepaPayment> get getFromPrefs async {
    SepaPayment n = new SepaPayment();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    n.iban = prefs.getString('iban');
    n.bic = prefs.getString('bic');
    n.recipient = prefs.getString('recipient');
    n.currency = prefs.getString('curreny');
    n.amount = 0.0;
    n.message = "";
    if (!n.valid) {
      n = new SepaPayment();
    }
    return n;
  }

  String get qrData {
    return "BCD\n"
        "001\n"
        "1\n"
        "SCT\n"
        "$bic\n"
        "$recipient\n"
        "$iban\n"
        "$currency${amount.toStringAsPrecision(2)}\n"
        "\n"
        "\n"
        "$message";
  }
}