import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';

Widget UploadCompleteBody(BuildContext context, {
  @required File file,//사진파일
  }){
  double sizeUnit = SheepsTextStyle.sizeUnit(context).fontSize;
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Container(
        height: 200*sizeUnit,
        width:  200*sizeUnit,
        decoration: BoxDecoration(
            border: Border.all(color: Color(0xFFD1D1D1)),
            image: DecorationImage(
                image: FileImage(file),
                fit: BoxFit.cover)
        ),
      ),
      Row(
        children: [
          SizedBox(height: 40*sizeUnit),
        ],
      ),
      Text(
        '업로드 완료!\n빠르게 검토해드릴게요.',
        style: SheepsTextStyle.b1(context),
        textAlign: TextAlign.center,
      ),
      SizedBox(height: 40*sizeUnit),
      GestureDetector(
        onTap: (){
          Navigator.pop(context);
        },
        child: Container(
          width:320*sizeUnit,
          height: 48*sizeUnit,
          decoration: BoxDecoration(
            color: Color(0xFF61C680),
            borderRadius: new BorderRadius.circular(8*sizeUnit),
          ),
          child: Align(
            alignment: Alignment.center,
            child: Text(
              '돌아가기',
              style: SheepsTextStyle.button1(context),
            ),
          ),
        ),
      )
    ],
  );
}