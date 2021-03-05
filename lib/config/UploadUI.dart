import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/config/GlobalAsset.dart';

Widget UploadBody(BuildContext context, {
  @required File file,//사진파일
  @required Function cancelFileChangeFunc,//사진파일 변경 취소 함수
  String hintText = '',//업로드 버튼 위 설명
  @required Function cameraFunc,//카메라 탭 함수
  @required Function galleryFunc,//갤러리 탭 함수
  }){
  double sizeUnit = SheepsTextStyle.sizeUnit(context).fontSize;
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      file == null ?
      Align(
        alignment: Alignment.topCenter,
        child: Container(
          height: 200*sizeUnit,
          width:  200*sizeUnit,
          decoration: BoxDecoration(
              border: Border.all(color: Color(0xFFD1D1D1))
          ),
        ),
      ) :
      GestureDetector(
          child: Container(
            width: 200*sizeUnit,
            height: 200*sizeUnit,
            decoration: BoxDecoration(
                color: Color(0xFFEEEEEE),
                borderRadius: BorderRadius.all(Radius.circular(8*sizeUnit)),
                image: DecorationImage(
                    image: FileImage(file),
                    fit: BoxFit.cover)),
            child: Stack(
              children: [
                Positioned(
                    top: 6*sizeUnit,
                    right: 6*sizeUnit,
                    child: Container(
                      width: 16*sizeUnit,
                      height: 16*sizeUnit,
                      decoration: BoxDecoration(
                          color: Color(0xFF61C680), borderRadius: BorderRadius.circular(8*sizeUnit)),
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.only(left: 1*sizeUnit),
                          child: Container(
                            width: 10*sizeUnit,
                            height: 10*sizeUnit,
                            decoration: BoxDecoration(
                                color: Color(0xFF61C680),
                                borderRadius: BorderRadius.circular(5*sizeUnit)),
                            child:SvgPicture.asset(
                              svgTrashCan,
                              color: Colors.white,
                              height: 10*sizeUnit,
                            ),
                          ),
                        ),
                      ),
                    )
                )
              ],
            ),
          ),
          onTap: cancelFileChangeFunc,
      ),
      Row(
        children: [
          SizedBox(height: 40*sizeUnit),
        ],
      ),
      Text(
        hintText,
        style: SheepsTextStyle.b1(context),
        textAlign: TextAlign.center,
      ),
      SizedBox(height: 40*sizeUnit),
      GestureDetector(
        onTap: ()async{
          await SheepsBottomSheetForImg(context,cameraFunc: cameraFunc, galleryFunc: galleryFunc);
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
              '자료 업로드하기',
              style: SheepsTextStyle.button1(context),
            ),
          ),
        ),
      )
    ],
  );
}