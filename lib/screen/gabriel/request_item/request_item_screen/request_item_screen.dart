import 'package:project_skripsi/api/api.dart';
import 'package:project_skripsi/constant/dialog_constant.dart';
import 'package:project_skripsi/utils/local_data.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:flutter/services.dart';

class RequestedItemScreen extends StatefulWidget {
  @override
  _RequestedItemScreenState createState() => _RequestedItemScreenState();
}

class _RequestedItemScreenState extends State<RequestedItemScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<Offset> _slideCardAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
    _opacityAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _slideAnimation = Tween<Offset>(begin: Offset(0.0, 0.1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _slideCardAnimation = Tween<Offset>(
            begin: Offset(-0.5, 0.0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _quantityController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _submitForm() async {
    final name = await LocalData.getData('user');
    if (_formKey.currentState!.validate()) {
      final data = {
        'product_name': _productNameController.text,
        'quantity': int.parse(_quantityController.text),
        'username': name
      };
      var header = <String, String>{};

      header['Content-Type'] = 'application/json';
      DialogConstant.loading(context, 'Loading...');
      Future.delayed(Duration(seconds: 2), () {
        API.basePost('/request_item.php', data, header, true, (result, error) {
          Get.back();
          if (error != null) {
            DialogConstant.alert('Request Item Failed');
          }
          if (result != null) {
            Alert(
              context: context,
              type: AlertType.success,
              title: "Success",
              desc: "Requested Item Submitted Successfully!",
              buttons: [
                DialogButton(
                  child: Text(
                    "OK",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  onPressed: () {
                    Get.back();
                    Get.back();
                  },
                  color: Color(0xFF42A5F5), // Blue accent for success
                  radius: BorderRadius.circular(10.0),
                ),
              ],
            ).show();
          }
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Requested Item Form',
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.w600,
            color: Colors.white, // White color for the title
          ),
        ),
        backgroundColor: Color(0xFF42A5F5), // Soft blue header
        elevation: 0,
      ),
      body: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: Container(
            color: Colors.white, // White background for the entire screen
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  SlideTransition(
                    position: _slideCardAnimation,
                    child: Card(
                      elevation: 10, // Added shadow to the card
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      color: Colors.white, // White color for the form card
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: TextFormField(
                          controller: _productNameController,
                          decoration: InputDecoration(
                            labelText: 'Product Name',
                            labelStyle: TextStyle(color: Colors.black54),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            floatingLabelBehavior: FloatingLabelBehavior
                                .never, // Label disappears when focused
                            prefixIcon: Icon(
                              Icons.production_quantity_limits,
                              color: Color(
                                  0xFF42A5F5), // Blue icon for consistency
                            ),
                          ),
                          style: TextStyle(color: Colors.black87),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the product name';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  SlideTransition(
                    position: _slideCardAnimation,
                    child: Card(
                      elevation: 10, // Added shadow to the card
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      color: Colors.white, // White color for the form card
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: TextFormField(
                          controller: _quantityController,
                          decoration: InputDecoration(
                            labelText: 'Quantity',
                            labelStyle: TextStyle(color: Colors.black54),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            floatingLabelBehavior: FloatingLabelBehavior
                                .never, // Label disappears when focused
                            prefixIcon: Icon(
                              Icons.format_list_numbered,
                              color: Color(
                                  0xFF42A5F5), // Blue icon for consistency
                            ),
                          ),
                          keyboardType:
                              TextInputType.number, // Numeric keyboard
                          inputFormatters: [
                            FilteringTextInputFormatter
                                .digitsOnly, // Restrict input to digits only
                          ],
                          style: TextStyle(color: Colors.black87),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the quantity';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Quantity must be a number';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  SlideTransition(
                    position: _slideCardAnimation,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF42A5F5), // Blue button
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 5,
                        textStyle: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      onPressed: _submitForm,
                      child: Text('Submit'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
