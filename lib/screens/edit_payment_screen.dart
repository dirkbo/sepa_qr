import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:money_qr/models/payment.dart';
import 'package:money_qr/providers/payment_provider.dart';
import 'package:money_qr/screens/recipients_list_screen.dart';
import 'package:provider/provider.dart';

class EditPaymentScreen extends StatefulWidget {
  static const routeName = "/edit/";

  @override
  _EditPaymentScreenState createState() => _EditPaymentScreenState();
}

class _EditPaymentScreenState extends State<EditPaymentScreen> {
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
    print("DidChange Edit Dependencies");
    _payment = _paymentProvider.payment;
    _isValid = _payment.valid;
    super.didChangeDependencies();
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
                  Text("Bearbeiten", style: _theme.textTheme.headline5,),
                  const SizedBox(height: 16.0),
                  Row(
                    children: [
                      Flexible(
                        child: TextFormField(
                          decoration: InputDecoration(labelText: "An"),
                          textInputAction: TextInputAction.next,
                          initialValue: _payment.recipient,
                          validator: (value) {
                            String sanitizedVal = value.trim();
                            if (sanitizedVal.isEmpty || sanitizedVal.length < 5)
                              return 'Empfänger angeben';
                            return null;
                          },
                          onSaved: (value) {
                            String sanitizedVal = value.trim();
                            _payment.recipient = sanitizedVal;
                          },
                          onChanged: (value) {checkValid(); },
                        ),
                      ),
                      IconButton(icon: Icon(Icons.contacts), onPressed: () async {
                        final result = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => RecipientsListScreen())
                        );
                        if (result != null) {
                          _paymentProvider.update(result);
                          _paymentFormKey.currentState.reset();
                        }
                      }),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  TextFormField(
                    decoration: InputDecoration(labelText: "IBAN"),
                    textInputAction: TextInputAction.next,
                    initialValue: _payment.iban,
                    validator: (value) {
                      String sanitizedVal = value.trim().replaceAll(' ', '');
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
                      _payment.iban = sanitizedVal;
                    },
                    onChanged: (value) {checkValid(); },
                  ),
                  const SizedBox(height: 8.0),
                  TextFormField(
                    decoration: InputDecoration(labelText: "BIC / SWIFT"),
                    textInputAction: TextInputAction.next,
                    initialValue: _payment.bic,
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
                      _payment.bic = sanitizedVal;
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
                          initialValue: _payment.currency,
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
                            _payment.currency = sanitizedVal;
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
