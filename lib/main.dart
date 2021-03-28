import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() {
  runApp(MoneyQR());
}

class MoneyQR extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MoneyQRHomePage(title: 'Money QR'),
    );
  }
}

class MoneyQRHomePage extends StatefulWidget {
  MoneyQRHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MoneyQRHomePageState createState() => _MoneyQRHomePageState();
}

class SepaPayment {
  String isin;
  String bic;
  String recipient;
  String message;
  String currency;
  double amount;

  SepaPayment({
    this.isin : "DE33100205000001194700",
    this.bic : "BFSWDE33BER",
    this.recipient : "Wikimedia Foerdergesellschaft",
    this.message : "Spende fuer Wikipedia",
    this.amount : 0.00,
    this.currency : "EUR"
  });

  String get qrData {
    return "BCD\n"
        "001\n"
        "1\n"
        "SCT\n"
        "$bic\n"
        "$recipient\n"
        "$isin\n"
        "$currency${amount.toStringAsPrecision(2)}\n"
        "\n"
        "\n"
        "$message";
  }
}

class _MoneyQRHomePageState extends State<MoneyQRHomePage> {
  SepaPayment paymentData = SepaPayment();
  String qrData;

  @override
  void initState() {
    qrData = paymentData.qrData;
    super.initState();
  }

  void updateQrData({bool doSetState : false}) {
    if (doSetState) {
      setState(() {
        qrData = paymentData.qrData;
      });
    } else {
      qrData = paymentData.qrData;
    }
  }
  @override
  Widget build(BuildContext context) {
    final ThemeData _theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: 300.0,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text("Deine Überweisung", style: _theme.textTheme.headline4),
                    ],),
                  const SizedBox(height: 16.0,),
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
                  QrImage(
                    data: qrData,
                    version: QrVersions.auto,
                    size: 320,
                    gapless: false,
                  ),
                  const SizedBox(height: 16.0,),
                  Text("Scanne den QR-Code mit deiner Banking App, um die Überwesiungsdaten zu übernehmen und die Überweisung abzuschließen", softWrap: true,),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Zahlung bearbeiten',
        child: Icon(Icons.edit),
      ),
    );
  }
}
