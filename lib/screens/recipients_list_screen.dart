import 'package:flutter/material.dart';
import 'package:money_qr/models/payment.dart';
import 'package:money_qr/providers/payment_provider.dart';
import 'package:provider/provider.dart';

import '../models/recipient.dart';

class RecipientsListScreen extends StatefulWidget {
  static const routeName = "/saved/";

  @override
  _RecipientsListScreenState createState() => _RecipientsListScreenState();
}

class _RecipientsListScreenState extends State<RecipientsListScreen> {
  List<PaymentRecipient> savedRecipients = [
    PaymentRecipient(iban: "DE33 1002 0500 0001 1947 00", bic: "BFSWDE33BER", name: "Wikimedia Foerdergesellschaft"),
  ];

  Widget savedPaymentRecipientItemBuilder(BuildContext context, int index) {
    final recipient = savedRecipients[index];
    return ListTile(
      title: Text(recipient.name),
      subtitle: Text("${recipient.iban}\n${recipient.bic} - ${recipient.currency}"),
      onTap: () {
        SepaPayment payment = SepaPayment.fromRecipient(recipient);
        Navigator.of(context).pop(payment);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData _theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Saved Payment Contacts"),
      ),
      body: SafeArea(
        child: ListView.builder(
            itemCount: savedRecipients.length,
            itemBuilder: savedPaymentRecipientItemBuilder,
        ),
      ),
    );
  }
}
