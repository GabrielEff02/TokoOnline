import 'package:project_skripsi/api/api.dart';
import 'package:project_skripsi/constant/dialog_constant.dart';
import 'package:project_skripsi/utils/local_data.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddressListScreen extends StatefulWidget {
  @override
  _AddressListScreenState createState() => _AddressListScreenState();
}

class _AddressListScreenState extends State<AddressListScreen> {
  List<Map<String, dynamic>> addresses = [];
  int selectedAddressID = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getAddressData();
    });
  }

  Future<void> getAddressData() async {
    DialogConstant.loading(context, "Loading");

    String? addressData = await LocalData.getData("address");
    selectedAddressID = int.tryParse(addressData) ?? 0;

    await API.basePost(
      "/address.php",
      {"username": await LocalData.getData("user")},
      {'Content-Type': 'application/json'},
      true,
      (result, error) {
        if (result != null && result['error'] != true) {
          setState(() {
            addresses = List<Map<String, dynamic>>.from(result['data']);
          });
        } else {
          DialogConstant.alert(error.toString());
        }
      },
    );

    Get.back();
  }

  void _confirmSetDefault(int addressID) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Konfirmasi"),
        content: Text(
            "Apakah Anda yakin ingin menjadikan alamat ini sebagai default?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                selectedAddressID = addressID;
                LocalData.saveData("address", addressID.toString());
              });
              Navigator.pop(context);
            },
            child: Text("Ya"),
          ),
        ],
      ),
    );
  }

  void _addAddress() {
    // showDialog(
    //   context: context,
    //   builder: (context) {
    //     return AlertDialog(
    //       title: Text('Tambah Alamat Baru'),
    //       content: Column(
    //         mainAxisSize: MainAxisSize.min,
    //         children: [
    //           TextField(decoration: InputDecoration(labelText: 'Alamat')),
    //           TextField(decoration: InputDecoration(labelText: 'Keterangan')),
    //           TextField(decoration: InputDecoration(labelText: 'Kota')),
    //           TextField(decoration: InputDecoration(labelText: 'Provinsi')),
    //           TextField(decoration: InputDecoration(labelText: 'Kode Pos')),

    //         ],
    //       ),
    //       actions: [
    //         TextButton(
    //           onPressed: () => Navigator.pop(context),
    //           child: Text('Batal'),
    //         ),
    //         ElevatedButton(
    //           onPressed: () {
    //             Navigator.pop(context);
    //           },
    //           child: Text('Simpan'),
    //         ),
    //       ],
    //     );
    //   },
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Alamat'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: addresses.isNotEmpty
                  ? ListView.builder(
                      itemCount: addresses.length,
                      itemBuilder: (context, index) {
                        final address = addresses[index];
                        int addressID = int.parse(address['address_id']);

                        return Card(
                          elevation: 3,
                          margin: EdgeInsets.only(bottom: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: RadioListTile<int>(
                            value: addressID,
                            groupValue: selectedAddressID,
                            onChanged: (value) => _confirmSetDefault(value!),
                            title: Text(
                              address['address'],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            secondary: IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {},
                            ),
                          ),
                        );
                      },
                    )
                  : Container(),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addAddress,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Tambah Alamat Baru',
                      style: TextStyle(fontSize: 16, color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
