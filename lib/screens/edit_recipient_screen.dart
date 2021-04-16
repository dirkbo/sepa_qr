import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../models/payment.dart';
import '../models/recipient.dart';


class EditRecipientScreen extends StatefulWidget {
  static const routeName = "/recipient/edit/";

  @override
  _EditRecipientScreenState createState() => _EditRecipientScreenState();
}

class _EditRecipientScreenState extends State<EditRecipientScreen> {
  static const contactsBoxName = "paymentContacts";
  final _recipientFormKey = GlobalKey<FormState>();
  Box<PaymentRecipient> box;

  PaymentRecipient _recipient = PaymentRecipient();
  bool _modeCreate = true;
  int _originalId;
  bool _isInit = false;
  bool _isValid = false;

  void checkValid() {
    final bool valid  = (
        _recipientFormKey.currentState != null &&
            _recipientFormKey.currentState.validate()
    );
    setState(() {
      _isValid = valid;
    });
  }

  Future<void> savePayment() async {
    _recipientFormKey.currentState.save();
    if (_modeCreate && _originalId == null) {
      box.add(_recipient);
    } else {
      box.put(_originalId, _recipient);
    }
  }

  @override
  void didChangeDependencies() {
    if (!_isInit) {
      final Map<String, dynamic> args = ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
      _isValid = false;
      _originalId = null;
      _modeCreate = true;
      if (args != null && args.containsKey('id')) {
        _originalId = args['id'] as int;
        _modeCreate = false;
      }
      box = Hive.box<PaymentRecipient>(contactsBoxName);
      _isInit = true;
    }
    if (_originalId != null)
      setState(() {
        _recipient = box.getAt(_originalId);
        _isValid = _recipient != null ?  _recipient.valid : false;
      });
    print("DidChange Edit Dependencies");
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData _theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_modeCreate ? "Empfänger erstellen" : "Empfänger bearbeiten"),
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            width: 300.0,
            child: SingleChildScrollView(
              child: Form(
                autovalidateMode: AutovalidateMode.always,
                key: _recipientFormKey,
                child: Column(children: [
                  Text("Empfänger", style: _theme.textTheme.headline5,),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    decoration: InputDecoration(labelText: "An"),
                    textInputAction: TextInputAction.next,
                    initialValue: _recipient != null ? _recipient.name : '',
                    validator: (value) {
                      String sanitizedVal = value.trim();
                      if (sanitizedVal.isEmpty || sanitizedVal.length < 5)
                        return 'Empfänger angeben';
                      return null;
                    },
                    onSaved: (value) {
                      String sanitizedVal = value.trim();
                      _recipient.name = sanitizedVal;
                    },
                    onChanged: (value) {checkValid(); },
                  ),
                  const SizedBox(height: 8.0),
                  TextFormField(
                    decoration: InputDecoration(labelText: "IBAN"),
                    textInputAction: TextInputAction.next,
                    initialValue: _recipient != null ? _recipient.iban : '',
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
                      _recipient.iban = sanitizedVal;
                    },
                    onChanged: (value) {checkValid(); },
                  ),
                  const SizedBox(height: 8.0),
                  TextFormField(
                    decoration: InputDecoration(labelText: "BIC / SWIFT"),
                    textInputAction: TextInputAction.next,
                    initialValue: _recipient != null ?  _recipient.bic : '',
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
                      _recipient.bic = sanitizedVal;
                    },
                    onChanged: (value) {checkValid(); },
                  ),
                  const SizedBox(height: 8.0),
                  TextFormField(
                    decoration: InputDecoration(labelText: "Währung"),
                    textInputAction: TextInputAction.next,
                    initialValue: _recipient != null ?  _recipient.currency : "EUR",
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
                      _recipient.currency = sanitizedVal;
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
