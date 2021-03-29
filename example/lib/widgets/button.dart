import 'package:flutter/material.dart';

class AppSolidButton extends StatelessWidget {
  final String text;
  final Function onTap;
  final double width;
  final Color backgroundColor;
  final bool isEnable;

  const AppSolidButton(
      {Key key,
      this.text,
      this.onTap,
      this.width = 100,
      this.backgroundColor = Colors.blue, this.isEnable = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isEnable ? 1 : 0.5,
      child: GestureDetector(
        onTap: () {
          if(isEnable) {
            onTap();
          }
        },
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
      ),
    );
  }
}
