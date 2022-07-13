
import 'package:flutter/material.dart';

class CameraCover extends StatelessWidget {
  final color;
  const CameraCover({
    Key? key,
    MaterialColor? this.color = Colors.grey,
  }) : super(key: key);

  @override
  Widget build(BuildContext) {
    return Container(
      child: Icon(
          Icons.quick_contacts_dialer_sharp, size: 100, color: this.color,),
      decoration: ShapeDecoration(
          shape: Border.all(width: 2, color: Colors.purple)),
    );
  }
}
