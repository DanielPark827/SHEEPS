import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:sheeps_app/Setting/AppSetting.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/config/NavigationNum.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/userdata/GlobalProfile.dart';
import 'package:sheeps_app/userdata/User.dart';
import 'package:sheeps_app/chat/ChatRoomPage.dart';
import 'package:sheeps_app/network/ApiProvider.dart';
import 'package:sheeps_app/profile/MyDetailProfile.dart';
import 'package:sheeps_app/profile/MyRequestTeamListPage.dart';
import 'package:sheeps_app/profile/MyTeamProfile.dart';
import 'package:sheeps_app/profile/PersonalLikes.dart';
import 'package:sheeps_app/profile/TeamLikes.dart';
import 'package:sheeps_app/profile/models/ModelPersonalLikes.dart';
import 'package:sheeps_app/profile/models/ModelTeamLikes.dart';
import 'package:sheeps_app/network/SocketProvider.dart';
import 'package:sheeps_app/Community/PostedPage.dart';
import 'package:sheeps_app/Community/models/Community.dart';

class MyPage extends StatefulWidget {
  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> with SingleTickerProviderStateMixin {

  double sizeUnit = 1;
  AnimationController extendedController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    extendedController = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 1),
        lowerBound: 0.0,
        upperBound: 1.0);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    extendedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    sizeUnit = SheepsTextStyle.sizeUnit(context).fontSize;
    NavigationNum navigationNum = Provider.of<NavigationNum>(context);

    SocketProvider socket = Provider.of<SocketProvider>(context);

    UserData user = GlobalProfile.loggedInUser;

    Future.microtask(() async {
      AllNotification = await getNotiByStatus();
    });

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),//사용자 스케일팩터 무시
        child: Container(
          color: Colors.white,
          child: SafeArea(
            child: Scaffold(
              appBar: SheepsAppBar(context, '마이페이지'),
              body: Container(
                color: Color(0xFFF8F8F8),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SheepsMyPageInfo(context, user, extendedController),
                      SizedBox(height: 12*sizeUnit),
                      Container(
                        width: 360*sizeUnit,
                        height: 32*sizeUnit,
                        color: Colors.transparent,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12*sizeUnit),
                          child: Row(
                            children: [
                              Text(
                                '프로필',
                                style: SheepsTextStyle.h4(context),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SettingColumn(str: "나의 개인 프로필", myFunc: () {
                        Navigator.push(
                            context, // 기본 파라미터, SecondRoute로 전달
                            MaterialPageRoute(
                                builder: (context) => MyDetailProfile(index: 0))).then((value) {
                          setState(() {

                          });
                        });
                      },),
                      SizedBox(height: 1),
                      SettingColumn(str: "나의 팀 프로필", myFunc: () {
                        Navigator.push(
                            context, // 기본 파라미터, SecondRoute로 전달
                            MaterialPageRoute(builder: (context) => MyTeamProfile()));
                      },),
                      SizedBox(height: 1*sizeUnit),
                      SettingColumn(str: "좋아요 한 개인 프로필", myFunc: () async {

                        var list = await ApiProvider().post('/Profile/Personal/SelectLIke', jsonEncode(
                            {
                              "userID" : GlobalProfile.loggedInUser.userID,
                            }
                        ));
                        if(null != list) {
                          List<ModelPersonalLikes> PersonalLikesList = [];
                          PersonalLikesList.clear();
                          for(int i = 0; i < list.length; ++i){
                            Map<String, dynamic> data = list[i];

                            ModelPersonalLikes item = ModelPersonalLikes.fromJson(data);

                            PersonalLikesList.add(item);

                            for(int i = 0 ; i < PersonalLikesList.length; ++i){
                              await GlobalProfile.getFutureUserByUserID(PersonalLikesList[i].TargetID);
                            }
                          }

                          Navigator.push(
                              context,  // 기본 파라미터, SecondRoute로 전달
                              MaterialPageRoute(builder: (context)=>PersonalLikes(personalLikesList: PersonalLikesList,))
                          );
                        }
                      },),
                      SizedBox(height: 1),
                      SettingColumn(str: "좋아요 한 팀 프로필", myFunc: () async {

                        var list = await ApiProvider().post('/Team/SelectLike', jsonEncode(
                            {
                              "userID" : GlobalProfile.loggedInUser.userID,
                            }
                        ));


                        if(null != list) {
                          List<ModelTeamLikes> TeamLikesList = [];
                          for(int i = 0; i < list.length; ++i){
                            Map<String, dynamic> data = list[i];

                            ModelTeamLikes item = ModelTeamLikes.fromJson(data);

                            TeamLikesList.add(item);
                          }

                          for(int i = 0 ; i < TeamLikesList.length; ++i){
                            await GlobalProfile.getFutureTeamByID(TeamLikesList[i].TeamID);
                          }

                          Navigator.push(
                              context,  // 기본 파라미터, SecondRoute로 전달
                              MaterialPageRoute(builder: (context)=>TeamLikes(teamLikesList: TeamLikesList,))
                          );
                        }
                      },),
                      SizedBox(height: 12*sizeUnit),
                      Container(
                        width: 360*sizeUnit,
                        height: 32*sizeUnit,
                        color: Colors.transparent,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12*sizeUnit),
                          child: Row(
                            children: [
                              Text(
                                '채팅 및 요청',
                                style: SheepsTextStyle.h4(context),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SettingColumn(str: "진행 중인 채팅", myFunc: () {
                        socket.setRoomStatus(ROOM_STATUS_ROOM);
                        Navigator.push(
                            context, // 기본 파라미터, SecondRoute로 전달
                            MaterialPageRoute(builder: (context) => ChatRoomPage()));
                      },),
                      SizedBox(height: 1),
                      SettingColumn(str: "보낸 팀 요청", myFunc: () {
                        Navigator.push(
                            context, // 기본 파라미터, SecondRoute로 전달
                            MaterialPageRoute(builder: (context) => MyRequestTeamListPage()));
                      },),
                      SizedBox(height: 12*sizeUnit),
                      Container(
                        width: 360*sizeUnit,
                        height: 32*sizeUnit,
                        color: Colors.transparent,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12*sizeUnit),
                          child: Row(
                            children: [
                              Text(
                                '커뮤니티',
                                style: SheepsTextStyle.h4(context),
                              ),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: ()async{
                          GlobalProfile.postedList.clear();

                          var tmp = new List<dynamic>();
                          tmp= await ApiProvider().post('/CommunityPost/SelectUser', jsonEncode(
                              {
                                "userID" : GlobalProfile.loggedInUser.userID,
                              }
                          ));
                          if(tmp != null) {
                            for (int i = 0; i < tmp.length; i++) {
                              Community community = Community.fromJson(tmp[i]);
                              GlobalProfile.postedList.add(community);
                            }
                          }
                          Navigator.push(context,MaterialPageRoute(builder: (context)=>PostedPage(GlobalProfile.postedList,'내가 쓴 글')));
                        },
                        child: buildGotoNextPage(context,'내가 쓴 글'),
                      ),
                      SizedBox(height: 1*sizeUnit),
                      GestureDetector(
                          onTap: ()async{
                            GlobalProfile.postedList.clear();

                            var tmp = new List<dynamic>();
                            tmp= await ApiProvider().post('/CommunityPost/Reply/SelectUser', jsonEncode(
                                {
                                  "userID" : GlobalProfile.loggedInUser.userID,
                                }
                            ));
                            if(tmp != null) {
                              for (int i = 0; i < tmp.length; i++) {
                                Community community = Community.fromJson(tmp[i]);
                                GlobalProfile.postedList.add(community);
                              }
                            }
                            Navigator.push(context,MaterialPageRoute(builder: (context)=>PostedPage(GlobalProfile.postedList,'내가 쓴 댓글')));
                          },
                          child: buildGotoNextPage(context,'내가 쓴 댓글')),
                      SizedBox(height: 1*sizeUnit),
                      GestureDetector(
                        onTap: ()async{
                          GlobalProfile.postedList.clear();

                          var tmp = new List<dynamic>();
                          tmp= await ApiProvider().post('/CommunityPost/SelectUserLIke', jsonEncode(
                              {
                                "userID" : GlobalProfile.loggedInUser.userID,
                              }
                          ));
                          if(tmp != null) {
                            for (int i = 0; i < tmp.length; i++) {
                              Community community =
                              Community.fromJson(tmp[i]);
                              GlobalProfile.postedList.add(community);
                            }
                          }
                          Navigator.push(context,MaterialPageRoute(builder: (context)=>PostedPage(GlobalProfile.postedList,'좋아요 한 글')));
                        },
                        child: buildGotoNextPage(context,'좋아요 한 글'),
                      ),
                      SizedBox(height: 20*sizeUnit),
                      GestureDetector(
                        onTap: (){
                          Navigator.push(
                              context,  // 기본 파라미터, SecondRoute로 전달
                              MaterialPageRoute(builder: (context)=>AppSetting()) // SecondRoute를 생성하여 적재
                          );
                        },
                        child: buildGotoNextPage(context,'앱 설정'),
                      ),
                      SizedBox(height: 40*sizeUnit),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
