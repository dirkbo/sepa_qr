import 'package:flutter/material.dart';
import 'package:money_qr/providers/payment_provider.dart';
import 'package:money_qr/screens/edit_payment_screen.dart';
import 'package:money_qr/screens/share_sheet.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../models/payment.dart';

class MoneyQRHomePage extends StatefulWidget {
  static const routeName = "/";

  const MoneyQRHomePage({super.key, required this.title});

  final String title;

  @override
  State<MoneyQRHomePage> createState() => _MoneyQRHomePageState();
}



class _MoneyQRHomePageState extends State<MoneyQRHomePage> {
  SepaPayment paymentData = SepaPayment();
  String? qrData;
  bool _isInit = false;
  PaymentProvider? paymentProvider;

  @override
  void initState() {
    qrData = paymentData.qrData;
    super.initState();
  }

  void updateQrData({bool doSetState = false}) {
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
      Future.delayed(Duration(milliseconds: 200), () async { await paymentProvider?.getFromPrefs(doNotify: true); });
      _isInit = true;
    }
    paymentData = paymentProvider?.payment ?? SepaPayment();
    updateQrData();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share),
            tooltip: 'Teilen',
            onPressed: () => showShareSheet(context, paymentData),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: SizedBox(
              width: 300.0,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text("Deine Überweisung", style: theme.textTheme.headlineMedium, softWrap: true,),
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
                  if (paymentData.bic.trim().isNotEmpty) ...[
                    const SizedBox(height: 8.0,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("BIC:"),
                        Text(paymentData.bic),
                      ],),
                  ],
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
                  QrImageView(
                    data: qrData ?? "",
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
