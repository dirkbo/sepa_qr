import 'package:flutter/material.dart';

class EditPaymentScreen extends StatefulWidget {
  static const routeName = "/edit/";

  @override
  _EditPaymentScreenState createState() => _EditPaymentScreenState();
}

class _EditPaymentScreenState extends State<EditPaymentScreen> {
  bool isValid() {
    return false;
  }

  void savePayment() {

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
                child: Column(children: [
                  Text("Bearbeiten"),
                  const SizedBox(height: 16.0),
                  TextFormField(decoration: InputDecoration(labelText: "An"),),
                  const SizedBox(height: 8.0),
                  TextFormField(
                    decoration: InputDecoration(labelText: "ISIN"),),
                  const SizedBox(height: 8.0),
                  TextFormField(
                    decoration: InputDecoration(labelText: "BIC / SWIFT"),),
                  const SizedBox(height: 8.0),
                  TextFormField(
                    decoration: InputDecoration(labelText: "Währung"),),
                  const SizedBox(height: 8.0),
                  TextFormField(
                    decoration: InputDecoration(labelText: "Betrag"),),
                  const SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(onPressed: () {
                        Navigator.of(context).pop();
                      }, child: Text("Abbrechen")),
                      ElevatedButton(onPressed: isValid()
                          ? () {
                            savePayment();
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
