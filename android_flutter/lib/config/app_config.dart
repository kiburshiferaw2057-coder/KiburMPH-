class PaymentAccount {
  final String method;
  final String accountNumber;
  final String accountHolder;

  const PaymentAccount({
    required this.method,
    required this.accountNumber,
    required this.accountHolder,
  });
}

enum AppLanguage {
  amharic('am', 'አማርኛ', 'Amharic'),
  afanOromo('om', 'Afaan Oromoo', 'Afan Oromo'),
  tigrigna('ti', 'ትግርኛ', 'Tigrigna'),
  english('en', 'English', 'English'),
  arabic('ar', 'العربية', 'Arabic'),
  others('other', 'Others', 'Others');

  final String code;
  final String nativeLabel;
  final String englishLabel;

  const AppLanguage(this.code, this.nativeLabel, this.englishLabel);
}

class AppConfig {
  static const String appName = 'BINGO ET';
  static const String versionLabel = 'v3.0';
  static const String referenceWebUrl = 'http://www.bingo1020.com';
  static const String apiBaseUrl = 'https://bingo1020.onrender.com';
  static const String accountHolder = 'Kibur shiferaw kassa';
  static const AppLanguage defaultLanguage = AppLanguage.amharic;

  static const int roundDurationSeconds = 120;
  static const int minCardNumber = 1;
  static const int maxCardNumber = 600;
  static const bool muteAlarmSound = true;
  static const bool showBalance = true;
  static const bool showBirrPaymentsOnly = true;
  static const bool hideEightyPercentMetric = true;

  static const List<PaymentAccount> paymentAccounts = [
    PaymentAccount(
      method: 'Telebirr',
      accountNumber: '0912341486',
      accountHolder: accountHolder,
    ),
    PaymentAccount(
      method: 'Telebirr',
      accountNumber: '0941705946',
      accountHolder: accountHolder,
    ),
    PaymentAccount(
      method: 'CBE',
      accountNumber: '1000058081624',
      accountHolder: accountHolder,
    ),
    PaymentAccount(
      method: 'BOA',
      accountNumber: '82323805',
      accountHolder: accountHolder,
    ),
  ];
}
