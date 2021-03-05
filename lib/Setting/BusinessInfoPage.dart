import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/config/GlobalAsset.dart';

class BusinessInfoPage extends StatelessWidget {

  double sizeUnit = 1;

  @override
  Widget build(BuildContext context) {
    sizeUnit = SheepsTextStyle.sizeUnit(context).fontSize;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),//사용자 스케일팩터 무시
        child: Container(
          color: Colors.white,
          child: SafeArea(
            child: Scaffold(
              backgroundColor: Colors.white,
              appBar: SheepsAppBar(context, '사업자 정보'),
              body: Padding(
                padding: EdgeInsets.fromLTRB(20*sizeUnit, 0, 20*sizeUnit, 0),
                child: Column(
                  children: [
                    SizedBox(height: 40*sizeUnit),
                    SvgPicture.asset(svgSheepsGreenImageLogo, width: 100*sizeUnit, height: 100*sizeUnit),
                    SizedBox(height: 12*sizeUnit,),
                    SvgPicture.asset(svgSheepsGreenWriteLogo, width: 150*sizeUnit, height: 28*sizeUnit),
                    SizedBox(height: 24*sizeUnit),
                    Row(
                      children: [
                        Container(
                            width: 56*sizeUnit,
                            child: Text('회사명', textAlign: TextAlign.left, style: TextStyle(fontSize: screenWidth * 12/360, fontWeight: FontWeight.bold),),
                        ),
                        SizedBox(width: screenWidth * 12/360,),
                        Container(
                            child: Text('주식회사 쉽스', style: TextStyle(fontSize: screenWidth * 12/360),),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          width: screenWidth * 56/360,
                          child: Text('등록 번호', textAlign: TextAlign.left, style: TextStyle(fontSize: screenWidth * 12/360, fontWeight: FontWeight.bold),),
                        ),
                        SizedBox(width: screenWidth * 12/360,),
                        Container(
                          child: Text('184-86-01811', style: TextStyle(fontSize: screenWidth * 12/360),),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          width: screenWidth * 56/360,
                          child: Text('대표자', textAlign: TextAlign.left, style: TextStyle(fontSize: screenWidth * 12/360, fontWeight: FontWeight.bold),),
                        ),
                        SizedBox(width: screenWidth * 12/360,),
                        Container(
                          child: Text('허재혁', style: TextStyle(fontSize: screenWidth * 12/360),),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          width: screenWidth * 56/360,
                          child: Text('개업년월일', textAlign: TextAlign.left, style: TextStyle(fontSize: screenWidth * 12/360, fontWeight: FontWeight.bold),),
                        ),
                        SizedBox(width: screenWidth * 12/360,),
                        Container(
                          child: Text('2020년 07월 31일', style: TextStyle(fontSize: screenWidth * 12/360),),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          width: screenWidth * 56/360,
                          child: Text('사업 종류', textAlign: TextAlign.left, style: TextStyle(fontSize: screenWidth * 12/360, fontWeight: FontWeight.bold),),
                        ),
                        SizedBox(width: screenWidth * 12/360,),
                        Container(
                          child: Text('서비스업', style: TextStyle(fontSize: screenWidth * 12/360),),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          width: screenWidth * 56/360,
                          child: Text('주소', textAlign: TextAlign.left, style: TextStyle(fontSize: screenWidth * 12/360, fontWeight: FontWeight.bold),),
                        ),
                        SizedBox(width: screenWidth * 12/360,),
                        Container(
                          child: Text('인천광역시 미추홀구 재넘이길 133-2, 206호', style: TextStyle(fontSize: screenWidth * 12/360),),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          width: screenWidth * 56/360,
                          child: Text('고객 센터', textAlign: TextAlign.left, style: TextStyle(fontSize: screenWidth * 12/360, fontWeight: FontWeight.bold),),
                        ),
                        SizedBox(width: screenWidth * 12/360,),
                        Container(
                          child: Text('070-7794-1468', style: TextStyle(fontSize: screenWidth * 12/360),),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
