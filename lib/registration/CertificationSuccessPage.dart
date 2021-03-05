import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/GlobalAsset.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/registration/RegistrationSuccessPage.dart';
class CertificationSuccessPage extends StatefulWidget {
  Map<String, String> result;

  @override
  _CertificationSuccessPageState createState() => _CertificationSuccessPageState();
}

class _CertificationSuccessPageState extends State<CertificationSuccessPage> {
  double sizeUnit = 1;
  @override
  Widget build(BuildContext context) {
    sizeUnit = SheepsTextStyle.sizeUnit(context).fontSize;
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),//사용자 스케일팩터 무시
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: new AppBar(
          backgroundColor: hexToColor("#FFFFFF"),
          elevation: 0.0,
          centerTitle: true,
          title: Text('본인인증하기',
            style: SheepsTextStyle.appBar(context),
          ),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: SvgPicture.asset(
                'assets/images/Public/GreenCheckIcon.svg',
                height: 100*sizeUnit,
                width: 100*sizeUnit,
              ),
            ),
            SizedBox(height: 60*sizeUnit),
            Text(
              '본인인증이\n완료되었습니다.',
              textAlign: TextAlign.center,
              style: SheepsTextStyle.h1(context)
            ),
            SizedBox(height: 20*sizeUnit),
            Text(
              '쉽스와 즐거운 스타트업 생활이 되세요',
              style: SheepsTextStyle.b3(context)
            ),
            SizedBox(height: 60*sizeUnit),
          ],
        ),
        bottomNavigationBar: GestureDetector(
          onTap: () async {
            Navigator.push(
                context, // 기본 파라미터, SecondRoute로 전달
                MaterialPageRoute(builder: (context) => RegistrationSuccessPage()));
          },
          child: Container(
              height: 60*sizeUnit,
              width: 360*sizeUnit,
              decoration: BoxDecoration(
                color: hexToColor("#61C680"),
              ),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  '확인',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenHeight*0.025,
                  ),
                ),
              )
          ),
        ),
      ),
    );
  }
}
