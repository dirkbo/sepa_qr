import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:money_qr/models/payment.dart';
import 'package:money_qr/models/recipient.dart';
import 'package:money_qr/providers/payment_provider.dart';
import 'package:money_qr/screens/recipients_list_screen.dart';
import 'package:provider/provider.dart';

class EditPaymentScreen extends StatefulWidget {
  static const routeName = "/payment/edit/";

  @override
  _EditPaymentScreenState createState() => _EditPaymentScreenState();
}

class _EditPaymentScreenState extends State<EditPaymentScreen> {
  static const contactsBoxName = "paymentContacts";
  final _paymentFormKey = GlobalKey<FormState>();

  SepaPayment _payment;
  PaymentProvider _paymentProvider;
  bool _isInit = false;
  bool _isValid = false;

  void checkValid() {
    final bool valid  = (
        _paymentFormKey.currentState != null &&
            _paymentFormKey.currentState.validate()
    );
    setState(() {
      _isValid = valid;
    });
  }

  Future<void> savePayment() async {
    _paymentFormKey.currentState.save();
    _paymentProvider.update(_payment);
    await _paymentProvider.savePayment();
  }


  @override
  void didChangeDependencies() {
    if (!_isInit) {
      _paymentProvider = Provider.of<PaymentProvider>(context, listen: true);
      _isInit = true;
    }
    _payment = _paymentProvider.payment;
    _isValid = _payment.valid;
    super.didChangeDependencies();
  }

  Future<void> selectFromRecipientList() async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => RecipientsListScreen())
    );
    if (result != null) {
      PaymentRecipient recipient = Hive.box<PaymentRecipient>(contactsBoxName).getAt(result);
      SepaPayment payment = SepaPayment.fromRecipient(recipient);
      _paymentProvider.update(payment);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData _theme = Theme.of(context);
    if (_paymentProvider.payment != null)
      _payment = _paymentProvider.payment;
    return Scaffold(
      appBar: AppBar(
        title: Text("Zahlung bearbeiten"),
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            width: 300.0,
            child: SingleChildScrollView(
              child: Form(
                autovalidateMode: AutovalidateMode.always,
                key: _paymentFormKey,
                child: Column(children: [
                  Text("Zahlung", style: _theme.textTheme.headline5,),
                  const SizedBox(height: 16.0),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(child: Text("Empfänger wählen "), onPressed: selectFromRecipientList,),
                        IconButton(icon: Icon(Icons.contacts), color: Colors.blue, onPressed: selectFromRecipientList),
                      ]),
                  const SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("An:"),
                      Text(_payment.recipient),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('IBAN:'),
                    Text(_payment.iban),
                  ],),
                  const SizedBox(height: 8.0),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('BIC:'),
                      Text(_payment.bic),
                    ],),
                  const SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Flexible(
                        child: TextFormField(
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(labelText: "Betrag"),
                          initialValue: _payment.amount.toString(),
                          validator: (value) {
                            String sanitizedVal = value.trim();
                            if (double.tryParse(sanitizedVal) == null)
                              return "Betrag muss eine Zahl sein!";
                            return null;
                          },
                          onSaved: (value) {
                            String sanitizedVal = value.trim();
                            _payment.amount = double.tryParse(sanitizedVal);
                          },
                          onChanged: (value) {checkValid(); },
                        ),
                      ),
                      const SizedBox(width: 16.0,),
                      Text(_payment.currency),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  TextFormField(
                    decoration: InputDecoration(labelText: "Nachricht"),
                    initialValue: _payment.message,
                    validator: (value) {
                      String sanitizedVal = value.trim();
                      //if (sanitizedVal.isEmpty || sanitizedVal.length < 8)
                      //  return 'BIC muss mindestens 8 Zeichen lang sein';
                      if (sanitizedVal.length > 25 )// && sanitizedVal.length != 11)
                        return 'Nachricht darf maximal 25 Zeichen lang sein'; // ToDo: ? Regeln
                      //if (!SepaPayment.isValidIBAN(sanitizedVal))
                      //  return "BIC ist ungültig!";
                      return null;
                    },
                    onSaved: (value) {
                      String sanitizedVal = value.trim();
                      _payment.message = sanitizedVal;
                    },
                    onChanged: (value) {checkValid(); },
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(onPressed: () {
                        Navigator.of(context).pop();
                      }, child: Text("Abbrechen")),
                      ElevatedButton(
                          onPressed: _isValid
                          ? () async {
                            await savePayment();
                            Navigator.of(context).pop();
                            }
                          : null, child: Text("Übernehmen")),
                    ],)
                ],),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
