import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sheeps_app/Setting/model/Banner.dart';
import 'package:sheeps_app/chat/models/ChatDatabase.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/config/constants.dart';
import 'package:sheeps_app/network/ApiProvider.dart';
import 'package:sheeps_app/network/SocketProvider.dart';
import 'package:sheeps_app/notification/models/NotiDatabase.dart';
import 'package:sheeps_app/onboarding/OnboardingScreen.dart';
import 'package:sheeps_app/registration/LoginSelectPage.dart';
import 'package:sheeps_app/login/LoginPage.dart';
import 'package:sheeps_app/config/GlobalAsset.dart';


class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    try{
      (() async {
        // ignore: invalid_use_of_visible_for_testing_member
        //SharedPreferences.setMockInitialValues({});
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        bool res = prefs.getBool('IfNewUser');

        // if(!kReleaseMode){
        //   NotiDBHelper().dropTable();
        //   ChatDBHelper().dropTable();
        // }

        //client에서 시작전 세팅되어야 할 데이터
        setClientBannerData();

        if(res == null) {
          Timer(Duration(seconds: 1), () {
            Navigator.pushReplacement(context, MaterialPageRoute(
                builder: (context) => OnboardingScreen()
            )
            );
          });
        } else if(res){
          bool res = prefs.getBool('autoLoginKey');

          screenWidth = MediaQuery.of(context).size.width;
          screenHeight = MediaQuery.of(context).size.height;

          // ignore: unnecessary_statements
          SocketProvider provider = Provider.of<SocketProvider>(context, listen: false);

          if(res == false) {
            Timer(Duration(seconds: 1), () {
              Navigator.pushReplacement(
                  context, // 기본 파라미터, SecondRoute로 전달
                  MaterialPageRoute(
                      builder: (context) =>
                          LoginSelectPage()) // SecondRoute를 생성하여 적재
              );
            });
          } else {
            String isSocial = prefs.getString('socialLogin');

            dynamic result;
            String id = '';
            String pw = '';
            if(isSocial == '0'){
              id = prefs.getString('autoLoginId');
              pw = prefs.getString('autoLoginPw');

              String loginURL = !kReleaseMode ? '/Profile/Personal/DebugLogin' : '/Profile/Personal/Login';

              result = await ApiProvider().post(loginURL, jsonEncode(
                  {
                    "id": id,
                    "password": pw,
                  }
              ));
            } else if(isSocial == '1'){
              id = prefs.getString('autoLoginId');
              pw = prefs.getString('autoLoginPw');

              result = await ApiProvider().post('/Profile/SocialLogin', jsonEncode(
                  {
                    "id" : id,
                    "name" : pw,
                    "social" : 1
                  }
              ));
            }else{
              id = prefs.getString('autoLoginAppleId');
              pw = prefs.getString('autoLoginApplePw');

              result = await ApiProvider().post('/Profile/SocialLogin', jsonEncode(
                  {
                    "id" : id,
                    "name" : pw,
                    "social" : 2
                  }
              ));
            }

            if(result == null || result['result'] == null){
              final SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setBool('autoLoginKey',false);
              prefs.setString('autoLoginId', null);
              prefs.setString('autoLoginPw', null);

              Fluttertoast.showToast(msg: "로그인 정보가 올바르지 않습니다.\n로그인 페이지로 이동합니다.", toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 1, backgroundColor: Color.fromRGBO(0, 0, 0, 0.51), textColor: hexToColor('#FFFFFF') );

              Navigator.push(
                  context,
                  // 기본 파라미터, SecondRoute로 전달
                  MaterialPageRoute(
                      builder: (context) =>
                          LoginSelectPage()));
            }else{
              globalLogin(context, provider, result, isHandLogin: false);
            }
          }}}
      )();
    }catch(e){
      Navigator.push(
          context,
          // 기본 파라미터, SecondRoute로 전달
          MaterialPageRoute(builder: (context) => LoginPage()));
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double sizeUnit = SheepsTextStyle.sizeUnit(context).fontSize;

    return new Scaffold(
      backgroundColor: kPrimaryColor,
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children:[
              Container(
                child: SvgPicture.asset(
                  svgSheepsGreenImageLogo,
                  width: 145 *sizeUnit,
                  height: 105 *sizeUnit,
                  color: Colors.white,
                ),
              ),
              Row(
                children: [
                  SizedBox(height: 16*sizeUnit),
                ],
              ),
              Container(
                child: SvgPicture.asset(
                  svgSheepsGreenWriteLogo,
                  width: 150*sizeUnit,
                  height: 28*sizeUnit,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                "Copyright © 2021 SHEEPS Inc. ",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10 *sizeUnit, color: Color.fromRGBO(255, 255, 255, 0.6),
                    height: 0.6,
                  ),
              ),
              Text(
                '모든 권리 보유.',
                style: TextStyle(
                  fontSize: 10 *sizeUnit, color: Color.fromRGBO(255, 255, 255, 0.6),
                  height: 0.6
                ),
              ),
              Row(
                children: [
                  SizedBox(
                    height: 40*sizeUnit,
                  ),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}
