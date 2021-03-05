import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sheeps_app/TeamProfileModifys/model/Team.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/GlobalAsset.dart';
import 'package:sheeps_app/config/constants.dart';
import 'package:sheeps_app/network/ApiProvider.dart';
import 'package:sheeps_app/userdata/MyBadge.dart';
import 'package:sheeps_app/Badge/model/ModelBadge.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';

class AddBadgeForTeamProfileModify extends StatefulWidget {
  final Team team;

  AddBadgeForTeamProfileModify({Key key, @required this.team}) : super(key : key);

  @override
  _AddBadgeState createState() => _AddBadgeState();
}

class _AddBadgeState extends State<AddBadgeForTeamProfileModify> {
  double sizeUnit = 1;
  final svgBlackBadge = 'assets/images/Badge/BlackBadge.svg';

  List<BadgeModel> TeamBadgeList = [];//해당 팀이 가질 수 있는 BadgeList

  List<int> TeamBadge_Activity = [];
  List<int> TeamBadge_Career = [];
  List<int> TeamBadge_Award = [];
  List<int> TeamBadge_Charm = [];


  void initTeamBadgePart() {
    bool Flag = false;

    TeamBadge_Activity.clear();
    TeamBadge_Career.clear();
    TeamBadge_Award.clear();
    TeamBadge_Charm.clear();

    if(TeamBadgeDescriptionList != null){
      for(int i = 1; i < TeamBadgeDescriptionList.length; i++) {

        TeamBadgeDescriptionList[i].IsTeamCanSelect = false;

        if(TeamBadgeList != null){
          for(int j = 0; j < TeamBadgeList.length; j++) {
            if(TeamBadgeList[j].badgeID == TeamBadgeDescriptionList[i].index) {
              TeamBadgeDescriptionList[i].IsTeamCanSelect = true;
              break;
            }
          }
        }

        if(TeamBadgeDescriptionList[i].Category == "활동") {
          TeamBadge_Activity.add(TeamBadgeDescriptionList[i].index);
        } else if (TeamBadgeDescriptionList[i].Category == "경력") {
          TeamBadge_Career.add(TeamBadgeDescriptionList[i].index);
        } else if (TeamBadgeDescriptionList[i].Category == "수상") {
          TeamBadge_Award.add(TeamBadgeDescriptionList[i].index);
        } else if (TeamBadgeDescriptionList[i].Category == "매력") {
          TeamBadge_Charm.add(TeamBadgeDescriptionList[i].index);
        }
      }
    }

    debugPrint("Team initBadgePart Success");
  }

  Future<bool> init() async {
    var list = await ApiProvider().post('/Badge/SelectTeamID', jsonEncode(
        {
          "teamID" :widget.team.id,
        }
    ));
    if(null != list) {

      TeamBadgeList.clear();
      for(int i = 0; i < list.length; ++i){
        Map<String, dynamic> data = list[i];
        BadgeModel item = BadgeModel.fromJson(data);
        TeamBadgeList.add(item);
      }

      initTeamBadgePart();
      return true;
    } else {
      return false;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  Widget getBadgeListUI(List<int> list, String title){
    int mok =  (list.length / 3).ceil();

    return Container(
      padding: EdgeInsets.fromLTRB(sizeUnit * 12, 0, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: sizeUnit * 12),
            child: Text(
              title,
              style: TextStyle(
                fontSize: sizeUnit * 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: sizeUnit * 20),
          list.length != 0 ? Align(
            alignment: Alignment.center,
            child: Container(
              height: mok * sizeUnit * 116 + mok * sizeUnit * 8,
              child: GridView.count(
                crossAxisCount: 3,
                physics: NeverScrollableScrollPhysics(),
                mainAxisSpacing: 8 * sizeUnit,
                children: List.generate(list.length, (index) {
                  return Opacity(
                    opacity: TeamBadgeDescriptionList[list[index]].IsTeamCanSelect ? 1.0 : 0.08,
                    child: GestureDetector(
                      onTap: (){
                        if(TeamBadgeDescriptionList[list[index]].IsTeamCanSelect ){
                          BadgeDialog(context,list[index]).then((value) {
                            setState(() {

                            });
                          });
                        } else {
                          onlyBadgeDialog(context, list[index]);
                        }
                      },
                      child: SvgPicture.asset(
                        ReturnTeamBadgeSVG(list[index]),
                        width: sizeUnit * 104,
                        height: sizeUnit * 104,
                      ),
                    ),
                  );
                }),
              ),
            ),
          ) : SizedBox.shrink(),
          SizedBox(height: sizeUnit * 20),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    sizeUnit = SheepsTextStyle.sizeUnit(context).fontSize;
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),//사용자 스케일팩터 무시
      child: Scaffold(
        backgroundColor: hexToColor("#FFFFFF"),
        appBar: SheepsAppBar(context,'뱃지 선택'),
        body: FutureBuilder(
            future: init(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              //해당 부분은 data를 아직 받아 오지 못했을때 실행되는 부분을 의미한다.
              if (snapshot.hasData == false) {
                return CircularProgressIndicator();
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
                return  SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      getBadgeListUI(TeamBadge_Activity, "활동"),
                      getBadgeListUI(TeamBadge_Career, "경력"),
                      getBadgeListUI(TeamBadge_Award, "수상"),
                      getBadgeListUI(TeamBadge_Charm, "매력"),
                    ],
                  ),
                );
              }
            }),
        bottomNavigationBar: SizedBox(
          height: 192*sizeUnit,
          child: Column(
            children: [
              SizedBox(height: sizeUnit*12,),
              Container(
                  height: 108*sizeUnit,
                  width: 360*sizeUnit,
                  child: Row(
                    children: [
                      SizedBox(width: 12*sizeUnit),
                      widget.team.badge1 != 0//test
                          ?
                      Stack(
                        alignment: Alignment.topRight,
                        children: [
                          Container(
                            width: 108*sizeUnit,
                            height: 108*sizeUnit,
                            child: ClipRRect(
                              borderRadius: new BorderRadius.circular(8*sizeUnit),
                              child: SvgPicture.asset(
                                ReturnTeamBadgeSVG(widget.team.badge1),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 4*sizeUnit,
                            right: 4*sizeUnit,
                            child: GestureDetector(
                              onTap: (){
                                setState(() {
                                  widget.team.badge1 = 0;
                                });
                              },
                              child: Container(
                                width: 16*sizeUnit,
                                height: 16*sizeUnit,
                                decoration: BoxDecoration(
                                    color: hexToColor("#61C680"),
                                    borderRadius: BorderRadius.circular(8*sizeUnit)),
                                child: Center(
                                  child: SvgPicture.asset(
                                    svgTrashCan,
                                    color: Colors.white,
                                    height: 10*sizeUnit,
                                    width: 10*sizeUnit,
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      )
                          : Container(
                        width: 108*sizeUnit,
                        height: 108*sizeUnit,
                        decoration: BoxDecoration(
                          color: hexToColor('#EEEEEE'),
                          borderRadius: BorderRadius.circular(4*sizeUnit),
                        ),
                      ),
                      SizedBox(width: 6*sizeUnit),
                      widget.team.badge2 != 0//test
                          ? Stack(
                        alignment: Alignment.topRight,
                            children: [
                              Container(
                                width: 108*sizeUnit,
                                height: 108*sizeUnit,
                                child: ClipRRect(
                                  borderRadius:
                                  new BorderRadius.circular(8*sizeUnit),
                                  child: SvgPicture.asset(
                                    ReturnTeamBadgeSVG(widget.team.badge2),//test
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 4*sizeUnit,
                                right: 4*sizeUnit,
                                child: GestureDetector(
                                  onTap: (){
                                    setState(() {
                                      widget.team.badge2 = 0;
                                    });
                                  },
                                  child: Container(
                                    width: 16*sizeUnit,
                                    height: 16*sizeUnit,
                                    decoration: BoxDecoration(
                                        color: hexToColor("#61C680"),
                                        borderRadius: BorderRadius.circular(8*sizeUnit)),
                                    child: Center(
                                      child: SvgPicture.asset(
                                        svgTrashCan,
                                        color: Colors.white,
                                        height: 10*sizeUnit,
                                        width: 10*sizeUnit,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                          : Container(
                        width: 108*sizeUnit,
                        height: 108*sizeUnit,
                        decoration: BoxDecoration(
                          color: hexToColor('#EEEEEE'),
                          borderRadius: BorderRadius.circular(4*sizeUnit),
                        ),
                      ),
                      SizedBox(width: 6*sizeUnit),
                      widget.team.badge3 != 0//test
                          ? Stack(
                        alignment: Alignment.topRight,
                            children: [
                              Container(
                                width: 108*sizeUnit,
                                height: 108*sizeUnit,
                                child: ClipRRect(
                                  borderRadius:
                                  new BorderRadius.circular(8*sizeUnit),
                                  child: SvgPicture.asset(
                                    ReturnTeamBadgeSVG(widget.team.badge3),//test
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 4*sizeUnit,
                                right: 4*sizeUnit,
                                child: GestureDetector(
                                  onTap: (){
                                    setState(() {
                                      widget.team.badge3 = 0;
                                    });
                                  },
                                  child: Container(
                                    width: 16*sizeUnit,
                                    height: 16*sizeUnit,
                                    decoration: BoxDecoration(
                                        color: hexToColor("#61C680"),
                                        borderRadius: BorderRadius.circular(8*sizeUnit)),
                                    child: Center(
                                      child: SvgPicture.asset(
                                        svgTrashCan,
                                        color: Colors.white,
                                        height: 10*sizeUnit,
                                        width: 10*sizeUnit,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                          : Container(
                        width: 108*sizeUnit,
                        height: 108*sizeUnit,
                        decoration: BoxDecoration(
                          color: hexToColor('#EEEEEE'),
                          borderRadius: BorderRadius.circular(4*sizeUnit),
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            svgLockIconGrey,
                          ),
                        ),
                      ),
                    ],
                  )
              ),
              SizedBox(height: 12*sizeUnit),
              GestureDetector(
                onTap: (){
                  Navigator.pop(context);
                },
                child: Container(
                    height: 60*sizeUnit,
                    decoration: BoxDecoration(
                      color: kPrimaryColor,
                    ),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        '완료',
                        style: SheepsTextStyle.button1(context),
                      ),
                    )
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  BadgeDialog(BuildContext context, int id) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black12.withOpacity(0.6),
      builder: (BuildContext context){
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8 * sizeUnit)
          ),
          actions: [
            Container(
              width: 280*sizeUnit,
              decoration: new BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8 * sizeUnit),
              ),
              padding: EdgeInsets.all(12*sizeUnit),
              child: Column(
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
                    ReturnTeamBadgeSVG(id),
                    height: 160*sizeUnit,
                    width: 160*sizeUnit,
                  ),
                  SizedBox(height: 16*sizeUnit),
                  Text(
                    TeamBadgeDescriptionList[id].Part,
                    style: SheepsTextStyle.h1(context),
                  ),
                  SizedBox(height: 8*sizeUnit),
                  Text(
                    TeamBadgeDescriptionList[id].Title,
                    style: SheepsTextStyle.b4(context),
                  ),
                  SizedBox(height: 16*sizeUnit),
                  Text(
                    TeamBadgeDescriptionList[id].Description,
                    style: SheepsTextStyle.b3(context),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20*sizeUnit),
                  GestureDetector(
                    onTap: (){
                      if(widget.team.badge1 != id && widget.team.badge2 != id && widget.team.badge3 != id) {
                        if(widget.team.badge1 == 0) {
                          setState(() {
                            widget.team.badge1 = id;
                          });
                        } else if(widget.team.badge2 == 0) {
                          setState(() {
                            widget.team.badge2 = id;
                          });
                        } else {
                          setState(() {
                            widget.team.badge3 = id;
                          });
                        }
                      }
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
                          '뱃지 선택하기',
                          style: SheepsTextStyle.button1(context),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
  onlyBadgeDialog(BuildContext context, int id) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black12.withOpacity(0.6),
      builder: (BuildContext context){
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(8 * sizeUnit)
          ),
          actions: [
            Container(
              width: 280*sizeUnit,
              decoration: new BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(8*sizeUnit)),
              ),
              padding: EdgeInsets.all(12*sizeUnit),
              child: Column(
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
                    ReturnTeamBadgeSVG(id),
                    height: 160*sizeUnit,
                    width: 160*sizeUnit,
                  ),
                  SizedBox(height: 16*sizeUnit),
                  Text(
                    TeamBadgeDescriptionList[id].Part,
                    style: SheepsTextStyle.h1(context),
                  ),
                  SizedBox(height: 8*sizeUnit),
                  Text(
                    TeamBadgeDescriptionList[id].Title,
                    style: SheepsTextStyle.b4(context),
                  ),
                  SizedBox(height: 16*sizeUnit),
                  Text(
                    TeamBadgeDescriptionList[id].Description,
                    style: SheepsTextStyle.b3(context),
                    textAlign: TextAlign.center,
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
            ),
          ],
        );
      }
    );
  }
}
