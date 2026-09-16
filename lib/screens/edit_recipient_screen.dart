import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../models/payment.dart';
import '../models/recipient.dart';
import '../models/sepa.dart';


class EditRecipientScreen extends StatefulWidget {
  static const routeName = "/recipient/edit/";

  const EditRecipientScreen({super.key});

  @override
  State<EditRecipientScreen> createState() => _EditRecipientScreenState();
}

class _EditRecipientScreenState extends State<EditRecipientScreen> {
  static const contactsBoxName = "paymentContacts";
  final _recipientFormKey = GlobalKey<FormState>();
  Box<PaymentRecipient>? box;

  PaymentRecipient _recipient = PaymentRecipient();
  bool _modeCreate = true;
  int? _originalId;
  bool _isInit = false;
  bool _isValid = false;

  // Tracks the IBAN/currency fields' live (unsaved) text, since the BIC
  // field's own validator needs to know about them as the user types.
  String _currentIban = '';
  String _currentCurrency = 'EUR';

  void checkValid() {
    final bool valid  = _recipientFormKey.currentState?.validate() ?? false;
    setState(() {
      _isValid = valid;
    });
  }

  Future<void> savePayment() async {
    _recipientFormKey.currentState?.save();
    if (_modeCreate && _originalId == null) {
      box?.add(_recipient);
    } else {
      box?.put(_originalId, _recipient);
    }
  }

  @override
  void didChangeDependencies() {
    if (!_isInit) {
      final Map<String, dynamic> args =
          (ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?) ?? {};
      _isValid = false;
      _originalId = null;
      _modeCreate = true;
      if (args.containsKey('id')) {
        _originalId = args['id'] as int;
        _modeCreate = false;
      }
      box = Hive.box<PaymentRecipient>(contactsBoxName);
      _isInit = true;
    }
    if (_originalId != null) {
      setState(() {
        if (_originalId != null) {
          _recipient = box?.getAt(_originalId!) ?? PaymentRecipient();
          _isValid = _recipient.valid;
          _currentIban = _recipient.iban;
          _currentCurrency = _recipient.currency;
        } else {
          _recipient = PaymentRecipient();
          _isValid = false;
        }
      });
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_modeCreate ? "Empfänger erstellen" : "Empfänger bearbeiten"),
      ),
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: 300.0,
            child: SingleChildScrollView(
              child: Form(
                autovalidateMode: AutovalidateMode.always,
                key: _recipientFormKey,
                child: Column(children: [
                  Text("Empfänger", style: theme.textTheme.headlineMedium,),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    decoration: InputDecoration(labelText: "An"),
                    textInputAction: TextInputAction.next,
                    initialValue: _recipient.name,
                    validator: (value) {
                      String sanitizedVal = value?.trim() ?? '';
                      if (sanitizedVal.isEmpty || sanitizedVal.length < 5) {
                        return 'Empfänger angeben';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      String sanitizedVal = value?.trim() ?? '';
                      _recipient.name = sanitizedVal;
                    },
                    onChanged: (value) {checkValid(); },
                  ),
                  const SizedBox(height: 8.0),
                  TextFormField(
                    decoration: InputDecoration(labelText: "IBAN"),
                    textInputAction: TextInputAction.next,
                    initialValue: _recipient.iban,
                    validator: (value) {
                      String sanitizedVal = (value?.trim() ?? '').replaceAll(' ', '');
                      if (sanitizedVal.isEmpty || sanitizedVal.length < 15) {
                        return 'IBAN muss mindestens 15 Zeichen lang sein';
                      }
                      if (sanitizedVal.length > 32) {
                        return 'IBAN darf maximal 32 Zeichen lang sein';
                      }
                      if (!SepaPayment.isValidIBAN(sanitizedVal)) {
                        return "IBAN ist ungültig!";
                      }
                      return null;
                    },
                    onSaved: (value) {
                      String sanitizedVal = value?.trim() ?? '';
                      _recipient.iban = sanitizedVal;
                    },
                    onChanged: (value) {
                      _currentIban = value;
                      checkValid();
                    },
                  ),
                  const SizedBox(height: 8.0),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: isBicRequired(
                              iban: _currentIban, currency: _currentCurrency)
                          ? "BIC / SWIFT"
                          : "BIC / SWIFT (optional)",
                    ),
                    textInputAction: TextInputAction.next,
                    initialValue: _recipient.bic,
                    validator: (value) {
                      String sanitizedVal = value?.trim() ?? '';
                      if (sanitizedVal.isEmpty) {
                        return isBicRequired(
                                iban: _currentIban, currency: _currentCurrency)
                            ? 'BIC erforderlich (außerhalb SEPA oder in Fremdwährung)'
                            : null;
                      }
                      if (sanitizedVal.length < 8) {
                        return 'BIC muss mindestens 8 Zeichen lang sein';
                      }
                      if (sanitizedVal.length > 8 && sanitizedVal.length != 11) {
                        return 'BIC darf 8 oder  11 Zeichen lang sein';
                      }
                      //if (!SepaPayment.isValidIBAN(sanitizedVal))
                      //  return "BIC ist ungültig!";
                      return null;
                    },
                    onSaved: (value) {
                      String sanitizedVal = value?.trim() ?? '';
                      _recipient.bic = sanitizedVal;
                    },
                    onChanged: (value) {checkValid(); },
                  ),
                  const SizedBox(height: 8.0),
                  TextFormField(
                    decoration: InputDecoration(labelText: "Währung"),
                    textInputAction: TextInputAction.next,
                    initialValue: _recipient.currency,
                    validator: (value) {
                      String sanitizedVal = value?.trim() ?? '';
                      if (sanitizedVal.isEmpty || sanitizedVal.length < 3) {
                        return 'Währung muss mindestens 3 Zeichen lang sein';
                      }
                      //if (sanitizedVal.length > 8 && sanitizedVal.length != 11)
                      //  return 'BIC darf 8 oder  11 Zeichen lang sein';
                      //if (!SepaPayment.isValidIBAN(sanitizedVal))
                      //  return "BIC ist ungültig!";
                      return null;
                    },
                    onSaved: (value) {
                      String sanitizedVal = (value?.trim() ?? '').toUpperCase();
                      _recipient.currency = sanitizedVal;
                    },
                    onChanged: (value) {
                      _currentCurrency = value;
                      checkValid();
                    },
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
                            if (!context.mounted) return;
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
