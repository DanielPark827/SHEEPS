import 'dart:convert';

import 'package:cupertino_will_pop_scope/cupertino_will_pop_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/network/ApiProvider.dart';
import 'package:sheeps_app/registration/PhoneNumberAuthPage.dart';
import 'package:sheeps_app/registration/model/RegistrationModel.dart';

class RegistrationSuccessPage extends StatefulWidget {
  Map<String, String> result;

  RegistrationSuccessPage({Key key, this.result, }) : super(key : key);

  @override
  _RegistrationSuccessPageState createState() => _RegistrationSuccessPageState();
}

class _RegistrationSuccessPageState extends State<RegistrationSuccessPage> {
  double sizeUnit = 1;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    sizeUnit = SheepsTextStyle.sizeUnit(context).fontSize;
    return ConditionalWillPopScope(
      shouldAddCallbacks: true,
      onWillPop: null,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
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
                          '회원가입 완료!',
                          style: SheepsTextStyle.h1(context),
                        ),
                      ),
                      SizedBox(
                        height: 20*sizeUnit
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 20*sizeUnit),
                        child: Text(
                          '이제 본인인증만 진행하면,\n모든 서비스 이용이 가능해요!',
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
                Navigator.pushReplacement(context, MaterialPageRoute(
                  builder: (context) => PhoneNumberAuthPage(),
                ));
              },
              child: Container(
                  width: 360*sizeUnit,
                  height: 60*sizeUnit,
                  color: hexToColor("#61C680"),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      "본인인증 하기",
                      style: SheepsTextStyle.button1(context),
                    ),
                  ))
          ),
          ),
        ),
      ),
    );
  }
}
