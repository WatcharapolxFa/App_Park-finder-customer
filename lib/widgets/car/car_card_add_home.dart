import 'package:flutter/material.dart';

Widget carCardAddHome() {
  return Container(
    height: 104,
    padding: const EdgeInsets.all(2),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: const BorderRadius.all(Radius.circular(10)),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.5),
          spreadRadius: 2,
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: const Row(
      children: [
        Expanded(
            child: Icon(
          Icons.add,
          size: 60,
        )),
      ],
    ),
  );
}
