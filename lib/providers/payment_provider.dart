import 'package:flutter/foundation.dart';

import '../models/payment.dart';

class PaymentProvider with ChangeNotifier {
  SepaPayment _payment;

  PaymentProvider() {
    _payment = new SepaPayment();
  }

  Future<void> getFromPrefs({bool doNotify: true}) async {
    final SepaPayment newPayment = await SepaPayment.getFromPrefs;
    _payment = newPayment;
    if (doNotify)
      notifyListeners();
  }

  Future<void> savePayment() async {
    await _payment.saveToPrefs();
  }

  SepaPayment get payment {
    return _payment;
  }

  void update(SepaPayment newPayment) {
    _payment = newPayment;
    notifyListeners();
  }
}