import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sheeps_app/Badge/model/ModelBadge.dart';
import 'package:sheeps_app/TeamProfileModifys/model/Team.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/network/ApiProvider.dart';
import 'package:sheeps_app/userdata/GlobalProfile.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'AddTeam/AddTeam.dart';
import 'DetailTeamProfile.dart';
import 'package:sheeps_app/config/GlobalAsset.dart';
import 'package:sheeps_app/config/constants.dart';


class MyTeamProfile extends StatefulWidget {
  @override
  _MyTeamProfileState createState() => _MyTeamProfileState();
}

class _MyTeamProfileState extends State<MyTeamProfile> with SingleTickerProviderStateMixin {
  final String svgAddTeamIcon= 'assets/images/Profile/AddTeamIcon.svg';

  List<Team> myTeamList = List<Team>();

  ScrollController _scrollController = ScrollController();
  AnimationController extendedController;

  double sizeUnit = 1;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    extendedController = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 3),
        lowerBound: 0.0,
        upperBound: 1.0);

    //내 팀 리스트를 만들어야하는데, 리더리스트랑 팀리스트랑 더해야하나 고민되네
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
          myTeamList.add(await GlobalProfile.getFutureTeamByID(teamList[i]['TeamID']));
        }
      }
    }).then((value) {
      setState(() {

      });
    });

  }

  @override
  void dispose() {
    // TODO: implement dispose

    _scrollController.dispose();
    extendedController.dispose();
    super.dispose();
  }

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
              floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
              appBar: SheepsAppBar(context,'나의 팀 프로필'),
              body:
                Container(
                  color: Colors.white,
                  padding:EdgeInsets.only(
                      top: 20*sizeUnit,
                      left: 12*sizeUnit,
                      right: 12*sizeUnit,
                  ),
                  child: myTeamList.length > 0
                    ? GridView.count(
                      //primary: false,
                      controller: _scrollController,
                      mainAxisSpacing: 16*sizeUnit,
                      crossAxisSpacing: 16*sizeUnit,
                      crossAxisCount: 2,
                      childAspectRatio: 160 / 292,
                      //각 그리드뷰 비율 조정
                      children: List.generate(myTeamList.length, (index) {
                        if(index == myTeamList.length){
                          return CupertinoActivityIndicator();
                        }
                        return Container(
                          width: 160*sizeUnit,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Hero(
                                tag: GlobalProfile.teamProfile[index].id,
                                //tag: "${PersonalProfile[index].Id}",
                                //tag: "1",
                                child: Stack(
                                  children: [
                                    Container(
                                      width: 160*sizeUnit,
                                      height: 160*sizeUnit,
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
                                                    ))).then((value) {
                                                      setState(() {
                                                        myTeamList[index] = value;
                                                      });
                                            });
                                          },
                                          child:
                                          myTeamList[index].profileUrlList[0] == 'BasicImage' ?
                                          Container(
                                            decoration: BoxDecoration(
                                              color: hexToColor('#F8F8F8'),
                                              borderRadius: new BorderRadius.circular(8*sizeUnit),
                                              boxShadow: [
                                                new BoxShadow(
                                                  color: Color.fromRGBO(116, 125, 130, 0.2),
                                                  offset: Offset(1,1),
                                                  blurRadius: 4,
                                                ),
                                              ],
                                            ),
                                            child:  Center(child: SvgPicture.asset(svgPersonalProfileBasicImage,width: 84*sizeUnit,height: 84*sizeUnit)),
                                          ) :
                                          Container(
                                              width: 160*sizeUnit,
                                              height: 160*sizeUnit,
                                              decoration: BoxDecoration(
                                                boxShadow: [
                                                  new BoxShadow(
                                                    color: Color.fromRGBO(116, 125, 130, 0.2),
                                                    offset: Offset(1,1),
                                                    blurRadius: 4,
                                                  ),
                                                ],
                                              ),
                                              child: FittedBox(
                                                  child:   getExtendedImage(myTeamList[index].profileUrlList[0], 160, extendedController),
                                                fit: BoxFit.fill,
                                              )
                                          )
                                      ),
                                    ),
                                    Container(
                                      color: Colors.black.withOpacity(0.8),
                                    ),
                                    myTeamList[index].badge1 != 0
                                        ? Badge1(context, index)
                                        : Container(),
                                    myTeamList[index].badge2 != 0
                                        ? Badge2(context, index)
                                        : Container(),
                                    myTeamList[index].badge3 != 0
                                        ? Badge3(context, index)
                                        : Container(),
                                  ],
                                ),
                              ),
                              SizedBox(height: 8*sizeUnit),
                              Container(
                                height: 22*sizeUnit,
                                width: 160*sizeUnit,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    myTeamList[index].name,
                                    style: SheepsTextStyle.h3(context),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              SizedBox(height: 4*sizeUnit),
                              Wrap(
                                runSpacing:  4*sizeUnit,
                                spacing: 4*sizeUnit,
                                children: [
                                  Tag3(context, index),
                                  Tag1(context, index),
                                  Tag2(context, index),
                                ],
                              ),
                              SizedBox(height: 8*sizeUnit),
                              Container(
                                height: 48*sizeUnit,
                                child: Text(
                                  myTeamList[index].information,
                                  maxLines: 3,
                                  style: SheepsTextStyle.b4(context).copyWith(height: 1.3),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    )
                    : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(svgGreySheepEyeX,width: 192*sizeUnit ,height: 138*sizeUnit),
                        SizedBox(height: 40*sizeUnit),
                        Center(
                          child: Text(
                            '참가한 팀이 없습니다.\n팀 생성 또는 참가 요청을 해보세요!',
                            style: SheepsTextStyle.b2(context),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                ),
              floatingActionButton: GestureDetector(
                onTap: (){
                  Navigator.push(
                      context, // 기본 파라미터, SecondRoute로 전달
                      MaterialPageRoute(
                          builder: (context) =>
                              AddTeam()) // SecondRoute를 생성하여 적재
                  ).then((value) {
                    setState(() {
                      if(value != null){
                        myTeamList.insert(0, value);
                      }
                    });
                  });
                },
                child: Padding(
                  padding: EdgeInsets.only(bottom:72*sizeUnit),
                  child: Container(
                    width: 100*sizeUnit,
                    height: 32*sizeUnit,
                    decoration: new BoxDecoration(
                      color: Color(0xFFEFF9F2),
                      borderRadius: new BorderRadius.circular(8*sizeUnit),
                      boxShadow: [
                        new BoxShadow(
                          color: Color.fromRGBO(116, 125, 130, 0.2),
                          offset: Offset(1*sizeUnit,1*sizeUnit),
                          blurRadius: 4,
                        ),],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(svgAddTeamIcon,width: 16*sizeUnit,height: 16*sizeUnit),
                        SizedBox(width: 8*sizeUnit),
                        Text('팀 생성',
                          style: SheepsTextStyle.b3(context),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Positioned Badge3(BuildContext context, int index) {
    return Positioned(
      right: 72*sizeUnit,
      bottom: 8*sizeUnit,
      child: Container(
        width: 32*sizeUnit,
        height: 32*sizeUnit,
        child: ClipRRect(
          borderRadius: new BorderRadius.circular(8*sizeUnit),
          child: FittedBox(
            child: SvgPicture.asset(
              ReturnTeamBadgeSVG(myTeamList[index].badge3),
            ),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Positioned Badge2(BuildContext context, int index) {
    return Positioned(
      right: 40*sizeUnit,
      bottom: 8*sizeUnit,
      child: Container(
        width: 32*sizeUnit,
        height: 32*sizeUnit,
        child: ClipRRect(
          borderRadius: new BorderRadius.circular(8*sizeUnit),
          child: FittedBox(
            child: SvgPicture.asset(
              ReturnTeamBadgeSVG(myTeamList[index].badge2),
            ),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Positioned Badge1(BuildContext context, int index) {
    return Positioned(
      right: 8*sizeUnit,
      bottom: 8*sizeUnit,
      child: GestureDetector(
        onTap: (){
          BadgeDialogForDetailedTeamProfile(context,index);
        },
        child: Container(
          width: 32*sizeUnit,
          height: 32*sizeUnit,
          child: ClipRRect(
            borderRadius: new BorderRadius.circular(8*sizeUnit),
            child: FittedBox(
              child: SvgPicture.asset(
                ReturnTeamBadgeSVG(myTeamList[index].badge1),
              ),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }

  Container Tag3(BuildContext context, int index) {
    return Container(
      height: 18*sizeUnit,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8*sizeUnit),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              myTeamList[index].category,
              style: SheepsTextStyle.cat1(context),
            ),
          ],
        ),
      ),
      decoration: BoxDecoration(
        borderRadius: new BorderRadius.circular(4.0*sizeUnit),
        color: hexToColor("#E5E5E5"),
      ),
    );
  }

  Container Tag2(BuildContext context, int index) {
    String location = (myTeamList[index].location == null || myTeamList[index].location == '') ? '' : myTeamList[index].location;
    String subLocation = (myTeamList[index].subLocation == null || myTeamList[index].subLocation == '') ? '' : myTeamList[index].subLocation;

    return Container(
      height: 18*sizeUnit,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8*sizeUnit),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              location + ' ' + subLocation,
              style: SheepsTextStyle.cat1(context),
            ),
          ],
        ),
      ),
      decoration: BoxDecoration(
        borderRadius: new BorderRadius.circular(4*sizeUnit),
        color: hexToColor("#E5E5E5"),
      ),
    );
  }

  Container Tag1(BuildContext context, int index) {
    return Container(
      height: 18*sizeUnit,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8*sizeUnit),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              myTeamList[index].part,
              style: SheepsTextStyle.cat1(context),
            ),
          ],
        ),
      ),
      decoration: BoxDecoration(
        borderRadius: new BorderRadius.circular(4*sizeUnit),
        color: hexToColor("#E5E5E5"),
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
                      svgGreyXIcon,
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
}
