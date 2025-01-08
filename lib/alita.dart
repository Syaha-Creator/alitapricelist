// ignore_for_file: use_build_context_synchronously

import 'package:alitapricelist/login.dart';
import 'package:alitapricelist/url.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:logger/web.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pattern_formatter/numeric_formatter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Alita extends StatefulWidget {
  const Alita({super.key});

  @override
  State<Alita> createState() => _AlitaState();
}

class _AlitaState extends State<Alita> {
  var logger = Logger();
  final NumberFormat currencyFormat =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp. ', decimalDigits: 0);
  // Dropdown options
  List<String> areaOptions = [];
  List<String> channelOptions = [];
  List<String> brandOptions = [];
  List<String> kasurOptions = [];
  List<String> divanOptions = [];
  List<String> headboardOptions = [];
  List<String> sorongOptions = [];
  List<String> ukuranOptions = [];

  // Selected values
  String? selectedArea;
  String? selectedChannel;
  String? selectedBrand;
  String? selectedKasur;
  String? selectedDivan = 'Tanpa Divan';
  String? selectedHeadboard = 'Tanpa Headboard';
  String? selectedSorong = 'Tanpa Sorong';
  String? selectedUkuran;

  // Data API
  List<Map<String, dynamic>> originalResults = [];

  // Hasil pencarian
  List<Map<String, dynamic>> searchResults = [];

  // Selected Card
  Map<String, dynamic>? selectedItem;
  Map<int, Map<String, double>> cardDiscounts = {};

  // Filter Dropdown
  List<dynamic> result = [];

  // Loading
  bool isLoading = false;
  bool isDropdownLoading = false;

  // Login
  String? nama, token, image;
  getPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    nama = prefs.getString('name')!;
    image = prefs.getString('image_url')!;

    setState(() {
      nama = prefs.getString('name');
      image = prefs.getString('image_url');
    });
  }

  Future<bool> logout() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    token = preferences.getString("access_token");

    final response = await http.post(
      Uri.parse('${URLV2}oauth/revoke?token=${token!}$Client_Andro'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    if (response.statusCode == 200) {
      var result = jsonDecode(response.body);
      logger.i(result);
      Fluttertoast.showToast(
          msg: "Logout Success",
          backgroundColor: Colors.redAccent.shade200,
          textColor: Colors.white,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP);

      setState(() {
        preferences.setInt("value", 0);
        preferences.remove("email");
        preferences.remove("name");
      });

      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const Login()));

      return true;
    } else {
      Fluttertoast.showToast(
          msg: "Logout Failed  Status = ${response.statusCode}",
          backgroundColor: Colors.redAccent.shade100,
          textColor: Colors.white,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP);
    }
    throw Exception(response.statusCode);
  }

  @override
  void initState() {
    super.initState();
    getPref();
    fetchAndProcessDropdownData();
  }

  Future<void> fetchAndProcessDropdownData() async {
    setState(() {
      isDropdownLoading = true;
    });

    final url = Uri.parse(
        'https://alitav2.massindo.com/api/rawdata_price_lists?access_token=d60Jls5Tr2n63aGOKWXYALhX5JRwXREE2IneQoGKiT4&client_id=hqJ199kBBLePkNt9mhS9EbgaCC6RarYxQux-fzebUZ8&client_secret=xtvj63aVIPaFNOiGKtOu1Su5EBYzdP_MZTG60uwGzP0');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'success' && data['result'] is List) {
          result = data['result'];

          // Memproses dropdown options
          setState(() {
            areaOptions = result
                .map((item) => item['area'] as String?)
                .whereType<String>()
                .toSet()
                .toList();

            selectedChannel = null;
            selectedBrand = null;
            selectedKasur = null;
            selectedDivan = 'Tanpa Divan';
            selectedHeadboard = 'Tanpa Headboard';
            selectedSorong = 'Tanpa Sorong';
            selectedUkuran = null;

            channelOptions = [];
            brandOptions = [];
            kasurOptions = [];
            divanOptions = [];
            headboardOptions = [];
            sorongOptions = [];
            ukuranOptions = [];
          });
        } else {
          throw Exception('Unexpected data format');
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      logger.e('⛔ Error fetching dropdown data: $e');
    } finally {
      setState(() {
        isDropdownLoading = false;
      });
    }
  }

  void updateChannelOptions(String area) {
    channelOptions = result
        .where((item) => item['area'] == area)
        .map((item) => item['channel'] as String?)
        .whereType<String>()
        .toSet()
        .toList();

    selectedChannel = null;
    selectedBrand = null;
    selectedKasur = null;
    selectedDivan = 'Tanpa Divan';
    selectedHeadboard = 'Tanpa Headboard';
    selectedSorong = 'Tanpa Sorong';
    selectedUkuran = null;

    brandOptions = [];
    kasurOptions = [];
    divanOptions = [];
    headboardOptions = [];
    sorongOptions = [];
    ukuranOptions = [];
  }

  void updateBrandOptions(String channel) {
    brandOptions = result
        .where((item) => item['channel'] == channel)
        .map((item) => item['brand'] as String?)
        .whereType<String>()
        .toSet()
        .toList();

    selectedBrand = null;
    selectedKasur = null;
    selectedDivan = 'Tanpa Divan';
    selectedHeadboard = 'Tanpa Headboard';
    selectedSorong = 'Tanpa Sorong';
    selectedUkuran = null;

    kasurOptions = [];
    divanOptions = [];
    headboardOptions = [];
    sorongOptions = [];
    ukuranOptions = [];
  }

  void updateKasurOptions(String brand, String channel) {
    kasurOptions = result
        .where((item) => item['brand'] == brand && item['channel'] == channel)
        .map((item) => item['kasur'] as String?)
        .whereType<String>()
        .toSet()
        .toList();

    selectedKasur = null;
    selectedDivan = 'Tanpa Divan';
    selectedHeadboard = 'Tanpa Headboard';
    selectedSorong = 'Tanpa Sorong';
    selectedUkuran = null;

    divanOptions = [];
    headboardOptions = [];
    sorongOptions = [];
    ukuranOptions = [];
  }

  void updateDivanOptions(String kasur, String brand, String channel) {
    divanOptions = result
        .where((item) =>
            item['kasur'] == kasur &&
            item['brand'] == brand &&
            item['channel'] == channel)
        .map((item) => item['divan'] as String?)
        .whereType<String>()
        .toSet()
        .toList();

    setState(() {
      selectedDivan =
          divanOptions.isNotEmpty ? divanOptions.first : 'Tanpa Divan';
    });
  }

  void updateHeadboardOptions(String kasur, String brand, String channel) {
    headboardOptions = result
        .where((item) =>
            item['kasur'] == kasur &&
            item['brand'] == brand &&
            item['channel'] == channel)
        .map((item) => item['headboard'] as String?)
        .whereType<String>()
        .toSet()
        .toList();

    setState(() {
      selectedHeadboard = headboardOptions.isNotEmpty
          ? headboardOptions.first
          : 'Tanpa Headboard';
    });
  }

  void updateSorongOptions(String kasur, String brand, String channel) {
    sorongOptions = result
        .where((item) =>
            item['kasur'] == kasur &&
            item['brand'] == brand &&
            item['channel'] == channel)
        .map((item) => item['sorong'] as String?)
        .whereType<String>()
        .toSet()
        .toList();

    setState(() {
      selectedSorong =
          sorongOptions.isNotEmpty ? sorongOptions.first : 'Tanpa Sorong';
    });
  }

  void updateUkuranOptions(String kasur, String brand, String channel) {
    ukuranOptions = result
        .where((item) =>
            item['kasur'] == kasur &&
            item['brand'] == brand &&
            item['channel'] == channel)
        .map((item) => item['ukuran'] as String?)
        .whereType<String>()
        .toSet()
        .toList();

    setState(() {
      selectedUkuran = null;
    });
  }

  Future<void> fetchAndProcessData() async {
    setState(() {
      isLoading = true;
    });

    final url = Uri.parse(
        'https://alitav2.massindo.com/api/rawdata_price_lists?access_token=d60Jls5Tr2n63aGOKWXYALhX5JRwXREE2IneQoGKiT4&client_id=hqJ199kBBLePkNt9mhS9EbgaCC6RarYxQux-fzebUZ8&client_secret=xtvj63aVIPaFNOiGKtOu1Su5EBYzdP_MZTG60uwGzP0');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'success' && data['result'] is List) {
          List<dynamic> result = data['result'];

          setState(() {
            originalResults = result.map((item) {
              final Map<String, dynamic> processedItem = Map.from(item);

              processedItem['pricelist'] = (item['pricelist'] != null)
                  ? formatCurrency(item['pricelist'])
                  : 'Tanpa data';
              processedItem['harga_net'] = (item['end_user_price'] != null)
                  ? formatCurrency(item['end_user_price'])
                  : 'Tanpa data';

              if (item['pricelist'] != null && item['end_user_price'] != null) {
                double totalDiskon = item['pricelist'] - item['end_user_price'];
                processedItem['total_diskon'] = formatCurrency(totalDiskon);
              } else {
                processedItem['total_diskon'] = 'Tanpa data';
              }

              List<String> bonuses = [];
              for (int i = 1; i <= 5; i++) {
                String bonusKey = 'bonus_$i';
                String qtyKey = 'qty_bonus$i';

                if (item[bonusKey] != null && item[qtyKey] != null) {
                  bonuses.add('${item[qtyKey]} ${item[bonusKey]}');
                }
              }
              processedItem['bonuses'] = bonuses.join('\n');
              return processedItem;
            }).toList();

            searchResults = List.from(originalResults);
          });
        } else {
          throw Exception('Unexpected data format');
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      logger.e('⛔ Error fetching search data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void search() async {
    if (originalResults.isEmpty) {
      setState(() {
        isLoading = true;
      });

      await fetchAndProcessData();
    }

    setState(() {
      searchResults = originalResults.where((item) {
        return (selectedArea == null || item['area'] == selectedArea) &&
            (selectedChannel == null || item['channel'] == selectedChannel) &&
            (selectedBrand == null || item['brand'] == selectedBrand) &&
            (selectedKasur == null || item['kasur'] == selectedKasur) &&
            (selectedDivan == null || item['divan'] == selectedDivan) &&
            (selectedHeadboard == null ||
                item['headboard'] == selectedHeadboard) &&
            (selectedSorong == null || item['sorong'] == selectedSorong) &&
            (selectedUkuran == null || item['ukuran'] == selectedUkuran);
      }).toList();

      isLoading = false;
      if (searchResults.isEmpty) {
        Fluttertoast.showToast(
          msg: "Data Tidak di Temukan",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.redAccent,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    });
  }

  void clearFilters() {
    setState(() {
      selectedArea = null;
      selectedChannel = null;
      selectedBrand = null;
      selectedKasur = null;
      selectedDivan = 'Tanpa Divan';
      selectedHeadboard = 'Tanpa Headboard';
      selectedSorong = 'Tanpa Sorong';
      selectedUkuran = null;
      searchResults.clear();

      channelOptions = [];
      brandOptions = [];
      kasurOptions = [];
      divanOptions = [];
      headboardOptions = [];
      sorongOptions = [];
      ukuranOptions = [];
    });
  }

  double getDropdownHeight(List<String> items) {
    if (items.isEmpty) return 130;
    if (items.length == 2) {
      return 180;
    }
    if (items.length == 3) {
      return 240;
    }
    return items.length > 4 ? 300 : items.length * 130;
  }

  // void showCicilanDialog(
  //     BuildContext context, double? cicilan12, double? cicilan15) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text("Cicilan"),
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Text(
  //                 "Cicilan 12 Bulan: ${cicilan12 != null ? formatCurrency(cicilan12) : 'Tanpa data'}"),
  //             const SizedBox(height: 8),
  //             Text(
  //                 "Cicilan 15 Bulan: ${cicilan15 != null ? formatCurrency(cicilan15) : 'Tanpa data'}"),
  //           ],
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //             child: const Text("Tutup"),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  void showCicilanInputDialog(
      BuildContext context, Map<String, dynamic> item, VoidCallback onUpdate) {
    // Ambil jumlah bulan dan cicilan yang sudah ada
    int initialBulan = item['cicilan']?['jumlah_bulan'] ?? 0;
    double initialCicilan = item['cicilan']?['per_bulan'] ?? 0;

    TextEditingController bulanController = TextEditingController(
        text: initialBulan > 0 ? initialBulan.toString() : '');
    double hargaNet = double.tryParse(
            item['harga_net'].replaceAll('Rp. ', '').replaceAll('.', '')) ??
        0;
    double cicilanPerBulan = initialCicilan > 0 ? initialCicilan : hargaNet;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Hitung Cicilan'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Jumlah Bulan'),
                            const SizedBox(height: 8),
                            TextField(
                              controller: bulanController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                hintText: 'Masukkan bulan',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                final jumlahBulan = int.tryParse(value) ?? 0;
                                setState(() {
                                  cicilanPerBulan = jumlahBulan > 0
                                      ? hargaNet / jumlahBulan
                                      : hargaNet;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Cicilan per Bulan'),
                            const SizedBox(height: 8),
                            TextField(
                              readOnly: true,
                              decoration: InputDecoration(
                                hintText: formatCurrency(cicilanPerBulan),
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: const Text("Simpan"),
                  onPressed: () {
                    final jumlahBulan = int.tryParse(bulanController.text) ?? 0;

                    // Simpan cicilan ke item
                    if (jumlahBulan > 0) {
                      item['cicilan'] = {
                        'jumlah_bulan': jumlahBulan,
                        'per_bulan': cicilanPerBulan,
                      };
                    } else {
                      item['cicilan'] = null;
                    }

                    // Perbarui state aplikasi
                    setState(() {
                      searchResults[searchResults.indexOf(item)] = item;
                    });

                    // Callback untuk memperbarui UI
                    onUpdate();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void showDiscountPopup(
      BuildContext context, Map<String, dynamic> item, VoidCallback onUpdate) {
    int itemId = item['id'];

    double disc1 = cardDiscounts[itemId]?['disc1'] ?? 0;
    double disc2 = cardDiscounts[itemId]?['disc2'] ?? 0;
    double disc3 = cardDiscounts[itemId]?['disc3'] ?? 0;
    double disc4 = cardDiscounts[itemId]?['disc4'] ?? 0;
    double disc5 = cardDiscounts[itemId]?['disc5'] ?? 0;

    double nominal1 = cardDiscounts[itemId]?['nominal1'] ?? 0;
    double nominal2 = cardDiscounts[itemId]?['nominal2'] ?? 0;
    double nominal3 = cardDiscounts[itemId]?['nominal3'] ?? 0;
    double nominal4 = cardDiscounts[itemId]?['nominal4'] ?? 0;
    double nominal5 = cardDiscounts[itemId]?['nominal5'] ?? 0;

    TextEditingController disc1Controller =
        TextEditingController(text: disc1 > 0 ? disc1.toString() : '');
    TextEditingController disc2Controller =
        TextEditingController(text: disc2 > 0 ? disc2.toString() : '');
    TextEditingController disc3Controller =
        TextEditingController(text: disc3 > 0 ? disc3.toString() : '');
    TextEditingController disc4Controller =
        TextEditingController(text: disc4 > 0 ? disc4.toString() : '');
    TextEditingController disc5Controller =
        TextEditingController(text: disc5 > 0 ? disc5.toString() : '');

    TextEditingController nominalDisc1Controller = TextEditingController(
        text: nominal1 > 0 ? currencyFormat.format(nominal1) : '');
    TextEditingController nominalDisc2Controller = TextEditingController(
        text: nominal2 > 0 ? currencyFormat.format(nominal2) : '');
    TextEditingController nominalDisc3Controller = TextEditingController(
        text: nominal3 > 0 ? currencyFormat.format(nominal3) : '');
    TextEditingController nominalDisc4Controller = TextEditingController(
        text: nominal4 > 0 ? currencyFormat.format(nominal4) : '');
    TextEditingController nominalDisc5Controller = TextEditingController(
        text: nominal5 > 0 ? currencyFormat.format(nominal5) : '');

    double priceList = double.tryParse(
            item['pricelist']?.replaceAll('Rp. ', '').replaceAll('.', '') ??
                '0') ??
        0;

    double originalPrice = item['end_user_price'] ?? 0;

    double calculatedPrice = item['harga_net'] != null
        ? double.tryParse(
                item['harga_net'].replaceAll('Rp. ', '').replaceAll('.', '')) ??
            originalPrice
        : originalPrice;

    double totalDiscount = priceList - calculatedPrice;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Diskon'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Input diskon untuk pengguna
                    Row(
                      children: [
                        // Input Diskon dalam Persen
                        Expanded(
                          child: TextField(
                            controller: disc1Controller,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                labelText: 'Diskon 1 (%)'),
                            onChanged: (value) {
                              setState(() {
                                disc1 = double.tryParse(value) ?? 0;
                                nominalDisc1Controller.text =
                                    ((calculatedPrice * disc1) / 100)
                                        .toStringAsFixed(0);
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Input Diskon dalam Nominal
                        Expanded(
                          child: TextField(
                            inputFormatters: [ThousandsFormatter()],
                            controller: nominalDisc1Controller,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                labelText: 'Nominal (Rp)'),
                            onChanged: (value) {
                              setState(() {
                                double nominal = double.tryParse(
                                        value.replaceAll(',', '')) ??
                                    0;
                                disc1 = (nominal / calculatedPrice) * 100;
                                disc1Controller.text = disc1.toStringAsFixed(2);
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        // Input Diskon dalam Persen
                        Expanded(
                          child: TextField(
                            controller: disc2Controller,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                labelText: 'Diskon 2 (%)'),
                            onChanged: (value) {
                              setState(() {
                                disc2 = double.tryParse(value) ?? 0;
                                nominalDisc2Controller.text =
                                    ((calculatedPrice * disc2) / 100)
                                        .toStringAsFixed(0);
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Input Diskon dalam Nominal
                        Expanded(
                          child: TextField(
                            inputFormatters: [ThousandsFormatter()],
                            controller: nominalDisc2Controller,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                labelText: 'Nominal (Rp)'),
                            onChanged: (value) {
                              setState(() {
                                double nominal = double.tryParse(
                                        value.replaceAll(',', '')) ??
                                    0;
                                disc2 = (nominal / calculatedPrice) * 100;
                                disc2Controller.text = disc2.toStringAsFixed(2);
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        // Input Diskon dalam Persen
                        Expanded(
                          child: TextField(
                            controller: disc3Controller,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                labelText: 'Diskon 3 (%)'),
                            onChanged: (value) {
                              setState(() {
                                disc3 = double.tryParse(value) ?? 0;
                                nominalDisc3Controller.text =
                                    ((calculatedPrice * disc3) / 100)
                                        .toStringAsFixed(0);
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Input Diskon dalam Nominal
                        Expanded(
                          child: TextField(
                            inputFormatters: [ThousandsFormatter()],
                            controller: nominalDisc3Controller,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                labelText: 'Nominal (Rp)'),
                            onChanged: (value) {
                              setState(() {
                                double nominal = double.tryParse(
                                        value.replaceAll(',', '')) ??
                                    0;
                                disc3 = (nominal / calculatedPrice) * 100;
                                disc3Controller.text = disc3.toStringAsFixed(2);
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        // Input Diskon dalam Persen
                        Expanded(
                          child: TextField(
                            controller: disc4Controller,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                labelText: 'Diskon 4 (%)'),
                            onChanged: (value) {
                              setState(() {
                                disc4 = double.tryParse(value) ?? 0;
                                nominalDisc4Controller.text =
                                    ((calculatedPrice * disc4) / 100)
                                        .toStringAsFixed(0);
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Input Diskon dalam Nominal
                        Expanded(
                          child: TextField(
                            inputFormatters: [ThousandsFormatter()],
                            controller: nominalDisc4Controller,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                labelText: 'Nominal (Rp)'),
                            onChanged: (value) {
                              setState(() {
                                double nominal = double.tryParse(
                                        value.replaceAll(',', '')) ??
                                    0;
                                disc4 = (nominal / calculatedPrice) * 100;
                                disc4Controller.text = disc4.toStringAsFixed(2);
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        // Input Diskon dalam Persen
                        Expanded(
                          child: TextField(
                            controller: disc5Controller,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                labelText: 'Diskon 5 (%)'),
                            onChanged: (value) {
                              setState(() {
                                disc5 = double.tryParse(value) ?? 0;
                                nominalDisc5Controller.text =
                                    ((calculatedPrice * disc5) / 100)
                                        .toStringAsFixed(0);
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Input Diskon dalam Nominal
                        Expanded(
                          child: TextField(
                            inputFormatters: [ThousandsFormatter()],
                            controller: nominalDisc5Controller,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                labelText: 'Nominal (Rp)'),
                            onChanged: (value) {
                              setState(() {
                                double nominal = double.tryParse(
                                        value.replaceAll(',', '')) ??
                                    0;
                                disc5 = (nominal / calculatedPrice) * 100;
                                disc5Controller.text = disc5.toStringAsFixed(2);
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    _buildRow(
                        'Total Diskon', currencyFormat.format(totalDiscount)),
                    _buildRow(
                        'Harga Net', currencyFormat.format(calculatedPrice)),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text("Reset"),
                  onPressed: () {
                    setState(() {
                      cardDiscounts[itemId] = {};

                      disc1Controller.clear();
                      disc2Controller.clear();
                      disc3Controller.clear();
                      disc4Controller.clear();
                      disc5Controller.clear();

                      nominalDisc1Controller.clear();
                      nominalDisc2Controller.clear();
                      nominalDisc3Controller.clear();
                      nominalDisc4Controller.clear();
                      nominalDisc5Controller.clear();

                      disc1 = 0;
                      disc2 = 0;
                      disc3 = 0;
                      disc4 = 0;
                      disc5 = 0;
                      nominal1 = 0;
                      nominal2 = 0;
                      nominal3 = 0;
                      nominal4 = 0;
                      nominal5 = 0;
                      calculatedPrice = originalPrice;
                      totalDiscount = priceList - calculatedPrice;
                    });
                  },
                ),
                TextButton(
                  child: const Text("Simpan"),
                  onPressed: () {
                    Map<String, double> updatedDiscounts = {};

                    // Periksa dan simpan diskon 1 jika diisi
                    if (disc1 > 0) {
                      updatedDiscounts['disc1'] =
                          double.parse(disc1.toStringAsFixed(2));
                    }
                    if (nominalDisc1Controller.text.isNotEmpty) {
                      double? nominal1 = double.tryParse(
                          nominalDisc1Controller.text.replaceAll(',', ''));
                      if (nominal1 != null) {
                        updatedDiscounts['nominal1'] = nominal1;
                      }
                    }

                    // Periksa dan simpan diskon 2 jika diisi
                    if (disc2 > 0) {
                      updatedDiscounts['disc2'] =
                          double.parse(disc2.toStringAsFixed(2));
                    }
                    if (nominalDisc2Controller.text.isNotEmpty) {
                      double? nominal2 = double.tryParse(
                          nominalDisc2Controller.text.replaceAll(',', ''));
                      if (nominal2 != null) {
                        updatedDiscounts['nominal2'] = nominal2;
                      }
                    }

                    // Periksa dan simpan diskon 3 jika diisi
                    if (disc3 > 0) {
                      updatedDiscounts['disc3'] =
                          double.parse(disc3.toStringAsFixed(2));
                    }
                    if (nominalDisc3Controller.text.isNotEmpty) {
                      double? nominal3 = double.tryParse(
                          nominalDisc3Controller.text.replaceAll(',', ''));
                      if (nominal3 != null) {
                        updatedDiscounts['nominal3'] = nominal3;
                      }
                    }

                    // Periksa dan simpan diskon 4 jika diisi
                    if (disc4 > 0) {
                      updatedDiscounts['disc4'] =
                          double.parse(disc4.toStringAsFixed(2));
                    }
                    if (nominalDisc4Controller.text.isNotEmpty) {
                      double? nominal4 = double.tryParse(
                          nominalDisc4Controller.text.replaceAll(',', ''));
                      if (nominal4 != null) {
                        updatedDiscounts['nominal4'] = nominal4;
                      }
                    }

                    // Periksa dan simpan diskon 5 jika diisi
                    if (disc5 > 0) {
                      updatedDiscounts['disc5'] =
                          double.parse(disc5.toStringAsFixed(2));
                    }
                    if (nominalDisc5Controller.text.isNotEmpty) {
                      double? nominal5 = double.tryParse(
                          nominalDisc5Controller.text.replaceAll(',', ''));
                      if (nominal5 != null) {
                        updatedDiscounts['nominal5'] = nominal5;
                      }
                    }

                    // Simpan nilai yang valid ke cardDiscounts
                    cardDiscounts[itemId] = updatedDiscounts;

                    calculatedPrice = calculateDiscountedPrice(
                      originalPrice,
                      [disc1, disc2, disc3, disc4, disc5],
                    );

                    totalDiscount = priceList - calculatedPrice;

                    if (updatedDiscounts.isEmpty) {
                      cardDiscounts.remove(itemId); // Hapus diskon jika kosong
                    }

                    if (item['cicilan'] != null) {
                      int jumlahBulan = item['cicilan']['jumlah_bulan'];
                      if (jumlahBulan > 0) {
                        item['cicilan']['per_bulan'] =
                            calculatedPrice / jumlahBulan;
                      }
                    }

                    // Update item dengan nilai terbaru untuk total diskon dan harga net
                    item['total_diskon'] = formatCurrency(totalDiscount);
                    item['harga_net'] = formatCurrency(calculatedPrice);

                    onUpdate();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  double calculateDiscountedPrice(double hargaNet, List<double> discounts) {
    double finalPrice = hargaNet;
    for (var disc in discounts) {
      finalPrice -= finalPrice * (disc / 100);
    }
    return finalPrice;
  }

  void showEditNetPricePopup(
      BuildContext context, Map<String, dynamic> item, VoidCallback onUpdate) {
    double priceList = double.tryParse(
            item['pricelist']?.replaceAll('Rp. ', '').replaceAll('.', '') ??
                '0') ??
        0;

    double originalNetPrice = item['harga_net'] != null
        ? double.tryParse(
                item['harga_net'].replaceAll('Rp. ', '').replaceAll('.', '')) ??
            item['end_user_price']
        : item['end_user_price'] ?? 0;

    TextEditingController netPriceController =
        TextEditingController(text: formatCurrency2(originalNetPrice));

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Harga Net'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Masukkan Harga Net Baru'),
              const SizedBox(height: 8),
              TextFormField(
                inputFormatters: [ThousandsFormatter()],
                controller: netPriceController,
                decoration: const InputDecoration(
                  prefixText: 'Rp. ',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text("Simpan"),
              onPressed: () {
                double newNetPrice = double.tryParse(
                        netPriceController.text.replaceAll(',', '')) ??
                    originalNetPrice;

                double newTotalDiscount = priceList - newNetPrice;

                item['harga_net'] = formatCurrency(newNetPrice);
                item['total_diskon'] = formatCurrency(newTotalDiscount);

                onUpdate();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  String _getAppliedDiscounts(int itemId) {
    if (cardDiscounts.containsKey(itemId) &&
        cardDiscounts[itemId]!.isNotEmpty) {
      final discounts = cardDiscounts[itemId]!;
      return [
        discounts['disc1'] ?? 0,
        discounts['disc2'] ?? 0,
        discounts['disc3'] ?? 0,
        discounts['disc4'] ?? 0,
        discounts['disc5'] ?? 0
      ].where((discount) => discount > 0).join(' + ');
    }
    return '0'; // Tampilkan 0 jika tidak ada diskon
  }

  String formatCurrency(double amount) {
    final formatCurrency =
        NumberFormat.currency(locale: 'id', symbol: 'Rp. ', decimalDigits: 0);
    return formatCurrency.format(amount);
  }

  String formatCurrency2(double amount) {
    final formatCurrency =
        NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0);
    return formatCurrency.format(amount);
  }

  Widget _buildRow(String label, String? value) {
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
          ),
        ),
        const Text(
          ': ',
          style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
        ),
        Expanded(
          child: Text(
            value ?? 'Tanpa data',
            style: const TextStyle(fontFamily: 'Poppins'),
          ),
        ),
      ],
    );
  }

  String _formatRow(String label, String? value, int maxWidth) {
    value = value ?? 'Tanpa data';
    return '${label.padRight(maxWidth)} : $value';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.asset(
                  'assets/logo.png',
                  height: 30,
                ),
                const SizedBox(width: 10),
                const Text(
                  "Pricelist",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    fontFamily: 'Poppins',
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
            InkWell(
              onTap: () {
                logout();
              },
              child: Image.asset(
                'assets/power.png',
                width: 30,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 4,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // DropdownSearch for each dropdown
              DropdownSearch<String>(
                dropdownDecoratorProps: const DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    labelText: "Area",
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    border: OutlineInputBorder(),
                  ),
                ),
                popupProps: PopupProps.menu(
                  showSearchBox: true,
                  constraints: BoxConstraints(
                    maxHeight: getDropdownHeight(areaOptions),
                  ),
                ),
                items: areaOptions.isNotEmpty ? areaOptions : [],
                onChanged: (value) {
                  setState(() {
                    selectedArea = value;
                    selectedChannel = null;
                    selectedBrand = null;
                    selectedKasur = null;
                    updateChannelOptions(value!);
                  });
                },
                selectedItem: selectedArea,
                filterFn: (item, filter) =>
                    item.toLowerCase().contains(filter.toLowerCase()),
              ),
              const SizedBox(height: 10),
              DropdownSearch<String>(
                dropdownDecoratorProps: const DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    labelText: "Channel",
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    border: OutlineInputBorder(),
                  ),
                ),
                popupProps: PopupProps.menu(
                  showSearchBox: true,
                  constraints: BoxConstraints(
                    maxHeight: getDropdownHeight(channelOptions),
                  ),
                ),
                items: channelOptions.isNotEmpty ? channelOptions : [],
                onChanged: (value) {
                  setState(() {
                    selectedChannel = value;
                    selectedBrand = null;
                    selectedKasur = null;
                    updateBrandOptions(value!);
                  });
                },
                selectedItem: selectedChannel,
                filterFn: (item, filter) =>
                    item.toLowerCase().contains(filter.toLowerCase()),
              ),
              const SizedBox(height: 10),
              DropdownSearch<String>(
                dropdownDecoratorProps: const DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    labelText: "Brand",
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    border: OutlineInputBorder(),
                  ),
                ),
                popupProps: PopupProps.menu(
                  showSearchBox: true,
                  constraints: BoxConstraints(
                    maxHeight: getDropdownHeight(brandOptions),
                  ),
                ),
                items: brandOptions.isNotEmpty ? brandOptions : [],
                onChanged: (value) {
                  setState(() {
                    selectedBrand = value;
                    selectedKasur = null;
                    if (selectedChannel != null) {
                      updateKasurOptions(selectedBrand!, selectedChannel!);
                    }
                  });
                },
                selectedItem: selectedBrand,
                filterFn: (item, filter) =>
                    item.toLowerCase().contains(filter.toLowerCase()),
              ),
              const SizedBox(height: 10),
              DropdownSearch<String>(
                dropdownDecoratorProps: const DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    labelText: "Kasur",
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    border: OutlineInputBorder(),
                  ),
                ),
                popupProps: PopupProps.menu(
                  showSearchBox: true,
                  constraints: BoxConstraints(
                    maxHeight: getDropdownHeight(kasurOptions),
                  ),
                ),
                items: kasurOptions.isNotEmpty ? kasurOptions : [],
                onChanged: (value) {
                  setState(() {
                    selectedKasur = value;
                    if (value != null) {
                      updateDivanOptions(
                          value, selectedBrand ?? '', selectedChannel ?? '');
                      updateHeadboardOptions(
                          value, selectedBrand ?? '', selectedChannel ?? '');
                      updateSorongOptions(
                          value, selectedBrand ?? '', selectedChannel ?? '');
                      updateUkuranOptions(
                          value, selectedBrand ?? '', selectedChannel ?? '');
                    }
                  });
                },
                selectedItem: selectedKasur,
                filterFn: (item, filter) =>
                    item.toLowerCase().contains(filter.toLowerCase()),
              ),
              const SizedBox(height: 10),
              DropdownSearch<String>(
                dropdownDecoratorProps: const DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    labelText: "Divan",
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    border: OutlineInputBorder(),
                  ),
                ),
                popupProps: PopupProps.menu(
                  showSearchBox: true,
                  constraints: BoxConstraints(
                    maxHeight: getDropdownHeight(divanOptions),
                  ),
                ),
                items: divanOptions.isNotEmpty ? divanOptions : [],
                onChanged: (value) {
                  setState(() {
                    selectedDivan = value;
                  });
                },
                selectedItem: selectedDivan,
                filterFn: (item, filter) =>
                    item.toLowerCase().contains(filter.toLowerCase()),
              ),
              const SizedBox(height: 10),
              DropdownSearch<String>(
                dropdownDecoratorProps: const DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    labelText: "Headboard",
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    border: OutlineInputBorder(),
                  ),
                ),
                popupProps: PopupProps.menu(
                  showSearchBox: true,
                  constraints: BoxConstraints(
                    maxHeight: getDropdownHeight(headboardOptions),
                  ),
                ),
                items: headboardOptions.isNotEmpty ? headboardOptions : [],
                onChanged: (value) {
                  setState(() {
                    selectedHeadboard = value;
                  });
                },
                selectedItem: selectedHeadboard,
                filterFn: (item, filter) =>
                    item.toLowerCase().contains(filter.toLowerCase()),
              ),
              const SizedBox(height: 10),
              DropdownSearch<String>(
                dropdownDecoratorProps: const DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    labelText: "Sorong",
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    border: OutlineInputBorder(),
                  ),
                ),
                popupProps: PopupProps.menu(
                  showSearchBox: true,
                  constraints: BoxConstraints(
                    maxHeight: getDropdownHeight(sorongOptions),
                  ),
                ),
                items: sorongOptions.isNotEmpty ? sorongOptions : [],
                onChanged: (value) {
                  setState(() {
                    selectedSorong = value;
                  });
                },
                selectedItem: selectedSorong,
                filterFn: (item, filter) =>
                    item.toLowerCase().contains(filter.toLowerCase()),
              ),
              const SizedBox(height: 10),
              DropdownSearch<String>(
                dropdownDecoratorProps: const DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    labelText: "Ukuran",
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    border: OutlineInputBorder(),
                  ),
                ),
                popupProps: PopupProps.menu(
                  showSearchBox: true,
                  constraints: BoxConstraints(
                    maxHeight: getDropdownHeight(ukuranOptions),
                  ),
                ),
                items: ukuranOptions.isNotEmpty ? ukuranOptions : [],
                onChanged: (value) {
                  setState(() {
                    selectedUkuran = value;
                  });
                },
                selectedItem: selectedUkuran,
                filterFn: (item, filter) =>
                    item.toLowerCase().contains(filter.toLowerCase()),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: clearFilters,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 18),
                    ),
                    child: const Text(
                      "Clean Filters",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: search,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 18),
                    ),
                    child: const Text(
                      "Search",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (isDropdownLoading)
                const Center(child: CircularProgressIndicator()),

              // Indikator loading untuk hasil pencarian
              if (isLoading) const Center(child: CircularProgressIndicator()),

              // Tampilkan hasil pencarian jika sudah ada data dan tidak sedang loading
              if (!isLoading && searchResults.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    final item = searchResults[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildRow('Kasur', item['kasur']),
                            _buildRow('Divan', item['divan']),
                            _buildRow('Headboard', item['headboard']),
                            _buildRow('Sorong', item['sorong']),
                            _buildRow('Ukuran', item['ukuran']),
                            _buildRow('Program', item['program']),
                            _buildRow('Price List', item['pricelist']),
                            const SizedBox(height: 5),
                            const Text(
                              'Bonus :',
                              style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              item['bonuses'] ?? "",
                              style: const TextStyle(fontFamily: 'Poppins'),
                            ),
                            const SizedBox(height: 10),
                            _buildRow('Total Diskon', item['total_diskon']),
                            if (_getAppliedDiscounts(item['id']) != '0')
                              _buildRow(
                                'Diskon yang Dipakai',
                                _getAppliedDiscounts(item['id']),
                              ),
                            _buildRow('Harga Net', item['harga_net']),
                            if (item['cicilan'] != null &&
                                item['cicilan']['jumlah_bulan'] > 0)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildRow(
                                    'Cicilan',
                                    '${item['cicilan']['jumlah_bulan']} x ${formatCurrency(item['cicilan']['per_bulan'])}',
                                  ),
                                ],
                              ),
                            const SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    showCicilanInputDialog(context, item, () {
                                      setState(() {});
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color.fromRGBO(37, 211, 102, 1),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text(
                                    "Cicilan",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'Poppins'),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    showEditNetPricePopup(context, item, () {
                                      setState(() {});
                                    });
                                  },
                                  icon: const Icon(Icons.edit,
                                      color: Colors.blue),
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      selectedItem = item;
                                    });
                                    showDiscountPopup(
                                      context,
                                      selectedItem!,
                                      () {
                                        setState(() {});
                                      },
                                    );
                                  },
                                  icon: const Icon(Icons.help_outline,
                                      color: Colors.orange),
                                ),
                                IconButton(
                                  onPressed: () {
                                    try {
                                      // Generate shareable text content
                                      final labels = [
                                        'Kasur',
                                        'Divan',
                                        'Headboard',
                                        'Sorong',
                                        'Ukuran',
                                        'Program',
                                        'Price List',
                                        'Total Diskon',
                                        'Harga Net'
                                      ];

                                      // Hitung panjang maksimum label
                                      final maxLabelWidth = labels
                                          .map((label) => label.length)
                                          .reduce((a, b) => a > b ? a : b);

                                      // Format teks rapi
                                      final shareContent = '''
                                        Detail Kasur:
                                        ${_formatRow('Kasur', item['kasur'], maxLabelWidth)}
                                        ${_formatRow('Divan', item['divan'], maxLabelWidth)}
                                        ${_formatRow('Headboard', item['headboard'], maxLabelWidth)}
                                        ${_formatRow('Sorong', item['sorong'], maxLabelWidth)}
                                        ${_formatRow('Ukuran', item['ukuran'], maxLabelWidth)}
                                        ${_formatRow('Program', item['program'], maxLabelWidth)}
                                        ${_formatRow('Price List', item['pricelist'], maxLabelWidth)}
                                        ${_formatRow('Total Diskon', item['total_diskon'], maxLabelWidth)}
                                        ${_formatRow('Harga Net', item['harga_net'], maxLabelWidth)}

                                        Bonus:
                                        ${item['bonuses'] ?? "Tanpa Bonus"}
                                              ''';
                                      // Share the content
                                      Share.share(shareContent);
                                    } catch (e) {
                                      logger.e("Error while sharing text: $e");
                                      Fluttertoast.showToast(
                                        msg: "Failed to share text",
                                        backgroundColor: Colors.redAccent,
                                        textColor: Colors.white,
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.TOP,
                                      );
                                    }
                                  },
                                  icon: const Icon(Icons.share,
                                      color: Colors.green),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
