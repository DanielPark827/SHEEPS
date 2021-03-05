
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';

import '../../config/constants.dart';

class OnboardingContent extends StatelessWidget {
  const OnboardingContent({
    Key key,
    this.text,
    this.image,
  }) : super(key: key);
  final String text, image;

  @override
  Widget build(BuildContext context) {
    double sizeUnit = SheepsTextStyle.sizeUnit(context).fontSize;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(width: 4*sizeUnit,),
            SvgPicture.asset(
              image,
              height: 40 * sizeUnit,
              width: 40 * sizeUnit,
            ),
          ],
        ),
        SizedBox(height: 24*sizeUnit),
        Text(
          text,
          textAlign: TextAlign.start,
          style: SheepsTextStyle.h1(context),
        ),
        SizedBox(height: 20*sizeUnit),
        Text(
          "SHEEPS는 진짜 초기 스타트업들을 위한\n상생협업 플랫폼이에요!",
          style: SheepsTextStyle.b1(context),
        ),
      ],
    );
  }
}
