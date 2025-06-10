import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'text_constant.dart';

class DialogConstant {
  static showToast(String message) {
    return Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
    );
  }

  static void alert(String message, {VoidCallback? function}) {
    showDialog(
      context: Get.context!,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 16,
          backgroundColor: Colors.white,
          child: AnimatedScale(
            scale: 1.1,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Add a subtle animation for the icon to make it more dynamic
                  AnimatedOpacity(
                    opacity: 1.0,
                    duration: Duration(milliseconds: 500),
                    child: Icon(
                      Icons.error_outline,
                      color: Colors.redAccent,
                      size: 60,
                    ),
                  ),
                  const SizedBox(height: 16),

                  AnimatedOpacity(
                    opacity: 1.0,
                    duration: Duration(milliseconds: 500),
                    child: Text(
                      message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[800],
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 5,
                      ),
                      child: Text(
                        'OKE',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        if (message.contains("tidak dapat diproses")) {
                          Navigator.pop(context);
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            "/detail_pesanan_page",
                            (Route<dynamic> route) => false,
                          );
                        } else {
                          if (function != null) {
                            function();
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static loading(BuildContext context, String text) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor: Colors.white,
          elevation: 10,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.grey[100],
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: LoadingTextAnimation(text: text),
          ),
        );
      },
    );
  }

// Alternatif dengan animasi yang lebih smooth
  static showConfirmDialog(
      String title, String message, VoidCallback callback) {
    showGeneralDialog(
      context: Get.context!,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black54,
      transitionDuration: Duration(milliseconds: 300),
      pageBuilder: (context, animation1, animation2) {
        return Container();
      },
      transitionBuilder: (context, animation1, animation2, child) {
        return Transform.scale(
          scale: animation1.value,
          child: Opacity(
            opacity: animation1.value,
            child: Dialog(
              elevation: 20,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header dengan gradient
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue.shade400,
                            Colors.blue.shade600,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.error_outline,
                              size: 35,
                              color: Colors.white,
                            ),
                          ),
                          if (title.isNotEmpty) ...[
                            SizedBox(height: 16),
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Content
                    Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        message,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade700,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    // Action buttons dengan style modern
                    Padding(
                      padding: EdgeInsets.fromLTRB(24, 0, 24, 24),
                      child: Row(
                        children: [
                          // Tombol Tidak
                          Expanded(
                            child: Container(
                              height: 48,
                              margin: EdgeInsets.only(right: 8),
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey.shade100,
                                  foregroundColor: Colors.grey.shade700,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  "Tidak",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Tombol Ya
                          Expanded(
                            child: Container(
                              height: 48,
                              margin: EdgeInsets.only(left: 8),
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  callback();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue.shade600,
                                  foregroundColor: Colors.white,
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  "Ya",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
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
        );
      },
    );
  }

  static alertMultipleOption(
      String title, String content, List<Widget> widgets, context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
              title: new Text(title),
              content: new Text(content),
              actions: widgets,
            ));
  }

  static showBottomSheet({BuildContext? context, Widget? child}) {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        context: context!,
        builder: (BuildContext bc) {
          return child!;
        });
  }

  static bottomSheetScrolled({BuildContext? context, Widget? child}) {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        backgroundColor: Colors.white,
        context: context!,
        isScrollControlled: true,
        builder: (BuildContext bc) {
          return DraggableScrollableSheet(
            initialChildSize: 0.4,
            minChildSize: 0.2,
            maxChildSize: 0.75,
            expand: false,
            builder: (context, scroll) {
              return child!;
            },
          );
        });
  }

  static showSnackBar(messages) {
    Get.snackbar('', messages,
        snackPosition: SnackPosition.BOTTOM,
        // backgroundColor: ColorConstant.white,
        snackStyle: SnackStyle.FLOATING,
        // borderColor: ColorConstant.primary2,
        borderWidth: 1,
        titleText: Container(),
        borderRadius: 1,
        messageText: Center(
          child: Text(
            messages,
            style: TextConstant.regular
                .copyWith(color: Colors.redAccent, fontSize: 12),
          ),
        ),
        margin: EdgeInsets.only(bottom: 70, left: 10, right: 10));
  }
}

class LoadingTextAnimation extends StatefulWidget {
  final String text;

  const LoadingTextAnimation({required this.text});

  @override
  _LoadingTextAnimationState createState() => _LoadingTextAnimationState();
}

class _LoadingTextAnimationState extends State<LoadingTextAnimation> {
  late String displayedText;
  late int currentIndex;
  late bool isAnimating;

  @override
  void initState() {
    super.initState();
    displayedText = '';
    currentIndex = 0;
    isAnimating = true;

    Future.delayed(Duration(milliseconds: 100), _startAnimation);
  }

  void _startAnimation() {
    if (isAnimating) {
      if (currentIndex < widget.text.length) {
        setState(() {
          displayedText += widget.text[currentIndex];
          currentIndex++;
        });
      } else {
        setState(() {
          displayedText = '';
          currentIndex = 0;
        });
      }

      Future.delayed(Duration(milliseconds: 200), _startAnimation);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFF135082)),
        ),
        SizedBox(height: 20),
        Text(
          displayedText,
          style: TextStyle(
            color: const Color(0xFF135082),
            fontSize: 18.0,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 10),
        // Padding(
        //   padding: const EdgeInsets.symmetric(horizontal: 20),
        //   child: LinearProgressIndicator(
        //     valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
        //     backgroundColor: Colors.teal[50],
        //   ),
        // ),
        SizedBox(height: 10),
      ],
    );
  }

  @override
  void dispose() {
    isAnimating = false;
    super.dispose();
  }
}
