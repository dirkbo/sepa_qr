# Money QR

A small Flutter app that turns a SEPA bank transfer into a scannable QR code
([EPC069-12 / "Girocode"](https://en.wikipedia.org/wiki/EPC_QR_code) format),
so someone can pay you by scanning it with their banking app instead of
typing in your IBAN by hand.

## Features

- Generates an EPC QR code from an IBAN, BIC, recipient name, amount and
  payment reference
- Address book of saved recipients, stored locally with [Hive](https://pub.dev/packages/hive)
- Last-used payment details are remembered between launches (`shared_preferences`)
- IBAN validation via the [`iban`](https://pub.dev/packages/iban) package
- Runs on Android, Windows desktop and the web; the `ios/` project
  scaffolding is present but has not been built/tested from this repo

The app is currently only localized in German.

## Tech stack

- Flutter / Dart, state managed with [`provider`](https://pub.dev/packages/provider)
- [`hive`](https://pub.dev/packages/hive) + `hive_flutter` for on-device storage of saved recipients
- [`qr_flutter`](https://pub.dev/packages/qr_flutter) to render the QR code

## Project layout

```
lib/
├── main.dart                     # App entry point, Hive init, route table
├── models/
│   ├── payment.dart               # SepaPayment: the data that becomes qrData
│   └── recipient.dart             # PaymentRecipient: a saved address-book entry (Hive model)
├── providers/
│   └── payment_provider.dart      # Holds the in-progress payment, persists/restores it
└── screens/
    ├── paymentqr_screen.dart      # Home screen: shows the QR code
    ├── edit_payment_screen.dart   # Edit the current payment's amount/message/recipient
    ├── edit_recipient_screen.dart # Create/edit a saved recipient
    └── recipients_list_screen.dart# Address book list
```

## Getting started

Requires the Flutter SDK (see `environment.sdk` in `pubspec.yaml` for the
minimum Dart version). Then:

```bash
flutter pub get
```

Run it:

```bash
flutter run -d windows   # Windows desktop
flutter run -d chrome    # Web (needs Chrome installed and on PATH,
                          # or set CHROME_EXECUTABLE)
flutter run -d android   # Android device/emulator
```

Build a release artifact:

```bash
flutter build apk        # Android
flutter build web        # Web
flutter build windows    # Windows desktop
```

### Regenerating the Hive model

`PaymentRecipient` (`lib/models/recipient.dart`) uses Hive's code generation
to produce `recipient.g.dart`. If you change its fields, regenerate it with:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Known caveats

- `hive` and `hive_generator` are unmaintained; `build_runner` is pinned to
  `^2.4.13` in `pubspec.yaml` because newer releases pull in an
  `analyzer`/`source_gen` chain that conflicts with `hive_generator`. See
  the [`hive_ce`](https://pub.dev/packages/hive_ce) fork if this becomes a
  blocker.
- `test/widget_test.dart` is still the default template test and doesn't
  actually exercise this app.
