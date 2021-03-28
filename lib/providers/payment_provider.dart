import 'package:flutter/foundation.dart';

import '../models/payment.dart';

class PaymentProvider with ChangeNotifier {
  SepaPayment payment;

  PaymentProvider() {
    payment = new SepaPayment();
  }

  Future<void> getFromPrefs() async {
    final SepaPayment newPayment = await SepaPayment.getFromPrefs;
    payment = newPayment;
    notifyListeners();
  }

  Future<void> savePayment() async {
    await payment.saveToPrefs();
  }

  SepaPayment get getPayment {
    return payment;
  }

  void update(SepaPayment newPayment) {
    payment = newPayment;
    notifyListeners();
  }
}