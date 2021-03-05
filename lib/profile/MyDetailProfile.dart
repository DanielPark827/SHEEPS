import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:sheeps_app/Badge/model/ModelBadge.dart';
import 'package:sheeps_app/TeamProfileModifys/model/Team.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/config/constants.dart';
import 'package:sheeps_app/profile/DetailTeamProfile.dart';
import 'package:sheeps_app/network/ApiProvider.dart';
import 'package:sheeps_app/network/SocketProvider.dart';
import 'package:sheeps_app/profileModify/MyProfileModify.dart';
import 'package:sheeps_app/userdata/GlobalProfile.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/config/GlobalAsset.dart';


class MyDetailProfile extends StatefulWidget {
  final int index;

  MyDetailProfile({Key key, @required this.index}) : super(key : key);

  @override
  _MyDetailProfileState createState() => _MyDetailProfileState();
}

class _MyDetailProfileState extends State<MyDetailProfile>
    with SingleTickerProviderStateMixin {
  double sizeUnit = 1;
  int currentPage = 0;
  bool lastStatus = true;
  bool lastStatus2 = true;


  SocketProvider _socket;
  ScrollController _scrollController = ScrollController();
  final String svgWhiteBackArrow = 'assets/images/Profile/WhiteBackArrow.svg';
  final String svgSetting = 'assets/images/ProfileModify/Setting.svg';

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
  AnimationController extendedController;
  List<Team> myTeamList = List<Team>();

  @override
  void initState() {
    Future.microtask(() async {
      var leaderList = await ApiProvider().post('/Team/Profile/Leader', jsonEncode(
          {
            "userID" : GlobalProfile.loggedInUser.userID
          }
      ));

      if(leaderList != null){
        for(int i = 0 ; i < leaderList.length; ++i){
          myTeamList.add(Team.fromJson(leaderList[i]));
        }
      }

      var teamList = await ApiProvider().post('/Team/Profile/SelectUser', jsonEncode({
        "userID" : GlobalProfile.loggedInUser.userID
      }));

      if(teamList != null){

        for(int i = 0 ; i < teamList.length; ++i){
          myTeamList.add(GlobalProfile.getTeamByID(teamList[i]['TeamID']));
        }
      }
    }).then((value) {
      setState(() {

      });
    });


    extendedController = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 3),
        lowerBound: 0.0,
        upperBound: 1.0);

    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);

    super.initState();
  }

  @override
  void dispose() {
    _scrollController?.removeListener(_scrollListener);
    _scrollController?.dispose();
    extendedController?.dispose();
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
                        title: Text(GlobalProfile.loggedInUser.name,
                            textAlign: TextAlign.center,
                            style: SheepsTextStyle.appBar(context).copyWith(color: isShrink ? Colors.black : Colors.transparent,),
                        ),
                        leading: appbarBackButton(context),
                        actions: [
                          appbarMyDetailProfile(context),
                        ],
                        flexibleSpace: FlexibleSpaceBar(
                          centerTitle: true,
                          background: Hero(
                            tag: GlobalProfile.loggedInUser.userID,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                PageView.builder(
                                  onPageChanged: (value) {
                                    setState(() {
                                      currentPage = value;
                                    });
                                  },
                                  itemCount: GlobalProfile.loggedInUser.profileUrlList.length, //추후 이미지 여러개 부분 수정 필요
                                  itemBuilder: (context, index) => Stack(
                                    children: [
                                      GlobalProfile.loggedInUser.profileUrlList[0] == 'BasicImage'
                                          ?
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
                                              ),
                                          ),
                                      )
                                          :
                                       Container(
                                          width: 360*sizeUnit,
                                          height: 360*sizeUnit,
                                          child: FittedBox(
                                            child: getExtendedImage(GlobalProfile.loggedInUser.profileUrlList[index], 0, extendedController, isRounded: false),
                                            fit: BoxFit.cover,
                                          )
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
                                      GlobalProfile.loggedInUser.profileUrlList.length,
                                          (index) => buildDot(index: index),
                                    ),
                                  ),
                                ),
                                GlobalProfile.loggedInUser.badge1 != 0
                                    ? Positioned(
                                  right: 12*sizeUnit,
                                  bottom: 12*sizeUnit,
                                  child: GestureDetector(
                                    onTap: (){
                                      ShowBadgeDialogForDetailProfile(context, GlobalProfile.loggedInUser.badge1);
                                    },
                                    child: Container(
                                      width: 48*sizeUnit,
                                      height: 48*sizeUnit,
                                      child: ClipRRect(
                                        borderRadius:
                                        new BorderRadius.circular(8*sizeUnit),
                                        child: FittedBox(
                                          child: SvgPicture.asset(
                                            ReturnPersonalBadgeSVG(GlobalProfile.loggedInUser.badge1),
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                    : Container(),
                                GlobalProfile.loggedInUser.badge2 != 0
                                    ? Positioned(
                                  right: 60*sizeUnit,
                                  bottom: 12*sizeUnit,
                                  child: GestureDetector(
                                    onTap: (){
                                      ShowBadgeDialogForDetailProfile(context, GlobalProfile.loggedInUser.badge2);
                                    },
                                    child: Container(
                                      width: 48*sizeUnit,
                                      height: 48*sizeUnit,
                                      child: ClipRRect(
                                        borderRadius:
                                        new BorderRadius.circular(8*sizeUnit),
                                        child: FittedBox(
                                          child: SvgPicture.asset(
                                            ReturnPersonalBadgeSVG(GlobalProfile.loggedInUser.badge2),
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                    : Container(),
                                GlobalProfile.loggedInUser.badge3 != 0
                                    ? Positioned(
                                  right: 108*sizeUnit,
                                  bottom: 12*sizeUnit,
                                  child: GestureDetector(
                                    onTap: (){
                                      ShowBadgeDialogForDetailProfile(context, GlobalProfile.loggedInUser.badge3);
                                    },
                                    child: Container(
                                      width: 48*sizeUnit,
                                      height: 48*sizeUnit,
                                      child: ClipRRect(
                                        borderRadius:
                                        new BorderRadius.circular(8*sizeUnit),
                                        child: FittedBox(
                                          child: SvgPicture.asset(
                                            ReturnPersonalBadgeSVG(GlobalProfile.loggedInUser.badge3),
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
                                        width: 280*sizeUnit,
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(GlobalProfile.loggedInUser.name,
                                            style: SheepsTextStyle.h1(context).copyWith(fontSize: 24*sizeUnit),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      Spacer(),
                                      Padding(
                                        padding: EdgeInsets.only(right: 12*sizeUnit),
                                        child: SvgPicture.asset(
                                          svgShareBox,
                                          width: 21*sizeUnit,
                                          height: 21*sizeUnit,
                                        ),
                                      ),
                                      RightPadding(),
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
                                        GlobalProfile.loggedInUser.part == null || GlobalProfile.loggedInUser.part.isEmpty ? SizedBox.shrink()
                                            : Container(
                                          height: 20*sizeUnit,
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 8*sizeUnit),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  GlobalProfile.loggedInUser.part,
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
                                        GlobalProfile.loggedInUser.subPart == null || GlobalProfile.loggedInUser.subPart.isEmpty ? SizedBox.shrink()
                                            : Container(
                                          height: 20*sizeUnit,
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 8*sizeUnit),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  GlobalProfile.loggedInUser.subPart,
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
                                        GlobalProfile.loggedInUser.location == null || GlobalProfile.loggedInUser.location.isEmpty ? SizedBox.shrink()
                                            : Container(
                                          height: 20*sizeUnit,
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 8*sizeUnit),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  GlobalProfile.loggedInUser.location + " " + GlobalProfile.loggedInUser.subLocation,
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
                                          GlobalProfile.loggedInUser.information == null || GlobalProfile.loggedInUser.information.isEmpty ? '' : GlobalProfile.loggedInUser.information,
                                          style: SheepsTextStyle.b3(context),
                                        )
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
                                GlobalProfile.loggedInUser.UserUnivList != null && GlobalProfile.loggedInUser.UserUnivList.length > 0 ?
                                Padding(
                                  padding: EdgeInsets.only(top: 8*sizeUnit),
                                  child: Row(
                                    children: [
                                      LeftPadding(),
                                      Text(
                                        GlobalProfile.loggedInUser.UserUnivList[0].PfLicenseContents==null ? '- 학사 미기재':'- ' + '${GlobalProfile.loggedInUser.UserUnivList[0].PfLicenseContents}'+' / 학사',
                                        style: SheepsTextStyle.b3(context),
                                      ),
                                      SheepsProfileVerificationStateIcon(context, GlobalProfile.loggedInUser.UserUnivList[0].PfLicenseAuth),
                                    ],
                                  ),
                                ) : SizedBox.shrink(),
                                GlobalProfile.loggedInUser.UserGraduateList != null && GlobalProfile.loggedInUser.UserGraduateList.length > 0 ?
                                Padding(
                                  padding: EdgeInsets.only(top: 8*sizeUnit),
                                  child: Row(
                                    children: [
                                      LeftPadding(),
                                      Text(
                                        '- ' + '${GlobalProfile.loggedInUser.UserGraduateList[0].PfGraduateName}'+' / 대학원',
                                        style: SheepsTextStyle.b3(context),
                                      ),
                                      SheepsProfileVerificationStateIcon(context, GlobalProfile.loggedInUser.UserGraduateList[0].PfGraduateAuth),
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
                                GlobalProfile.loggedInUser.UserCareerList != null && GlobalProfile.loggedInUser.UserCareerList.length > 0 ?
                                SizedBox(
                                  child: ListView.builder(
                                      physics: const NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      scrollDirection: Axis.vertical,
                                      itemCount: GlobalProfile.loggedInUser.UserCareerList.length,
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
                                                  '- '+'${GlobalProfile.loggedInUser.UserCareerList[index].PfCareerContents}',
                                                  style: SheepsTextStyle.b3(context),
                                                ),
                                              ),
                                              SheepsProfileVerificationStateIcon(context, GlobalProfile.loggedInUser.UserCareerList[index].PfCareerAuth),
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
                                GlobalProfile.loggedInUser.UserLicenseList != null && GlobalProfile.loggedInUser.UserLicenseList.length > 0 ?
                                SizedBox(
                                  child: ListView.builder(
                                      physics: const NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      scrollDirection: Axis.vertical,
                                      itemCount: GlobalProfile.loggedInUser.UserLicenseList.length,
                                      itemBuilder: (BuildContext context, int index) => Column(
                                        children: [
                                          SizedBox(height: 8*sizeUnit),
                                          Row(
                                            children: [
                                              LeftPadding(),
                                              Container(
                                                constraints: BoxConstraints(maxWidth: 300*sizeUnit),
                                                child: Text(
                                                  '- '+'${GlobalProfile.loggedInUser.UserLicenseList[index].PfLicenseContents}',
                                                  style: SheepsTextStyle.b3(context),
                                                ),
                                              ),
                                              SheepsProfileVerificationStateIcon(context, GlobalProfile.loggedInUser.UserLicenseList[index].PfLicenseAuth),
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
                                      '수상 이력',
                                      style: SheepsTextStyle.h3(context),
                                    ),
                                  ],
                                ),
                                GlobalProfile.loggedInUser.UserWinList != null && GlobalProfile.loggedInUser.UserWinList.length > 0 ?
                                SizedBox(
                                  child: ListView.builder(
                                      physics: const NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      scrollDirection: Axis.vertical,
                                      itemCount:GlobalProfile.loggedInUser.UserWinList.length,
                                      itemBuilder: (BuildContext context, int index) => Column(
                                        children: [
                                          SizedBox(height: 8*sizeUnit),
                                          Row(
                                            children: [
                                              LeftPadding(),
                                              Container(
                                                constraints: BoxConstraints(maxWidth: 300*sizeUnit),
                                                child: Text(
                                                  '- '+'${GlobalProfile.loggedInUser.UserWinList[index].PfWinContents}',
                                                  style: SheepsTextStyle.b3(context),
                                                ),
                                              ),
                                              SheepsProfileVerificationStateIcon(context, GlobalProfile.loggedInUser.UserWinList[index].PfWinAuth),
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
                                                    PageRouteBuilder(
                                                        transitionDuration:
                                                        Duration(milliseconds: 300),
                                                        pageBuilder: (_, __, ___) => DetailTeamProfile(
                                                          index: index,
                                                          team: myTeamList[index],
                                                        )
                                                    )
                                                );
                                              },
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  Stack(
                                                    children: [
                                                      myTeamList[index].profileUrlList[0] == 'BasicImage' ?
                                                      Container(
                                                        width: 120*sizeUnit,
                                                        height: 120*sizeUnit,
                                                        decoration: BoxDecoration(
                                                          color: hexToColor('#F8F8F8'),
                                                          borderRadius: new BorderRadius.circular(8*sizeUnit),
                                                        ),
                                                        child:  Center(
                                                          child: SvgPicture.asset(
                                                            svgPersonalProfileBasicImage,
                                                            width: 120*sizeUnit,
                                                            height: 120*sizeUnit,
                                                          ),
                                                        ),
                                                      ) :
                                                      Container(
                                                          width: 120*sizeUnit,
                                                          height: 120*sizeUnit,
                                                          child: FittedBox(
                                                              child: getExtendedImage(myTeamList[index].profileUrlList[0], 120, extendedController)
                                                          )
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
                              ],
                            ),
                          ),

                        ]),

                      ),
                    ],
                  ),
                  bottomOpacity(context),
                  //BottomButtons(context, _socket),
                ],
              ),
            ),
          ),
        ),
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

  InkWell appbarMyDetailProfile(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context, // 기본 파라미터, SecondRoute로 전달
            MaterialPageRoute(
                builder: (context) => MyProfileModify())).then((value) {
          setState(() {

          });
        });
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
    );
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
      margin: EdgeInsets.only(right: 5),
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
  SizedBox RightPadding() => SizedBox(width: 12*sizeUnit);
}
