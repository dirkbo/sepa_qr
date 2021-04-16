import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';
import 'package:money_qr/screens/edit_recipient_screen.dart';

import '../models/payment.dart';
import '../models/recipient.dart';

class RecipientsListScreen extends StatefulWidget {
  static const routeName = "/recipient/list/";

  @override
  _RecipientsListScreenState createState() => _RecipientsListScreenState();
}

class _RecipientsListScreenState extends State<RecipientsListScreen> {
  static const contactsBoxName = "paymentContacts";

  Widget savedPaymentRecipientItemBuilder(BuildContext context, int index) {
    final recipient = Hive.box<PaymentRecipient>(contactsBoxName).values.toList()[index];
    return ListTile(
      title: Text(recipient.name),
      subtitle: Text("${recipient.iban}\n${recipient.bic} - ${recipient.currency}"),
      onTap: () {
        Navigator.of(context).pop(index);
      },
      onLongPress: () {
        Navigator.of(context).pushNamed(EditRecipientScreen.routeName, arguments: {'id': index});
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
      floatingActionButton: FloatingActionButton(child: Icon(Icons.add), onPressed: () {
        Navigator.of(context).pushNamed(EditRecipientScreen.routeName);
      },),
      body: SafeArea(
        child: ValueListenableBuilder(
          valueListenable: Hive.box<PaymentRecipient>(contactsBoxName).listenable(),
          builder: (context, Box<PaymentRecipient> box, _) {
            if (box.values.isEmpty)
              return Center(
                child: Text("Keine Empfänger vorhanden"),
              );
            return ListView.builder(
              itemCount: box.values.length,
              itemBuilder: savedPaymentRecipientItemBuilder,
            );
          }),
      ),
    );
  }
}
