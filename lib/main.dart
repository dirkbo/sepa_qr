import 'package:flutter/material.dart';
import 'package:money_qr/providers/payment_provider.dart';
import 'package:money_qr/screens/edit_payment_screen.dart';
import 'package:provider/provider.dart';

import 'screens/paymentqr_screen.dart';
import 'screens/recipients_list_screen.dart';

void main() {
  runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => PaymentProvider()),
        ],
        child: MoneyQR(),
      )
  );
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

