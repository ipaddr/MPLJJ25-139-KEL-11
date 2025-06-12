import 'package:flutter/material.dart';
import 'package:smartschool2/public/utils/constant.dart';

class Skilton extends StatelessWidget {
  const Skilton({Key? key, this.height, this.width, this.decoration})
    : super(key: key);
  final height;
  final width;
  final decoration;
  @override
  Widget build(BuildContext context) {
    return Container(height: height, width: width, decoration: decoration);
  }
}
