import 'dart:convert';
import 'package:project_skripsi/screen/gabriel/core/app_export.dart';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> transactions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTransactions();
  }

  NumberFormat currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  Future<void> fetchTransactions() async {
    try {
      final String username = await LocalData.getData('user');
      final String apiUrl =
          "${API.BASE_URL}/api/toko/get_transactions?username=$username";

      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        final List<Map<String, dynamic>> transactionsData =
            List<Map<String, dynamic>>.from(data['data']);
        setState(() {
          transactions = transactionsData.map((item) {
            return {
              "transaction_id": item["transaction_id"],
              "date": item["transaction_date"],
              "total_amount": item["total_amount"] is String
                  ? (double.parse(item["total_amount"])).toInt()
                  : item["total_amount"].toInt(),
              "status": item['status'].toString(),
              "is_delivery": item['is_delivery'].toString(),
              "address": item['address'],
              "compan_name": item['compan_name'],
              "driver_id": item['driver_id'],
              "driver_name": item['driver_name'],
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

  String _getStatusText(String status) {
    switch (status) {
      case '0':
        return 'Prepare';
      case '1':
        return 'Ready';
      case '2':
        return 'Diantar';
      case '3':
        return 'Selesai';
      default:
        return 'Unknown';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case '0':
        return Colors.orange;
      case '1':
        return Colors.blue;
      case '2':
        return Colors.green;
      case '3':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case '0':
        return Icons.pending_actions;
      case '1':
        return Icons.check_circle_outline;
      case '2':
        return Icons.local_shipping;
      case '3':
        return Icons.done_all;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Riwayat Transaksi',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20)),
        backgroundColor: Colors.indigo[600],
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.indigo[600]!),
                  ),
                  SizedBox(height: 16),
                  Text('Memuat riwayat transaksi...',
                      style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            )
          : transactions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long,
                          size: 80, color: Colors.grey[400]),
                      SizedBox(height: 16),
                      Text('Belum ada transaksi',
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500)),
                      SizedBox(height: 8),
                      Text('Riwayat transaksi Anda akan muncul di sini',
                          style: TextStyle(color: Colors.grey[500])),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: fetchTransactions,
                  color: Colors.indigo[600],
                  child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      return _buildTransactionCard(transactions[index], index);
                    },
                  ),
                ),
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> transaction, int index) {
    String status = transaction['status'];
    String isDelivery = transaction['is_delivery'];
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () =>
            _showTransactionDetail(transaction['transaction_id'].toString()),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [Colors.white, Colors.grey[50]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Transaction ID
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.indigo[50],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.indigo[100]!),
                    ),
                    child: Text(
                      '#${transaction['transaction_id']}',
                      style: TextStyle(
                        color: Colors.indigo[700],
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  // Status
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: _getStatusColor(status).withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getStatusIcon(status),
                          size: 16,
                          color: _getStatusColor(status),
                        ),
                        SizedBox(width: 4),
                        Text(
                          _getStatusText(status),
                          style: TextStyle(
                            color: _getStatusColor(status),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16),

              // Company Name
              Row(
                children: [
                  Icon(Icons.store, color: Colors.grey[600], size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      transaction['compan_name'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12),

              // Delivery Type & Address
              Row(
                children: [
                  Icon(
                    isDelivery == '1'
                        ? Icons.delivery_dining
                        : Icons.store_mall_directory,
                    color: Colors.grey[600],
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isDelivery == '1' ? 'Delivery' : 'Pickup',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        if (isDelivery == '1')
                          Text(
                            transaction['address'],
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16),

              if (status == '2')
                Row(
                  children: [
                    Icon(Icons.person, color: Colors.grey[600], size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        transaction['driver_name'] ?? '-',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                  ],
                ),

              SizedBox(height: 12),
              // Bottom Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Date
                  Row(
                    children: [
                      Icon(Icons.access_time,
                          color: Colors.grey[500], size: 16),
                      SizedBox(width: 4),
                      Text(
                        _formatDate(transaction['date']),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  // Amount
                  Text(
                    currencyFormatter.format(transaction['total_amount']),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              if (isDelivery == '1') ...[
                SizedBox(height: 16),
                _buildProgressIndicator(status),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(String currentStatus) {
    List<Map<String, dynamic>> deliverySteps = [
      {'status': '0', 'label': 'Prepare', 'icon': Icons.pending_actions},
      {'status': '1', 'label': 'Ready', 'icon': Icons.check_circle_outline},
      {'status': '2', 'label': 'Diantar', 'icon': Icons.local_shipping},
      {'status': '3', 'label': 'Selesai', 'icon': Icons.done_all},
    ];

    int currentIndex =
        deliverySteps.indexWhere((step) => step['status'] == currentStatus);

    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: deliverySteps.asMap().entries.map((entry) {
          int index = entry.key;
          Map<String, dynamic> step = entry.value;
          bool isActive = index <= currentIndex;
          bool isCurrent = index == currentIndex;

          return Expanded(
            child: Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isActive
                        ? _getStatusColor(step['status'])
                        : Colors.grey[300],
                    shape: BoxShape.circle,
                    boxShadow: isCurrent
                        ? [
                            BoxShadow(
                              color: _getStatusColor(step['status'])
                                  .withOpacity(0.3),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    step['icon'],
                    color: isActive ? Colors.white : Colors.grey[600],
                    size: 18,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  step['label'],
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                    color: isActive
                        ? _getStatusColor(step['status'])
                        : Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  String _formatDate(String dateTime) {
    try {
      DateTime parsedDate = DateTime.parse(dateTime);
      return DateFormat('dd MMM yyyy, HH:mm').format(parsedDate);
    } catch (e) {
      return dateTime;
    }
  }

  void _showTransactionDetail(String transactionId) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.7),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.indigo[600],
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Detail Transaksi",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                // Content
                Flexible(
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: _fetchTransactionItems(transactionId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container(
                          height: 200,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.indigo[600]!),
                                ),
                                SizedBox(height: 16),
                                Text("Memuat detail...",
                                    style: TextStyle(color: Colors.grey[600])),
                              ],
                            ),
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Container(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Icon(Icons.error_outline,
                                  size: 48, color: Colors.red[400]),
                              SizedBox(height: 16),
                              Text(
                                "Gagal memuat detail transaksi",
                                style: TextStyle(color: Colors.red[600]),
                              ),
                            ],
                          ),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Container(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Icon(Icons.inbox,
                                  size: 48, color: Colors.grey[400]),
                              SizedBox(height: 16),
                              Text(
                                "Tidak ada item dalam transaksi ini",
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        );
                      }

                      List<Map<String, dynamic>> transactionItems =
                          snapshot.data!;
                      return ListView.builder(
                        padding: EdgeInsets.all(16),
                        shrinkWrap: true,
                        itemCount: transactionItems.length,
                        itemBuilder: (context, index) {
                          final item = transactionItems[index];
                          return _buildItemCard(item);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildItemCard(Map<String, dynamic> item) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Image.network(
                  "${API.BASE_URL}/img/gambar_produk/${item['url']}",
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.image_not_supported,
                        size: 30, color: Colors.grey[500]);
                  },
                ),
              ),
            ),
            SizedBox(width: 12),
            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['nama'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.grey[800],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: Text(
                          "Qty: ${item['quantity']}",
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                  Text(
                    currencyFormatter
                        .format((double.parse(item['total_price'])).toInt()),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchTransactionItems(
      String transactionId) async {
    try {
      final response = await http.get(Uri.parse(
          "${API.BASE_URL}/api/toko/get_transactions_detail?transaction_id=$transactionId"));

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
