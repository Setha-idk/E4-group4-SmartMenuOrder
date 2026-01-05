import 'package:flutter/material.dart';
import 'package:group_project/consent/colors.dart';

// Reusable AppBar widget for the app
PreferredSizeWidget appbar() {
  return AppBar(
    title: const Text(
      'Smart Menu Order',
      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
    ),
    backgroundColor: maincolor,
    elevation: 2,
    centerTitle: true,
  );
}
