import 'dart:convert';

import 'package:badges/badges.dart';
import 'package:cupertino_will_pop_scope/cupertino_will_pop_scope.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sheeps_app/Badge/model/ModelBadge.dart';
import 'package:sheeps_app/TeamProfileModifys/TeamProfileModify.dart';
import 'package:sheeps_app/TeamProfileModifys/model/Team.dart';
import 'package:sheeps_app/chat/TeamChatPage.dart';
import 'package:sheeps_app/chat/models/ChatGlobal.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/config/constants.dart';
import 'package:sheeps_app/profile/DetailProfile.dart';
import 'package:sheeps_app/network/ApiProvider.dart';
import 'package:sheeps_app/network/SocketProvider.dart';
import 'package:sheeps_app/profile/models/ModelTeamLikes.dart';
import 'package:sheeps_app/userdata/GlobalProfile.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/config/GlobalAsset.dart';


class DetailTeamProfile extends StatefulWidget {
  final int index;
  final Team team;

  DetailTeamProfile({Key key, @required this.index, @required this.team}) : super(key : key);

  @override
  _DetailTeamProfileState createState() => _DetailTeamProfileState();
}

class _DetailTeamProfileState extends State<DetailTeamProfile>
    with SingleTickerProviderStateMixin {
  double sizeUnit = 1;
  int currentPage = 0;
  bool lastStatus = true;
  bool lastStatus2 = true;

  final int INVITE_STATUS_POSSIBLE = 0;
  final int INVITE_STATUS_ALREADY_TEAM = 1;
  final int INVITE_STATUS_WAITING = 2;
  final int INVITE_STATUS_HAVE_NOT_TEAM_MEMBER = 3;
  final int INVITE_STATUS_IMPOSSOBLE_JOIN = 4;
  int INVITE_STATUS;
  String inviteWord;
  Color inviteBoxColor;

  int roomIndex = 0;
  bool isActiveChat = false;
  String roomName = '';

  SocketProvider _socket;
  ScrollController _scrollController;
  AnimationController extendedController;

  List<int> totalList = List<int>();
  Team modifyTeam;

  final String svgWhiteBackArrow = 'assets/images/Profile/WhiteBackArrow.svg';
  final String svgGreenLeaderIcon = 'assets/images/Profile/GreyLeaderIcon.svg';
  final String svgSetting = 'assets/images/ProfileModify/Setting.svg';
  String svgchatIcon = 'assets/images/Chat/chatSmallIcon.svg';
  final GreyXIcon = 'assets/images/Public/GreyXIcon.svg';

  SharedPreferences localStorage;
  String key = 'TeamLikesList';

  bool Likes= false;

  bool isCanTapLike = true;
  int tapLikeDelayMilliseconds = 500;

  List<ModelTeamLikes> TeamLikesList = [];

  Future<bool> init(BuildContext context) async {
    var list = await ApiProvider().post('/Team/SelectLike', jsonEncode(
        {
          "userID" : GlobalProfile.loggedInUser.userID,
          "teamID" : widget.team.id
        }
    ));

    if(null != list) {

      for(int i = 0; i < list.length; ++i){
        Map<String, dynamic> data = list[i];

        ModelTeamLikes item = ModelTeamLikes.fromJson(data);

        if(IsSame(item.TeamID, widget.team.id)) {
          Likes = true;
        }

        TeamLikesList.add(item);
        //await NotiDBHelper().createData(noti);
      }

      return true;
    } else {
      return false;
    }
  }

  bool IsSame(int I1, int I2) {
    if(I1 == I2) {
      return true;
    } else {
      return false;
    }

  }


  _scrollListener() {
    if (isShrink != lastStatus) {
      setState(() {
        lastStatus = isShrink;
      });
    }
    if(isShrink2 != lastStatus2){
      setState(() {
        lastStatus2 = isShrink2;
      });
    }
  }

  bool get isShrink {
    return _scrollController.hasClients &&
        _scrollController.offset > (318 - kToolbarHeight);
  }

  bool get isShrink2 {
    return _scrollController.hasClients &&
        _scrollController.offset > (10);
  }

  @override
  void initState() {
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    modifyTeam = widget.team;

    INVITE_STATUS = INVITE_STATUS_WAITING;
    inviteWord = '초대 진행중..';
    inviteBoxColor = hexToColor('#CCCCCC');

    totalList.add(widget.team.leaderID);

    if(widget.team.userList != null && widget.team.userList.length != 0){
      for(int i = 0 ; i < widget.team.userList.length; ++i){
        if(widget.team.leaderID != widget.team.userList[i]){
          totalList.add(widget.team.userList[i]);
          GlobalProfile.getFutureUserByUserID(widget.team.userList[i]);
        }
      }
    }

    (() async {
      var res = await ApiProvider().post('/Team/Invite/TargetSelect', jsonEncode({
        "teamID" : widget.team.id,
        "userID" : GlobalProfile.loggedInUser.userID
      }));

      roomName = getRoomName(widget.team.id, widget.team.leaderID, true);
      for(int i = 0 ; i < ChatGlobal.roomInfoList.length; ++i){
        if(ChatGlobal.roomInfoList[i].roomName == roomName){
          isActiveChat = true;
          roomIndex = i;
          break;
        }
      }

      if(res == null || res.length == 0){
        if(GlobalProfile.loggedInUser.userID == widget.team.leaderID){
          INVITE_STATUS = INVITE_STATUS_HAVE_NOT_TEAM_MEMBER;
          inviteWord = '팀원이 없습니다.';
          inviteBoxColor = hexToColor('#CCCCCC');

          if(isActiveChat) {
            INVITE_STATUS = INVITE_STATUS_ALREADY_TEAM;
            inviteWord = '팀 채팅방 이동!';
            inviteBoxColor = hexToColor('#61C680');
          }
        }else{
          if(isActiveChat) {
            INVITE_STATUS = INVITE_STATUS_ALREADY_TEAM;
            inviteWord = '팀 채팅방 이동!';
            inviteBoxColor = hexToColor('#61C680');
          }else{

            if(widget.team.possibleJoin == 0){
              INVITE_STATUS = INVITE_STATUS_IMPOSSOBLE_JOIN;
              inviteWord = "팀 모집 상태가 아닙니다.";
              inviteBoxColor = hexToColor('#CCCCCC');
              svgchatIcon = null;
            }else{
              INVITE_STATUS = INVITE_STATUS_POSSIBLE;
              inviteWord = '팀 참가 요청';
              inviteBoxColor = hexToColor('#61C680');
              svgchatIcon = null;
            }
          }
        }
      }else{
        var response = res['Response'];

        if(response == 1){
          INVITE_STATUS = INVITE_STATUS_ALREADY_TEAM;
          inviteWord = '팀 채팅방 이동!';
          inviteBoxColor = hexToColor('#61C680');
        }else if(response == 2){
          if(widget.team.possibleJoin == 0){
            INVITE_STATUS = INVITE_STATUS_IMPOSSOBLE_JOIN;
            inviteWord = "팀 모집 상태가 아닙니다.";
            inviteBoxColor = hexToColor('#CCCCCC');
            svgchatIcon = null;
          }else{
            INVITE_STATUS = INVITE_STATUS_POSSIBLE;
            inviteWord = '팀 참가 요청';
            inviteBoxColor = hexToColor('#61C680');
            svgchatIcon = null;
          }
        }else{
          INVITE_STATUS = INVITE_STATUS_WAITING;
          inviteWord = '초대 진행중..';
          inviteBoxColor = hexToColor('#CCCCCC');
        }
      }
    })();

    extendedController = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 3),
        lowerBound: 0.0,
        upperBound: 1.0);

    super.initState();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    extendedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    sizeUnit = SheepsTextStyle.sizeUnit(context).fontSize;
    _socket = Provider.of<SocketProvider>(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),//사용자 스케일팩터 무시
        child: Container(
          color: Colors.white,
          child: SafeArea(
            child: ConditionalWillPopScope(
              shouldAddCallbacks: true,
              onWillPop: () async {
                Navigator.pop(context, modifyTeam);
                return Future.value(true);
              },
              child: Scaffold(
                body: Stack(
                  children: [
                    CustomScrollView(
                      controller: _scrollController,
                      slivers: [
                        SliverAppBar(
                          elevation: 0,
                          expandedHeight: 360*sizeUnit,
                          floating: false,
                          pinned: true,
                          backgroundColor: Colors.white,
                          centerTitle: true,
                          title: Text(modifyTeam.name,
                              textAlign: TextAlign.center,
                            style: SheepsTextStyle.appBar(context).copyWith(color: isShrink ? Colors.black : Colors.transparent,),
                          ),
                          leading:InkWell(
                            onTap: () {
                              setState(() {
                                Likes = false;
                              });
                              Navigator.pop(context, modifyTeam);
                            },
                            child: Padding(
                              padding: EdgeInsets.all(12*sizeUnit),
                              child: SvgPicture.asset(
                                svgWhiteBackArrow,
                                color: isShrink ? Colors.black :Colors.white,
                                width: 28*sizeUnit,
                                height: 28*sizeUnit,
                              ),
                            ),
                          ),
                          actions: [
                            modifyTeam.leaderID == GlobalProfile.loggedInUser.userID ? InkWell(
                              onTap: () {
                                Navigator.push(
                                    context, // 기본 파라미터, SecondRoute로 전달
                                    MaterialPageRoute(
                                        builder: (context) => TeamProfileModify(team: modifyTeam,))).then((value) {
                                          setState(() {
                                            if(value != null){
                                              modifyTeam = value;
                                            }
                                        });});
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: SvgPicture.asset(
                                  svgSetting,
                                  color: isShrink ? Colors.black :Colors.white,
                                  width: 28*sizeUnit,
                                  height: 28*sizeUnit,
                                ),
                              ),
                            ) :
                                SizedBox(),
                          ],
                          flexibleSpace: FlexibleSpaceBar(
                            centerTitle: true,
                            background: Hero(
                              //tag: "${PersonalProfile[widget.index].Id}",
                              tag: modifyTeam.id,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  PageView.builder(
                                    onPageChanged: (value) {
                                      setState(() {
                                        currentPage = value;
                                      });
                                    },
                                    itemCount: modifyTeam.profileUrlList.length, //추후 이미지 여러개 부분 수정 필요
                                    itemBuilder: (context, index) => Stack(
                                      children: [
                                        modifyTeam.profileUrlList[0] == 'BasicImage' ?
                                        Container(
                                          width: 360*sizeUnit,
                                          height: 360*sizeUnit,
                                          decoration: BoxDecoration(
                                          color: hexToColor('#F8F8F8'),
                                          borderRadius: new BorderRadius.circular(8*sizeUnit),
                                          boxShadow: [
                                            new BoxShadow(
                                            color: Color.fromRGBO(116, 125, 130, 0.2),
                                            blurRadius: 4,
                                            ),
                                          ],
                                        ),
                                          child: Center(
                                              child: SvgPicture.asset(
                                                svgPersonalProfileBasicImage,
                                                width: 192*sizeUnit,
                                                height: 138*sizeUnit,
                                                fit: BoxFit.cover,
                                              )
                                          )
                                        )
                                        :
                                        Container(
                                            width: 360*sizeUnit,
                                            height: 360*sizeUnit,
                                            child: FittedBox(
                                              child: getExtendedImage(modifyTeam.profileUrlList[index], 0, extendedController, isRounded: false),
                                              fit: BoxFit.cover,
                                            ),
                                        ),
                                        Container(//프로필 위 아래 그라데이션
                                          width: 360*sizeUnit,
                                          height: 360*sizeUnit,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [Color.fromRGBO(0, 0, 0, 0.2),Color.fromRGBO(0, 0, 0, 0.08),Color.fromRGBO(0, 0, 0, 0),Color.fromRGBO(0, 0, 0, 0),Color.fromRGBO(0, 0, 0, 0),Color.fromRGBO(0, 0, 0, 0),Color.fromRGBO(0, 0, 0, 0),Color.fromRGBO(0, 0, 0, 0),Color.fromRGBO(0, 0, 0, 0),Color.fromRGBO(0, 0, 0, 0),Color.fromRGBO(0, 0, 0, 0),Color.fromRGBO(0, 0, 0, 0),Color.fromRGBO(0, 0, 0, 0),Color.fromRGBO(0, 0, 0, 0.03),Color.fromRGBO(0, 0, 0, 0.08)],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                    left: 12*sizeUnit,
                                    bottom: 12*sizeUnit,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: List.generate(
                                        modifyTeam.profileUrlList.length,
                                            (index) => buildDot(index: index),
                                      ),
                                    ),
                                  ),
                                  modifyTeam.badge1 != 0
                                      ? Positioned(
                                    right: 12*sizeUnit,
                                    bottom: 12*sizeUnit,
                                    child: GestureDetector(
                                      onTap: (){
                                        BadgeDialogForDetailedTeamProfile(context,modifyTeam.badge1);
                                      },
                                      child: Container(
                                        width: 48*sizeUnit,
                                        height: 48*sizeUnit,
                                        child: ClipRRect(
                                          borderRadius:
                                          new BorderRadius.circular(8*sizeUnit),
                                          child: FittedBox(
                                            child: SvgPicture.asset(
                                              ReturnTeamBadgeSVG(modifyTeam.badge1),
                                            ),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                      : Container(),
                                  modifyTeam.badge2 != 0
                                      ? Positioned(
                                    right: 60*sizeUnit,
                                    bottom: 12*sizeUnit,
                                    child: GestureDetector(
                                      onTap: (){
                                        BadgeDialogForDetailedTeamProfile(context,modifyTeam.badge2);
                                      },
                                      child: Container(
                                        width: 48*sizeUnit,
                                        height: 48*sizeUnit,
                                        child: ClipRRect(
                                          borderRadius:
                                          new BorderRadius.circular(8*sizeUnit),
                                          child: FittedBox(
                                            child: SvgPicture.asset(
                                              ReturnTeamBadgeSVG(modifyTeam.badge2),
                                            ),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                      : Container(),
                                  modifyTeam.badge3 != 0
                                      ? Positioned(
                                    right: 108*sizeUnit,
                                    bottom: 12*sizeUnit,
                                    child: GestureDetector(
                                      onTap: (){
                                        BadgeDialogForDetailedTeamProfile(context,modifyTeam.badge3);
                                      },
                                      child: Container(
                                        width: 48*sizeUnit,
                                        height: 48*sizeUnit,
                                        child: ClipRRect(
                                          borderRadius:
                                          new BorderRadius.circular(8*sizeUnit),
                                          child: FittedBox(
                                            child: SvgPicture.asset(
                                                ReturnTeamBadgeSVG(modifyTeam.badge3),
                                            ),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                      : Container(),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SliverList(
                          delegate: SliverChildListDelegate([
                            Container(
                              constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height - 40*sizeUnit),
                              color: Colors.white,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(top: 20*sizeUnit),
                                    child: Row(
                                      children: [
                                        LeftPadding(),
                                        Container(
                                          height: 36*sizeUnit,
                                          width: 272*sizeUnit,
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(modifyTeam.name,
                                              style: SheepsTextStyle.h1(context).copyWith(fontSize: 24*sizeUnit),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        Spacer(),
                                        Padding(
                                          padding: EdgeInsets.only(right: 16*sizeUnit),
                                          child: SvgPicture.asset(
                                            svgShareBox,
                                            width: 21*sizeUnit,
                                            height: 21*sizeUnit,
                                          ),
                                        ),
                                        FutureBuilder(
                                            future: init(context),
                                            builder: (BuildContext context, AsyncSnapshot snapshot) {
                                              //해당 부분은 data를 아직 받아 오지 못했을때 실행되는 부분을 의미한다.
                                              if (snapshot.hasData == false) {
                                                return SvgPicture.asset(
                                                  "assets/images/Profile/heartGrey.svg",
                                                );
                                              }
                                              //error가 발생하게 될 경우 반환하게 되는 부분
                                              else if (snapshot.hasError) {
                                                return Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    'Error: ${snapshot.error}',
                                                    style: TextStyle(fontSize: 15),
                                                  ),
                                                );
                                              }
                                              // 데이터를 정상적으로 받아오게 되면 다음 부분을 실행하게 되는 것이다.
                                              else {
                                                return GestureDetector(
                                                  onTap: () async {
                                                    if(isCanTapLike) {
                                                      isCanTapLike = false;
                                                      var res = await ApiProvider().post('/Team/InsertLike', jsonEncode(
                                                          {
                                                            "userID" : GlobalProfile.loggedInUser.userID,
                                                            "teamID":modifyTeam.id,
                                                          }
                                                      ));

                                                      setState(() {
                                                        Likes = !Likes;
                                                        Future.delayed(Duration(milliseconds: tapLikeDelayMilliseconds),(){
                                                          isCanTapLike = true;
                                                        });
                                                      });
                                                    }
                                                  },
                                                  child: Padding(
                                                    padding: EdgeInsets.only(right: 12*sizeUnit),
                                                    child: SvgPicture.asset(
                                                      "assets/images/Profile/heartGrey.svg",
                                                      color: Likes == true ? kPrimaryColor : null,
                                                      width: 21*sizeUnit,
                                                      height: 21*sizeUnit,
                                                    ),
                                                  ),
                                                );
                                              }
                                            }),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 16*sizeUnit),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 12*sizeUnit),
                                    child: Container(
                                      width: 336*sizeUnit,
                                      child: Wrap(
                                        runSpacing: 4*sizeUnit,
                                        spacing: 4*sizeUnit,
                                        children: [
                                          Container(
                                            height: 20*sizeUnit,
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 8*sizeUnit),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    modifyTeam.category,
                                                    style: SheepsTextStyle.cat2(context),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            decoration: BoxDecoration(
                                              borderRadius: new BorderRadius.circular(4*sizeUnit),
                                              color: hexToColor("#E5E5E5"),
                                            ),
                                          ),
                                          Container(
                                            height: 20*sizeUnit,
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 8*sizeUnit),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    modifyTeam.part,
                                                    style: SheepsTextStyle.cat2(context),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            decoration: BoxDecoration(
                                              borderRadius: new BorderRadius.circular(4*sizeUnit),
                                              color: hexToColor("#E5E5E5"),
                                            ),
                                          ),
                                          Container(
                                            height: 20*sizeUnit,
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 8*sizeUnit),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    modifyTeam.location + " " + (modifyTeam.subLocation == null ? '' : modifyTeam.subLocation),
                                                    style: SheepsTextStyle.cat2(context),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            decoration: BoxDecoration(
                                              borderRadius: new BorderRadius.circular(4*sizeUnit),
                                              color: hexToColor("#E5E5E5"),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 20*sizeUnit),
                                  Row(
                                    children: [
                                      LeftPadding(),
                                      Container(
                                          width: 336*sizeUnit,
                                          child: Text(
                                            modifyTeam.information,
                                            style: SheepsTextStyle.b3(context),
                                          ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 20*sizeUnit),
                                  Row(
                                    children: [
                                      LeftPadding(),
                                      Text(
                                        '인증',
                                        style: SheepsTextStyle.h3(context),
                                      ),
                                    ],
                                  ),
                                  modifyTeam.TeamAuthList != null && modifyTeam.TeamAuthList.length > 0 ?  SizedBox(
                                    child: ListView.builder(
                                        physics: const NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        scrollDirection: Axis.vertical,
                                        itemCount: modifyTeam.TeamAuthList.length,
                                        itemBuilder: (BuildContext context, int index) => Column(
                                          children: [
                                            SizedBox(height: 8*sizeUnit),
                                            Row(
                                              children: [
                                                LeftPadding(),
                                                Container(
                                                  constraints: BoxConstraints(maxWidth: 300*sizeUnit),
                                                  child: Text(
                                                    '- '+'${modifyTeam.TeamAuthList[index].TAuthContents}',
                                                    style: SheepsTextStyle.b3(context),
                                                  ),
                                                ),
                                                SheepsProfileVerificationStateIcon(context, modifyTeam.TeamAuthList[index].TAuthAuth),
                                              ],
                                            ),
                                          ],
                                        )
                                    ),
                                  ) : SizedBox.shrink(),
                                  SizedBox(height: 20*sizeUnit),
                                  Row(
                                    children: [
                                      LeftPadding(),
                                      Text(
                                        '수행 내역',
                                        style: SheepsTextStyle.h3(context),
                                      ),
                                    ],
                                  ),
                                  modifyTeam.TeamPerformList != null && modifyTeam.TeamPerformList.length > 0 ?  SizedBox(
                                    child: ListView.builder(
                                        physics: const NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        scrollDirection: Axis.vertical,
                                        itemCount: modifyTeam.TeamPerformList.length,
                                        itemBuilder: (BuildContext context, int index) => Column(
                                          children: [
                                            SizedBox(height: 8*sizeUnit),
                                            Row(
                                              children: [
                                                LeftPadding(),
                                                Container(
                                                  constraints: BoxConstraints(maxWidth: 300*sizeUnit),
                                                  child: Text(
                                                    '- '+'${modifyTeam.TeamPerformList[index].TPerformContents}',
                                                    style: SheepsTextStyle.b3(context),
                                                  ),
                                                ),
                                                SheepsProfileVerificationStateIcon(context, modifyTeam.TeamPerformList[index].TPerformAuth),
                                              ],
                                            ),
                                          ],
                                        )
                                    ),
                                  ) : SizedBox.shrink(),
                                  SizedBox(height: 20*sizeUnit),
                                  Row(
                                    children: [
                                      LeftPadding(),
                                      Text(
                                        '수상 내역',
                                        style: SheepsTextStyle.h3(context),
                                      ),
                                    ],
                                  ),
                                  modifyTeam.TeamWinList != null && modifyTeam.TeamWinList.length > 0 ?  SizedBox(
                                    child: ListView.builder(
                                        physics: const NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        scrollDirection: Axis.vertical,
                                        itemCount: modifyTeam.TeamWinList.length,
                                        itemBuilder: (BuildContext context, int index) => Column(
                                          children: [
                                            SizedBox(height: 8*sizeUnit),
                                            Row(
                                              children: [
                                                LeftPadding(),
                                                Container(
                                                  constraints: BoxConstraints(maxWidth: 300*sizeUnit),
                                                  child: Text(
                                                    '- '+'${modifyTeam.TeamWinList[index].TWinContents}',
                                                    style: SheepsTextStyle.b3(context),
                                                  ),
                                                ),
                                                SheepsProfileVerificationStateIcon(context, modifyTeam.TeamWinList[index].TWinAuth),
                                              ],
                                            ),
                                          ],
                                        )
                                    ),
                                  ) : SizedBox.shrink(),
                                  SizedBox(height: 20*sizeUnit),
                                  Row(
                                    children: [
                                      LeftPadding(),
                                      Text(
                                        '소속 팀원',
                                        style: SheepsTextStyle.h3(context),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8*sizeUnit),
                                  Container(
                                    padding: EdgeInsets.fromLTRB(12*sizeUnit, 0, 0, 0),
                                    height: 228*sizeUnit,
                                    color: Colors.white,
                                    child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        cacheExtent: 30,
                                        reverse: false,
                                        shrinkWrap: true,
                                        itemCount: totalList.length,
                                        itemBuilder: (context, index) {
                                          return Container(
                                            margin: const EdgeInsets.symmetric(horizontal: 4.0),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                GestureDetector(
                                                  onTap : () {

                                                    if(totalList[index] == GlobalProfile.loggedInUser.userID){

                                                    }else{
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) => new DetailProfile(
                                                                  index: 0,
                                                                  user: GlobalProfile.getUserByUserID(totalList[index]))));
                                                    }
                                                  },

                                                  child:
                                                  index == 0 ?
                                                  Badge(
                                                    padding: EdgeInsets.all(0),
                                                    shape: BadgeShape.square,
                                                    position: BadgePosition.topStart(top: 4*sizeUnit, start: 4*sizeUnit),
                                                    borderRadius: BorderRadius.circular(8*sizeUnit),
                                                    elevation: 0,
                                                    badgeColor: Colors.transparent,
                                                    badgeContent: SvgPicture.asset(
                                                      svgGreenLeaderIcon,
                                                      width: 20*sizeUnit,
                                                      height: 20*sizeUnit,
                                                    ),
                                                    child: Align(
                                                      alignment: Alignment.centerLeft,
                                                      child:GlobalProfile.getUserByUserID(totalList[index]).profileUrlList[0] == 'BasicImage' ?
                                                      Container(
                                                        width: 120*sizeUnit,
                                                        height: 120*sizeUnit,
                                                        decoration: BoxDecoration(
                                                          color: hexToColor('#F8F8F8'),
                                                          borderRadius: new BorderRadius.circular(8),
                                                        ),
                                                        child:  Center(
                                                          child: SvgPicture.asset(
                                                            svgPersonalProfileBasicImage,
                                                            width: 120*sizeUnit,
                                                            height: 120*sizeUnit,
                                                          ),
                                                        ),
                                                      )
                                                          : Container(
                                                        width: 120*sizeUnit,
                                                        height: 120*sizeUnit,
                                                        decoration: BoxDecoration(
                                                          boxShadow: [
                                                            new BoxShadow(
                                                              color: Color.fromRGBO(166, 125, 130, 0.2),
                                                              blurRadius: 4,
                                                            ),],
                                                        ),
                                                        child: ClipRRect(
                                                          borderRadius:
                                                          new BorderRadius.circular(8*sizeUnit),
                                                          child: FittedBox(
                                                            child: getExtendedImage(GlobalProfile.getUserByUserID(totalList[index]).profileUrlList[0], 120, extendedController),
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ) :
                                                  GlobalProfile.getUserByUserID(totalList[index]).profileUrlList[0] == 'BasicImage' ?
                                                  Container(
                                                    width: 120*sizeUnit,
                                                    height: 120*sizeUnit,
                                                    decoration: BoxDecoration(
                                                      color: hexToColor('#F8F8F8'),
                                                      borderRadius: new BorderRadius.circular(4*sizeUnit),
                                                      boxShadow: [
                                                        BoxShadow(
                                                            color: Color.fromRGBO(116, 125, 130, 0.1),
                                                            blurRadius: 2*sizeUnit,
                                                            offset: Offset(1*sizeUnit, 1*sizeUnit)
                                                        ),
                                                      ],
                                                    ),
                                                    child:  Center(child: SvgPicture.asset(svgPersonalProfileBasicImage,width: 87*sizeUnit,height: 63*sizeUnit)),
                                                  )
                                                      : Container(
                                                    width: 120*sizeUnit,
                                                    height: 120*sizeUnit,
                                                    decoration: BoxDecoration(
                                                      boxShadow: [
                                                        BoxShadow(
                                                            color: Color.fromRGBO(116, 125, 130, 0.1),
                                                            blurRadius: 2*sizeUnit,
                                                            offset: Offset(1*sizeUnit, 1*sizeUnit)
                                                        ),
                                                      ],
                                                    ),
                                                    child: ClipRRect(
                                                      borderRadius: BorderRadius.circular(8*sizeUnit),
                                                      child: FittedBox(
                                                        child: getExtendedImage(GlobalProfile.getUserByUserID(totalList[index]).profileUrlList[0], 120, extendedController),
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(height: 8*sizeUnit),
                                                Container(
                                                  height: 16*sizeUnit,
                                                  width: 120*sizeUnit,
                                                  child: Text(
                                                    GlobalProfile.getUserByUserID(totalList[index]).name,
                                                    style: SheepsTextStyle.h4(context),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                SizedBox(height: 4*sizeUnit),
                                                Container(
                                                  width : 120*sizeUnit,
                                                  child: Wrap(
                                                    spacing: 4*sizeUnit,
                                                    runSpacing: 4*sizeUnit,
                                                    children: [
                                                      GlobalProfile.getUserByUserID(totalList[index]).part == null || GlobalProfile.getUserByUserID(totalList[index]).part == ''? SizedBox.shrink()
                                                          : Container(
                                                        height: 18*sizeUnit,
                                                        child: Padding(
                                                          padding: EdgeInsets.symmetric(horizontal: 4*sizeUnit),
                                                          child: Column(
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            children: [
                                                              Text(
                                                                GlobalProfile.getUserByUserID(totalList[index]).part,
                                                                style: SheepsTextStyle.cat1(context),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        decoration: BoxDecoration(
                                                          borderRadius: new BorderRadius.circular(4*sizeUnit),
                                                          color: hexToColor("#E5E5E5"),
                                                        ),
                                                      ),
                                                      GlobalProfile.getUserByUserID(totalList[index]).location == null || GlobalProfile.getUserByUserID(totalList[index]).subLocation == '' ? Container()
                                                          : Container(
                                                        height: 18*sizeUnit,
                                                        child: Padding(
                                                          padding: EdgeInsets.symmetric(horizontal: 4*sizeUnit),
                                                          child: Column(
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            children: [
                                                              Text(
                                                                GlobalProfile.getUserByUserID(totalList[index]).location,
                                                                style: SheepsTextStyle.cat1(context),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        decoration: BoxDecoration(
                                                          borderRadius: new BorderRadius.circular(4*sizeUnit),
                                                          color: hexToColor("#E5E5E5"),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }
                                    ),
                                  ),
                                  SizedBox(height: 80*sizeUnit),
                                ],
                              ),
                            ),
                          ]),
                        ),
                      ],
                    ),

                    bottomOpacity(context),
                    BottomButtons(context, _socket),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future BadgeDialogForDetailedTeamProfile(BuildContext context, int id) {
    return showGeneralDialog(
                                        context: context,
                                        barrierDismissible: true,
                                        barrierLabel:
                                        MaterialLocalizations.of(context).modalBarrierDismissLabel,
                                        barrierColor: Colors.black12.withOpacity(0.6),
                                        transitionDuration: Duration(milliseconds: 150),
                                        pageBuilder:
                                            (BuildContext context, Animation first, Animation second) {
                                          return Center(
                                            child: Container(
                                              decoration: new BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                new BorderRadius.all(new Radius.circular(8.0)),
                                              ),
                                              width: MediaQuery.of(context).size.width *
                                                  0.7777777777777778,
                                              height: MediaQuery.of(context).size.height * 0.65,
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  GestureDetector(
                                                    onTap: (){
                                                      Navigator.pop(context);
                                                    },
                                                    child: Align(
                                                      alignment: Alignment.topRight,
                                                      child: SvgPicture.asset(
                                                        GreyXIcon,
                                                        height: screenHeight*0.04375,
                                                        width: screenHeight*0.04375,
                                                      ),
                                                    ),
                                                  ),
                                                  SvgPicture.asset(
                                                    ReturnTeamBadgeSVG(id),
                                                    height: screenHeight*0.25,
                                                    width: screenHeight*0.25,

                                                  ),
                                                  SizedBox(height: screenHeight*0.025,),
                                                  Text(
                                                    '${TeamBadgeDescriptionList[id].Part}',
                                                    style: TextStyle(
                                                        fontSize: screenWidth*0.06666,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.black
                                                    ),
                                                  ),
                                                  SizedBox(height: 40*sizeUnit),
                                                  Text(
                                                    '${TeamBadgeDescriptionList[id].Part}',
                                                    style: TextStyle(
                                                        color: hexToColor('#AAAAAA'),
                                                        fontSize: 12*sizeUnit
                                                    ),
                                                  ),
                                                  SizedBox(height: screenHeight*0.025,),
                                                  Text(
                                                    '${TeamBadgeDescriptionList[id].Description}',
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 12*sizeUnit
                                                    ),
                                                  ),
                                                  Expanded(child:SizedBox()),
                                                  GestureDetector(
                                                    onTap: (){
                                                      Navigator.pop(context);
                                                    },
                                                    child: Container(
                                                      width: screenWidth*0.7111111,
                                                      height: screenHeight*0.0625,
                                                      decoration: BoxDecoration(
                                                        color: kPrimaryColor,
                                                        borderRadius: BorderRadius.circular(8*sizeUnit),
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          '확인',
                                                          style: TextStyle(
                                                              fontSize: 12*sizeUnit,
                                                              color: Colors.white
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(height: 20*sizeUnit),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      );
  }

  Positioned BottomButtons(BuildContext context, SocketProvider socket) {
    return Positioned(
      bottom: 0,
      child: //isShrink?
      AnimatedOpacity(
        duration: Duration(milliseconds: 100),
        opacity: isShrink ? 1 : 0,
        child: Container(
            width: 360*sizeUnit,
            height: 72*sizeUnit,
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                    top: BorderSide(
                      color : hexToColor('#eeeeee'),
                      width : 1.0,
                    )
                )
            ),
            child: Column(
              children: [
                SizedBox(height: 12*sizeUnit),
                Row(children: [
                  SizedBox(width:12*sizeUnit),
                  GestureDetector(
                    onTap: () {
                      if(INVITE_STATUS == INVITE_STATUS_WAITING ||
                          INVITE_STATUS == INVITE_STATUS_HAVE_NOT_TEAM_MEMBER ||
                          INVITE_STATUS == INVITE_STATUS_IMPOSSOBLE_JOIN) return;

                      if(false == isActiveChat){
                        Function okFunc = () async {
                          await ApiProvider().post('/Team/Request/Insert', jsonEncode(
                              {
                                "teamID" : modifyTeam.id,
                                "userID" : GlobalProfile.loggedInUser.userID,
                                "leaderID" : modifyTeam.leaderID,
                                "roomName" : roomName
                              }
                          ));

                          setState(() {
                            inviteWord = "요청 확인 중..";
                            inviteBoxColor = hexToColor('#CCCCCC');
                            INVITE_STATUS = INVITE_STATUS_WAITING;
                          });

                          Function func = () {
                            Navigator.pop(context); //팀 초대 요청 닫기
                            Navigator.pop(context); //바텀 팀 목록 닫기
                          };

                          showSheepsDialog(
                            context: context,
                            title: '참가 요청 완료!',
                            description: '팀 참가 요청을 보냈습니다!\n상대방이 수락하면 팀원으로 초대됩니다!',
                            okFunc: func,
                            isCancelButton: false,
                            isBarrierDismissible: false,
                          );
                        };

                        showSheepsDialog(
                          context: context,
                          title: '팀 요청하기',
                          isLogo: false,
                          description: '마음에 드시는 팀을 만나셨군요.\n팀 참가 요청을 보내볼까요?',
                          okText: '보낼래요',
                          okFunc: okFunc,
                          cancelText: '좀 더 생각해볼게요',
                        );
                      }else{
                        _socket.setRoomStatus(ROOM_STATUS_CHAT);
                        Navigator.push(
                            context,  // 기본 파라미터, SecondRoute로 전달
                            MaterialPageRoute(builder: (context)=>TeamChatPage(
                                roomName: roomName,
                                titleName :  modifyTeam.name,
                                chatUserList: GlobalProfile.getUserListByUserIDList(ChatGlobal.roomInfoList[roomIndex].chatUserIDList)))
                        ).then((value) {
                          setState(() {
                            socket.setRoomStatus(ROOM_STATUS_ETC);
                          });
                        });
                      }
                    },
                    child: Container(
                      width: 336*sizeUnit,
                      height: 48*sizeUnit,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8*sizeUnit),
                        color: inviteBoxColor,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          svgchatIcon != null ?
                          SvgPicture.asset(
                            svgchatIcon,
                            width: 24*sizeUnit,
                            height: 24*sizeUnit,
                          ) : Container(),
                          svgchatIcon != null ? SizedBox(width: 8*sizeUnit) : Container(),
                          Text(
                            inviteWord,
                            style: SheepsTextStyle.button1(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],),
              ],
            )
        ),
      ),
    );
  }

  Positioned bottomOpacity(BuildContext context) {
    return Positioned(
      bottom: 0,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 0),
        width: 360*sizeUnit,
        height: 120*sizeUnit,
        decoration: BoxDecoration(
          gradient: isShrink2
              ? LinearGradient(
              colors: [Colors.transparent, Colors.transparent],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter)
              : LinearGradient(colors: [
            Color.fromARGB(255, 255, 255, 255),
            Color.fromARGB(128, 255, 255, 255),
            Color.fromARGB(64, 255, 255, 255),
            Color.fromARGB(20, 255, 255, 255),
          ], stops: [
            0,
            0.15,
            0.4,
            1
          ], begin: Alignment.bottomCenter, end: Alignment.topCenter),
        ),
      ),
    );
  }

  AnimatedContainer buildDot({int index}) {
    return AnimatedContainer(
      duration: kAnimationDuration,
      margin: EdgeInsets.only(right: 4*sizeUnit),
      height: 4*sizeUnit,
      width: currentPage == index
          ? 12*sizeUnit
          : 4*sizeUnit,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(2*sizeUnit),
      ),
    );
  }

  SizedBox LeftPadding() => SizedBox(width: 12*sizeUnit);
}
