// // ignore_for_file: use_build_context_synchronously
// import 'package:flutter/material.dart';
// //import 'package:dropdown_search/dropdown_search.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:intl/intl.dart';
// import 'package:logger/web.dart';

// class Home extends StatefulWidget {
//   const Home({super.key});

//   @override
//   State<Home> createState() => _HomeState();
// }

// class _HomeState extends State<Home> {
//   var logger = Logger();
//   final NumberFormat currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp. ', decimalDigits: 0);
//   double appliedDisc1 = 0;
//   double appliedDisc2 = 0;
//   double appliedDisc3 = 0;
//   double appliedDisc4 = 0;
//   double appliedDisc5 = 0;
//   List<String> areaList = [];
//   List<String> brandList = [];
//   List<String> channelList = [];
//   List<String> divanList = [];
//   List<double> hargaList = [];
//   List<String> headboardList = [];
//   List<String> sorongList = [];
//   List<String> kasurList = [];
//   List<String> ukuranList = [];
//   double currentNetPrice = 0;
//   double selectedHargaNet = 0;
//   double originalPrice = 0;
//   List<Map<String, dynamic>> apiData = []; // Menyimpan data dari API
//   List<Map<String, String>> searchResults = []; // Menyimpan hasil pencarian
//   List<Map<String, dynamic>> searchResultsHarga = [];
//   String? selectedArea;
//   String? selectedBrand;
//   String? selectedChannel;
//   String? selectedDivan = "Tanpa Divan";
//   String? selectedHeadboard = "Tanpa Headboard";
//   String? selectedKasur;
//   String? selectedSorong = "Tanpa Sorong";
//   String? selectedUkuran;
//   double? totalDiskonUpdated;

//   @override
//   void initState() {
//     super.initState();
//     fetchData();
//   }

//   Future<void> fetchData() async {
//   try {
//     final response = await http.get(Uri.parse(
//         'https://alitav2.massindo.com/api/rawdata_price_lists?access_token=d60Jls5Tr2n63aGOKWXYALhX5JRwXREE2IneQoGKiT4&client_id=hqJ199kBBLePkNt9mhS9EbgaCC6RarYxQux-fzebUZ8&client_secret=xtvj63aVIPaFNOiGKtOu1Su5EBYzdP_MZTG60uwGzP0'));

//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);

//       if (data['result'] != null) {
//         final results = List<Map<String, dynamic>>.from(data['result']);

//         final List<String> areas = results.map((item) => item['area']).whereType<String>().toSet().toList();
//         final List<String> brands = results.map((item) => item['brand']).whereType<String>().toSet().toList();
//         final List<String> kasurs = results.map((item) => item['kasur']).whereType<String>().toSet().toList();
//         final List<String> divans = results.map((item) => item['divan']).whereType<String>().toSet().toList();
//         final List<String> headboards = results.map((item) => item['headboard']).whereType<String>().toSet().toList();
//         final List<String> ukurans = results.map((item) => item['ukuran']).whereType<String>().toSet().toList();
//         final List<String> channels = results.map((item) => item['channel']).whereType<String>().toSet().toList();
//         final List<String> sorongs = results.map((item) => item['sorong']).whereType<String>().toSet().toList();
//         final List<double> prices = results.map((item) {
//           final price = item['end_user_price'];
//           if (price is String) return double.tryParse(price) ?? 0.0;
//           if (price is double) return price;
//           return 0.0;
//         }).toList();

//         setState(() {
//           apiData = results;
//           areaList = areas;
//           brandList = brands;
//           kasurList = kasurs;
//           divanList = divans;
//           headboardList = headboards;
//           ukuranList = ukurans;
//           channelList = channels;
//           sorongList = sorongs;
//           hargaList = prices;
//         });
//       } else {
//         logger.e('Tidak ada hasil dari API');
//         _resetLists();
//       }
//     } else {
//       logger.e('Failed to load data, status code: ${response.statusCode}');
//       _resetLists();
//       throw Exception('Failed to load data');
//     }
//   } catch (e) {
//     logger.e('Error fetching data: $e');
//     _resetLists();
//   }
//   }

//   double getDropdownHeight(List<String> items) {
//     if (items.isEmpty) return 130;
//     if (items.length == 2) {
//       return 180;
//     }
//     return items.length > 4 ? 300 : items.length * 130;
//   }

//   void searchItems() {
//     searchResults.clear();

//     for (var item in apiData) {
//       if ((selectedKasur == null || item['kasur'] == selectedKasur) &&
//           (selectedDivan == null || item['divan'] == selectedDivan) &&
//           (selectedHeadboard == null ||
//               item['headboard'] == selectedHeadboard) &&
//           (selectedUkuran == null || item['ukuran'] == selectedUkuran) &&
//           (selectedSorong == null || item['sorong'] == selectedSorong)) {
//         double pricelist = (item['pricelist'] ?? 0).toDouble();
//         double hargaNet = (item['end_user_price'] ?? 0).toDouble();
//         double totalDiskon = pricelist - hargaNet;
//         // double realPrice = 0;

//         // Get bonus information
//         List<String> bonuses = [];
//         for (int i = 1; i <= 5; i++) {
//           String? bonus = item['bonus_$i'];
//           int? qty = item['qty_bonus$i'];

//           if (bonus != null && qty != null && qty > 0) {
//             bonuses.add('$qty $bonus');
//           }
//         }

//         // Get installment information
//         double? cicilan12 = (item['cicilan_12'] ?? 0).toDouble();
//         double? cicilan15 = (item['cicilan_15'] ?? 0).toDouble();

//         // Store the search result with installment information
//         searchResults.add({
//           "kasur": item['kasur'] ?? "",
//           "divan": item['divan'] ?? "",
//           "headboard": item['headboard'] ?? "",
//           "sorong": item['sorong'] ?? "",
//           "ukuran": item['ukuran'] ?? "",
//           "price_list": NumberFormat.currency(locale: 'id_ID', symbol: 'Rp. ', decimalDigits: 0)
//               .format(pricelist),
//           "program": item['program'] ?? "",
//           "bonuses": bonuses.join("\n"),
//           "total_diskon": NumberFormat.currency(locale: 'id_ID', symbol: 'Rp. ', decimalDigits: 0)
//               .format(totalDiskon),
//           "harga_net": NumberFormat.currency(locale: 'id_ID', symbol: 'Rp. ', decimalDigits: 0)
//               .format(hargaNet),
//           // "real_price": NumberFormat.currency(locale: 'id_ID', symbol: 'Rp. ')
//           // .format(realPrice),
//           "cicilan_12": cicilan12 != null
//               ? NumberFormat.currency(locale: 'id_ID', symbol: 'Rp. ', decimalDigits: 0)
//                   .format(cicilan12)
//               : "N/A",
//           "cicilan_15": cicilan15 != null
//               ? NumberFormat.currency(locale: 'id_ID', symbol: 'Rp. ', decimalDigits: 0)
//                   .format(cicilan15)
//               : "N/A",
//         });
//       }
//     }

//     setState(() {
//       searchResults = searchResults;
//     });
//   }

//   void clearFilters() {
//     setState(() {
//       selectedArea = null;
//       selectedChannel = null;
//       selectedBrand = null;
//       selectedKasur = null;
//       selectedDivan = "Tanpa Divan";
//       selectedHeadboard = "Tanpa Headboard";
//       selectedUkuran = null;
//       selectedSorong = "Tanpa Sorong";
//       searchResults.clear();
//     });
//   }

//   // Function to show popup for Cicilan
//   void showCicilanPopup(Map<String, String> result) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Cicilan'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text('Cicilan 12 bulan: ${result['cicilan_12']}'),
//               Text('Cicilan 15 bulan: ${result['cicilan_15']}'),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: const Text('Close'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // Function to show popup for Diskon
//   Future<double> fetchEndUserPrice() async {
//     const String apiUrl =
//         'https://alitav2.massindo.com/api/rawdata_price_lists?access_token=d60Jls5Tr2n63aGOKWXYALhX5JRwXREE2IneQoGKiT4&client_id=hqJ199kBBLePkNt9mhS9EbgaCC6RarYxQux-fzebUZ8&client_secret=xtvj63aVIPaFNOiGKtOu1Su5EBYzdP_MZTG60uwGzP0';

//     try {
//       final response = await http.get(Uri.parse(apiUrl));

//       if (response.statusCode == 200) {
//         // logger.i('Response body: ${response.body}');

//         final data = json.decode(response.body);
//         List<dynamic> resultList = data['result'];

//         if (resultList.isNotEmpty) {
//           double endUserPrice = resultList[0]['end_user_price'] != null
//               ? (resultList[0]['end_user_price'] as num).toDouble()
//               : 0;
//           logger.i('Fetch endUserPrice :$endUserPrice');
//           return endUserPrice;
//         } else {
//           throw Exception('Tidak ada hasil yang ditemukan di dalam "result"');
//         }
//       } else {
//         throw Exception('Gagal mengambil data dari API');
//       }
//     } catch (e) {
//       logger.e('Catch endUserPrice : $e');
//       return 0;
//     }
//   }

//   Future<double> fetchPricelist() async {
//     const String apiUrl =
//         'https://alitav2.massindo.com/api/rawdata_price_lists?access_token=d60Jls5Tr2n63aGOKWXYALhX5JRwXREE2IneQoGKiT4&client_id=hqJ199kBBLePkNt9mhS9EbgaCC6RarYxQux-fzebUZ8&client_secret=xtvj63aVIPaFNOiGKtOu1Su5EBYzdP_MZTG60uwGzP0';

//     try {
//       final response = await http.get(Uri.parse(apiUrl));

//       if (response.statusCode == 200) {

//         final data = json.decode(response.body);
//         List<dynamic> resultList = data['result'];

//         if (resultList.isNotEmpty) {
//           double priceList = resultList[0]['pricelist'] != null
//               ? (resultList[0]['pricelist'] as num).toDouble()
//               : 0;
//           logger.i('Fetch Price List :$priceList');
//           return priceList;
//         } else {
//           throw Exception('Tidak ada hasil yang ditemukan di dalam "result"');
//         }
//       } else {
//         throw Exception('Gagal mengambil data dari API');
//       }
//     } catch (e) {
//       logger.e('Catch endUserPrice : $e');
//       return 0;
//     }
//   }

//   // Fungsi untuk memperbarui nilai total diskon di searchResults
//   void updateTotalDiskonInSearchResults(
//       int index, double newTotalDiskon, double newRealPrice) {
//     setState(() {
//       if (index >= 0 && index < searchResults.length) {
//         searchResults[index]['total_diskon'] =
//             NumberFormat.currency(locale: 'id_ID', symbol: 'Rp. ', decimalDigits: 0)
//                 .format(newTotalDiskon);
//         searchResults[index]['harga_net'] =
//             NumberFormat.currency(locale: 'id_ID', symbol: 'Rp. ', decimalDigits: 0)
//                 .format(newRealPrice);
//       }
//     });
//   }

//   // Function to show popup for Discount with API value
//   void showDiskonPopup(int index, double selectedHargaNet, Map<String, double> batasDiskon) async {
//     if (selectedHargaNet == 0) {
//       selectedHargaNet = await fetchEndUserPrice();
//       currentNetPrice = selectedHargaNet;
//     }else{
//        currentNetPrice = selectedHargaNet;
//     }
//      logger.i('Current Net Price2 : $currentNetPrice');
//     logger.i('Current Net Price : $selectedHargaNet');
//     double priceList = await fetchPricelist();

//     if (selectedHargaNet == 0) {
//       _showErrorDialog(context, "Gagal mendapatkan harga dari API.");
//       return;
//     }else{
//        currentNetPrice = selectedHargaNet;
//     }

//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Diskon'),
//           content: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text("Harga : ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp. ', decimalDigits: 0).format(currentNetPrice)}"),
//                 // Diskon 1
//                 TextField(
//                   decoration: InputDecoration(
//                     labelText: 'Diskon 1 (max ${batasDiskon["disc1"]! * 100}%)',
//                   ),
//                   keyboardType: TextInputType.number,
//                   controller: TextEditingController(text: (appliedDisc1 * 100).toStringAsFixed(0)), // tampilkan nilai diskon yg sudah ada
//                   onChanged: (value) {
//                     appliedDisc1 = (double.tryParse(value) ?? 0) / 100;
//                     if (appliedDisc1 > batasDiskon["disc1"]!) {
//                       _showErrorDialog(context, 'Diskon 1 melebihi batas maksimal!');
//                       appliedDisc1 = batasDiskon["disc1"]!;
//                     }
//                   },
//                 ),
//                 // Diskon 2
//                 TextField(
//                   decoration: InputDecoration(
//                     labelText: 'Diskon 2 (max ${batasDiskon["disc2"]! * 100}%)',
//                   ),
//                   keyboardType: TextInputType.number,
//                   controller: TextEditingController(text: (appliedDisc2 * 100).toStringAsFixed(0)),
//                   onChanged: (value) {
//                     appliedDisc2 = (double.tryParse(value) ?? 0) / 100;
//                     if (appliedDisc2 > batasDiskon["disc2"]!) {
//                       _showErrorDialog(context, 'Diskon 2 melebihi batas maksimal!');
//                       appliedDisc2 = batasDiskon["disc2"]!;
//                     }
//                   },
//                 ),
//                 // Diskon 3
//                 TextField(
//                   decoration: InputDecoration(
//                     labelText: 'Diskon 3 (max ${batasDiskon["disc3"]! * 100}%)',
//                   ),
//                   keyboardType: TextInputType.number,
//                   controller: TextEditingController(text: (appliedDisc3 * 100).toStringAsFixed(0)),
//                   onChanged: (value) {
//                     appliedDisc3 = (double.tryParse(value) ?? 0) / 100;
//                     if (appliedDisc3 > batasDiskon["disc3"]!) {
//                       _showErrorDialog(context, 'Diskon 3 melebihi batas maksimal!');
//                       appliedDisc3 = batasDiskon["disc3"]!;
//                     }
//                   },
//                 ),
//                 // Diskon 4
//                 TextField(
//                   decoration: InputDecoration(
//                     labelText: 'Diskon 4 (max ${batasDiskon["disc4"]! * 100}%)',
//                   ),
//                   keyboardType: TextInputType.number,
//                   controller: TextEditingController(text: (appliedDisc4 * 100).toStringAsFixed(0)),
//                   onChanged: (value) {
//                     appliedDisc4 = (double.tryParse(value) ?? 0) / 100;
//                     if (appliedDisc4 > batasDiskon["disc4"]!) {
//                       _showErrorDialog(context, 'Diskon 4 melebihi batas maksimal!');
//                       appliedDisc4 = batasDiskon["disc4"]!;
//                     }
//                   },
//                 ),
//                 // Diskon 5
//                 TextField(
//                   decoration: InputDecoration(
//                     labelText: 'Diskon 5 (max ${batasDiskon["disc5"]! * 100}%)',
//                   ),
//                   keyboardType: TextInputType.number,
//                   controller: TextEditingController(text: (appliedDisc5 * 100).toStringAsFixed(0)),
//                   onChanged: (value) {
//                     appliedDisc5 = (double.tryParse(value) ?? 0) / 100;
//                     if (appliedDisc5 > batasDiskon["disc5"]!) {
//                       _showErrorDialog(context, 'Diskon 5 melebihi batas maksimal!');
//                       appliedDisc5 = batasDiskon["disc5"]!;
//                     }
//                   },
//                 ),
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 setState(() {
//                   appliedDisc1 = 0;
//                   appliedDisc2 = 0;
//                   appliedDisc3 = 0;
//                   appliedDisc4 = 0;
//                   appliedDisc5 = 0;
//                   currentNetPrice = originalPrice;
//                   totalDiskonUpdated = priceList - currentNetPrice;
//                 });

//                 // Tutup dialog
//                 Navigator.of(context).pop();
//                 updateTotalDiskonInSearchResults(index, totalDiskonUpdated ?? 0, currentNetPrice);
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(
//                     content: Text('Diskon berhasil direset!'),
//                   ),
//                 );
//               },
//               child: const Text('Reset'),
//             ),
//             TextButton(
//               onPressed: () {
//                 currentNetPrice = hitungHargaNet(
//                   originalPrice,
//                   appliedDisc1,
//                   appliedDisc2,
//                   appliedDisc3,
//                   appliedDisc4,
//                   appliedDisc5,
//                 );

//                 double totalDiskonBaru = priceList - currentNetPrice;

//                 setState(() {
//                   totalDiskonUpdated = totalDiskonBaru;
//                 });

//                 Navigator.of(context).pop();
//                 updateTotalDiskonInSearchResults(index, totalDiskonBaru, currentNetPrice);
//               },
//               child: const Text('Hitung Harga'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   double hitungHargaNet(double originalPrice, double disc1, double disc2, double disc3, double disc4, double disc5) {
//   return originalPrice * (1 - disc1) * (1 - disc2) * (1 - disc3) * (1 - disc4) * (1 - disc5);
//   }

//   void showInputHargaNetPopup(int index) {
//     TextEditingController hargaNetController = TextEditingController();

//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Edit Harga Net'),
//           content: TextField(
//             controller: hargaNetController,
//             keyboardType: TextInputType.number,
//             decoration: const InputDecoration(labelText: 'Masukkan Harga Net baru'),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: const Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () async {
//                 double newHargaNet = double.tryParse(hargaNetController.text) ?? 0;
//                 if (newHargaNet > 0) {
//                   double priceList = await fetchPricelist();

//                   if (priceList > 0) {
//                     double newTotalDiskon = priceList - newHargaNet;

//                     setState(() {
//                       searchResults[index]['harga_net'] =
//                           NumberFormat.currency(locale: 'id_ID', symbol: 'Rp. ', decimalDigits: 0).format(newHargaNet);
//                       searchResults[index]['total_diskon'] =
//                           NumberFormat.currency(locale: 'id_ID', symbol: 'Rp. ', decimalDigits: 0).format(newTotalDiskon);
//                     });

//                     Navigator.of(context).pop();
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(
//                         content: Text('Harga Net berhasil diperbarui!'),
//                       ),
//                     );
//                   } else {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(
//                         content: Text('Gagal mengambil harga pricelist. Coba lagi nanti.'),
//                       ),
//                     );
//                   }
//                 } else {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(
//                       content: Text('Masukkan nilai Harga Net yang valid.'),
//                     ),
//                   );
//                 }
//               },
//               child: const Text('Save'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _resetLists() {
//     setState(() {
//     apiData = [];
//     areaList = [];
//     brandList = [];
//     kasurList = [];
//     divanList = ["Tanpa Divan"];
//     headboardList = ["Tanpa Headboard"];
//     ukuranList = [];
//     channelList = [];
//     sorongList = ["Tanpa Sorong"];
//     hargaList = [];
//     });
//   }

//   void _showErrorDialog(BuildContext context, String message) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Error'),
//           content: Text(message),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: const Text('Close'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Widget _buildRow(String label, String? value) {
//     return Row(
//       children: [
//         SizedBox(
//           width:
//               120, // Set fixed width for label to align all labels consistently
//           child: Text(
//             label,
//             style: const TextStyle(
//                 fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
//           ),
//         ),
//         const Text(
//           ': ', // Display colon after the label
//           style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
//         ),
//         Expanded(
//           child: Text(
//             value ?? 'Tanpa data',
//             style: const TextStyle(fontFamily: 'Poppins'),
//           ),
//         ),
//       ],
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             const Row(
//               children: [
//                 Icon(Icons.price_check, color: Colors.white),
//                 SizedBox(width: 10),
//                 Text(
//                   "Pricelist",
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 20,
//                     fontFamily: 'Poppins',
//                     color: Colors.white,
//                     letterSpacing: 1,
//                   ),
//                 ),
//               ],
//             ),
//             Image.asset(
//               'assets/jalan.png',
//               height: 30,
//             ),
//           ],
//         ),
//         backgroundColor: Colors.blueAccent,
//         elevation: 4,
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//   //             DropdownSearch<String>(
//   //               decoratorProps: const DropDownDecoratorProps(
//   //                 decoration: InputDecoration(
//   //                   labelText: "Area",
//   //                   contentPadding:
//   //                       EdgeInsets.symmetric(vertical: 12, horizontal: 8),
//   //                   border: OutlineInputBorder(),
//   //                 ),
//   //               ),
//   //               popupProps: PopupProps.menu(
//   //                 showSearchBox: true,
//   //                 constraints: BoxConstraints(
//   //                   maxHeight: getDropdownHeight(areaList),
//   //                 ),
//   //               ),
//   // //               asyncItems: (String filter) async {
//   // //   // Return the list as a Future
//   // //   return areaList.isNotEmpty ? areaList.cast<String>() : [];
//   // // },
//   // //               items: areaList.isNotEmpty ? areaList : [],
//   //               onChanged: (value) {
//   //                 setState(() {
//   //                   selectedArea = value;
//   //                 });
//   //               },
//   //               selectedItem: selectedArea,
//   //               filterFn: (item, filter) =>
//   //                   item.toLowerCase().contains(filter.toLowerCase()),
//   //             ),
//   //             const SizedBox(height: 10),
//   //             DropdownSearch<String>(
//   //               decoratorProps: const DropDownDecoratorProps(
//   //                 decoration: InputDecoration(
//   //                   labelText: "Channel",
//   //                   contentPadding:
//   //                       EdgeInsets.symmetric(vertical: 12, horizontal: 8),
//   //                   border: OutlineInputBorder(),
//   //                 ),
//   //               ),
//   //               popupProps: PopupProps.menu(
//   //                 showSearchBox: true,
//   //                 constraints: BoxConstraints(
//   //                   maxHeight: getDropdownHeight(channelList),
//   //                 ),
//   //               ),
//   //             //  items: channelList.isNotEmpty ? channelList : [],
//   //               onChanged: (value) {
//   //                 setState(() {
//   //                   selectedChannel = value;
//   //                 });
//   //               },
//   //               selectedItem: selectedChannel,
//   //               filterFn: (item, filter) =>
//   //                   item.toLowerCase().contains(filter.toLowerCase()),
//   //             ),
//   //             const SizedBox(height: 10),
//   //             DropdownSearch<String>(
//   //               decoratorProps: const DropDownDecoratorProps(
//   //                 decoration: InputDecoration(
//   //                   labelText: "Brand",
//   //                   contentPadding:
//   //                       EdgeInsets.symmetric(vertical: 12, horizontal: 8),
//   //                   border: OutlineInputBorder(),
//   //                 ),
//   //               ),
//   //               popupProps: PopupProps.menu(
//   //                 showSearchBox: true,
//   //                 constraints: BoxConstraints(
//   //                   maxHeight: getDropdownHeight(brandList),
//   //                 ),
//   //               ),
//   //             //  items: brandList.isNotEmpty ? brandList : [],
//   //               onChanged: (value) {
//   //                 setState(() {
//   //                   selectedBrand = value;
//   //                 });
//   //               },
//   //               selectedItem: selectedBrand,
//   //               filterFn: (item, filter) =>
//   //                   item.toLowerCase().contains(filter.toLowerCase()),
//   //             ),
//   //             const SizedBox(height: 10),
//   //             DropdownSearch<String>(
//   //               decoratorProps: const DropDownDecoratorProps(
//   //                 decoration: InputDecoration(
//   //                   labelText: "Kasur",
//   //                   contentPadding:
//   //                       EdgeInsets.symmetric(vertical: 12, horizontal: 8),
//   //                   border: OutlineInputBorder(),
//   //                 ),
//   //               ),
//   //               popupProps: PopupProps.menu(
//   //                 showSearchBox: true,
//   //                 constraints: BoxConstraints(
//   //                   maxHeight: getDropdownHeight(kasurList),
//   //                 ),
//   //               ),
//   //              // items: kasurList.isNotEmpty ? kasurList : [],
//   //               onChanged: (value) {
//   //                 setState(() {
//   //                   selectedKasur = value;
//   //                 });
//   //               },
//   //               selectedItem: selectedKasur,
//   //               filterFn: (item, filter) =>
//   //                   item.toLowerCase().contains(filter.toLowerCase()),
//   //             ),
//   //             const SizedBox(height: 10),
//   //             DropdownSearch<String>(
//   //               decoratorProps: const DropDownDecoratorProps(
//   //                 decoration: InputDecoration(
//   //                   labelText: "Divan",
//   //                   contentPadding:
//   //                       EdgeInsets.symmetric(vertical: 12, horizontal: 8),
//   //                   border: OutlineInputBorder(),
//   //                 ),
//   //               ),
//   //               popupProps: PopupProps.menu(
//   //                 showSearchBox: true,
//   //                 constraints: BoxConstraints(
//   //                   maxHeight: getDropdownHeight(divanList),
//   //                 ),
//   //               ),
//   //              // items: divanList.isNotEmpty ? divanList : [],
//   //               onChanged: (value) {
//   //                 setState(() {
//   //                   selectedDivan = value;
//   //                 });
//   //               },
//   //               selectedItem: selectedDivan,
//   //               filterFn: (item, filter) =>
//   //                   item.toLowerCase().contains(filter.toLowerCase()),
//   //             ),
//   //             const SizedBox(height: 10),
//   //             DropdownSearch<String>(
//   //               decoratorProps: const DropDownDecoratorProps(
//   //                 decoration: InputDecoration(
//   //                   labelText: "Headboard",
//   //                   contentPadding:
//   //                       EdgeInsets.symmetric(vertical: 12, horizontal: 8),
//   //                   border: OutlineInputBorder(),
//   //                 ),
//   //               ),
//   //               popupProps: PopupProps.menu(
//   //                 showSearchBox: true,
//   //                 constraints: BoxConstraints(
//   //                   maxHeight: getDropdownHeight(headboardList),
//   //                 ),
//   //               ),
//   //               //items: headboardList.isNotEmpty ? headboardList : [],
//   //               onChanged: (value) {
//   //                 setState(() {
//   //                   selectedHeadboard = value;
//   //                 });
//   //               },
//   //               selectedItem: selectedHeadboard,
//   //               filterFn: (item, filter) =>
//   //                   item.toLowerCase().contains(filter.toLowerCase()),
//   //             ),
//   //             const SizedBox(height: 10),
//   //             DropdownSearch<String>(
//   //               decoratorProps: const DropDownDecoratorProps(
//   //                 decoration: InputDecoration(
//   //                   labelText: "Sorong",
//   //                   contentPadding:
//   //                       EdgeInsets.symmetric(vertical: 12, horizontal: 8),
//   //                   border: OutlineInputBorder(),
//   //                 ),
//   //               ),
//   //               popupProps: PopupProps.menu(
//   //                 showSearchBox: true,
//   //                 constraints: BoxConstraints(
//   //                   maxHeight: getDropdownHeight(sorongList),
//   //                 ),
//   //               ),
//   //             //  items: sorongList.isNotEmpty ? sorongList : [],
//   //               onChanged: (value) {
//   //                 setState(() {
//   //                   selectedSorong = value;
//   //                 });
//   //               },
//   //               selectedItem: selectedSorong,
//   //               filterFn: (item, filter) =>
//   //                   item.toLowerCase().contains(filter.toLowerCase()),
//   //             ),
//   //             const SizedBox(height: 10),
//   //             DropdownSearch<String>(
//   //               decoratorProps: const DropDownDecoratorProps(
//   //                 decoration: InputDecoration(
//   //                   labelText: "Ukuran",
//   //                   contentPadding:
//   //                       EdgeInsets.symmetric(vertical: 12, horizontal: 8),
//   //                   border: OutlineInputBorder(),
//   //                 ),
//   //               ),
//   //               popupProps: PopupProps.menu(
//   //                 showSearchBox: true,
//   //                 constraints: BoxConstraints(
//   //                   maxHeight: getDropdownHeight(ukuranList),
//   //                 ),
//   //               ),
//   //              // items: ukuranList.isNotEmpty ? ukuranList : [],
//   //               onChanged: (value) {
//   //                 setState(() {
//   //                   selectedUkuran = value;
//   //                 });
//   //               },
//   //               selectedItem: selectedUkuran,
//   //               filterFn: (item, filter) =>
//   //                   item.toLowerCase().contains(filter.toLowerCase()),
//   //             ),
//               const SizedBox(height: 20),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   ElevatedButton(
//                     onPressed: clearFilters,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.redAccent,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       padding: const EdgeInsets.symmetric(
//                           vertical: 12, horizontal: 18),
//                     ),
//                     child: const Text(
//                       "Clean Filters",
//                       style: TextStyle(color: Colors.white, fontSize: 16),
//                     ),
//                   ),
//                   ElevatedButton(
//                     onPressed: searchItems,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.blueAccent,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       padding: const EdgeInsets.symmetric(
//                           vertical: 12, horizontal: 18),
//                     ),
//                     child: const Text(
//                       "Search",
//                       style: TextStyle(color: Colors.white, fontSize: 16),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 20),
//               searchResults.isNotEmpty
//                   ? ListView.builder(
//                       shrinkWrap: true,
//                       physics: const NeverScrollableScrollPhysics(),
//                       itemCount: searchResults.length,
//                       itemBuilder: (context, index) {
//                         final result = searchResults[index];
//                         return Card(
//                           margin: const EdgeInsets.symmetric(vertical: 8.0),
//                           elevation: 3,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           child: Padding(
//                             padding: const EdgeInsets.all(12.0),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 _buildRow('Kasur', result['kasur']),
//                                 _buildRow('Divan', result['divan']),
//                                 _buildRow('Headboard', result['headboard']),
//                                 _buildRow('Sorong', result['sorong']),
//                                 _buildRow('Ukuran', result['ukuran']),
//                                 _buildRow('Program', result['program']),
//                                 _buildRow('Price List', result['price_list']),
//                                 const SizedBox(
//                                     height: 5), // Add space between sections
//                                 const Text(
//                                   'Bonus :',
//                                   style: TextStyle(
//                                       fontFamily: 'Poppins',
//                                       fontWeight: FontWeight.bold),
//                                 ),
//                                 Text(
//                                   result['bonuses'] ?? "",
//                                   style: const TextStyle(fontFamily: 'Poppins'),
//                                 ),
//                                 const SizedBox(height: 10),
//                                 _buildRow(
//                                     'Total Diskon', result['total_diskon']),
//                                 _buildRow('Harga Net', result['harga_net']),

//                                 Row(
//                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     ElevatedButton(
//                                       onPressed: () => showCicilanPopup(result),
//                                       style: ElevatedButton.styleFrom(
//                                         backgroundColor: const Color.fromRGBO(37, 211, 102, 1),
//                                         shape: RoundedRectangleBorder(
//                                           borderRadius: BorderRadius.circular(8),
//                                         ),
//                                       ),
//                                       child: const Text(
//                                         "Cicilan",
//                                         style: TextStyle(color: Colors.white),
//                                       ),
//                                     ),
//                                     IconButton(
//                                       onPressed: () {
//                                         showInputHargaNetPopup(index);
//                                       },
//                                       icon: const Icon(Icons.edit),
//                                       color: Colors.white,
//                                       tooltip: 'Edit HargaNet',
//                                       style: IconButton.styleFrom(
//                                         backgroundColor: Colors.blue,
//                                         shape: const CircleBorder(),
//                                       ),
//                                     ),
//                                     IconButton(
//                                       onPressed: () {
//                                         if (hargaList.any((endUserPrice) => endUserPrice > 0)) {
//                                           Map<String, double> batasDiskon = {
//                                             "disc1": 0.1,
//                                             "disc2": 0.05,
//                                             "disc3": 0.05,
//                                             "disc4": 0.05,
//                                             "disc5": 0.05,
//                                           };

//                                           double selectedHargaNet = 0;

//                                           String hargaNetString = searchResults[index]['harga_net'] ?? '0';

//                                           NumberFormat currencyFormatter = NumberFormat.currency(
//                                             locale: 'id_ID',
//                                             symbol: 'Rp. ',
//                                           );

//                                            selectedHargaNet = currencyFormatter.parse(hargaNetString).toDouble();

//                                           if (selectedHargaNet > 0) {
//                                             showDiskonPopup(index, selectedHargaNet, batasDiskon);
//                                           } else {
//                                             ScaffoldMessenger.of(context).showSnackBar(
//                                               const SnackBar(
//                                                 content: Text('Harga belum tersedia, coba lagi nanti'),
//                                               ),
//                                             );
//                                           }
//                                         } else {
//                                           ScaffoldMessenger.of(context).showSnackBar(
//                                             const SnackBar(
//                                               content: Text('Harga belum tersedia, coba lagi nanti'),
//                                             ),
//                                           );
//                                         }
//                                       },
//                                       icon: const Icon(Icons.help_outline),
//                                       color: Colors.white,
//                                       tooltip: 'Tampilkan Diskon',
//                                       style: IconButton.styleFrom(
//                                         backgroundColor: Colors.orange,
//                                         shape: const CircleBorder(),
//                                       ),
//                                     ),
//                                   ],
//                                 ),

//                               ],
//                             ),
//                           ),
//                         );
//                       },
//                     )
//                   : const Center(
//                       child: Padding(
//                         padding: EdgeInsets.symmetric(vertical: 20),
//                         child: Text("Tolong search terlebih dahulu",
//                             style: TextStyle(color: Colors.grey)),
//                       ),
//                     ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:logger/web.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var logger = Logger();
  final NumberFormat currencyFormat =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp. ', decimalDigits: 0);
  double appliedDisc1 = 0;
  double appliedDisc2 = 0;
  double appliedDisc3 = 0;
  double appliedDisc4 = 0;
  double appliedDisc5 = 0;
  List<String> areaList = [];
  List<String> brandList = [];
  List<String> channelList = [];
  List<String> divanList = [];
  List<double> hargaList = [];
  List<String> headboardList = [];
  List<String> sorongList = [];
  List<String> kasurList = [];
  List<String> ukuranList = [];
  double currentNetPrice = 0;
  double selectedHargaNet = 0;
  double originalPrice = 0;
  List<Map<String, dynamic>> apiData = []; // Menyimpan data dari API
  List<Map<String, String>> searchResults = []; // Menyimpan hasil pencarian
  List<Map<String, dynamic>> searchResultsHarga = [];
  String? selectedArea;
  String? selectedBrand;
  String? selectedChannel;
  String? selectedDivan = "Tanpa Divan";
  String? selectedHeadboard = "Tanpa Headboard";
  String? selectedKasur;
  String? selectedSorong = "Tanpa Sorong";
  String? selectedUkuran;
  double? totalDiskonUpdated;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final response = await http.get(Uri.parse(
          'https://alitav2.massindo.com/api/rawdata_price_lists?access_token=d60Jls5Tr2n63aGOKWXYALhX5JRwXREE2IneQoGKiT4&client_id=hqJ199kBBLePkNt9mhS9EbgaCC6RarYxQux-fzebUZ8&client_secret=xtvj63aVIPaFNOiGKtOu1Su5EBYzdP_MZTG60uwGzP0'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['result'] != null) {
          final results = List<Map<String, dynamic>>.from(data['result']);

          final List<String> areas = results
              .map((item) => item['area'])
              .whereType<String>()
              .toSet()
              .toList();
          final List<String> brands = results
              .map((item) => item['brand'])
              .whereType<String>()
              .toSet()
              .toList();
          final List<String> kasurs = results
              .map((item) => item['kasur'])
              .whereType<String>()
              .toSet()
              .toList();
          final List<String> divans = results
              .map((item) => item['divan'])
              .whereType<String>()
              .toSet()
              .toList();
          final List<String> headboards = results
              .map((item) => item['headboard'])
              .whereType<String>()
              .toSet()
              .toList();
          final List<String> ukurans = results
              .map((item) => item['ukuran'])
              .whereType<String>()
              .toSet()
              .toList();
          final List<String> channels = results
              .map((item) => item['channel'])
              .whereType<String>()
              .toSet()
              .toList();
          final List<String> sorongs = results
              .map((item) => item['sorong'])
              .whereType<String>()
              .toSet()
              .toList();
          final List<double> prices = results.map((item) {
            final price = item['end_user_price'];
            if (price is String) return double.tryParse(price) ?? 0.0;
            if (price is double) return price;
            return 0.0;
          }).toList();

          setState(() {
            apiData = results;
            areaList = areas;
            brandList = brands;
            kasurList = kasurs;
            divanList = divans;
            headboardList = headboards;
            ukuranList = ukurans;
            channelList = channels;
            sorongList = sorongs;
            hargaList = prices;
          });
        } else {
          logger.e('Tidak ada hasil dari API');
          _resetLists();
        }
      } else {
        logger.e('Failed to load data, status code: ${response.statusCode}');
        _resetLists();
        throw Exception('Failed to load data');
      }
    } catch (e) {
      logger.e('Error fetching data: $e');
      _resetLists();
    }
  }

  double getDropdownHeight(List<String> items) {
    if (items.isEmpty) return 130;
    if (items.length == 2) {
      return 180;
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
        // double realPrice = 0;

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
          "price_list": NumberFormat.currency(
                  locale: 'id_ID', symbol: 'Rp. ', decimalDigits: 0)
              .format(pricelist),
          "program": item['program'] ?? "",
          "bonuses": bonuses.join("\n"),
          "total_diskon": NumberFormat.currency(
                  locale: 'id_ID', symbol: 'Rp. ', decimalDigits: 0)
              .format(totalDiskon),
          "harga_net": NumberFormat.currency(
                  locale: 'id_ID', symbol: 'Rp. ', decimalDigits: 0)
              .format(hargaNet),
          // "real_price": NumberFormat.currency(locale: 'id_ID', symbol: 'Rp. ')
          // .format(realPrice),
          "cicilan_12": cicilan12 != null
              ? NumberFormat.currency(
                      locale: 'id_ID', symbol: 'Rp. ', decimalDigits: 0)
                  .format(cicilan12)
              : "N/A",
          "cicilan_15": cicilan15 != null
              ? NumberFormat.currency(
                      locale: 'id_ID', symbol: 'Rp. ', decimalDigits: 0)
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
      searchResults.clear();
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
              : 0;
          logger.i('Fetch endUserPrice :$endUserPrice');
          return endUserPrice;
        } else {
          throw Exception('Tidak ada hasil yang ditemukan di dalam "result"');
        }
      } else {
        throw Exception('Gagal mengambil data dari API');
      }
    } catch (e) {
      logger.e('Catch endUserPrice : $e');
      return 0;
    }
  }

  Future<double> fetchPricelist() async {
    const String apiUrl =
        'https://alitav2.massindo.com/api/rawdata_price_lists?access_token=d60Jls5Tr2n63aGOKWXYALhX5JRwXREE2IneQoGKiT4&client_id=hqJ199kBBLePkNt9mhS9EbgaCC6RarYxQux-fzebUZ8&client_secret=xtvj63aVIPaFNOiGKtOu1Su5EBYzdP_MZTG60uwGzP0';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> resultList = data['result'];

        if (resultList.isNotEmpty) {
          double priceList = resultList[0]['pricelist'] != null
              ? (resultList[0]['pricelist'] as num).toDouble()
              : 0;
          logger.i('Fetch Price List :$priceList');
          return priceList;
        } else {
          throw Exception('Tidak ada hasil yang ditemukan di dalam "result"');
        }
      } else {
        throw Exception('Gagal mengambil data dari API');
      }
    } catch (e) {
      logger.e('Catch endUserPrice : $e');
      return 0;
    }
  }

  // Fungsi untuk memperbarui nilai total diskon di searchResults
  void updateTotalDiskonInSearchResults(
      int index, double newTotalDiskon, double newRealPrice) {
    setState(() {
      if (index >= 0 && index < searchResults.length) {
        searchResults[index]['total_diskon'] = NumberFormat.currency(
                locale: 'id_ID', symbol: 'Rp. ', decimalDigits: 0)
            .format(newTotalDiskon);
        searchResults[index]['harga_net'] = NumberFormat.currency(
                locale: 'id_ID', symbol: 'Rp. ', decimalDigits: 0)
            .format(newRealPrice);
      }
    });
  }

  // Function to show popup for Discount with API value
  void showDiskonPopup(int index, double selectedHargaNet,
      Map<String, double> batasDiskon, Map<String, String> result) async {
    if (originalPrice == 0) {
      originalPrice = await fetchEndUserPrice();
      currentNetPrice = originalPrice;
    } else {
      currentNetPrice = selectedHargaNet;
    }
    logger.i('Current Net Price : $originalPrice');
    // double priceList = await fetchPricelist();
    String a = result['price_list'].toString();
    // double priceList = double.parse(a);
    //double priceList = await fetchPricelist();
    double priceList = double.parse(a.replaceAll(RegExp(r'[^0-9]'), ''));

    if (originalPrice == 0) {
      _showErrorDialog(context, "Gagal mendapatkan harga dari API.");
      return;
    } else {
      currentNetPrice = selectedHargaNet;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Diskon'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                    "Harga : ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp. ', decimalDigits: 0).format(currentNetPrice)}"),
                // Diskon 1
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Diskon 1 (max ${batasDiskon["disc1"]! * 100}%)',
                  ),
                  keyboardType: TextInputType.number,
                  controller: TextEditingController(
                      text: (appliedDisc1 * 100).toStringAsFixed(
                          0)), // tampilkan nilai diskon yg sudah ada
                  onChanged: (value) {
                    appliedDisc1 = (double.tryParse(value) ?? 0) / 100;
                    if (appliedDisc1 > batasDiskon["disc1"]!) {
                      _showErrorDialog(
                          context, 'Diskon 1 melebihi batas maksimal!');
                      appliedDisc1 = batasDiskon["disc1"]!;
                    }
                  },
                ),
                // Diskon 2
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Diskon 2 (max ${batasDiskon["disc2"]! * 100}%)',
                  ),
                  keyboardType: TextInputType.number,
                  controller: TextEditingController(
                      text: (appliedDisc2 * 100).toStringAsFixed(0)),
                  onChanged: (value) {
                    appliedDisc2 = (double.tryParse(value) ?? 0) / 100;
                    if (appliedDisc2 > batasDiskon["disc2"]!) {
                      _showErrorDialog(
                          context, 'Diskon 2 melebihi batas maksimal!');
                      appliedDisc2 = batasDiskon["disc2"]!;
                    }
                  },
                ),
                // Diskon 3
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Diskon 3 (max ${batasDiskon["disc3"]! * 100}%)',
                  ),
                  keyboardType: TextInputType.number,
                  controller: TextEditingController(
                      text: (appliedDisc3 * 100).toStringAsFixed(0)),
                  onChanged: (value) {
                    appliedDisc3 = (double.tryParse(value) ?? 0) / 100;
                    if (appliedDisc3 > batasDiskon["disc3"]!) {
                      _showErrorDialog(
                          context, 'Diskon 3 melebihi batas maksimal!');
                      appliedDisc3 = batasDiskon["disc3"]!;
                    }
                  },
                ),
                // Diskon 4
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Diskon 4 (max ${batasDiskon["disc4"]! * 100}%)',
                  ),
                  keyboardType: TextInputType.number,
                  controller: TextEditingController(
                      text: (appliedDisc4 * 100).toStringAsFixed(0)),
                  onChanged: (value) {
                    appliedDisc4 = (double.tryParse(value) ?? 0) / 100;
                    if (appliedDisc4 > batasDiskon["disc4"]!) {
                      _showErrorDialog(
                          context, 'Diskon 4 melebihi batas maksimal!');
                      appliedDisc4 = batasDiskon["disc4"]!;
                    }
                  },
                ),
                // Diskon 5
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Diskon 5 (max ${batasDiskon["disc5"]! * 100}%)',
                  ),
                  keyboardType: TextInputType.number,
                  controller: TextEditingController(
                      text: (appliedDisc5 * 100).toStringAsFixed(0)),
                  onChanged: (value) {
                    appliedDisc5 = (double.tryParse(value) ?? 0) / 100;
                    if (appliedDisc5 > batasDiskon["disc5"]!) {
                      _showErrorDialog(
                          context, 'Diskon 5 melebihi batas maksimal!');
                      appliedDisc5 = batasDiskon["disc5"]!;
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  appliedDisc1 = 0;
                  appliedDisc2 = 0;
                  appliedDisc3 = 0;
                  appliedDisc4 = 0;
                  appliedDisc5 = 0;
                  currentNetPrice = originalPrice;
                  totalDiskonUpdated = priceList - currentNetPrice;
                });

                // Tutup dialog
                // searchResults.clear();
                Navigator.of(context).pop();
                updateTotalDiskonInSearchResults(
                    index, totalDiskonUpdated ?? 0, currentNetPrice);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Diskon berhasil direset!'),
                  ),
                );
              },
              child: const Text('Reset'),
            ),
            TextButton(
              onPressed: () {
                currentNetPrice = hitungHargaNet(
                  selectedHargaNet,
                  appliedDisc1,
                  appliedDisc2,
                  appliedDisc3,
                  appliedDisc4,
                  appliedDisc5,
                );

                double totalDiskonBaru = priceList - currentNetPrice;

                setState(() {
                  totalDiskonUpdated = totalDiskonBaru;
                  appliedDisc1 = 0;
                  appliedDisc2 = 0;
                  appliedDisc3 = 0;
                  appliedDisc4 = 0;
                  appliedDisc5 = 0;
                });
                // searchResults.clear();
                Navigator.of(context).pop();

                updateTotalDiskonInSearchResults(
                    index, totalDiskonBaru, currentNetPrice);
              },
              child: const Text('Hitung Harga'),
            ),
          ],
        );
      },
    );
  }

  double hitungHargaNet(double originalPrice, double disc1, double disc2,
      double disc3, double disc4, double disc5) {
    return originalPrice *
        (1 - disc1) *
        (1 - disc2) *
        (1 - disc3) *
        (1 - disc4) *
        (1 - disc5);
  }

  void showInputHargaNetPopup(Map<String, String> result) {
    TextEditingController hargaNetController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Harga Net'),
          content: TextField(
            controller: hargaNetController,
            keyboardType: TextInputType.number,
            decoration:
                const InputDecoration(labelText: 'Masukkan Harga Net baru'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                double newHargaNet =
                    double.tryParse(hargaNetController.text) ?? 0;
                if (newHargaNet > 0) {
                  String a = result['price_list'].toString();
                  // double priceList = double.parse(a);
                  //double priceList = await fetchPricelist();
                  double priceList =
                      double.parse(a.replaceAll(RegExp(r'[^0-9]'), ''));

                  if (priceList > 0) {
                    double newTotalDiskon = priceList - newHargaNet;

                    setState(() {
                      result['harga_net'] = NumberFormat.currency(
                              locale: 'id_ID', symbol: 'Rp. ', decimalDigits: 0)
                          .format(newHargaNet);
                      result['total_diskon'] = NumberFormat.currency(
                              locale: 'id_ID', symbol: 'Rp. ', decimalDigits: 0)
                          .format(newTotalDiskon);
                    });

                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Harga Net berhasil diperbarui!'),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Gagal mengambil harga pricelist. Coba lagi nanti.'),
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Masukkan nilai Harga Net yang valid.'),
                    ),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _resetLists() {
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

  Widget _buildRow(String label, String? value) {
    return Row(
      children: [
        SizedBox(
          width:
              120, // Set fixed width for label to align all labels consistently
          child: Text(
            label,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
          ),
        ),
        const Text(
          ': ', // Display colon after the label
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
              'assets/jalan.png',
              height: 30,
            ),
          ],
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 4,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // DropdownSearch<String>(
              //   dropdownDecoratorProps: const DropDownDecoratorProps(
              //     dropdownSearchDecoration: InputDecoration(
              //       labelText: "Area",
              //       contentPadding:
              //           EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              //       border: OutlineInputBorder(),
              //     ),
              //   ),
              //   popupProps: PopupProps.menu(
              //     showSearchBox: true,
              //     constraints: BoxConstraints(
              //       maxHeight: getDropdownHeight(areaList),
              //     ),
              //   ),
              //   items: areaList.isNotEmpty ? areaList : [],
              //   onChanged: (value) {
              //     setState(() {
              //       selectedArea = value;
              //     });
              //   },
              //   selectedItem: selectedArea,
              //   filterFn: (item, filter) =>
              //       item.toLowerCase().contains(filter.toLowerCase()),
              // ),
              // const SizedBox(height: 10),
              // DropdownSearch<String>(
              //   dropdownDecoratorProps: const DropDownDecoratorProps(
              //     dropdownSearchDecoration: InputDecoration(
              //       labelText: "Channel",
              //       contentPadding:
              //           EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              //       border: OutlineInputBorder(),
              //     ),
              //   ),
              //   popupProps: PopupProps.menu(
              //     showSearchBox: true,
              //     constraints: BoxConstraints(
              //       maxHeight: getDropdownHeight(channelList),
              //     ),
              //   ),
              //   items: channelList.isNotEmpty ? channelList : [],
              //   onChanged: (value) {
              //     setState(() {
              //       selectedChannel = value;
              //     });
              //   },
              //   selectedItem: selectedChannel,
              //   filterFn: (item, filter) =>
              //       item.toLowerCase().contains(filter.toLowerCase()),
              // ),
              // const SizedBox(height: 10),
              // DropdownSearch<String>(
              //   dropdownDecoratorProps: const DropDownDecoratorProps(
              //     dropdownSearchDecoration: InputDecoration(
              //       labelText: "Brand",
              //       contentPadding:
              //           EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              //       border: OutlineInputBorder(),
              //     ),
              //   ),
              //   popupProps: PopupProps.menu(
              //     showSearchBox: true,
              //     constraints: BoxConstraints(
              //       maxHeight: getDropdownHeight(brandList),
              //     ),
              //   ),
              //   items: brandList.isNotEmpty ? brandList : [],
              //   onChanged: (value) {
              //     setState(() {
              //       selectedBrand = value;
              //     });
              //   },
              //   selectedItem: selectedBrand,
              //   filterFn: (item, filter) =>
              //       item.toLowerCase().contains(filter.toLowerCase()),
              // ),
              // const SizedBox(height: 10),
              // DropdownSearch<String>(
              //   dropdownDecoratorProps: const DropDownDecoratorProps(
              //     dropdownSearchDecoration: InputDecoration(
              //       labelText: "Kasur",
              //       contentPadding:
              //           EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              //       border: OutlineInputBorder(),
              //     ),
              //   ),
              //   popupProps: PopupProps.menu(
              //     showSearchBox: true,
              //     constraints: BoxConstraints(
              //       maxHeight: getDropdownHeight(kasurList),
              //     ),
              //   ),
              //   items: kasurList.isNotEmpty ? kasurList : [],
              //   onChanged: (value) {
              //     setState(() {
              //       selectedKasur = value;
              //     });
              //   },
              //   selectedItem: selectedKasur,
              //   filterFn: (item, filter) =>
              //       item.toLowerCase().contains(filter.toLowerCase()),
              // ),
              // const SizedBox(height: 10),
              // DropdownSearch<String>(
              //   dropdownDecoratorProps: const DropDownDecoratorProps(
              //     dropdownSearchDecoration: InputDecoration(
              //       labelText: "Divan",
              //       contentPadding:
              //           EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              //       border: OutlineInputBorder(),
              //     ),
              //   ),
              //   popupProps: PopupProps.menu(
              //     showSearchBox: true,
              //     constraints: BoxConstraints(
              //       maxHeight: getDropdownHeight(divanList),
              //     ),
              //   ),
              //   items: divanList.isNotEmpty ? divanList : [],
              //   onChanged: (value) {
              //     setState(() {
              //       selectedDivan = value;
              //     });
              //   },
              //   selectedItem: selectedDivan,
              //   filterFn: (item, filter) =>
              //       item.toLowerCase().contains(filter.toLowerCase()),
              // ),
              // const SizedBox(height: 10),
              // DropdownSearch<String>(
              //   dropdownDecoratorProps: const DropDownDecoratorProps(
              //     dropdownSearchDecoration: InputDecoration(
              //       labelText: "Headboard",
              //       contentPadding:
              //           EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              //       border: OutlineInputBorder(),
              //     ),
              //   ),
              //   popupProps: PopupProps.menu(
              //     showSearchBox: true,
              //     constraints: BoxConstraints(
              //       maxHeight: getDropdownHeight(headboardList),
              //     ),
              //   ),
              //   items: headboardList.isNotEmpty ? headboardList : [],
              //   onChanged: (value) {
              //     setState(() {
              //       selectedHeadboard = value;
              //     });
              //   },
              //   selectedItem: selectedHeadboard,
              //   filterFn: (item, filter) =>
              //       item.toLowerCase().contains(filter.toLowerCase()),
              // ),
              // const SizedBox(height: 10),
              // DropdownSearch<String>(
              //   dropdownDecoratorProps: const DropDownDecoratorProps(
              //     dropdownSearchDecoration: InputDecoration(
              //       labelText: "Sorong",
              //       contentPadding:
              //           EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              //       border: OutlineInputBorder(),
              //     ),
              //   ),
              //   popupProps: PopupProps.menu(
              //     showSearchBox: true,
              //     constraints: BoxConstraints(
              //       maxHeight: getDropdownHeight(sorongList),
              //     ),
              //   ),
              //   items: sorongList.isNotEmpty ? sorongList : [],
              //   onChanged: (value) {
              //     setState(() {
              //       selectedSorong = value;
              //     });
              //   },
              //   selectedItem: selectedSorong,
              //   filterFn: (item, filter) =>
              //       item.toLowerCase().contains(filter.toLowerCase()),
              // ),
              // const SizedBox(height: 10),
              // DropdownSearch<String>(
              //   dropdownDecoratorProps: const DropDownDecoratorProps(
              //     dropdownSearchDecoration: InputDecoration(
              //       labelText: "Ukuran",
              //       contentPadding:
              //           EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              //       border: OutlineInputBorder(),
              //     ),
              //   ),
              //   popupProps: PopupProps.menu(
              //     showSearchBox: true,
              //     constraints: BoxConstraints(
              //       maxHeight: getDropdownHeight(ukuranList),
              //     ),
              //   ),
              //   items: ukuranList.isNotEmpty ? ukuranList : [],
              //   onChanged: (value) {
              //     setState(() {
              //       selectedUkuran = value;
              //     });
              //   },
              //   selectedItem: selectedUkuran,
              //   filterFn: (item, filter) =>
              //       item.toLowerCase().contains(filter.toLowerCase()),
              // ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    onPressed: searchItems,
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
              searchResults.isNotEmpty
                  ? ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: searchResults.length,
                      itemBuilder: (context, index) {
                        final result = searchResults[index];
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
                                _buildRow('Kasur', result['kasur']),
                                _buildRow('Divan', result['divan']),
                                _buildRow('Headboard', result['headboard']),
                                _buildRow('Sorong', result['sorong']),
                                _buildRow('Ukuran', result['ukuran']),
                                _buildRow('Program', result['program']),
                                _buildRow('Price List', result['price_list']),
                                const SizedBox(
                                    height: 5), // Add space between sections
                                const Text(
                                  'Bonus :',
                                  style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  result['bonuses'] ?? "",
                                  style: const TextStyle(fontFamily: 'Poppins'),
                                ),
                                const SizedBox(height: 10),
                                _buildRow(
                                    'Total Diskon', result['total_diskon']),
                                _buildRow('Harga Net', result['harga_net']),

                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () => showCicilanPopup(result),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromRGBO(
                                            37, 211, 102, 1),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: const Text(
                                        "Cicilan",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        showInputHargaNetPopup(result);
                                      },
                                      icon: const Icon(Icons.edit),
                                      color: Colors.white,
                                      tooltip: 'Edit HargaNet',
                                      style: IconButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                        shape: const CircleBorder(),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        if (hargaList.any((endUserPrice) =>
                                            endUserPrice > 0)) {
                                          Map<String, double> batasDiskon = {
                                            "disc1": 0.1,
                                            "disc2": 0.05,
                                            "disc3": 0.05,
                                            "disc4": 0.05,
                                            "disc5": 0.05,
                                          };

                                          double selectedHargaNet = 0;

                                          String hargaNetString =
                                              searchResults[index]
                                                      ['harga_net'] ??
                                                  '0';

                                          NumberFormat currencyFormatter =
                                              NumberFormat.currency(
                                            locale: 'id_ID',
                                            symbol: 'Rp. ',
                                          );

                                          selectedHargaNet = currencyFormatter
                                              .parse(hargaNetString)
                                              .toDouble();

                                          if (selectedHargaNet > 0) {
                                            showDiskonPopup(
                                                index,
                                                selectedHargaNet,
                                                batasDiskon,
                                                result);
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
                                      icon: const Icon(Icons.help_outline),
                                      color: Colors.white,
                                      tooltip: 'Tampilkan Diskon',
                                      style: IconButton.styleFrom(
                                        backgroundColor: Colors.orange,
                                        shape: const CircleBorder(),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  : const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Text("Tolong search terlebih dahulu",
                            style: TextStyle(color: Colors.grey)),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
