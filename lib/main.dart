import 'package:flutter/material.dart';
import 'package:money_qr/screens/edit_payment_screen.dart';

import 'screens/paymentqr_screen.dart';

void main() {
  runApp(MoneyQR());
}

class MoneyQR extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Money QR',
      theme: ThemeData(primarySwatch: Colors.blue,),
      routes: {
        MoneyQRHomePage.routeName: (ctx) => MoneyQRHomePage(title: "Money QR",),
        EditPaymentScreen.routeName: (ctx) => EditPaymentScreen(),
      },
    );
  }
}

