import 'package:flutter/material.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';

import '../../config/constants.dart';

class DefaultButton extends StatelessWidget {
  const DefaultButton({
    Key key,
    this.text,
    this.press,
  }) : super(key: key);
  final String text;
  final Function press;

  @override
  Widget build(BuildContext context) {
    double sizeUnit = SheepsTextStyle.sizeUnit(context).fontSize;

    return SizedBox(
      width: 320 * sizeUnit,
      height: 48 * sizeUnit,
      child: FlatButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8*sizeUnit)),
        color: kPrimaryColor,
        onPressed: press,
        child: Text(
          text,
          style: SheepsTextStyle.button1(context),
        ),
      ),
    );
  }
}
