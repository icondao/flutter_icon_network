import 'package:flutter/material.dart';

class AppSolidButton extends StatelessWidget {
  final String text;
  final Function onTap;

  const AppSolidButton({Key key, this.text, this.onTap}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(6),
        ),
        width: 100,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Text( text, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),),
      ),
    );
  }
}
