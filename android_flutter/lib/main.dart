import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'config/app_config.dart';
import 'i18n/app_translations.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BingoEtV3App());
}

class BingoEtV3App extends StatelessWidget {
  const BingoEtV3App({super.key});

  @override
  Widget build(BuildContext context) {
    const vividBlue = Color(0xFF0B5ED7);
    return MaterialApp(
      title: '${AppConfig.appName} ${AppConfig.versionLabel}',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: vividBlue,
          primary: vividBlue,
          surface: const Color(0xFFF3F7FC),
        ),
        scaffoldBackgroundColor: const Color(0xFFF3F7FC),
      ),
      home: const BingoLobbyAndPaymentsScreen(),
    );
  }
}

class BingoLobbyAndPaymentsScreen extends StatefulWidget {
  const BingoLobbyAndPaymentsScreen({super.key});

  @override
  State<BingoLobbyAndPaymentsScreen> createState() =>
      _BingoLobbyAndPaymentsScreenState();
}

class _BingoLobbyAndPaymentsScreenState
    extends State<BingoLobbyAndPaymentsScreen> {
  Timer? _countdownTimer;
  int _secondsRemaining = AppConfig.roundDurationSeconds;
  final Set<int> _selectedCards = <int>{};
  final TextEditingController _receiptController = TextEditingController();
  final double _balanceBirr = 0.00;
  AppLanguage _selectedLanguage = AppConfig.defaultLanguage;
  String _selectedMethodLabel =
      '${AppConfig.paymentAccounts.first.method} - ${AppConfig.paymentAccounts.first.accountNumber}';

  String _t(String key) => AppTranslations.tr(_selectedLanguage, key);

  @override
  void initState() {
    super.initState();
    _syncCountdown();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _syncCountdown();
    });
  }

  void _syncCountdown() {
    final nowSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final rem = AppConfig.roundDurationSeconds -
        (nowSec % AppConfig.roundDurationSeconds);
    if (mounted) {
      setState(() => _secondsRemaining = rem);
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _receiptController.dispose();
    super.dispose();
  }

  String get _formattedCountdown {
    final mins = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final secs = (_secondsRemaining % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  void _copyValue(String value, String label) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${_t('copied')} $label: $value')),
    );
  }

  void _toggleCard(int cardNumber) {
    setState(() {
      if (_selectedCards.contains(cardNumber)) {
        _selectedCards.remove(cardNumber);
      } else {
        if (_selectedCards.length >= 10) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_t('maxCards'))),
          );
          return;
        }
        _selectedCards.add(cardNumber);
      }
    });
  }

  void _submitReceipt() {
    final receipt = _receiptController.text.trim();
    if (receipt.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_t('invalidReceipt'))),
      );
      return;
    }
    setState(() {
      _receiptController.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${_t('receiptLogged')} "$receipt" (${AppConfig.accountHolder} • $_selectedMethodLabel)',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const vividBlue = Color(0xFF0B5ED7);
    final textDir = _selectedLanguage == AppLanguage.arabic
        ? TextDirection.rtl
        : TextDirection.ltr;

    return Directionality(
      textDirection: textDir,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: vividBlue,
          foregroundColor: Colors.white,
          title: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 34,
                  height: 34,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  '${AppConfig.appName} ${AppConfig.versionLabel}',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          actions: [
            if (AppConfig.showBalance)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Text(
                    '${_balanceBirr.toStringAsFixed(2)} ${_t('balance')}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _t('language'),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    DropdownButton<AppLanguage>(
                      value: _selectedLanguage,
                      onChanged: (AppLanguage? newLang) {
                        if (newLang != null) {
                          setState(() => _selectedLanguage = newLang);
                        }
                      },
                      items: AppLanguage.values
                          .map(
                            (lang) => DropdownMenuItem<AppLanguage>(
                              value: lang,
                              child: Text('${lang.nativeLabel} (${lang.englishLabel})'),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              color: vividBlue,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _t('newGameEvery2Min'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '${_t('cardsRange')} • ${AppConfig.referenceWebUrl}',
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _formattedCountdown,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_t('selectCards')} (${AppConfig.minCardNumber}–${AppConfig.maxCardNumber}) • ${_t('selected')}: ${_selectedCards.length}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(12, (index) {
                        final cardNo = index + 1;
                        final selected = _selectedCards.contains(cardNo);
                        return ChoiceChip(
                          label: Text('#$cardNo'),
                          selected: selected,
                          onSelected: (_) => _toggleCard(cardNo),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${_t('accountHolder')}: ${AppConfig.accountHolder}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, size: 18),
                          onPressed: () => _copyValue(
                            AppConfig.accountHolder,
                            _t('accountHolder'),
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    ...AppConfig.paymentAccounts.map(
                      (acc) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text('${acc.method}: ${acc.accountNumber}'),
                        subtitle: Text('${_t('holder')}: ${acc.accountHolder}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed: () => _copyValue(acc.accountNumber, acc.method),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _t('receiptTitle'),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _selectedMethodLabel,
                      items: AppConfig.paymentAccounts
                          .map(
                            (a) => DropdownMenuItem(
                              value: '${a.method} - ${a.accountNumber}',
                              child: Text('${a.method} (${a.accountNumber})'),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setState(() => _selectedMethodLabel = v);
                        }
                      },
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: _t('paymentAccount'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _receiptController,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: _t('receiptNumber'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _submitReceipt,
                        icon: const Icon(Icons.receipt_long),
                        label: Text(_t('submitReceipt')),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
