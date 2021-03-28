import 'package:iban/iban.dart' as IBAN;

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
    return IBAN.isValid(iban);
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