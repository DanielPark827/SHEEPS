import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:sheeps_app/Badge/model/ModelBadge.dart';
import 'package:sheeps_app/TeamProfileModifys/model/Team.dart';
import 'package:sheeps_app/chat/ChatPage.dart';
import 'package:sheeps_app/chat/TeamChatPage.dart';
import 'package:sheeps_app/chat/models/ChatGlobal.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/config/constants.dart';
import 'package:sheeps_app/network/ApiProvider.dart';
import 'package:sheeps_app/network/SocketProvider.dart';
import 'package:sheeps_app/profile/models/ModelPersonalLikes.dart';
import 'package:sheeps_app/userdata/GlobalProfile.dart';
import 'package:sheeps_app/userdata/User.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/config/GlobalAsset.dart';

import 'AddTeam/AddTeam.dart';
import 'DetailTeamProfile.dart';

enum PERSONAL_INVITE_STATUS{
  POSSIBLE,
  ALREADY,
  WAITING
}

enum TEAM_INVITE_STATUS{
  POSSIBLE,
  ALREADY,
  WAITING
}

class DetailProfile extends StatefulWidget {
  final int index;
  final UserData user;

  DetailProfile({Key key, @required this.index, @required this.user}) : super(key : key);

  @override
  _DetailProfileState createState() => _DetailProfileState();
}

class _DetailProfileState extends State<DetailProfile>
    with SingleTickerProviderStateMixin {
  double sizeUnit = 1;
  int currentPage = 0;
  bool lastStatus = true;
  bool lastStatus2 = true;

  String teamInviteWord;
  String inviteWord;
  Color teamInviteBoxColor;
  Color personalInviteBoxColor;

  // ignore: non_constant_identifier_names
  PERSONAL_INVITE_STATUS personal_invite_status;
  // ignore: non_constant_identifier_names
  TEAM_INVITE_STATUS team_invite_status;

  bool isActiveTeamChat = false;
  bool isActiveChat = false;
  String teamRoomName = '';
  int teamRoomIndex = 0;
  String roomName = '';
  int roomIndex = 0;

  SocketProvider _socket;
  ScrollController _scrollController;
  AnimationController extendedController;

  final String svgWhiteBackArrow = 'assets/images/Profile/WhiteBackArrow.svg';

  bool Likes = false;

  bool isCanTapLike = true;
  int tapLikeDelayMilliseconds = 500;

  List<ModelPersonalLikes> PersonalLikesList = [];

  Future<bool> init(BuildContext context) async {
    var list = await ApiProvider().post('/Profile/Personal/SelectLIke', jsonEncode(
        {
          "userID" : GlobalProfile.loggedInUser.userID,
        }
    ));
    if(null != list) {

      for(int i = 0; i < list.length; ++i){
        Map<String, dynamic> data = list[i];

        ModelPersonalLikes item = ModelPersonalLikes.fromJson(data);

        if(IsSame(item.TargetID, widget.user.userID)) {
          Likes = true;
        }

        PersonalLikesList.add(item);
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
        _scrollController.offset > (390 - kToolbarHeight);
  }

  bool get isShrink2 {
    return _scrollController.hasClients &&
        _scrollController.offset > (10);
  }

  Future setTeamList() async {
    var leaderList = await ApiProvider().post('/Team/Profile/Leader', jsonEncode(
        {
          "userID" :widget.user.userID
        }
    ));

    if(leaderList != null){
      for(int i = 0 ; i < leaderList.length; ++i){
        myTeamList.add(Team.fromJson(leaderList[i]));
      }
    }

    var teamList = await ApiProvider().post('/Team/Profile/SelectUser', jsonEncode({
      "userID" : widget.user.userID
    }));

    if(teamList != null){
      for(int i = 0 ; i < teamList.length; ++i){
        myTeamList.add(GlobalProfile.getTeamByID(teamList[i]['TeamID']));
      }
    }
  }

  Future setTeamInviteStatus() async {
    var res = await ApiProvider().post('/Team/Invite/SelectTarget', jsonEncode({
      "userID" : GlobalProfile.loggedInUser.userID,
      "inviteID" : widget.user.userID
    }));

    if(res == null){
      team_invite_status = TEAM_INVITE_STATUS.POSSIBLE;
      teamInviteWord = '팀 초대하기';
      teamInviteBoxColor = hexToColor('#61C680');
    }else{
      var response = res[0]['Response'];

      teamRoomName = getRoomName(res[0]['TeamID'], GlobalProfile.loggedInUser.userID, true);
      if(response == 1){
        for(int i = 0 ; i < ChatGlobal.roomInfoList.length; ++i){
          if(ChatGlobal.roomInfoList[i].roomName == teamRoomName){
            isActiveTeamChat = true;
            teamRoomIndex = i;
            break;
          }
        }

        team_invite_status = TEAM_INVITE_STATUS.ALREADY;
        teamInviteWord = '이미 팀원이에요!';
        teamInviteBoxColor = hexToColor('#888888');
      }else if(response == 2){
        team_invite_status = TEAM_INVITE_STATUS.POSSIBLE;
        teamInviteWord = '팀 초대하기';
        teamInviteBoxColor = hexToColor('#61C680');
      }else{
        team_invite_status = TEAM_INVITE_STATUS.WAITING;
        teamInviteWord = '팀 초대중..';
        teamInviteBoxColor = hexToColor('#CCCCCC');
      }
    }
  }

  Future setPersonalInviteStatus() async {

    var res = await ApiProvider().post('/Room/Invite/TargetSelect', jsonEncode({
      "userID" : GlobalProfile.loggedInUser.userID,
      "inviteID" : widget.user.userID
    }));

    (() async {
      roomName = getRoomName(GlobalProfile.loggedInUser.userID, widget.user.userID, false);
      if(res != null){
        for(int i = 0 ; i < ChatGlobal.roomInfoList.length; ++i){
          if(ChatGlobal.roomInfoList[i].roomName == roomName){
            isActiveChat = true;
            roomIndex = i;
            break;
          }
        }

        if(isActiveChat) {
          personal_invite_status = PERSONAL_INVITE_STATUS.ALREADY;
          inviteWord = '채팅방 가기';
          personalInviteBoxColor = hexToColor('#5C88DA');
        }else{
          if(res['Response'] == 2){
            personal_invite_status = PERSONAL_INVITE_STATUS.POSSIBLE;
            inviteWord = '채팅 초대하기';
            personalInviteBoxColor = hexToColor('#5C88DA');
          }
        }
      }else{
        personal_invite_status = PERSONAL_INVITE_STATUS.POSSIBLE;
        inviteWord = '채팅 초대하기';
        personalInviteBoxColor = hexToColor('#5C88DA');
      }
    })();
  }
  List<Team> myTeamList = List<Team>();

  @override
  void initState() {



    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);

    team_invite_status = TEAM_INVITE_STATUS.WAITING;
    teamInviteWord = '팀 초대중..';
    teamInviteBoxColor = hexToColor('#CCCCCC');

    personal_invite_status = PERSONAL_INVITE_STATUS.WAITING;
    inviteWord = '채팅 초대중..';
    personalInviteBoxColor = hexToColor('#CCCCCC');

    (() async {
      // await setTeamList().then((value) => {
      //   setTeamInviteStatus().then((value) => setPersonalInviteStatus()).then((value) {
      //     setState(() {
      //
      //     });
      //   })
      // });
      await setTeamList();
      await setTeamInviteStatus();
      await setPersonalInviteStatus();
    })().then((value) {
      setState(() {

      });
    });

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
      child: Container(
        color: Colors.white,
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),//사용자 스케일팩터 무시
          child: SafeArea(
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
                        title: Text(widget.user.name,
                          textAlign: TextAlign.center,
                          style: SheepsTextStyle.appBar(context).copyWith(color: isShrink ? Colors.black : Colors.transparent,),
                        ),
                        leading: appbarBackButton(context),
                        flexibleSpace: FlexibleSpaceBar(
                          centerTitle: true,
                          background: Hero(
                            tag: widget.user.userID,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                PageView.builder(
                                  onPageChanged: (value) {
                                    setState(() {
                                      currentPage = value;
                                    });
                                  },
                                  itemCount: widget.user.profileUrlList.length, //추후 이미지 여러개 부분 수정 필요
                                  itemBuilder: (context, index) => Stack(
                                    children: [
                                      widget.user.profileUrlList[0] == 'BasicImage' ?
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
                                        child:  Center(child: SvgPicture.asset(
                                          svgPersonalProfileBasicImage,
                                          width: 192*sizeUnit,
                                          height: 138*sizeUnit,
                                        ),
                                        ),
                                      )
                                          :
                                      Container(
                                        width: 360*sizeUnit,
                                        height: 360*sizeUnit,
                                        child: FittedBox(
                                          child: getExtendedImage(widget.user.profileUrlList[index], 0, extendedController, isRounded: false),
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
                                  child: Container(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: List.generate(
                                        widget.user.profileUrlList.length,
                                            (index) => buildDot(index: index),
                                      ),
                                    ),
                                  ),
                                ),
                                widget.user.badge1 != 0
                                    ? Positioned(
                                  right: 12*sizeUnit,
                                  bottom: 12*sizeUnit,
                                  child: GestureDetector(
                                    onTap: (){
                                      ShowBadgeDialogForDetailProfile(context,widget.user.badge1);
                                    },
                                    child: Container(
                                      width: 48*sizeUnit,
                                      height: 48*sizeUnit,
                                      child: ClipRRect(
                                        borderRadius:
                                        new BorderRadius.circular(8*sizeUnit),
                                        child: FittedBox(
                                          child: SvgPicture.asset(
                                            ReturnPersonalBadgeSVG(widget.user.badge1),
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                    : Container(),
                                widget.user.badge2 != 0
                                    ? Positioned(
                                  right: 60*sizeUnit,
                                  bottom: 12*sizeUnit,
                                  child: GestureDetector(
                                    onTap: (){
                                      ShowBadgeDialogForDetailProfile(context,widget.user.badge2);
                                    },
                                    child: Container(
                                      width: 48*sizeUnit,
                                      height: 48*sizeUnit,
                                      child: ClipRRect(
                                        borderRadius:
                                        new BorderRadius.circular(8*sizeUnit),
                                        child: FittedBox(
                                          child: SvgPicture.asset(
                                            ReturnPersonalBadgeSVG(widget.user.badge2),
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                    : Container(),
                                widget.user.badge3 != 0
                                    ? Positioned(
                                  right: 108*sizeUnit,
                                  bottom: 12*sizeUnit,
                                  child: GestureDetector(
                                    onTap: (){
                                      ShowBadgeDialogForDetailProfile(context,widget.user.badge3);
                                    },
                                    child: Container(
                                      width: 48*sizeUnit,
                                      height: 48*sizeUnit,
                                      child: ClipRRect(
                                        borderRadius:
                                        new BorderRadius.circular(8*sizeUnit),
                                        child: FittedBox(
                                          child: SvgPicture.asset(
                                            ReturnPersonalBadgeSVG(widget.user.badge3),
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
                                  padding: EdgeInsets.only(top: 20*sizeUnit, left: 12*sizeUnit),
                                  child: Row(
                                    children: [
                                      Container(
                                        height: 36*sizeUnit,
                                        width: 272*sizeUnit,
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(widget.user.name.length > 15 ? widget.user.name.substring(0,15) : widget.user.name,
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
                                                width: 21*sizeUnit,
                                                height: 21*sizeUnit,
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
                                                    var res = await ApiProvider().post('/Profile/Personal/InsertLIke', jsonEncode(
                                                        {
                                                          "userID" : GlobalProfile.loggedInUser.userID,
                                                          "targetID":widget.user.userID,
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
                                          }
                                      ),
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
                                        widget.user.part == null || widget.user.part.isEmpty ? SizedBox.shrink()
                                            : Container(
                                          height: 20*sizeUnit,
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 8*sizeUnit),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  widget.user.part,
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
                                        widget.user.subPart == null || widget.user.subPart.isEmpty ? SizedBox.shrink()
                                            : Container(
                                          height: 20*sizeUnit,
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 8*sizeUnit),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  widget.user.subPart,
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
                                        widget.user.location == null || widget.user.location.isEmpty ? SizedBox.shrink():
                                        Container(
                                          height: 20*sizeUnit,
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 8*sizeUnit),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  widget.user.location + " " + widget.user.subLocation,
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
                                        widget.user.information == null ? '' : widget.user.information,
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
                                      '학력',
                                      style: SheepsTextStyle.h3(context),
                                    ),
                                  ],
                                ),
                                widget.user.UserUnivList != null && widget.user.UserUnivList.length > 0?
                                Padding(
                                  padding: EdgeInsets.only(top: 8*sizeUnit),
                                  child: Row(
                                    children: [
                                      LeftPadding(),
                                      Text(
                                        '- ' + '${widget.user.UserUnivList[0].PfLicenseContents}'+' / 학사',
                                        style: SheepsTextStyle.b3(context),
                                      ),
                                      SheepsProfileVerificationStateIcon(context, widget.user.UserUnivList[0].PfLicenseAuth),
                                    ],
                                  ),
                                ) : SizedBox.shrink(),
                                widget.user.UserGraduateList != null && widget.user.UserGraduateList.length > 0?
                                Padding(
                                  padding: EdgeInsets.only(top: 8*sizeUnit),
                                  child: Row(
                                    children: [
                                      LeftPadding(),
                                      Text(
                                        '- ' + '${widget.user.UserGraduateList[0].PfGraduateName}'+' / 대학원',
                                        style: SheepsTextStyle.b3(context),
                                      ),
                                      SheepsProfileVerificationStateIcon(context, widget.user.UserGraduateList[0].PfGraduateAuth),
                                    ],
                                  ),
                                ) : SizedBox.shrink(),
                                SizedBox(height: 20*sizeUnit),
                                Row(
                                  children: [
                                    LeftPadding(),
                                    Text(
                                      '경력',
                                      style: SheepsTextStyle.h3(context),
                                    ),
                                  ],
                                ),
                                widget.user.UserCareerList != null && widget.user.UserCareerList.length > 0 ?  SizedBox(
                                  child: ListView.builder(
                                      physics: const NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      scrollDirection: Axis.vertical,
                                      itemCount: widget.user.UserCareerList.length,
                                      itemBuilder: (BuildContext context, int index) =>
                                          Column(
                                            children: [
                                              SizedBox(height: 8*sizeUnit),
                                              Row(
                                                children: [
                                                  LeftPadding(),
                                                  Container(
                                                    constraints: BoxConstraints(maxWidth: 300*sizeUnit),
                                                    child: Text(
                                                      '- '+'${widget.user.UserCareerList[index].PfCareerContents}',
                                                      style: SheepsTextStyle.b3(context),
                                                    ),
                                                  ),
                                                  SheepsProfileVerificationStateIcon(context, widget.user.UserCareerList[index].PfCareerAuth),
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
                                      '자격증',
                                      style: SheepsTextStyle.h3(context),
                                    ),
                                  ],
                                ),
                                widget.user.UserLicenseList != null && widget.user.UserLicenseList.length > 0 ?
                                SizedBox(
                                  child: ListView.builder(
                                      physics: const NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      scrollDirection: Axis.vertical,
                                      itemCount: widget.user.UserLicenseList.length,
                                      itemBuilder: (BuildContext context, int index) => Column(
                                        children: [
                                          SizedBox(height: 8*sizeUnit),
                                          Row(
                                            children: [
                                              LeftPadding(),
                                              Container(
                                                constraints: BoxConstraints(maxWidth: 300*sizeUnit),
                                                child: Text(
                                                  '- '+'${widget.user.UserLicenseList[index].PfLicenseContents}',
                                                  style: SheepsTextStyle.b3(context),
                                                ),
                                              ),
                                              SheepsProfileVerificationStateIcon(context, widget.user.UserLicenseList[index].PfLicenseAuth),
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
                                widget.user.UserWinList != null && widget.user.UserWinList.length > 0?  SizedBox(
                                  child: ListView.builder(
                                      physics: const NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      scrollDirection: Axis.vertical,
                                      itemCount: widget.user.UserWinList.length,
                                      itemBuilder: (BuildContext context, int index) => Column(
                                        children: [
                                          SizedBox(height: 8*sizeUnit),
                                          Row(
                                            children: [
                                              LeftPadding(),
                                              Container(
                                                constraints: BoxConstraints(maxWidth: 300*sizeUnit),
                                                child: Text(
                                                  '- '+'${widget.user.UserWinList[index].PfWinContents}',
                                                  style: SheepsTextStyle.b3(context),
                                                ),
                                              ),
                                              SheepsProfileVerificationStateIcon(context, widget.user.UserWinList[index].PfWinAuth),
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
                                      '소속 팀',
                                      style: SheepsTextStyle.h3(context),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8*sizeUnit),
                                Container(
                                  padding: EdgeInsets.fromLTRB(12*sizeUnit, 0, 0, 0),
                                  height: 160*sizeUnit,
                                  color: Colors.white,
                                  child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      cacheExtent: 30,
                                      reverse: false,
                                      shrinkWrap: true,
                                      itemCount: myTeamList.length,
                                      itemBuilder: (context, index) {
                                        return Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) => new DetailTeamProfile(
                                                            index: index,
                                                            team: myTeamList[index])));
                                              },
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  Stack(
                                                    children: [
                                                      Container(
                                                        width: 120*sizeUnit,
                                                        height: 120*sizeUnit,
                                                        child: GestureDetector(
                                                            onTap: () {
                                                              Navigator.push(
                                                                  context,
                                                                  PageRouteBuilder(
                                                                      transitionDuration:
                                                                      Duration(milliseconds: 300),
                                                                      pageBuilder: (_, __, ___) => DetailTeamProfile(
                                                                        index: index,
                                                                        team: myTeamList[index],
                                                                      )));
                                                            },
                                                            child:
                                                            myTeamList[index].profileUrlList[0] == 'BasicImage' ?
                                                            Container(
                                                              decoration: BoxDecoration(
                                                                color: hexToColor('#F8F8F8'),
                                                                borderRadius: new BorderRadius.circular(8*sizeUnit),
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                    color: Color.fromRGBO(116, 125, 130, 0.1),
                                                                    blurRadius: 2*sizeUnit,
                                                                    offset: Offset(1*sizeUnit, 1*sizeUnit)
                                                                  ),
                                                                ],
                                                              ),
                                                              child: Center(
                                                                  child: SvgPicture.asset(
                                                                    svgPersonalProfileBasicImage,
                                                                    width: 120*sizeUnit,
                                                                    height: 120*sizeUnit,
                                                                  )
                                                              ),
                                                            ) :
                                                            Container(
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
                                                                child: FittedBox(
                                                                    child:   getExtendedImage(myTeamList[index].profileUrlList[0], 120, extendedController)
                                                                )
                                                            )
                                                        ),
                                                      ),
                                                      Container(
                                                        color: Colors.black.withOpacity(0.8),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 8*sizeUnit),
                                                  Container(
                                                    height: 16*sizeUnit,
                                                    width: 120*sizeUnit,
                                                    child: Text(
                                                      myTeamList[index].name,
                                                      style: SheepsTextStyle.h4(context),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(width: 8*sizeUnit),
                                          ],
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
                    onTap: () async {
                      if(team_invite_status == TEAM_INVITE_STATUS.WAITING) return;

                      if(false == isActiveTeamChat){

                        var res = await ApiProvider().post('/Team/Profile/Leader', jsonEncode(
                            {
                              "userID" : GlobalProfile.loggedInUser.userID
                            }
                        ));

                        if(res == null || res.length == 0){
                          //팀이 하나도 없으면
                          Function okFunc = () {
                            //팀 만들기 페이지로 이동
                            Navigator.pop(context);

                            Navigator.push(
                                context, // 기본 파라미터, SecondRoute로 전달
                                MaterialPageRoute(
                                    builder: (context) =>
                                        AddTeam()) // SecondRoute를 생성하여 적재
                            );
                          };

                          Function cancelFunc = () {
                            Navigator.pop(context);
                          };

                          showSheepsDialog(
                              context: context,
                              title: '팀 프로필이 필요해요!',
                              isLogo: false,
                              description: '팀 프로필을 만들어야\n마음에 드는 팀원을 초대할 수 있어요!',
                              okText: '팀 프로필 만들기',
                              okFunc: okFunc,
                              cancelText: '좀 더 둘러볼래요',
                              cancelFunc: cancelFunc
                          );

                        }else{
                          //가지고 있는 팀이 하나라면

                          int teamID = 0;
                          if(res.length == 1){
                            teamID = res[0]['id'];

                            Function okFunc = () async {
                              String postRoomName = getRoomName(teamID, GlobalProfile.loggedInUser.userID, true);

                              await ApiProvider().post('/Team/Invite/Insert', jsonEncode(
                                  {
                                    "teamID" : teamID,
                                    "userID" : widget.user.userID,
                                    "leaderID" : GlobalProfile.loggedInUser.userID,
                                    "userName" : GlobalProfile.loggedInUser.name,
                                    "roomName" : postRoomName
                                  }
                              ));

                              setState(() {
                                teamInviteWord = "팀 초대중..";
                                teamInviteBoxColor = hexToColor('#CCCCCC');
                                team_invite_status = TEAM_INVITE_STATUS.WAITING;
                              });

                              Function func = () {
                                Navigator.pop(context); //참가 요청 완료 닫기
                                Navigator.pop(context); //팀 초대 요청 닫기
                              };

                              showSheepsDialog(
                                context: context,
                                title: '참가 요청 완료!',
                                isLogo: false,
                                description: '팀 참가 요청을 보냈습니다!\n상대방이 수락하면 팀원으로 초대됩니다!',
                                okFunc: (){
                                  Navigator.pop(context); //참가 요청 완료 닫기
                                  Navigator.pop(context); //팀 초대 요청 닫기
                                },
                              );
                            };

                            Function cancelFunc = () {
                              Navigator.pop(context);
                            };

                            showSheepsDialog(
                              context: context,
                              title: '팀 참가 요청',
                              isLogo: false,
                              description: '마음에 드시는 분을 만나셨군요.\n팀 초대 요청을 보내볼까요?',
                              okText: '보낼래요',
                              okFunc: okFunc,
                              cancelText: '좀 더 생각해볼게요',
                              cancelFunc: cancelFunc,
                            );
                          }
                          else{

                            List<Team> teamList = new List<Team>();

                            for(int i = 0 ; i < res.length; ++i){
                              teamList.add(Team.fromJson(res[i]));
                            }

                            //팀 목록 바텀 리스
                            await myTeamListBottomSheet(context, teamList);
                          }
                        }
                      }else{
                        _socket.setRoomStatus(ROOM_STATUS_CHAT);

                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => new TeamChatPage(
                                    roomName: teamRoomName,
                                    titleName: GlobalProfile.getTeamByRoomName(teamRoomName).name,
                                    chatUserList: GlobalProfile.getUserListByUserIDList(ChatGlobal.roomInfoList[teamRoomIndex].chatUserIDList)))).then((value){
                          setState(() {
                            _socket.setRoomStatus(ROOM_STATUS_ROOM);
                          });
                        });
                      }


                    },
                    child: Container(
                      width: 164*sizeUnit,
                      height: 48*sizeUnit,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8*sizeUnit),
                        color: teamInviteBoxColor,
                      ),
                      child: Center(
                        child: Text(
                          teamInviteWord,
                          style: SheepsTextStyle.button1(context),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: 8*sizeUnit),
                  GestureDetector(
                    onTap: () {
                      if(personal_invite_status == PERSONAL_INVITE_STATUS.WAITING) return;

                      if(false == isActiveChat){

                        Function okFunc = () {
                          ApiProvider().post('/Room/Invite/Insert', jsonEncode(
                              {
                                "userID" : GlobalProfile.loggedInUser.userID,
                                "inviteID" : widget.user.userID,
                                "userName" : GlobalProfile.loggedInUser.name
                              }
                          ));

                          setState(() {
                            inviteWord = "채팅 초대중..";
                            personalInviteBoxColor = hexToColor('#CCCCCC');
                            personal_invite_status = PERSONAL_INVITE_STATUS.WAITING;
                          });

                          Navigator.pop(context);
                        };

                        showSheepsDialog(
                          context: context,
                          title: '채팅 초대하기',
                          isLogo: false,
                          description: '마음에 드시는 분을 만나셨군요.\n채팅 초대 요청을 보내볼까요?',
                          okText: '보낼래요',
                          okFunc: okFunc,
                          cancelText: '좀 더 생각해볼게요',
                        );
                      }

                      if(personal_invite_status == PERSONAL_INVITE_STATUS.ALREADY){

                        _socket.setRoomStatus(ROOM_STATUS_CHAT);
                        Navigator.push(
                            context,  // 기본 파라미터, SecondRoute로 전달
                            MaterialPageRoute(builder: (context)=>ChatPage(roomName: roomName, chatUser: widget.user,))
                        ).then((value) {
                          setState(() {
                            socket.setRoomStatus(ROOM_STATUS_ETC);
                          });
                        });
                      }
                    },
                    child: Container(
                      width: 164*sizeUnit,
                      height: 48*sizeUnit,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8*sizeUnit),
                        color: personalInviteBoxColor,
                      ),
                      child: Center(
                        child: Text(
                          inviteWord,
                          style: SheepsTextStyle.button1(context),
                        ),
                      ),
                    ),
                  )
                ],),
              ],
            )
        ),
      ),
    );
  }

  Future myTeamListBottomSheet(context, List<Team> list) async {

    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.only(
                topLeft: const Radius.circular(8.0),
                topRight: const Radius.circular(8.0))),
        context: context,
        backgroundColor: Colors.white,
        builder: (BuildContext bc) {
          return SizedBox(
            height: 240*sizeUnit,
            child: Column(
              children: [
                SizedBox(height: 8*sizeUnit),
                Container(
                  height: 4*sizeUnit,
                  width: 20*sizeUnit,
                  decoration: BoxDecoration(
                    color: Color(0xFFEEEEEE),
                    borderRadius: new BorderRadius.circular(2 * sizeUnit),
                    border: Border.all(style: BorderStyle.none),
                  ),
                ),
                SizedBox(height: 8*sizeUnit),
                Expanded(
                  child: ListView.separated(
                    separatorBuilder: (context, index) => Divider(
                      color: hexToColor("#E5E5E5"),
                      thickness: 1.5,
                    ),
                    cacheExtent: 30,
                    reverse: false,
                    shrinkWrap: true,
                    padding: EdgeInsets.fromLTRB(12*sizeUnit, 0.0, 12*sizeUnit, 0.0),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Function okFunc = () {
                            String postRoomName = getRoomName(list[index].id, GlobalProfile.loggedInUser.userID, true);

                            ApiProvider().post('/Team/Invite/Insert', jsonEncode(
                                {
                                  "teamID" : list[index].id,
                                  "leaderID" : list[index].leaderID,
                                  "userID" : widget.user.userID,
                                  "userName" : GlobalProfile.loggedInUser.name,
                                  "roomName" : postRoomName,
                                }
                            ));

                            setState(() {
                              teamInviteWord = "팀 초대중..";
                              teamInviteBoxColor = hexToColor('#CCCCCC');
                              team_invite_status = TEAM_INVITE_STATUS.WAITING;
                            });

                            Function func = () {
                              Navigator.pop(context); //참가 요청 완료 닫기
                              Navigator.pop(context); //팀 초대 요청 닫기
                              Navigator.pop(context); //바텀 팀 목록 닫기
                            };

                            showSheepsDialog(
                              context: context,
                              title: '참가 요청 완료!',
                              isLogo: false,
                              description: '팀 참가 요청을 보냈습니다!\n상대방이 수락하면 팀원으로 초대됩니다!',
                              okFunc: (){
                                Navigator.pop(context); //참가 요청 완료 닫기
                                Navigator.pop(context); //팀 초대 요청 닫기
                              },
                              isCancelButton: false,
                            );
                          };

                          Function cancelFunc = () {
                            Navigator.pop(context);
                          };
                          showSheepsDialog(
                            context: context,
                            title: '팀 참가 요청',
                            isLogo: false,
                            description: '마음에 드시는 분을 만나셨군요.\n팀 초대 요청을 보내볼까요?',
                            okText: '보낼래요',
                            okFunc: okFunc,
                            cancelText: '좀 더 생각해볼게요',
                            cancelFunc: cancelFunc,
                          );

                          //showAlertDialog(context, "팀 참가 요청", "마음에 드시는 분을 만나셨군요.\n팀 초대 요청을 보내볼까요?", "보낼래요", "좀 더 생각해볼게요", okFunc, cancelFunc);
                        },
                        child: Container(
                          height: 48*sizeUnit,
                          child: Row(
                            children: [
                              list[index].profileUrlList[0] == "BasicImage" ?
                              Container(
                                  width: 40*sizeUnit,
                                  height: 40*sizeUnit,
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
                                  child:
                                  SvgPicture.asset(
                                    svgPersonalProfileBasicImage,
                                    width: 60*sizeUnit,
                                    height: 60*sizeUnit,
                                  )
                              ) :

                              ClipRRect(
                                  borderRadius: new BorderRadius.circular(8*sizeUnit),
                                  child: FittedBox(child: getExtendedImage(list[index].profileUrlList[0], 120, extendedController),
                                  )
                              ),
                              SizedBox(width: 8*sizeUnit),
                              Text(list[index].name, style: SheepsTextStyle.b1(context)),
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
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        });
  }

  Positioned bottomOpacity(BuildContext context) {
    return Positioned(
      bottom: 0,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 0),
        width: 360*sizeUnit,
        height: 72*sizeUnit,
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

  InkWell appbarBackButton(BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() {
          Likes = false;
        });
        Navigator.pop(context);
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

  Future ShowBadgeDialogForDetailProfile(BuildContext context,int badgeId) {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(8 * sizeUnit)),
            actions: [
              Container(
                width: 280*sizeUnit,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(8*sizeUnit)),
                ),
                padding: EdgeInsets.all(12*sizeUnit),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: (){
                            Navigator.pop(context);
                          },
                          child: SvgPicture.asset(
                            svgGreyXIcon,
                            height: 28*sizeUnit,
                            width: 28*sizeUnit,
                          ),
                        ),
                      ],
                    ),
                    SvgPicture.asset(
                      ReturnPersonalBadgeSVG(badgeId),
                      height: 160*sizeUnit,
                      width: 160*sizeUnit,
                    ),
                    SizedBox(height: 16*sizeUnit),
                    Text(
                      '${PersonalBadgeDescriptionList[badgeId].Part}',
                      style: SheepsTextStyle.h1(context),
                    ),
                    SizedBox(height: 8*sizeUnit),
                    Text(
                      '${PersonalBadgeDescriptionList[badgeId].Title}',
                      style: SheepsTextStyle.b4(context),
                    ),
                    SizedBox(height: 16*sizeUnit),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12*sizeUnit),
                      child: Text(
                        '${PersonalBadgeDescriptionList[badgeId].Description}',
                        style: SheepsTextStyle.b3(context),
                      ),
                    ),
                    SizedBox(height: 20*sizeUnit),
                    GestureDetector(
                      onTap: (){

                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 240*sizeUnit,
                        height: 48*sizeUnit,
                        decoration: BoxDecoration(
                          color: kPrimaryColor,
                          borderRadius: BorderRadius.circular(8*sizeUnit),
                        ),
                        child: Center(
                          child: Text(
                            '확인',
                            style: SheepsTextStyle.button1(context),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          );
        }
    );
  }

  SizedBox LeftPadding() => SizedBox(width: 12*sizeUnit);
}
