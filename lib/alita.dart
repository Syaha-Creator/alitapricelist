import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/web.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  @override
  void initState() {
    super.initState();
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

  void updateKasurOptions(String brand) {
    kasurOptions = result
        .where((item) => item['brand'] == brand)
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

  void updateDivanOptions(String kasur) {
    divanOptions = result
        .where((item) => item['kasur'] == kasur)
        .map((item) => item['divan'] as String?)
        .whereType<String>()
        .toSet()
        .toList();
  }

  void updateHeadboardOptions(String kasur) {
    headboardOptions = result
        .where((item) => item['kasur'] == kasur)
        .map((item) => item['headboard'] as String?)
        .whereType<String>()
        .toSet()
        .toList();
  }

  void updateSorongOptions(String kasur) {
    sorongOptions = result
        .where((item) => item['kasur'] == kasur)
        .map((item) => item['sorong'] as String?)
        .whereType<String>()
        .toSet()
        .toList();
  }

  void updateUkuranOptions(String kasur) {
    ukuranOptions = result
        .where((item) => item['kasur'] == kasur)
        .map((item) => item['ukuran'] as String?)
        .whereType<String>()
        .toSet()
        .toList();
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
            (selectedDivan == 'Tanpa Divan' ||
                item['divan'] == selectedDivan) &&
            (selectedHeadboard == 'Tanpa Headboard' ||
                item['headboard'] == selectedHeadboard) &&
            (selectedSorong == 'Tanpa Sorong' ||
                item['sorong'] == selectedSorong) &&
            (selectedUkuran == null || item['ukuran'] == selectedUkuran);
      }).toList();

      isLoading = false;
      if (searchResults.isEmpty) {
        const snackBar = SnackBar(content: Text('Data Tidak di Temukan'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
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

  void showCicilanDialog(
      BuildContext context, double? cicilan12, double? cicilan15) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Cicilan"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  "Cicilan 12 Bulan: ${cicilan12 != null ? formatCurrency(cicilan12) : 'Tanpa data'}"),
              const SizedBox(height: 8),
              Text(
                  "Cicilan 15 Bulan: ${cicilan15 != null ? formatCurrency(cicilan15) : 'Tanpa data'}"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Tutup"),
            ),
          ],
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
                    TextField(
                      controller: disc1Controller,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Diskon 1 (%)',
                      ),
                      onChanged: (value) {
                        setState(() {
                          disc1 = double.tryParse(value) ?? 0;
                          if (disc1 > 10) {
                            disc1 = 10;
                            disc1Controller.text = '10';
                            disc1Controller.selection =
                                TextSelection.fromPosition(TextPosition(
                                    offset: disc1Controller.text.length));
                          }
                        });
                      },
                    ),
                    TextField(
                      controller: disc2Controller,
                      keyboardType: TextInputType.number,
                      decoration:
                          const InputDecoration(labelText: 'Diskon 2 (%)'),
                      onChanged: (value) {
                        setState(() {
                          disc2 = double.tryParse(value) ?? 0;
                          if (disc2 > 5) {
                            disc2 = 5;
                            disc2Controller.text = '5';
                            disc2Controller.selection =
                                TextSelection.fromPosition(TextPosition(
                                    offset: disc2Controller.text.length));
                          }
                        });
                      },
                    ),
                    TextField(
                      controller: disc3Controller,
                      keyboardType: TextInputType.number,
                      decoration:
                          const InputDecoration(labelText: 'Diskon 3 (%)'),
                      onChanged: (value) {
                        setState(() {
                          disc3 = double.tryParse(value) ?? 0;
                          if (disc3 > 5) {
                            disc3 = 5;
                            disc3Controller.text = '5';
                            disc3Controller.selection =
                                TextSelection.fromPosition(TextPosition(
                                    offset: disc3Controller.text.length));
                          }
                        });
                      },
                    ),
                    TextField(
                      controller: disc4Controller,
                      keyboardType: TextInputType.number,
                      decoration:
                          const InputDecoration(labelText: 'Diskon 4 (%)'),
                      onChanged: (value) {
                        setState(() {
                          disc4 = double.tryParse(value) ?? 0;
                          if (disc4 > 5) {
                            disc4 = 5;
                            disc4Controller.text = '5';
                            disc4Controller.selection =
                                TextSelection.fromPosition(TextPosition(
                                    offset: disc4Controller.text.length));
                          }
                        });
                      },
                    ),
                    TextField(
                      controller: disc5Controller,
                      keyboardType: TextInputType.number,
                      decoration:
                          const InputDecoration(labelText: 'Diskon 5 (%)'),
                      onChanged: (value) {
                        setState(() {
                          disc5 = double.tryParse(value) ?? 0;
                          if (disc5 > 5) {
                            disc5 = 5;
                            disc5Controller.text = '5';
                            disc5Controller.selection =
                                TextSelection.fromPosition(TextPosition(
                                    offset: disc5Controller.text.length));
                          }
                        });
                      },
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
                      // Reset semua diskon ke nilai kosong
                      disc1Controller.clear();
                      disc2Controller.clear();
                      disc3Controller.clear();
                      disc4Controller.clear();
                      disc5Controller.clear();

                      // Reset variabel diskon dan harga net ke nilai awal
                      disc1 = 0;
                      disc2 = 0;
                      disc3 = 0;
                      disc4 = 0;
                      disc5 = 0;
                      calculatedPrice = originalPrice;
                      totalDiscount = priceList - calculatedPrice;
                    });
                  },
                ),
                TextButton(
                  child: const Text("Hitung"),
                  onPressed: () {
                    setState(() {
                      // Hitung harga setelah diskon diterapkan
                      calculatedPrice = calculateDiscountedPrice(
                        originalPrice,
                        [disc1, disc2, disc3, disc4, disc5],
                      );

                      // Total diskon dihitung sebagai selisih antara pricelist dan harga setelah diskon
                      totalDiscount = priceList - calculatedPrice;
                    });
                  },
                ),
                TextButton(
                  child: const Text("Simpan"),
                  onPressed: () {
                    // Simpan nilai diskon terbaru di item
                    cardDiscounts[itemId] = {
                      'disc1': disc1,
                      'disc2': disc2,
                      'disc3': disc3,
                      'disc4': disc4,
                      'disc5': disc5,
                    };

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

    // Ambil nilai harga net saat ini
    double originalNetPrice = item['harga_net'] != null
        ? double.tryParse(
                item['harga_net'].replaceAll('Rp. ', '').replaceAll('.', '')) ??
            item['end_user_price']
        : item['end_user_price'] ?? 0;

    // Controller untuk mengisi harga net baru
    TextEditingController netPriceController =
        TextEditingController(text: originalNetPrice.toInt().toString());

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
              TextField(
                controller: netPriceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Harga Net Baru',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text("Simpan"),
              onPressed: () {
                // Ambil nilai harga net baru dari input pengguna
                double newNetPrice = double.tryParse(
                        netPriceController.text.replaceAll(',', '')) ??
                    originalNetPrice;

                // Hitung total diskon sebagai selisih antara pricelist dan harga net baru
                double newTotalDiscount = priceList - newNetPrice;

                // Update nilai harga net dan total diskon di item yang diklik
                item['harga_net'] = formatCurrency(newNetPrice);
                item['total_diskon'] = formatCurrency(newTotalDiscount);

                onUpdate(); // Panggil callback untuk memperbarui tampilan card
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  String formatCurrency(double amount) {
    final formatCurrency =
        NumberFormat.currency(locale: 'id', symbol: 'Rp. ', decimalDigits: 0);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(Icons.price_check, color: Colors.white),
                SizedBox(width: 10),
                Text(
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
            Image.asset(
              'assets/logo.png',
              height: 30,
            ),
          ],
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 4,
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
                    updateKasurOptions(value!);
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
                    updateDivanOptions(value!);
                    updateHeadboardOptions(value);
                    updateSorongOptions(value);
                    updateUkuranOptions(value);
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
                            _buildRow('Harga Net', item['harga_net']),
                            const SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    showCicilanDialog(context,
                                        item['cicilan_12'], item['cicilan_15']);
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
