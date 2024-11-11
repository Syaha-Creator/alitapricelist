import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:logger/web.dart';

class Pricelist extends StatefulWidget {
  const Pricelist({super.key});

  @override
  State<Pricelist> createState() => _PricelistState();
}

class _PricelistState extends State<Pricelist> {
  var logger = Logger();

  String? selectedArea;
  String? selectedChannel;
  String? selectedBrand;
  String? selectedKasur;
  String? selectedDivan = "Tanpa Divan";
  String? selectedHeadboard = "Tanpa Headboard";
  String? selectedUkuran;
  String? selectedSorong = "Tanpa Sorong";
  double selectedHargaNet = 0.0;

  double disc1 = 0.0;
  double disc2 = 0.0;
  double disc3 = 0.0;
  double disc4 = 0.0;
  double disc5 = 0.0;

  List<String> areaList = [];
  List<String> brandList = [];
  List<String> kasurList = [];
  List<String> divanList = [];
  List<String> headboardList = [];
  List<String> ukuranList = [];
  List<String> channelList = [];
  List<String> sorongList = [];
  List<double> hargaList = [];

  List<Map<String, dynamic>> searchResultsHarga = [];

  List<Map<String, dynamic>> apiData = []; // Menyimpan data dari API
  List<Map<String, String>> searchResults = []; // Menyimpan hasil pencarian

  @override
  void initState() {
    super.initState();
    fetchEndUserPrice();
    fetchData();
  }

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse(
        'https://alitav2.massindo.com/api/rawdata_price_lists?access_token=d60Jls5Tr2n63aGOKWXYALhX5JRwXREE2IneQoGKiT4&client_id=hqJ199kBBLePkNt9mhS9EbgaCC6RarYxQux-fzebUZ8&client_secret=xtvj63aVIPaFNOiGKtOu1Su5EBYzdP_MZTG60uwGzP0'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['result'] != null) {
        setState(() {
          apiData = List<Map<String, dynamic>>.from(data['result']);
          areaList = List<String>.from(
            (data['result'].map((item) => item['area']) as Iterable)
                .toSet()
                .where((area) => area != null),
          );
          brandList = List<String>.from(
            (data['result'].map((item) => item['brand']) as Iterable)
                .toSet()
                .where((brand) => brand != null),
          );
          kasurList = List<String>.from(
            (data['result'].map((item) => item['kasur']) as Iterable)
                .toSet()
                .where((kasur) => kasur != null),
          );
          divanList = List<String>.from(
            (data['result'].map((item) => item['divan']) as Iterable)
                .toSet()
                .where((divan) => divan != null),
          );
          headboardList = List<String>.from(
            (data['result'].map((item) => item['headboard']) as Iterable)
                .toSet()
                .where((headboard) => headboard != null),
          );
          ukuranList = List<String>.from(
            (data['result'].map((item) => item['ukuran']) as Iterable)
                .toSet()
                .where((ukuran) => ukuran != null),
          );
          channelList = List<String>.from(
            (data['result'].map((item) => item['channel']) as Iterable)
                .toSet()
                .where((channel) => channel != null),
          );
          sorongList = List<String>.from(
            (data['result'].map((item) => item['sorong']) as Iterable)
                .toSet()
                .where((sorong) => sorong != null),
          );
          hargaList =
              (data['result'].map((item) => item['end_user_price']) as Iterable)
                  .where((endUserPrice) => endUserPrice != null)
                  .map((endUserPrice) {
            if (endUserPrice is String) {
              return double.tryParse(endUserPrice) ??
                  0.0; // Jika tipe data String, parse ke double
            } else if (endUserPrice is double) {
              return endUserPrice; // Jika sudah berupa double, langsung kembalikan nilai
            } else {
              return 0.0; // Jika tipe data lain, kembalikan 0.0
            }
          }).toList();
          logger.i('Harga List: $hargaList');
        });
      } else {
        logger.e('Tidak ada hasil dari API');
        setState(() {
          apiData = [];
          areaList = [];
          brandList = [];
          kasurList = [];
          divanList = ["Tanpa Divan"];
          headboardList = ["Tanpa Headboard"];
          ukuranList = [];
          channelList = [];
          sorongList = ["Tanpa Sorong"];
          hargaList = [];
        });
      }
    } else {
      logger.e('Failed to load data');
      throw Exception('Failed to load data');
    }
  }

  double getDropdownHeight(List<String> items) {
    if (items.isEmpty) return 130;
    if (items.length == 2) {
      return 180; // Set height specifically for the "sorong" dropdown with 2 items
    }
    return items.length > 4 ? 300 : items.length * 130;
  }

  void searchItems() {
    searchResults.clear();

    for (var item in apiData) {
      if ((selectedKasur == null || item['kasur'] == selectedKasur) &&
          (selectedDivan == null || item['divan'] == selectedDivan) &&
          (selectedHeadboard == null ||
              item['headboard'] == selectedHeadboard) &&
          (selectedUkuran == null || item['ukuran'] == selectedUkuran) &&
          (selectedSorong == null || item['sorong'] == selectedSorong)) {
        double pricelist = (item['pricelist'] ?? 0).toDouble();
        double hargaNet = (item['end_user_price'] ?? 0).toDouble();
        double totalDiskon = pricelist - hargaNet;

        // Get bonus information
        List<String> bonuses = [];
        for (int i = 1; i <= 5; i++) {
          String? bonus = item['bonus_$i'];
          int? qty = item['qty_bonus$i'];

          if (bonus != null && qty != null && qty > 0) {
            bonuses.add('$qty $bonus');
          }
        }

        // Get installment information
        double? cicilan12 = (item['cicilan_12'] ?? 0).toDouble();
        double? cicilan15 = (item['cicilan_15'] ?? 0).toDouble();

        // Store the search result with installment information
        searchResults.add({
          "kasur": item['kasur'] ?? "",
          "divan": item['divan'] ?? "",
          "headboard": item['headboard'] ?? "",
          "sorong": item['sorong'] ?? "",
          "ukuran": item['ukuran'] ?? "",
          "price_list": NumberFormat.currency(locale: 'id_ID', symbol: 'Rp. ')
              .format(pricelist),
          "program": item['program'] ?? "",
          "bonuses": bonuses.join("\n"),
          "total_diskon": NumberFormat.currency(locale: 'id_ID', symbol: 'Rp. ')
              .format(totalDiskon),
          "harga_net": NumberFormat.currency(locale: 'id_ID', symbol: 'Rp. ')
              .format(hargaNet),
          "cicilan_12": cicilan12 != null
              ? NumberFormat.currency(locale: 'id_ID', symbol: 'Rp. ')
                  .format(cicilan12)
              : "N/A",
          "cicilan_15": cicilan15 != null
              ? NumberFormat.currency(locale: 'id_ID', symbol: 'Rp. ')
                  .format(cicilan15)
              : "N/A",
        });
      }
    }

    setState(() {
      searchResults = searchResults;
    });
  }

  void clearFilters() {
    setState(() {
      selectedArea = null;
      selectedChannel = null;
      selectedBrand = null;
      selectedKasur = null;
      selectedDivan = "Tanpa Divan";
      selectedHeadboard = "Tanpa Headboard";
      selectedUkuran = null;
      selectedSorong = "Tanpa Sorong";
      searchResults.clear(); // Clear search results
    });
  }

  // Function to show popup for Cicilan
  void showCicilanPopup(Map<String, String> result) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cicilan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Cicilan 12 bulan: ${result['cicilan_12']}'),
              Text('Cicilan 15 bulan: ${result['cicilan_15']}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // Function to show popup for Diskon
  Future<double> fetchEndUserPrice() async {
    const String apiUrl =
        'https://alitav2.massindo.com/api/rawdata_price_lists?access_token=d60Jls5Tr2n63aGOKWXYALhX5JRwXREE2IneQoGKiT4&client_id=hqJ199kBBLePkNt9mhS9EbgaCC6RarYxQux-fzebUZ8&client_secret=xtvj63aVIPaFNOiGKtOu1Su5EBYzdP_MZTG60uwGzP0';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        // logger.i('Response body: ${response.body}');

        final data = json.decode(response.body);
        List<dynamic> resultList = data['result'];

        if (resultList.isNotEmpty) {
          double endUserPrice = resultList[0]['end_user_price'] != null
              ? (resultList[0]['end_user_price'] as num).toDouble()
              : 0.0;
          // logger.i('Fetch endUserPrice :$endUserPrice');
          return endUserPrice;
        } else {
          throw Exception('Tidak ada hasil yang ditemukan di dalam "result"');
        }
      } else {
        throw Exception('Gagal mengambil data dari API');
      }
    } catch (e) {
      logger.e('Catch endUserPrice : $e');
      return 0.0;
    }
  }

  void updateSearchResults(String keyword) {
    setState(() {
      searchResultsHarga = apiData.where((item) {
        return item['end_user_price']
            .toLowerCase()
            .contains(keyword.toLowerCase());
      }).toList();
      logger.i('Update Result : $searchResultsHarga');
    });
  }

  // Function to show popup for Discount with API value
  void showDiskonPopup(
      double selectedHargaNet, Map<String, double> batasDiskon) async {
    try {
      // Fetch endUserPrice from API before showing the popup
      double endUserPrice =
          await fetchEndUserPrice(); // Fetch endUserPrice from API

      if (endUserPrice == 0.0) {
        // Handle case when endUserPrice is not retrieved
        // ignore: use_build_context_synchronously
        _showErrorDialog(context, "Gagal mendapatkan harga dari API.");
        return;
      }

      // Proceed to show the popup after getting the endUserPrice
      double disc1 = 0.0, disc2 = 0.0, disc3 = 0.0, disc4 = 0.0, disc5 = 0.0;
      double netPrice = endUserPrice;

      logger.i('netPrice :$netPrice');

      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Diskon'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                      "Harga Net: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp. ').format(selectedHargaNet)}"),
                  // Diskon 1
                  TextField(
                    decoration: InputDecoration(
                        labelText:
                            'Diskon 1 (max ${batasDiskon["disc1"]! * 100}%)'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      disc1 = double.tryParse(value) ?? 0.0;
                      disc1 = disc1 / 100;
                      if (disc1 > batasDiskon["disc1"]!) {
                        disc1 = batasDiskon["disc1"]!;
                        _showErrorDialog(
                            context, 'Diskon 1 melebihi batas maksimal!');
                      }
                    },
                  ),
                  // Diskon 2
                  TextField(
                    decoration: InputDecoration(
                        labelText:
                            'Diskon 2 (max ${batasDiskon["disc2"]! * 100}%)'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      disc2 = double.tryParse(value) ?? 0.0;
                      disc2 = disc2 / 100;
                      if (disc2 > batasDiskon["disc2"]!) {
                        disc2 = batasDiskon["disc2"]!;
                        _showErrorDialog(
                            context, 'Diskon 2 melebihi batas maksimal!');
                      }
                    },
                  ),
                  // Diskon 3
                  TextField(
                    decoration: InputDecoration(
                        labelText:
                            'Diskon 3 (max ${batasDiskon["disc3"]! * 100}%)'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      disc3 = double.tryParse(value) ?? 0.0;
                      disc3 = disc3 / 100;
                      if (disc3 > batasDiskon["disc3"]!) {
                        disc3 = batasDiskon["disc3"]!;
                        _showErrorDialog(
                            context, 'Diskon 3 melebihi batas maksimal!');
                      }
                    },
                  ),
                  // Diskon 4
                  TextField(
                    decoration: InputDecoration(
                        labelText:
                            'Diskon 4 (max ${batasDiskon["disc4"]! * 100}%)'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      disc4 = double.tryParse(value) ?? 0.0;
                      disc4 = disc4 / 100;
                      if (disc4 > batasDiskon["disc4"]!) {
                        disc4 = batasDiskon["disc4"]!;
                        _showErrorDialog(
                            context, 'Diskon 4 melebihi batas maksimal!');
                      }
                    },
                  ),
                  // Diskon 5
                  TextField(
                    decoration: InputDecoration(
                        labelText:
                            'Diskon 5 (max ${batasDiskon["disc5"]! * 100}%)'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      disc5 = double.tryParse(value) ?? 0.0;
                      disc5 = disc5 / 100;
                      if (disc5 > batasDiskon["disc5"]!) {
                        disc5 = batasDiskon["disc5"]!;
                        _showErrorDialog(
                            context, 'Diskon 5 melebihi batas maksimal!');
                      }
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  logger.i('Harga end user price : $selectedHargaNet');

                  netPrice = hitungHargaNet(
                      selectedHargaNet, disc1, disc2, disc3, disc4, disc5);

                  // Tampilkan hasilnya pada popup dialog
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Harga Setelah Diskon'),
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Harga net setelah diskon: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp. ').format(netPrice)}',
                            ),
                            Text(
                              'Total Diskon: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp. ').format(selectedHargaNet - netPrice)}',
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Close'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Text('Hitung Harga'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      logger.e('Catch :$e');
      // ignore: use_build_context_synchronously
      _showErrorDialog(context, 'Gagal mengambil harga dari API');
    }
  }

  double calculateNetPrice(double selectedHargaNet, List<double> discounts) {
    double discountedPrice = selectedHargaNet;

    for (double discount in discounts) {
      discountedPrice *= (1 - discount); // Terapkan diskon satu per satu
    }

    return discountedPrice;
  }

  double hitungHargaNet(double originalPrice, double disc1, double disc2,
      double disc3, double disc4, double disc5) {
    double priceAfterDisc1 = (1 - disc1) * originalPrice;
    double priceAfterDisc2 = (1 - disc2) * priceAfterDisc1;
    double priceAfterDisc3 = (1 - disc3) * priceAfterDisc2;
    double priceAfterDisc4 = (1 - disc4) * priceAfterDisc3;
    double priceAfterDisc5 = (1 - disc5) * priceAfterDisc4;

    return priceAfterDisc5;
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pricelist"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              DropdownSearch<String>(
                dropdownDecoratorProps: const DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    labelText: "Area",
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
                popupProps: PopupProps.menu(
                  showSearchBox: true,
                  constraints: BoxConstraints(
                    maxHeight: getDropdownHeight(areaList),
                  ),
                ),
                items: areaList.isNotEmpty ? areaList : [],
                onChanged: (value) {
                  setState(() {
                    selectedArea = value;
                  });
                },
                selectedItem: selectedArea,
                filterFn: (item, filter) =>
                    item.toLowerCase().contains(filter.toLowerCase()),
              ),
              const SizedBox(height: 5),
              DropdownSearch<String>(
                dropdownDecoratorProps: const DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    labelText: "Channel",
                  ),
                ),
                popupProps: PopupProps.menu(
                  showSearchBox: true,
                  constraints: BoxConstraints(
                    maxHeight: getDropdownHeight(channelList),
                  ),
                ),
                items: channelList.isNotEmpty ? channelList : [],
                onChanged: (value) {
                  setState(() {
                    selectedChannel = value;
                  });
                },
                selectedItem: selectedChannel,
                filterFn: (item, filter) =>
                    item.toLowerCase().contains(filter.toLowerCase()),
              ),
              const SizedBox(height: 5),
              DropdownSearch<String>(
                dropdownDecoratorProps: const DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    labelText: "Brand",
                  ),
                ),
                popupProps: PopupProps.menu(
                  showSearchBox: true,
                  constraints: BoxConstraints(
                    maxHeight: getDropdownHeight(brandList),
                  ),
                ),
                items: brandList.isNotEmpty ? brandList : [],
                onChanged: (value) {
                  setState(() {
                    selectedBrand = value;
                  });
                },
                selectedItem: selectedBrand,
                filterFn: (item, filter) =>
                    item.toLowerCase().contains(filter.toLowerCase()),
              ),
              const SizedBox(height: 5),
              DropdownSearch<String>(
                dropdownDecoratorProps: const DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    labelText: "Kasur",
                  ),
                ),
                popupProps: PopupProps.menu(
                  showSearchBox: true,
                  constraints: BoxConstraints(
                    maxHeight: getDropdownHeight(kasurList),
                  ),
                ),
                items: kasurList.isNotEmpty ? kasurList : [],
                onChanged: (value) {
                  setState(() {
                    selectedKasur = value;
                  });
                },
                selectedItem: selectedKasur,
                filterFn: (item, filter) =>
                    item.toLowerCase().contains(filter.toLowerCase()),
              ),
              const SizedBox(height: 5),
              DropdownSearch<String>(
                dropdownDecoratorProps: const DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    labelText: "Divan",
                  ),
                ),
                popupProps: PopupProps.menu(
                  showSearchBox: true,
                  constraints: BoxConstraints(
                    maxHeight: getDropdownHeight(divanList),
                  ),
                ),
                items: divanList.isNotEmpty ? divanList : [],
                onChanged: (value) {
                  setState(() {
                    selectedDivan = value;
                  });
                },
                selectedItem: selectedDivan,
                filterFn: (item, filter) =>
                    item.toLowerCase().contains(filter.toLowerCase()),
              ),
              const SizedBox(height: 5),
              DropdownSearch<String>(
                dropdownDecoratorProps: const DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    labelText: "Headboard",
                  ),
                ),
                popupProps: PopupProps.menu(
                  showSearchBox: true,
                  constraints: BoxConstraints(
                    maxHeight: getDropdownHeight(headboardList),
                  ),
                ),
                items: headboardList.isNotEmpty ? headboardList : [],
                onChanged: (value) {
                  setState(() {
                    selectedHeadboard = value;
                  });
                },
                selectedItem: selectedHeadboard,
                filterFn: (item, filter) =>
                    item.toLowerCase().contains(filter.toLowerCase()),
              ),
              const SizedBox(height: 5),
              DropdownSearch<String>(
                dropdownDecoratorProps: const DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    labelText: "Ukuran",
                  ),
                ),
                popupProps: PopupProps.menu(
                  showSearchBox: true,
                  constraints: BoxConstraints(
                    maxHeight: getDropdownHeight(ukuranList),
                  ),
                ),
                items: ukuranList.isNotEmpty ? ukuranList : [],
                onChanged: (value) {
                  setState(() {
                    selectedUkuran = value;
                  });
                },
                selectedItem: selectedUkuran,
                filterFn: (item, filter) =>
                    item.toLowerCase().contains(filter.toLowerCase()),
              ),
              const SizedBox(height: 5),
              DropdownSearch<String>(
                dropdownDecoratorProps: const DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    labelText: "Sorong",
                  ),
                ),
                popupProps: PopupProps.menu(
                  showSearchBox: true,
                  constraints: BoxConstraints(
                    maxHeight: getDropdownHeight(sorongList),
                  ),
                ),
                items: sorongList.isNotEmpty ? sorongList : [],
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: clearFilters,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text(
                      "Clean Filters",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: searchItems,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    child: const Text(
                      "Search",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              searchResults.isNotEmpty
                  ? ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: searchResults.length,
                      itemBuilder: (context, index) {
                        final result = searchResults[index];
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Kasur: ${result['kasur']}'),
                                Text('Divan: ${result['divan']}'),
                                Text('Headboard: ${result['headboard']}'),
                                Text('Sorong: ${result['sorong']}'),
                                Text('Ukuran: ${result['ukuran']}'),
                                Text('Price List: ${result['price_list']}'),
                                Text('Program: ${result['program']}'),
                                const SizedBox(
                                    height: 5), // Add space between sections
                                const Text('Bonus:'),
                                Text(result['bonuses'] ?? ""),
                                const SizedBox(
                                    height: 5), // Add space between sections
                                Text('Total Diskon: ${result['total_diskon']}'),
                                Text('Harga Net: ${result['harga_net']}'),

                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () => showCicilanPopup(
                                          result), // Pass the result to the popup
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                      ),
                                      child: const Text(
                                        "Cicilan",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        // Memeriksa apakah ada harga yang lebih dari 0
                                        if (hargaList.any((endUserPrice) =>
                                            endUserPrice > 0)) {
                                          Map<String, double> batasDiskon = {
                                            "disc1": 0.1,
                                            "disc2": 0.05,
                                            "disc3": 0.05,
                                            "disc4": 0.05,
                                            "disc5": 0.05,
                                          };

                                          // Ambil hargaNet dari item yang dipilih
                                          double selectedHargaNet = 0.0;

                                          try {
                                            // Pastikan 'harga_net' tidak null dengan memberikan nilai default '0' jika null
                                            String hargaNetString =
                                                searchResults[index]
                                                        ['harga_net'] ??
                                                    '0';

                                            NumberFormat currencyFormatter =
                                                NumberFormat.currency(
                                                    locale: 'id_ID',
                                                    symbol: 'Rp. ');

                                            // Parsing 'harga_net' menjadi double
                                            selectedHargaNet = currencyFormatter
                                                .parse(hargaNetString)
                                                .toDouble();
                                          } catch (e) {
                                            logger.e(
                                                'Error parsing harga_net: $e');
                                          }

                                          logger.i(
                                              'Parsed selectedHargaNet: $selectedHargaNet');

                                          if (selectedHargaNet > 0) {
                                            showDiskonPopup(
                                                selectedHargaNet, batasDiskon);
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'Harga belum tersedia, coba lagi nanti'),
                                              ),
                                            );
                                          }
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'Harga belum tersedia, coba lagi nanti'),
                                            ),
                                          );
                                        }
                                      },
                                      child: const Text('Tampilkan Diskon'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  : const Text("Tolong search terlebih dahulu"),
            ],
          ),
        ),
      ),
    );
  }
}
