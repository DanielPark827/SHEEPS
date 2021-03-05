import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:package_info/package_info.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sheeps_app/Setting/AppVersionPage.dart';
import 'package:sheeps_app/Setting/BusinessInfoPage.dart';
import 'package:sheeps_app/Setting/DetailAlarmPage.dart';
import 'package:sheeps_app/Setting/ModifyMemberInformation.dart';
import 'package:sheeps_app/chat/models/ChatDatabase.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/GlobalAsset.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/config/NavigationNum.dart';
import 'package:sheeps_app/dashboard/MyHomePage.dart';
import 'package:sheeps_app/network/ApiProvider.dart';
import 'package:sheeps_app/network/SocketProvider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sheeps_app/notification/models/NotiDatabase.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/userdata/GlobalProfile.dart';



class AppSetting extends StatefulWidget {
  @override
  _AppSettingState createState() => _AppSettingState();
}

class _AppSettingState extends State<AppSetting> {
  double sizeUnit = 1;
  bool DetailNotification = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      Future.microtask(() async {
        AllNotification = await getNotiByStatus();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    sizeUnit = SheepsTextStyle.sizeUnit(context).fontSize;

    NavigationNum navigationNum = Provider.of<NavigationNum>(context);
    SocketProvider socket = Provider.of<SocketProvider>(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),//사용자 스케일팩터 무시
        child: Container(
          color: Colors.white,
          child: SafeArea(
            child: Scaffold(
              backgroundColor: Color(0xFFF8F8F8),
              appBar: SheepsAppBar(context, '앱 설정'),
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      color: Colors.white,
                      height: 48*sizeUnit,
                      child: Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 12*sizeUnit),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '전체 알림',
                                style: SheepsTextStyle.b1(context),
                              ),
                            ),
                          ),
                          Expanded(child: SizedBox()),
                          Transform.scale(
                            scale: 0.8,
                            child: CupertinoSwitch(
                              value: AllNotification,
                              onChanged: (bool value) async {

                                await openAppSettings();

                                AllNotification = !AllNotification;
                              },
                            ),
                          ),
                          SizedBox(width: 4*sizeUnit),
                        ],
                      ),
                    ),
                    SizedBox(height: 1*sizeUnit),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,  // 기본 파라미터, SecondRoute로 전달
                            MaterialPageRoute(builder: (context)=>DetailAlarmPage()) // SecondRoute를 생성하여 적재
                        );
                      },
                      child: Container(
                        color: Colors.white,
                        height: 48*sizeUnit,
                        child: Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 12*sizeUnit),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  '세부 알림',
                                  style: SheepsTextStyle.b1(context),
                                ),
                              ),
                            ),
                            Expanded(child: SizedBox()),
                            Padding(
                              padding: EdgeInsets.only(right: 16*sizeUnit),
                              child: SvgPicture.asset(
                                svgGreyNextIcon,
                                width: 16*sizeUnit,
                                height: 16*sizeUnit,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 1*sizeUnit),
                    GestureDetector(
                      onTap: (){
                        Navigator.push(
                            context,  // 기본 파라미터, SecondRoute로 전달
                            MaterialPageRoute(builder: (context)=>ModifyMemberInformation()) // SecondRoute를 생성하여 적재
                        );
                      },
                      child: buildGotoNextPage(context,'회원 정보 변경'),
                    ),
                    SizedBox(height: 12*sizeUnit),
                    GestureDetector(
                      onTap: () async {
                        PackageInfo packageInfo = await PackageInfo.fromPlatform();
                        Navigator.push(
                            context,  // 기본 파라미터, SecondRoute로 전달
                            MaterialPageRoute(builder: (context)=>AppVersionPage(packageInfo: packageInfo,)) // SecondRoute를 생성하여 적재
                        );
                      },
                      child: buildGotoNextPage(context,'앱 버전')
                    ),
                    SizedBox(height: 1*sizeUnit),
                    GestureDetector(
                        onTap: () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (BuildContext context) {
                                return Scaffold(
                                  body: MyHomePage(
                                      url: 'https://sheeps.kr/inquire'),

                                ); // ... to here.
                              },
                            ),
                          );
                        },
                        child: buildGotoNextPage(context,'문의 하기'),
                    ),
                    SizedBox(height: 1*sizeUnit),
                    GestureDetector(
                      onTap: () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) {
                              return Scaffold(
                                // Add 6 lines from here...
                                body: MyHomePage(
                                    url: 'https://www.sheeps.kr'),
                              ); // ... to here.
                            },
                          ),
                        );
                      },
                      child: buildGotoNextPage(context,'SHEEPS 홈페이지 바로가기'),
                    ),
                    SizedBox(height: 12*sizeUnit),
                    GestureDetector(
                      onTap: () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) {
                              return Scaffold(
                                // Add 6 lines from here...
                                body: MyHomePage(
                                    url: 'https://sheeps.kr/termsandconditionsofservice'),
                              ); // ... to here.
                            },
                          ),
                        );
                      },
                      child: buildGotoNextPage(context,'이용 약관'),
                    ),
                    SizedBox(height: 1*sizeUnit),
                    GestureDetector(
                      onTap: () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) {
                              return Scaffold(
                                // Add 6 lines from here...
                                body: MyHomePage(
                                    url: 'https://sheeps.kr/privacypolicy'),
                              ); // ... to here.
                            },
                          ),
                        );
                      },
                      child: buildGotoNextPage(context,'개인정보취급방침'),
                    ),
                    SizedBox(height: 1*sizeUnit),
                    GestureDetector(
                      onTap: (){
                        Navigator.push(
                            context,  // 기본 파라미터, SecondRoute로 전달
                            MaterialPageRoute(builder: (context)=>BusinessInfoPage()) // SecondRoute를 생성하여 적재
                        );
                      },
                      child: buildGotoNextPage(context,'사업자 정보'),
                    ),
                    SizedBox(height: 12*sizeUnit),
                    GestureDetector(
                        onTap: () async {

                          Function okFunc = () async{

                            final SharedPreferences prefs = await SharedPreferences.getInstance();
                            prefs.setBool('autoLoginKey',false);
                            prefs.setString('autoLoginId', null);
                            prefs.setString('autoLoginPw', null);
                            socket.disconnect();

                            await ApiProvider().post('/Personal/Logout', jsonEncode(
                                {
                                  "userID" : GlobalProfile.loggedInUser.userID,
                                  "isSelf" : 1
                                }
                            ),isChat: true);
                            navigationNum.setNum(DASHBOARD_MAIN_PAGE);
                            Navigator.of(context).pushNamedAndRemoveUntil("/LoginSelectPage", (route) => false);
                            ChatDBHelper().dropTable();
                            NotiDBHelper().dropTable();
                          };

                          Function cancelFunc = () {
                            Navigator.pop(context);
                          };

                          showSheepsDialog(
                            context: context,
                            title: '로그아웃',
                            description: '로그아웃 시 채팅과 알림에 대한 내용이 지워져요.\n로그아웃 하시겠어요?',
                            okText: '할래요',
                            okFunc: okFunc,
                            cancelText: '좀 더 둘러볼래요',
                            cancelFunc: cancelFunc,
                          );
                        },
                        child: buildGotoNextPage(context,'로그아웃')
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
