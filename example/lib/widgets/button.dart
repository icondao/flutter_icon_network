import 'package:flutter/material.dart';

class AppSolidButton extends StatelessWidget {
  final String text;
  final Function onTap;
  final double width;
  final Color backgroundColor;

  const AppSolidButton(
      {Key key,
      this.text,
      this.onTap,
      this.width = 100,
      this.backgroundColor = Colors.blue})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(6),
        ),
        width: width,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}
