import 'package:project_skripsi/screen/gabriel/core/app_export.dart';
import 'package:project_skripsi/screen/gabriel/point_screen/point_cart_screen/point_cart_screen.dart';
import 'package:project_skripsi/screen/gabriel/request_item/request_item_screen/request_item_screen.dart';
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
      '/api/toko/get_request_item',
      {'username': await LocalData.getData('user')},
      {'Content-Type': 'application/json'},
      true,
      (result, error) {
        if (error != null &&
            error['error'] == true &&
            error['message'] == 'No data found') {
          completer.complete([]);
        } else if (result['error'] != true) {
          completer.complete(List<Map<String, dynamic>>.from(result['data']));
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
        title: Text('Daftar Permintaan Produk',
            style: TextStyle(color: Colors.white)),
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
            return ListView.builder(
              physics: AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(16),
              itemCount: data.length,
              itemBuilder: (context, index) {
                var product = data[index];
                return Card(
                  elevation: 4,
                  margin: EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: [Colors.white, Colors.grey.shade50],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.blueAccent.shade100,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  formatDate(product['REQUEST_DATE']),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue.shade800,
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(product['status']),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  product['status'],
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Text(
                            product['PRODUCT_NAME'],
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildInfoItem(
                                  'Jumlah',
                                  product['QUANTITY'].toString(),
                                  Icon(
                                    Icons.inventory_2_outlined,
                                    size: 16,
                                    color: Colors.green,
                                  ),
                                  Colors.green,
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: _buildInfoItem(
                                  'Point:',
                                  product['PRICE'] == 0
                                      ? '-'
                                      : _formatPrice(product['PRICE']),
                                  Container(),
                                  Colors.orange,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.business,
                                    size: 16, color: Colors.grey.shade600),
                                SizedBox(width: 8),
                                Text(
                                  'Cabang: ${product['compan_name'] ?? '-'}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 12),
                          product['status'] == 'Waiting'
                              ? Row(
                                  children: [
                                    // Tombol Tolak
                                    Expanded(
                                      child: Container(
                                        margin: EdgeInsets.only(right: 8),
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            // Aksi ketika tombol tolak ditekan
                                            DialogConstant.showConfirmDialog(
                                                'Apakah Anda Yakin?',
                                                'Apakah Anda yakin ingin untuk membatalkan produk "${product['PRODUCT_NAME']}"?',
                                                () => _handleAction(
                                                    'tolak', product));
                                          },
                                          icon: Icon(
                                            Icons.close,
                                            size: 18,
                                            color: Colors.white,
                                          ),
                                          label: Text(
                                            'Cancel',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            foregroundColor: Colors.white,
                                            elevation: 2,
                                            padding: EdgeInsets.symmetric(
                                                vertical: 12, horizontal: 16),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Tombol Terima
                                    Expanded(
                                      child: Container(
                                        margin: EdgeInsets.only(left: 8),
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            // Aksi ketika tombol terima ditekan
                                            DialogConstant.showConfirmDialog(
                                                'Apakah Anda Yakin?',
                                                'Apakah Anda yakin ingin untuk mengambil produk "${product['PRODUCT_NAME']}"?',
                                                () => _handleAction(
                                                    'terima', product));
                                          },
                                          icon: Icon(
                                            Icons.check,
                                            size: 18,
                                            color: Colors.white,
                                          ),
                                          label: Text(
                                            'Accept',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            foregroundColor: Colors.white,
                                            elevation: 2,
                                            padding: EdgeInsets.symmetric(
                                                vertical: 12, horizontal: 16),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Container(),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _handleAction(String action, var product) {
    if (action == 'terima') {
      LocalData.saveData('compan_code', product['compan_code']);
      Get.to(PointCartScreen(
          items: [
            {
              'request_id': product['REQUEST_ID'],
              'product_name': product['PRODUCT_NAME'],
              'quantity_selected': product['QUANTITY'],
              'price': (product['PRICE'] / product['QUANTITY']).toInt()
            }
          ],
          requestItem: true,
          callback: (result, error) async {
            if (result != null) {
              setState(() {
                futureData = getInitData();
              });
              await futureData;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(result['message']),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 2),
                ),
              );
            }
          }));
    } else {
      API.basePost(
          '/api/toko/reject_request',
          {'request_id': product['REQUEST_ID']},
          {'Content-Type': 'application/json'},
          true, (result, error) async {
        if (result != null) {
          setState(() {
            futureData = getInitData();
          });
          await futureData;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
        }
      });
    }
  }

  Widget _buildInfoItem(String label, String value, Widget icon, Color color) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              icon,
              SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }

// Helper function untuk warna status
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'waiting':
        return Colors.yellow;
      case 'approved by user':
      case 'approved':
        return Colors.green;
      case 'rejected':
      case 'ditolak':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

// Helper function untuk format harga
  String _formatPrice(dynamic price) {
    if (price == null || price == 0) return '0';
    return price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }
}
