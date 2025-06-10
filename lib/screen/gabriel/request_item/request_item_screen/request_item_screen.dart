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
  late AnimationController _bounceController;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<Offset> _slideCardAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );
    _bounceController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    _opacityAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _slideAnimation = Tween<Offset>(begin: Offset(0.0, 0.2), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _slideCardAnimation =
        Tween<Offset>(begin: Offset(-0.3, 0.0), end: Offset.zero).animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _bounceAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
        CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _quantityController.dispose();
    _controller.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    _bounceController.forward().then((_) => _bounceController.reverse());

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
        API.basePost('/api/toko/request_item', data, header, true,
            (result, error) {
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
                  onPressed: () {
                    Get.back();
                    Get.back();
                  },
                  color: Color(0xFF4CAF50),
                  radius: BorderRadius.circular(10.0),
                  child: Text(
                    "OK",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _opacityAnimation,
                  child: Container(
                    padding: EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: () => Get.back(),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Request Item',
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Fill out the form below',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Form Content
              Expanded(
                child: SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _opacityAnimation,
                    child: Container(
                      margin: EdgeInsets.only(top: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                        child: Form(
                          key: _formKey,
                          child: ListView(
                            padding: EdgeInsets.all(24),
                            children: [
                              // Product Name Field
                              SlideTransition(
                                position: _slideCardAnimation,
                                child: ScaleTransition(
                                  scale: _scaleAnimation,
                                  child: Container(
                                    margin: EdgeInsets.only(bottom: 24),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.1),
                                          blurRadius: 20,
                                          offset: Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: TextFormField(
                                      controller: _productNameController,
                                      decoration: InputDecoration(
                                        labelText: 'Nama Produk',
                                        labelStyle: GoogleFonts.poppins(
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w500,
                                        ),
                                        hintText:
                                            'Contoh: MacBook Pro, iPhone 13',
                                        hintStyle: GoogleFonts.poppins(
                                          color: Colors.grey[400],
                                          fontSize: 14,
                                        ),
                                        prefixIcon: Container(
                                          margin: EdgeInsets.all(12),
                                          padding: EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Color(0xFF667eea),
                                                Color(0xFF764ba2)
                                              ],
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Icon(
                                            Icons.inventory_2,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          borderSide: BorderSide.none,
                                        ),
                                        filled: true,
                                        fillColor: Colors.grey[50],
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 20,
                                        ),
                                      ),
                                      style: GoogleFonts.poppins(
                                        color: Colors.grey[800],
                                        fontWeight: FontWeight.w500,
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Harap mengisi Nama Produk';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ),
                              ),

                              // Quantity Field
                              SlideTransition(
                                position: _slideCardAnimation,
                                child: ScaleTransition(
                                  scale: _scaleAnimation,
                                  child: Container(
                                    margin: EdgeInsets.only(bottom: 32),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.1),
                                          blurRadius: 20,
                                          offset: Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: TextFormField(
                                      controller: _quantityController,
                                      decoration: InputDecoration(
                                        labelText: 'Quantity',
                                        labelStyle: GoogleFonts.poppins(
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w500,
                                        ),
                                        hintText: 'Contoh: 1, 5, 10',
                                        hintStyle: GoogleFonts.poppins(
                                          color: Colors.grey[400],
                                          fontSize: 14,
                                        ),
                                        prefixIcon: Container(
                                          margin: EdgeInsets.all(12),
                                          padding: EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Color(0xFF667eea),
                                                Color(0xFF764ba2)
                                              ],
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Icon(
                                            Icons.numbers,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          borderSide: BorderSide.none,
                                        ),
                                        filled: true,
                                        fillColor: Colors.grey[50],
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 20,
                                        ),
                                      ),
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      style: GoogleFonts.poppins(
                                        color: Colors.grey[800],
                                        fontWeight: FontWeight.w500,
                                      ),
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

                              // Submit Button
                              SlideTransition(
                                position: _slideCardAnimation,
                                child: ScaleTransition(
                                  scale: _bounceAnimation,
                                  child: Container(
                                    width: double.infinity,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(0xFF667eea),
                                          Color(0xFF764ba2)
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color(0xFF667eea)
                                              .withOpacity(0.4),
                                          blurRadius: 20,
                                          offset: Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                      ),
                                      onPressed: _submitForm,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.send_rounded,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                          SizedBox(width: 12),
                                          Text(
                                            'Submit Request',
                                            style: GoogleFonts.poppins(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(height: 20),

                              // Footer Info
                              SlideTransition(
                                position: _slideCardAnimation,
                                child: Container(
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[50],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.blue[100]!,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        color: Colors.blue[600],
                                        size: 20,
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          'Your request will be reviewed by our team within 24 hours.',
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            color: Colors.blue[700],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
