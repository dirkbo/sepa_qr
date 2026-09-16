import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:money_qr/screens/edit_recipient_screen.dart';

import '../models/recipient.dart';

class RecipientsListScreen extends StatefulWidget {
  static const routeName = "/recipient/list/";

  const RecipientsListScreen({super.key});

  @override
  State<RecipientsListScreen> createState() => _RecipientsListScreenState();
}

class _RecipientsListScreenState extends State<RecipientsListScreen> {
  static const contactsBoxName = "paymentContacts";
  static const maxWidth = 400.0;
  MediaQueryData? media;

  Future<bool> confirmDeleteRecipient(
      BuildContext context, PaymentRecipient recipient) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Empfänger löschen?"),
        content: Text(
            "Möchtest du \"${recipient.name}\" wirklich aus deinen gespeicherten Empfängern entfernen?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text("Abbrechen"),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text("Löschen"),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  Widget savedPaymentRecipientItemBuilder(BuildContext context, int index) {
    final box = Hive.box<PaymentRecipient>(contactsBoxName);
    final recipient = box.values.toList()[index];
    final dynamic recipientKey = box.keyAt(index);

    final tile = ListTile(
      title: Text(recipient.name),
      leading: CircleAvatar(
        child: Text(recipient.name[0]),
      ),
      subtitle: Text(
          "${recipient.prettyIBAN}\n${recipient.bic} - ${recipient.currency}"),
      onTap: () {
        Navigator.of(context).pop(index);
      },
      onLongPress: () {
        Navigator.of(context).pushNamed(EditRecipientScreen.routeName,
            arguments: {'id': index});
      },
    );

    final dismissible = Dismissible(
      key: ValueKey(recipientKey),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => confirmDeleteRecipient(context, recipient),
      onDismissed: (_) {
        box.delete(recipientKey);
      },
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: tile,
    );

    if (media!.size.width > maxWidth) {
      return Align(
        alignment: Alignment.center,
        child: SizedBox(
          width: 400.0,
          child: dismissible,
        ),
      );
    }
    return dismissible;
  }

  @override
  void didChangeDependencies() {
    media = MediaQuery.of(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Gespeicherte Empfänger"),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).pushNamed(EditRecipientScreen.routeName);
        },
      ),
      body: SafeArea(
        child: ValueListenableBuilder(
            valueListenable:
                Hive.box<PaymentRecipient>(contactsBoxName).listenable(),
            builder: (context, Box<PaymentRecipient> box, _) {
              if (box.values.isEmpty) {
                return Center(
                  child: Text("Keine Empfänger vorhanden"),
                );
              }
              return ListView.builder(
                itemCount: box.values.length,
                itemBuilder: savedPaymentRecipientItemBuilder,
              );
            }),
      ),
    );
  }
}
