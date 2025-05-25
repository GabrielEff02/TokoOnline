import 'dart:convert';
import 'package:project_skripsi/screen/gabriel/core/app_export.dart';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

// Lock orientation to portrait

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> transactions = [];
  bool isLoading = true;
  int totalBalance = 0;
  @override
  void initState() {
    super.initState();
    fetchTransactions();
  }

  @override
  void dispose() {
    super.dispose();
  }

  NumberFormat currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: '',
    decimalDigits: 0,
  );
  Future<void> fetchTransactions() async {
    try {
      final String username = await LocalData.getData('user');
      final String balance = await LocalData.getData('point');
      final String apiUrl =
          "${API.BASE_URL}/get_transactions.php?username=$username";

      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        setState(() {
          totalBalance = int.parse(balance);
          transactions = data.map((item) {
            return {
              "transaction_id": item["transaction_id"],
              "date": item["date"],
              "total_amount": item["total_amount"] is String
                  ? (double.parse(item["total_amount"])).toInt()
                  : item["total_amount"].toInt(),
              "isNegative": item["is_negative"] == "true",
              "status": item['status'],
              "is_delivery": item['is_delivery'],
              "keterangan": item['keterangan']
            };
          }).toList();

          isLoading = false;
        });
      } else {
        throw Exception('Failed to load transactions');
      }
    } catch (e) {
      print("Error fetching transactions: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Riwayat Transaksi', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : transactions.isEmpty
              ? Center(
                  child: Text('No transactions found',
                      style: TextStyle(color: Colors.black54)))
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildTotalBalanceCard(),
                      _buildTransactionDataTable(),
                      Padding(padding: EdgeInsets.all(8.adaptSize))
                    ],
                  ),
                ),
    );
  }

  Widget _buildTotalBalanceCard() {
    return Card(
      margin: EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Total Balance',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54)),
            SizedBox(height: 8),
            FutureBuilder(
              future: LocalData.getData('point'),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SizedBox(
                      height: 100,
                      child: Center(child: CircularProgressIndicator()));
                } else if (snapshot.hasError) {
                  return Text("Failed to load data.",
                      style: TextStyle(color: Colors.redAccent));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text("There's no transaction.",
                      style: TextStyle(color: Colors.black87));
                }
                return Text(currencyFormatter.format(int.parse(snapshot.data!)),
                    style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black));
              },
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionDataTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        children: [
          DataTable(
            showCheckboxColumn: false,
            columnSpacing: 20,
            border: TableBorder(
              horizontalInside: BorderSide(width: 1, color: Colors.grey),
              verticalInside: BorderSide(width: 1, color: Colors.grey),
            ),
            columns: [
              DataColumn(
                  label: Text('Date',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Keterangan',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Pemasukan',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  numeric: true),
              DataColumn(
                  label: Text('Pengeluaran',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  numeric: true),
              DataColumn(
                  label: Text('Saldo',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  numeric: true),
              DataColumn(
                  label: Text('Status',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  numeric: true),
            ],
            rows: [
              for (int i = 0; i < transactions.length; i++) ...[
                () {
                  int index = i;
                  Map<String, dynamic> transaction = transactions[i];

                  bool isNegative = transaction["isNegative"];
                  int totalAmount = transaction["total_amount"];
                  int amount = i == 0
                      ? totalBalance
                      : transactions[i - 1]["total_amount"];

                  setState(() {
                    totalBalance = i == 0
                        ? amount
                        : transactions[i - 1]["isNegative"]
                            ? totalBalance + amount
                            : totalBalance - amount;
                  });

                  return DataRow(
                    onSelectChanged: (selected) {
                      if (selected != null && selected) {
                        if (isNegative) {
                          _showNegativeDialog(transaction['transaction_id']);
                        }
                      }
                    },
                    color: WidgetStateProperty.resolveWith<Color?>(
                      (Set<WidgetState> states) {
                        return index.isOdd ? Colors.grey[200] : Colors.white;
                      },
                    ),
                    cells: [
                      DataCell(Text(transaction["date"],
                          textAlign: TextAlign.right)),
                      DataCell(Text(transaction['keterangan'],
                          textAlign: TextAlign.right)),
                      DataCell(Text(
                        isNegative ? "" : currencyFormatter.format(totalAmount),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.green),
                      )),
                      DataCell(Text(
                        isNegative ? currencyFormatter.format(totalAmount) : "",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.red),
                      )),
                      DataCell(Text(
                        currencyFormatter.format(totalBalance),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.blue),
                      )),
                      DataCell(TransactionStatusIcon(
                        context,
                        transaction["status"],
                        isNegative,
                        transaction['is_delivery'].toString(),
                      )),
                    ],
                  );
                }()
              ]
            ],
          ),
        ],
      ),
    );
  }

  Widget TransactionStatusIcon(
      BuildContext context, String status, bool isNegative, String isDelivery) {
    IconData iconData;
    Color iconColor;

    switch (status) {
      case '0':
        iconData = Icons.check_circle;
        iconColor = Colors.green;
        break;
      case '1':
        iconData = Icons.store;
        iconColor = Colors.blue;
        break;
      case '2':
        iconData = Icons.local_shipping;
        iconColor = Colors.orange;
        break;
      case '3':
        iconData = Icons.done_all;
        iconColor = Colors.purple;
        break;
      default:
        iconData = Icons.help_outline;
        iconColor = Colors.grey;
        break;
    }

    void _showIconsDialog() {
      showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.adaptSize)),
            ),
            child: Stack(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width *
                      (isDelivery == '1' ? .8 : .6),
                  padding: EdgeInsets.symmetric(
                      vertical: 24.adaptSize, horizontal: 20.adaptSize),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.adaptSize),
                    gradient: LinearGradient(
                      colors: [Colors.white.withOpacity(0.95), Colors.white],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Status Transaksi",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 28.adaptSize,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 18.h),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 26,
                        runSpacing: 14,
                        children: [
                          _buildIcon('0', Icons.check_circle, Colors.green,
                              status, 'Berhasil'),
                          _buildIcon(
                              '1', Icons.store, Colors.blue, status, 'Ready'),
                          if (isDelivery == '1')
                            _buildIcon('2', Icons.local_shipping, Colors.orange,
                                status, 'Pengiriman'),
                          _buildIcon('3', Icons.done_all, Colors.purple, status,
                              'Selesai'),
                        ],
                      ),
                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: IconButton(
                    icon: Icon(Icons.close,
                        size: 28.adaptSize,
                        color: const Color.fromARGB(255, 0, 0, 0)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    return IconButton(
      icon: Icon(
        iconData,
        color: iconColor,
        size: 30.adaptSize,
      ),
      onPressed: isNegative ? _showIconsDialog : null,
    );
  }

  Widget _buildIcon(String iconStatus, IconData icon, Color color,
      String currentStatus, String title) {
    bool isActive = iconStatus == currentStatus;
    double size = isActive ? 64.adaptSize : 42.adaptSize;
    double shadowOffset = isActive ? 3.adaptSize : 2.adaptSize;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          children: [
            Positioned(
              left: shadowOffset,
              top: shadowOffset,
              child: Icon(
                icon,
                color: Colors.black26,
                size: size,
              ),
            ),
            Icon(
              icon,
              color: color,
              size: size,
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Text(
          title,
          style: TextStyle(
            fontSize: isActive ? 18 : 15,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _showNegativeDialog(String transactionId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            "Transaction",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          content: FutureBuilder<List<Map<String, dynamic>>>(
            future: _fetchTransactionItems(transactionId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SizedBox(
                  height: 100,
                  child: Center(child: CircularProgressIndicator()),
                );
              } else if (snapshot.hasError) {
                return Text(
                  "Failed to load data.",
                  style: TextStyle(color: Colors.redAccent),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Text(
                  "No items found for this transaction.",
                  style: TextStyle(color: Colors.black87),
                );
              }
              List<Map<String, dynamic>> transactionItems = snapshot.data!;
              print(transactionItems);
              return SizedBox(
                height: 400,
                width: double.maxFinite,
                child: ListView.builder(
                  itemCount: transactionItems.length,
                  itemBuilder: (context, index) {
                    final item = transactionItems[index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                "${API.BASE_URL}/images/${item['image_url']}",
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(Icons.image_not_supported,
                                      size: 60, color: Colors.grey);
                                },
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['product_name'],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "Qty: ${item['quantity']}",
                                    style: TextStyle(color: Colors.black54),
                                  ),
                                  SizedBox(height: 4),
                                  Text.rich(
                                    TextSpan(
                                      text: "Total: ",
                                      style: TextStyle(color: Colors.black87),
                                      children: [
                                        TextSpan(
                                          text:
                                              "${(double.parse(item['total_price'])).toInt()}",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.redAccent,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Close", style: TextStyle(color: Colors.blueAccent)),
            ),
          ],
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _fetchTransactionItems(
      String transactionId) async {
    try {
      final response = await http.get(Uri.parse(
          "${API.BASE_URL}/get_transactions_detail.php?transaction_id=$transactionId"));

      if (response.statusCode == 200) {
        dynamic jsonResponse = jsonDecode(response.body);

        if (jsonResponse is List) {
          return jsonResponse
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
        } else {
          throw Exception("Invalid response format: Expected a List.");
        }
      } else {
        throw Exception(
            "Failed to fetch transaction items, Status Code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching transaction items: $e");
      return [];
    }
  }
}
