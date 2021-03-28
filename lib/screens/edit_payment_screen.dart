import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:money_qr/models/payment.dart';
import 'package:money_qr/providers/payment_provider.dart';
import 'package:provider/provider.dart';

class EditPaymentScreen extends StatefulWidget {
  static const routeName = "/edit/";

  @override
  _EditPaymentScreenState createState() => _EditPaymentScreenState();
}

class _EditPaymentScreenState extends State<EditPaymentScreen> {
  final _paymentFormKey = GlobalKey<FormState>();

  SepaPayment payment;
  PaymentProvider paymentProvider;
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
    paymentProvider.update(payment);
    await paymentProvider.savePayment();
  }

  @override
  void didChangeDependencies() {
    if (!_isInit) {
      paymentProvider = Provider.of<PaymentProvider>(context, listen: false);
      _isInit = true;
    }
    payment = paymentProvider.getPayment;
    _isValid = payment.valid;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData _theme = Theme.of(context);
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
                  Text("Bearbeiten", style: _theme.textTheme.headline5,),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    decoration: InputDecoration(labelText: "An"),
                    textInputAction: TextInputAction.next,
                    initialValue: payment.recipient,
                    validator: (value) {
                      String sanitizedVal = value.trim();
                      if (sanitizedVal.isEmpty || sanitizedVal.length < 5)
                        return 'Empfänger angeben';
                      return null;
                    },
                    onSaved: (value) {
                      String sanitizedVal = value.trim();
                      payment.recipient = sanitizedVal;
                    },
                    onChanged: (value) {checkValid(); },
                  ),
                  const SizedBox(height: 8.0),
                  TextFormField(
                    decoration: InputDecoration(labelText: "IBAN"),
                    textInputAction: TextInputAction.next,
                    initialValue: payment.iban,
                    validator: (value) {
                      String sanitizedVal = value.trim();
                      if (sanitizedVal.isEmpty || sanitizedVal.length < 15)
                        return 'IBAN muss mindestens 15 Zeichen lang sein';
                      if (sanitizedVal.length > 32)
                        return 'IBAN darf maximal 32 Zeichen lang sein';
                      if (!SepaPayment.isValidIBAN(sanitizedVal))
                        return "IBAN ist ungültig!";
                      return null;
                    },
                    onSaved: (value) {
                      String sanitizedVal = value.trim();
                      payment.iban = sanitizedVal;
                    },
                    onChanged: (value) {checkValid(); },
                  ),
                  const SizedBox(height: 8.0),
                  TextFormField(
                    decoration: InputDecoration(labelText: "BIC / SWIFT"),
                    textInputAction: TextInputAction.next,
                    initialValue: payment.bic,
                    validator: (value) {
                      String sanitizedVal = value.trim();
                      if (sanitizedVal.isEmpty || sanitizedVal.length < 8)
                        return 'BIC muss mindestens 8 Zeichen lang sein';
                      if (sanitizedVal.length > 8 && sanitizedVal.length != 11)
                        return 'BIC darf 8 oder  11 Zeichen lang sein';
                      //if (!SepaPayment.isValidIBAN(sanitizedVal))
                      //  return "BIC ist ungültig!";
                      return null;
                    },
                    onSaved: (value) {
                      String sanitizedVal = value.trim();
                      payment.bic = sanitizedVal;
                    },
                    onChanged: (value) {checkValid(); },
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Flexible(
                        child: TextFormField(
                          decoration: InputDecoration(labelText: "Währung"),
                          textInputAction: TextInputAction.next,
                          initialValue: payment.currency,
                          validator: (value) {
                            String sanitizedVal = value.trim();
                            if (sanitizedVal.isEmpty || sanitizedVal.length < 3)
                              return 'Währung muss mindestens 3 Zeichen lang sein';
                            //if (sanitizedVal.length > 8 && sanitizedVal.length != 11)
                            //  return 'BIC darf 8 oder  11 Zeichen lang sein';
                            //if (!SepaPayment.isValidIBAN(sanitizedVal))
                            //  return "BIC ist ungültig!";
                            return null;
                          },
                          onSaved: (value) {
                            String sanitizedVal = value.trim().toUpperCase();
                            payment.currency = sanitizedVal;
                          },
                          onChanged: (value) {checkValid(); },
                        ),
                      ),
                      const SizedBox(width: 16.0,),
                      Flexible(
                        child: TextFormField(
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(labelText: "Betrag"),
                          initialValue: payment.amount.toString(),
                          validator: (value) {
                            String sanitizedVal = value.trim();
                            if (sanitizedVal.isEmpty || sanitizedVal.length < 3)
                              return 'Währung muss mindestens 3 Zeichen lang sein';
                            //if (sanitizedVal.length > 8 && sanitizedVal.length != 11)
                            //  return 'BIC darf 8 oder  11 Zeichen lang sein';
                            //if (!SepaPayment.isValidIBAN(sanitizedVal))
                            //  return "BIC ist ungültig!";
                            if (double.tryParse(sanitizedVal) == null)
                              return "Betrag muss eine Zahl sein!";
                            return null;
                          },
                          onSaved: (value) {
                            String sanitizedVal = value.trim();
                            payment.amount = double.tryParse(sanitizedVal);
                          },
                          onChanged: (value) {checkValid(); },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  TextFormField(
                    decoration: InputDecoration(labelText: "Nachricht"),
                    initialValue: payment.message,
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
                      payment.message = sanitizedVal;
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
