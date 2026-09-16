/// ISO 3166-1 alpha-2 codes of SEPA participants: the 27 EU member states
/// plus the EEA/other countries that also take part in SEPA credit transfers.
const Set<String> sepaCountryCodes = {
  // EU member states
  'AT', 'BE', 'BG', 'HR', 'CY', 'CZ', 'DK', 'EE', 'FI', 'FR', 'DE', 'GR',
  'HU', 'IE', 'IT', 'LV', 'LT', 'LU', 'MT', 'NL', 'PL', 'PT', 'RO', 'SK',
  'SI', 'ES', 'SE',
  // Other SEPA participants
  'IS', 'LI', 'NO', 'CH', 'MC', 'SM', 'VA', 'AD', 'GB',
};

bool isSepaIban(String iban) {
  final cleaned = iban.trim().replaceAll(' ', '');
  if (cleaned.length < 2) return false;
  return sepaCountryCodes.contains(cleaned.substring(0, 2).toUpperCase());
}

/// A SEPA credit transfer in EUR to a SEPA-country IBAN can be routed by the
/// IBAN alone; anything else (a different currency, or a receiving bank
/// outside SEPA) still needs the BIC.
bool isBicRequired({required String iban, required String currency}) {
  if (currency.trim().toUpperCase() != 'EUR') return true;
  return !isSepaIban(iban);
}
