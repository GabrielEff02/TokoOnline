import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyTextField extends StatefulWidget {
  final String? initialData;
  final String? title;
  final bool? prefixIcon;
  final TextEditingController? controller;
  final Icon icon;
  final String inputType;
  final int? maxLength;

  const MyTextField({
    Key? key,
    this.initialData,
    this.controller,
    this.title,
    this.prefixIcon = true,
    required this.icon,
    required this.inputType,
    this.maxLength,
  }) : super(key: key);

  @override
  _MyTextFieldState createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    if (widget.initialData != null) {
      _controller.text = widget.initialData!;
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            widget.title ?? "",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Colors.grey[100]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 3,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: TextField(
            controller: _controller,
            keyboardType: _getKeyboardType(),
            inputFormatters: _getInputFormatters(),
            maxLength: widget.maxLength,
            onChanged: (value) {
              // Cek jika title adalah "nama" atau "tempat lahir"
              if ((widget.title == "Nama" || widget.title == "Tempat Lahir") &&
                  RegExp(r'\d').hasMatch(value)) {
                // Jika ada angka, batalkan input dengan menghapus angka
                _controller.text = value.replaceAll(RegExp(r'\d'), '');
                _controller.selection = TextSelection.fromPosition(
                  TextPosition(offset: _controller.text.length),
                );
                // Tampilkan pesan error
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content:
                      Text('${widget.title} tidak boleh mengandung angka.'),
                ));
              } else {
                if (widget.inputType == "string") {
                  setState(() {
                    _controller.text = value.toUpperCase();
                    _controller.selection = TextSelection.fromPosition(
                      TextPosition(offset: _controller.text.length),
                    );
                  });
                }
              }
            },
            readOnly: widget.inputType == "date",
            onTap: () {
              if (widget.inputType == "date") {
                _selectDate(context);
              }
            },
            decoration: InputDecoration(
              counterText: "",
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.purple),
                borderRadius: BorderRadius.circular(15),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.transparent),
                borderRadius: BorderRadius.circular(15),
              ),
              border: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.transparent),
                borderRadius: BorderRadius.circular(15),
              ),
              hintText: "Masukkan ${widget.title ?? ''}",
              hintStyle: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
              prefixIcon: widget.prefixIcon == true ? widget.icon : null,
              filled: true,
              fillColor: Colors.transparent,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  TextInputType _getKeyboardType() {
    if (widget.inputType == "number") return TextInputType.number;
    return TextInputType.text;
  }

  List<TextInputFormatter> _getInputFormatters() {
    List<TextInputFormatter> formatters = [];
    if (widget.inputType == "number") {
      formatters.add(FilteringTextInputFormatter.digitsOnly);
    }
    if (widget.maxLength != null) {
      formatters.add(LengthLimitingTextInputFormatter(widget.maxLength));
    }
    if (widget.title == "Nama" ||
        widget.title == "Tempat Lahir" ||
        widget.title == "Pekerjaan") {
      formatters.add(FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')));
    }
    return formatters;
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(DateTime.now().year - 100),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _controller.text =
            "${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}";
      });
    }
  }
}
