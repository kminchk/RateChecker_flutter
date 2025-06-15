import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'theme_notifier.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: const RateCheckerApp(),
    ),
  );
}

class RateCheckerApp extends StatelessWidget {
  const RateCheckerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'RateChecker',
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: Colors.white,
            primarySwatch: Colors.red,
            cardColor: Colors.white,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: Colors.black,
            cardColor: Colors.grey[900],
            primarySwatch: Colors.red,
          ),
          themeMode: themeNotifier.themeMode,
          home: const RateCheckerScreen(),
        );
      },
    );
  }
}

class RateCheckerScreen extends StatefulWidget {
  const RateCheckerScreen({super.key});

  @override
  State<RateCheckerScreen> createState() => _RateCheckerScreenState();
}

class _RateCheckerScreenState extends State<RateCheckerScreen> {
  final amountController = TextEditingController(text: '1000');
  String fromCurrency = 'JPY';
  String toCurrency = 'THB';
  double result = 0.0;
  double rate = 0.0;
  String lastUpdated = '';

  final List<String> currencies = [
    'USD',
    'THB',
    'EUR',
    'JPY',
    'KRW',
    'SGD',
    'AUD',
    'CNY',
    'GBP',
    'MYR',
    'PHP',
    'VND',
    'IDR',
    'CAD',
    'NZD',
    'CHF',
    'SEK',
    'NOK',
    'RUB',
    'HKD',
    'INR',
    'TWD',
    'DKK',
    'PLN',
    'TRY',
    'ZAR',
  ];

  Future<void> fetchRate() async {
    final url = Uri.parse(
      'https://v6.exchangerate-api.com/v6/311bc966946f991f1030f191/latest/$fromCurrency',
    );

    final response = await http.get(url);
    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (data['conversion_rates'][toCurrency] == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("ไม่พบเรตของสกุลเงินนี้")));
        return;
      }

      double rateFetched = data['conversion_rates'][toCurrency];
      double amount = double.tryParse(amountController.text) ?? 0;

      setState(() {
        rate = rateFetched;
        result = amount * rateFetched;
        lastUpdated = DateFormat('dd MMM yyyy HH:mm:ss').format(DateTime.now());
      });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("ไม่สามารถโหลดเรตได้")));
    }
  }

  void launchGitHub() async {
    final Uri url = Uri.parse('https://github.com/kminchk');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ไม่สามารถเปิดลิงก์ได้')));
    }
  }

  @override
  void initState() {
    super.initState();
    fetchRate();
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final isDark = themeNotifier.themeMode == ThemeMode.dark;

    return Scaffold(
      body: Stack(
        children: [
          // ปุ่มขวาบน
          Positioned(
            top: 60,
            right: 25,
            child: IconButton(
              icon: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
              onPressed: themeNotifier.toggleTheme,
            ),
          ),

          // เนื้อหา
          Center(
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // หัว
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/images/pen.png', height: 48),
                        const SizedBox(width: 8),
                        const Text(
                          "RateChecker",
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "リアルタイム為替レート 😊",
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "อัตราแลกเปลี่ยนเงินแบบเรียลไทม์",
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 24),

                    // Input
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      onChanged: (val) => fetchRate(),
                      decoration: const InputDecoration(
                        labelText: 'จำนวนเงิน (金額)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Dropdowns
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: fromCurrency,
                            items: currencies.map((e) {
                              return DropdownMenuItem(value: e, child: Text(e));
                            }).toList(),
                            onChanged: (val) {
                              setState(() => fromCurrency = val!);
                              fetchRate();
                            },
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Icon(Icons.swap_horiz),
                        ),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: toCurrency,
                            items: currencies.map((e) {
                              return DropdownMenuItem(value: e, child: Text(e));
                            }).toList(),
                            onChanged: (val) {
                              setState(() => toCurrency = val!);
                              fetchRate();
                            },
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ผลลัพธ์
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            "ผลการแปลงสกุลเงิน (換算結果)",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "${result.toStringAsFixed(2)} $toCurrency",
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "1 $fromCurrency = ${rate.toStringAsFixed(4)} $toCurrency",
                          ),
                          Text("Last updated: $lastUpdated"),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    ElevatedButton.icon(
                      onPressed: fetchRate,
                      icon: const Icon(Icons.refresh),
                      label: const Text("Refresh Rate"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(48),
                      ),
                    ),

                    const SizedBox(height: 24),
                    const Divider(),
                    const Text(
                      'Data provided by Exchange Rate API',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: launchGitHub,
                      child: const Text(
                        '</> Created by MinDev',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blueAccent,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
