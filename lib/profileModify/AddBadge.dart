import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/GlobalAsset.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/config/constants.dart';
import 'package:sheeps_app/userdata/GlobalProfile.dart';
import 'package:sheeps_app/userdata/User.dart';
import 'package:sheeps_app/Badge/model/ModelBadge.dart';
import 'package:sheeps_app/config/GlobalAsset.dart';

class AddBadge extends StatefulWidget {
  @override
  _AddBadgeState createState() => _AddBadgeState();

}

class _AddBadgeState extends State<AddBadge> {
  double sizeUnit = 1;

  UserData user = GlobalProfile.loggedInUser;

  @override
  void initState(){
    PersonalBadge_Activity.clear();
    PersonalBadge_Career.clear();
    PersonalBadge_Achieve.clear();
    PersonalBadge_Award.clear();
    PersonalBadge_Licence.clear();
    PersonalBadge_Education.clear();
    PersonalBadge_Charm.clear();

    if(PersonalBadgeDescriptionList != null){
      for(int i = 0; i < PersonalBadgeDescriptionList.length; i++) {

        PersonalBadgeDescriptionList[i].IsUserCanSelect = false;

        if(user.badgeList != null){
          for(int j = 0; j < user.badgeList.length; j++) {
            if(user.badgeList[j].badgeID == PersonalBadgeDescriptionList[i].index) {
              PersonalBadgeDescriptionList[i].IsUserCanSelect = true;
              break;
            }
          }
        }

        if(PersonalBadgeDescriptionList[i].Category == "활동") {
          PersonalBadge_Activity.add(PersonalBadgeDescriptionList[i].index);
        } else if (PersonalBadgeDescriptionList[i].Category == "경력") {
          PersonalBadge_Career.add(PersonalBadgeDescriptionList[i].index);
        } else if (PersonalBadgeDescriptionList[i].Category == "학력") {
          PersonalBadge_Achieve.add(PersonalBadgeDescriptionList[i].index);
        } else if (PersonalBadgeDescriptionList[i].Category == "수상") {
          PersonalBadge_Award.add(PersonalBadgeDescriptionList[i].index);
        } else if (PersonalBadgeDescriptionList[i].Category == "자격증") {
          PersonalBadge_Licence.add(PersonalBadgeDescriptionList[i].index);
        } else if (PersonalBadgeDescriptionList[i].Category == "교육") {
          PersonalBadge_Education.add(PersonalBadgeDescriptionList[i].index);
        } else if (PersonalBadgeDescriptionList[i].Category == "매력") {
          PersonalBadge_Charm.add(PersonalBadgeDescriptionList[i].index);
        }
      }
    }

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
              height: mok * sizeUnit * 116 + mok * sizeUnit * 8,  //figma는 104로나와있으나 짤려서 116으로 바꿈
              child: GridView.count(
                crossAxisCount: 3,
                physics: NeverScrollableScrollPhysics(),
                mainAxisSpacing: 8 * sizeUnit,
                children: List.generate(list.length, (index) {
                  return Opacity(
                    opacity: PersonalBadgeDescriptionList[list[index]].IsUserCanSelect ? 1.0 : 0.08,
                    child: GestureDetector(
                      onTap: (){
                        if(PersonalBadgeDescriptionList[list[index]].IsUserCanSelect) {
                          showBadgeDialog(context,list[index]).then((value) {
                            setState(() {

                            });
                          });
                        } else {
                          onlyShowBadgeDialog(context,list[index]);
                        }
                      },
                      child: SvgPicture.asset(
                        ReturnPersonalBadgeSVG(list[index]),
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
        appBar: SheepsAppBar(context, '뱃지 선택'),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              getBadgeListUI(PersonalBadge_Activity, "활동"),
              getBadgeListUI(PersonalBadge_Career, "경력"),
              getBadgeListUI(PersonalBadge_Achieve, "학력"),
              getBadgeListUI(PersonalBadge_Award, "수상"),
              getBadgeListUI(PersonalBadge_Licence, "자격증"),
              getBadgeListUI(PersonalBadge_Education, "교육"),
              getBadgeListUI(PersonalBadge_Charm, "매력"),

              //Container(width: 360*sizeUnit ,height: 1, decoration: BoxDecoration( color: hexToColor('#eeeeee'))),
            ],
          ),
        ),
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
                      user.badge1 != 0//test
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
//                                    badgeList[user.badge1].image,//test
                                  ReturnPersonalBadgeSVG(user.badge1),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 4*sizeUnit,
                            right: 4*sizeUnit,
                            child: GestureDetector(
                              onTap: (){
                                setState(() {
                                  user.badge1 = 0;
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
                              borderRadius: BorderRadius.circular(8*sizeUnit),
                            ),
                          ),
                      SizedBox(width: 6*sizeUnit),
                      user.badge2 != 0//test
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
                                    ReturnPersonalBadgeSVG(user.badge2),//test
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 4*sizeUnit,
                                right: 4*sizeUnit,
                                child: GestureDetector(
                                  onTap: (){
                                    setState(() {
                                      user.badge2 = 0;
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
                              borderRadius: BorderRadius.circular(8*sizeUnit),
                            ),
                          ),
                      SizedBox(width: 6*sizeUnit),
                      user.badge3 != 0//test
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
                                    ReturnPersonalBadgeSVG(user.badge3),//test
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 4*sizeUnit,
                                right: 4*sizeUnit,
                                child: GestureDetector(
                                  onTap: (){
                                    setState(() {
                                      user.badge3 = 0;
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
                              borderRadius: BorderRadius.circular(8*sizeUnit),
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

  showBadgeDialog(BuildContext context,int id){
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8 * sizeUnit)),
            actions: [
              Container(
              width: 280*sizeUnit,
              decoration: BoxDecoration(
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
                    ReturnPersonalBadgeSVG(id),
                    height: 160*sizeUnit,
                    width: 160*sizeUnit,
                  ),
                  SizedBox(height: 16*sizeUnit),
                  Text(
                    PersonalBadgeDescriptionList[id].Part,
                    style: SheepsTextStyle.h1(context),
                  ),
                  SizedBox(height: 8*sizeUnit),
                  Text(
                    PersonalBadgeDescriptionList[id].Title,
                    style: SheepsTextStyle.b4(context),
                  ),
                  SizedBox(height: 16*sizeUnit),
                  Text(
                    PersonalBadgeDescriptionList[id].Description,
                    style: SheepsTextStyle.b3(context),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20*sizeUnit),
                  GestureDetector(
                    onTap: (){
                      if(user.badge1 != id && user.badge2 != id && user.badge3 != id) {
                        if(user.badge1 == 0) {
                          user.badge1 = id;
                        } else if(user.badge2 == 0) {
                          user.badge2 = id;
                        } else {
                          user.badge3 = id;
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
            )
            ],
          );
      }
    );
  }
  onlyShowBadgeDialog(BuildContext context,int id){
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8 * sizeUnit)
            ),
            actions: [
              Container(
                width: 280*sizeUnit,
                decoration: BoxDecoration(
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
                      ReturnPersonalBadgeSVG(id),
                      height: 160*sizeUnit,
                      width: 160*sizeUnit,
                    ),
                    SizedBox(height: 16*sizeUnit),
                    Text(
                      PersonalBadgeDescriptionList[id].Part,
                      style: SheepsTextStyle.h1(context),
                    ),
                    SizedBox(height: 8*sizeUnit),
                    Text(
                      PersonalBadgeDescriptionList[id].Title,
                      style: SheepsTextStyle.b4(context),
                    ),
                    SizedBox(height: 16*sizeUnit),
                    Text(
                      PersonalBadgeDescriptionList[id].Description,
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
              )
            ],
          );
        }
    );
  }
}
