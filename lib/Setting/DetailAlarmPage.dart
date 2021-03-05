import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sheeps_app/network/ApiProvider.dart';
import 'package:sheeps_app/network/FirebaseNotification.dart';
import 'package:sheeps_app/userdata/GlobalProfile.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';

class DetailAlarmPage extends StatefulWidget {
  @override
  _DetailAlarmPageState createState() => _DetailAlarmPageState();
}

class _DetailAlarmPageState extends State<DetailAlarmPage> {
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
              appBar: SheepsAppBar(context,'세부 알림'),
              body: Container(
                color: Color(0xFFF8F8F8),
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
                                '마케팅 알림',
                                style: SheepsTextStyle.b1(context),
                              ),
                            ),
                          ),
                          Expanded(child: SizedBox()),
                          Transform.scale(
                            scale: 0.8,
                            child: CupertinoSwitch(
                              value: FirebaseNotifications.isMarketing,
                              onChanged: (bool value) async {
                                FirebaseNotifications.isMarketing = value;
                                await ApiProvider().post('/Fcm/DetailAlarmSetting', jsonEncode(
                                    {
                                      "userID" : GlobalProfile.loggedInUser.userID,
                                      "marketing" : FirebaseNotifications.isMarketing,
                                      "chatting" : FirebaseNotifications.isChatting,
                                      "team" : FirebaseNotifications.isTeam,
                                      "community" : FirebaseNotifications.isCommuntiy
                                    }
                                ));
                                setState(() {

                                });
                              },
                            ),
                          ),
                          SizedBox(width: 4*sizeUnit),
                        ],
                      ),
                    ),
                    SizedBox(height: 1*sizeUnit),
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
                                '채팅 알림',
                                style: SheepsTextStyle.b1(context),
                              ),
                            ),
                          ),
                          Expanded(child: SizedBox()),
                          Transform.scale(
                            scale: 0.8,
                            child: CupertinoSwitch(
                              value: FirebaseNotifications.isChatting,
                              onChanged: (bool value) async {
                                FirebaseNotifications.isChatting = value;
                                await ApiProvider().post('/Fcm/DetailAlarmSetting', jsonEncode(
                                    {
                                      "userID" : GlobalProfile.loggedInUser.userID,
                                      "marketing" : FirebaseNotifications.isMarketing,
                                      "chatting" : FirebaseNotifications.isChatting,
                                      "team" : FirebaseNotifications.isTeam,
                                      "community" : FirebaseNotifications.isCommuntiy
                                    }
                                ));
                                setState(() {

                                });
                              },
                            ),
                          ),
                          SizedBox(width: 4*sizeUnit),
                        ],
                      ),
                    ),
                    SizedBox(height: 1*sizeUnit),
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
                                '팀 초대 알림 알림',
                                style: SheepsTextStyle.b1(context),
                              ),
                            ),
                          ),
                          Expanded(child: SizedBox()),
                          Transform.scale(
                            scale: 0.8,
                            child: CupertinoSwitch(
                              value: FirebaseNotifications.isTeam,
                              onChanged: (bool value) async {
                                FirebaseNotifications.isTeam = value;
                                await ApiProvider().post('/Fcm/DetailAlarmSetting', jsonEncode(
                                    {
                                      "userID" : GlobalProfile.loggedInUser.userID,
                                      "marketing" : FirebaseNotifications.isMarketing,
                                      "chatting" : FirebaseNotifications.isChatting,
                                      "team" : FirebaseNotifications.isTeam,
                                      "community" : FirebaseNotifications.isCommuntiy
                                    }
                                ));
                                setState(() {

                                });
                              },
                            ),
                          ),
                          SizedBox(width: 4*sizeUnit),
                        ],
                      ),
                    ),
                    SizedBox(height: 1*sizeUnit),
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
                                '커뮤니티 알림',
                                style: SheepsTextStyle.b1(context),
                              ),
                            ),
                          ),
                          Expanded(child: SizedBox()),
                          Transform.scale(
                            scale: 0.8,
                            child: CupertinoSwitch(
                              value: FirebaseNotifications.isCommuntiy,
                              onChanged: (bool value) async {
                                FirebaseNotifications.isCommuntiy = value;
                                await ApiProvider().post('/Fcm/DetailAlarmSetting', jsonEncode(
                                    {
                                      "userID" : GlobalProfile.loggedInUser.userID,
                                      "marketing" : FirebaseNotifications.isMarketing,
                                      "chatting" : FirebaseNotifications.isChatting,
                                      "team" : FirebaseNotifications.isTeam,
                                      "community" : FirebaseNotifications.isCommuntiy
                                    }
                                ));
                                setState(() {

                                });
                              },
                            ),
                          ),
                          SizedBox(width: 4*sizeUnit),
                        ],
                      ),
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
