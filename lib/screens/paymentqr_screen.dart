import 'package:flutter/material.dart';
import 'package:money_qr/providers/payment_provider.dart';
import 'package:money_qr/screens/edit_payment_screen.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../models/payment.dart';

class MoneyQRHomePage extends StatefulWidget {
  static const routeName = "/";

  MoneyQRHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MoneyQRHomePageState createState() => _MoneyQRHomePageState();
}



class _MoneyQRHomePageState extends State<MoneyQRHomePage> {
  SepaPayment paymentData = SepaPayment();
  String qrData;
  bool _isInit = false;
  PaymentProvider paymentProvider;

  @override
  void initState() {
    qrData = paymentData.qrData;
    super.initState();
  }

  void updateQrData({bool doSetState : false}) {
    if (doSetState) {
      setState(() {
        qrData = paymentData.qrData;
      });
    } else {
      qrData = paymentData.qrData;
    }
  }

  @override
  void didChangeDependencies() {
    if (!_isInit) {
      paymentProvider = Provider.of<PaymentProvider>(context, listen: true);
      Future.delayed(Duration(milliseconds: 200), () async { await paymentProvider.getFromPrefs(); });
      _isInit = true;
    }
    paymentData = paymentProvider.getPayment;
    updateQrData();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData _theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: 300.0,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text("Deine Überweisung", style: _theme.textTheme.headline5, softWrap: true,),
                    ],),
                  const SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("An:"),
                      Text(paymentData.recipient),
                    ],),
                  const SizedBox(height: 8.0,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("IBAN:"),
                      Text(paymentData.iban),
                    ],),
                  const SizedBox(height: 8.0,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("BIC:"),
                      Text(paymentData.bic),
                    ],),
                  const SizedBox(height: 8.0,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Nachricht:"),
                      Text(paymentData.message),
                    ],),
                  const SizedBox(height: 8.0,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Betrag:"),
                      Text("${paymentData.currency} ${paymentData.amount.toStringAsFixed(2)}"),
                    ],),
                  const SizedBox(height: 16.0,),
                  QrImage(
                    data: qrData,
                    version: QrVersions.auto,
                    size: 320,
                    gapless: false,
                  ),
                  const SizedBox(height: 16.0,),
                  Text("Scanne den QR-Code mit deiner Banking App, um die Überweisungsdaten zu übernehmen und die Überweisung abzuschließen", softWrap: true,),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(EditPaymentScreen.routeName);
        },
        tooltip: 'Zahlung bearbeiten',
        child: Icon(Icons.edit),
      ),
    );
  }
}
