import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';

class AuthSuccessPage extends StatefulWidget {
  Map<String, String> result;

  AuthSuccessPage({Key key, this.result, }) : super(key : key);

  @override
  _AuthSuccessPageState createState() => _AuthSuccessPageState();
}

class _AuthSuccessPageState extends State<AuthSuccessPage> {
  double sizeUnit = 1;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isNewMemeber = true;
  }

  @override
  Widget build(BuildContext context) {
    sizeUnit = SheepsTextStyle.sizeUnit(context).fontSize;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),//사용자 스케일팩터 무시
        child: Scaffold(
          body: SafeArea(
              child:
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 20*sizeUnit),
                    child: Text(
                      '본인인증 완료!',
                      style: SheepsTextStyle.h1(context),
                    ),
                  ),
                  SizedBox(
                      height: 20*sizeUnit
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 20*sizeUnit),
                    child: Text(
                      '스타트업을 위한 스타트업, 쉽스입니다.\n쉽스에서는 창업도 어렵지 않아요!',
                      style: SheepsTextStyle.b2(context),
                    ),
                  ),
                  SizedBox(
                    height: 72*sizeUnit,
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(100*sizeUnit, 0, 0, 0),
                    child: SvgPicture.asset(
                      'assets/images/LoginReg/sheepsBlendImageLogo.svg',
                      width: 290*sizeUnit,
                      height: 210*sizeUnit,
                    ),
                  ),
                ],
              )
          ),
          bottomNavigationBar: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                  width: 360*sizeUnit,
                  height: 60*sizeUnit,
                  color: hexToColor("#61C680"),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      "로그인 하기",
                      style: SheepsTextStyle.button1(context),
                    ),
                  ))
          ),
        ),
      ),
    );
  }
}
