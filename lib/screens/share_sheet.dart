import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../models/payment.dart';

Future<void> showShareSheet(BuildContext context, SepaPayment payment) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
    ),
    builder: (context) => _ShareSheet(payment: payment),
  );
}

Future<Uint8List> _buildQrPngBytes(SepaPayment payment,
    {double size = 640}) async {
  const quietZone = 32.0;
  const textTopPadding = 24.0;
  const lineSpacing = 10.0;

  final lines = [
    "Empfänger: ${payment.recipient}",
    "IBAN: ${payment.iban}",
    if (payment.message.trim().isNotEmpty) "Nachricht: ${payment.message}",
    "Betrag: ${payment.currency} ${payment.amount.toStringAsFixed(2)}",
  ];

  final textPainters = lines.map((line) {
    final tp = TextPainter(
      text: TextSpan(
        text: line,
        style: const TextStyle(color: Colors.black, fontSize: 26.0),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout(maxWidth: size);
    return tp;
  }).toList();

  final canvasWidth = size + quietZone * 2;
  final canvasHeight = quietZone +
      size +
      textTopPadding +
      textPainters.fold<double>(
          0.0, (sum, tp) => sum + tp.height + lineSpacing) +
      quietZone;

  final qrImage = await QrPainter(
    data: payment.qrData,
    version: QrVersions.auto,
    gapless: false,
  ).toImage(size);

  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.drawRect(
    Rect.fromLTWH(0, 0, canvasWidth, canvasHeight),
    Paint()..color = Colors.white,
  );
  canvas.drawImage(qrImage, const Offset(quietZone, quietZone), Paint());

  double y = quietZone + size + textTopPadding;
  for (final tp in textPainters) {
    tp.paint(canvas, Offset(quietZone, y));
    y += tp.height + lineSpacing;
  }

  final picture = recorder.endRecording();
  final composed =
      await picture.toImage(canvasWidth.toInt(), canvasHeight.toInt());
  final byteData = await composed.toByteData(format: ui.ImageByteFormat.png);

  // ui.Image/Picture/TextPainter hold native memory that is only reclaimed on
  // an explicit dispose, not by the Dart GC.
  picture.dispose();
  composed.dispose();
  qrImage.dispose();
  for (final tp in textPainters) {
    tp.dispose();
  }

  return byteData!.buffer.asUint8List();
}

String _paymentText(SepaPayment payment) {
  return "An: ${payment.recipient}\n"
      "IBAN: ${payment.iban}\n"
      "BIC: ${payment.bic}\n"
      "Betrag: ${payment.currency} ${payment.amount.toStringAsFixed(2)}\n"
      "Nachricht: ${payment.message}";
}

Future<void> _shareImageBytes(Uint8List bytes, SepaPayment payment) {
  return SharePlus.instance.share(ShareParams(
    files: [XFile.fromData(bytes, mimeType: 'image/png', name: 'money_qr.png')],
    text: _paymentText(payment),
    subject: 'Money QR',
  ));
}

Future<void> _shareQrImage(SepaPayment payment) async {
  await _shareImageBytes(await _buildQrPngBytes(payment), payment);
}

Future<void> _sharePaymentText(SepaPayment payment) {
  return SharePlus.instance.share(ShareParams(
    text: _paymentText(payment),
    subject: 'Money QR',
  ));
}

Future<void> _saveQrImage(BuildContext context, SepaPayment payment) async {
  // Resolved before the first await: the sheet is popped on tap, so its context
  // is torn down while the image is still being generated.
  final messenger = ScaffoldMessenger.of(context);
  final bytes = await _buildQrPngBytes(payment);
  try {
    await Gal.putImageBytes(bytes, album: 'Money QR', name: 'money_qr');
    messenger.showSnackBar(
      const SnackBar(content: Text("QR-Code in der Galerie gespeichert")),
    );
  } catch (_) {
    // Saving to a device gallery isn't available on this platform (e.g. web,
    // Windows desktop) — fall back to sharing the image instead.
    await _shareImageBytes(bytes, payment);
  }
}

class _ShareSheet extends StatelessWidget {
  const _ShareSheet({required this.payment});

  final SepaPayment payment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(6.0),
                    child: QrImageView(
                      data: payment.qrData,
                      version: QrVersions.auto,
                      size: 56.0,
                      gapless: false,
                    ),
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        payment.recipient,
                        style: theme.textTheme.titleMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "${payment.currency} ${payment.amount.toStringAsFixed(2)} · ${payment.iban}",
                        style: theme.textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Text("Teilen als", style: theme.textTheme.titleMedium),
            const SizedBox(height: 4.0),
            // On web, sharing an image and saving one both just trigger the
            // same browser download, so showing both is redundant.
            if (!kIsWeb)
              _ShareOptionTile(
                icon: Icons.qr_code,
                title: "QR-Code als Bild",
                subtitle: "PNG zum Weiterleiten oder Ausdrucken",
                onTap: () {
                  Navigator.of(context).pop();
                  _shareQrImage(payment);
                },
              ),
            _ShareOptionTile(
              icon: Icons.description_outlined,
              title: "Zahlungsdaten als Text",
              subtitle: "Empfänger, IBAN, Betrag und Nachricht",
              onTap: () {
                Navigator.of(context).pop();
                _sharePaymentText(payment);
              },
            ),
            _ShareOptionTile(
              icon: Icons.download_rounded,
              title: "Als Bild speichern",
              subtitle: "Legt den QR-Code in der Galerie ab",
              onTap: () {
                Navigator.of(context).pop();
                _saveQrImage(context, payment);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ShareOptionTile extends StatelessWidget {
  const _ShareOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.primaryContainer,
        foregroundColor: theme.colorScheme.onPrimaryContainer,
        child: Icon(icon),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: onTap,
    );
  }
}
