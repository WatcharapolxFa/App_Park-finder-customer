import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../assets/colors/constant.dart';

@immutable
class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData iconData;
  final TextInputType keyboardType;
  final bool obscureText;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final FocusNode? focusNode;
  final List<TextInputFormatter>? inputFormatters;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.iconData,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.onChanged,
    this.validator,
    this.focusNode,
    this.inputFormatters,
  });

  @override
  CustomTextFieldState createState() => CustomTextFieldState();
}

class CustomTextFieldState extends State<CustomTextField> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    setState(() {}); // Rebuild widget when focus changes.
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color determineColor() =>
        _focusNode.hasFocus ? AppColor.appPrimaryColor : Colors.grey;

    return TextFormField(
      controller: widget.controller,
      onChanged: widget.onChanged,
      validator: widget.validator,
      keyboardType: widget.keyboardType,
      cursorColor: determineColor(),
      style: TextStyle(color: determineColor()),
      obscureText: widget.obscureText,
      focusNode: _focusNode,
      inputFormatters: widget.inputFormatters,
      decoration: InputDecoration(
        prefixIcon: Icon(widget.iconData, color: determineColor()),
        labelText: widget.label,
        labelStyle: TextStyle(color: determineColor()),
        border: const UnderlineInputBorder(),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColor.appPrimaryColor),
        ),
      ),
    );
  }
}
