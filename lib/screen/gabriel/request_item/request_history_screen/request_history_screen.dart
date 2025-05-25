import 'package:project_skripsi/api/api.dart';
import 'package:project_skripsi/screen/gabriel/core/app_export.dart';
import 'package:project_skripsi/constant/dialog_constant.dart';
import 'package:project_skripsi/screen/gabriel/not_found_screen/not_found_screen.dart';
import 'package:project_skripsi/utils/local_data.dart';
import 'package:flutter/material.dart';
import 'package:project_skripsi/screen/gabriel/request_item/request_item_screen/request_item_screen.dart';
import 'package:get/get.dart';
import 'dart:async';

import 'package:intl/intl.dart';

class RequestHistoryScreen extends StatefulWidget {
  @override
  _RequestHistoryScreenState createState() => _RequestHistoryScreenState();
}

class _RequestHistoryScreenState extends State<RequestHistoryScreen> {
  late Future<List<Map<String, dynamic>>> futureData;

  @override
  void initState() {
    super.initState();
    futureData = getInitData();
  }

  Future<List<Map<String, dynamic>>> getInitData() async {
    Completer<List<Map<String, dynamic>>> completer = Completer();

    API.basePost(
      '/get_request_item.php',
      {'username': await LocalData.getData('user')},
      {'Content-Type': 'application/json'},
      true,
      (result, error) {
        if (result != null && result['error'] != true) {
          completer.complete(List<Map<String, dynamic>>.from(result['data']));
        } else if (result['error'] == true &&
            result['message'] == 'No data found') {
          completer.complete([]);
        } else {
          DialogConstant.alert(error.toString());
          completer.completeError(error);
        }
      },
    );

    return completer.future;
  }

  String formatDate(String date) {
    try {
      DateTime parsedDate = DateTime.parse(date);
      return DateFormat('dd-MM-yyyy').format(parsedDate);
    } catch (e) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Text('Daftar Produk', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent.shade700,
        elevation: 4,
        shadowColor: Colors.blueAccent.shade100,
        actions: [
          IconButton(
              onPressed: () => Get.to(() => RequestedItemScreen()),
              icon: Icon(Icons.request_page))
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            futureData = getInitData();
          });
          await futureData;
        },
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: futureData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('Tidak ada data'));
            }

            List<Map<String, dynamic>> data = snapshot.data!;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          spreadRadius: 2)
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columnSpacing: 20,
                        dataRowHeight: 50,
                        headingRowColor: MaterialStateColor.resolveWith(
                            (states) => Colors.blueAccent.shade100),
                        dataRowColor: MaterialStateColor.resolveWith(
                            (states) => Colors.white),
                        border: TableBorder.all(
                            width: 1, color: Colors.grey.shade300),
                        columns: [
                          DataColumn(
                              label: Text('Tanggal',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16))),
                          DataColumn(
                              label: Text('Nama Produk',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16))),
                          DataColumn(
                              label: Text('Jumlah',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16))),
                        ],
                        rows: data.asMap().entries.map((entry) {
                          int index = entry.key;
                          var product = entry.value;
                          return DataRow(
                            color: MaterialStateColor.resolveWith((states) =>
                                index.isEven
                                    ? Colors.grey.shade200
                                    : Colors.white),
                            cells: [
                              DataCell(Text(formatDate(product['REQUEST_DATE']),
                                  style: TextStyle(fontSize: 14))),
                              DataCell(Text(product['PRODUCT_NAME'],
                                  style: TextStyle(fontSize: 14))),
                              DataCell(Text(product['QUANTITY'].toString(),
                                  style: TextStyle(fontSize: 14))),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
