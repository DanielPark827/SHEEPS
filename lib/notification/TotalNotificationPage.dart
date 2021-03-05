import 'package:badges/badges.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/NavigationNum.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/notification/models/NotificationModel.dart';
import 'package:sheeps_app/profile/models/ProfileState.dart';
import 'package:sheeps_app/userdata/GlobalProfile.dart';
import 'package:sheeps_app/config/GlobalAsset.dart';

class TotalNotificationPage extends StatefulWidget {
  @override
  _TotalNotificationPageState createState() => _TotalNotificationPageState();
}

class _TotalNotificationPageState extends State<TotalNotificationPage> {
  double sizeUnit = 1;
  NavigationNum navigationNum;
  ProfileState profileState;

  @override
  Widget build(BuildContext context) {
    sizeUnit = SheepsTextStyle.sizeUnit(context).fontSize;

    setNotiListRead();

    if(navigationNum == null) navigationNum = Provider.of<NavigationNum>(context);
    if(profileState == null) profileState = Provider.of<ProfileState>(context);

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),//사용자 스케일팩터 무시
      child: Scaffold(
        backgroundColor: hexToColor("#E5E5E5"),
        appBar: SheepsAppBar(context, '전체 알림'),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Container(
                color: hexToColor("#E5E5E5"),
                child: ListView.separated(
                  separatorBuilder: (context,index) => Container(
                      height: 1*sizeUnit, width: double.infinity, color: hexToColor('#F8F8F8')),
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  itemCount: notiList.length,
                  itemBuilder: (BuildContext context, int index) => Container(
                      height: 72*sizeUnit,
                      color: Colors.white,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 76*sizeUnit,
                            child:  Badge(
                              shape: BadgeShape.square,
                              //position: BadgePosition.topStart(top: screenHeight*0.0705, start: screenHeight*0.0575  ),
                              position: BadgePosition.topStart(top: 46*sizeUnit, start: 50*sizeUnit),
                              borderRadius: BorderRadius.circular(8*sizeUnit),
                              badgeColor:hexToColor("#61C680"),
                              badgeContent: SvgPicture.asset(
                                GetNotificationIconIndex(notiList[index].type),
                                width: 10*sizeUnit,
                                height: 10*sizeUnit,
                              ),
                              child: Center(
                                child: notiList[index].from == -1 ?
                                  Container(
                                      width:56*sizeUnit,
                                      height: 56*sizeUnit,
                                      decoration: BoxDecoration(
                                        color: hexToColor('#F8F8F8'),
                                        borderRadius: new BorderRadius.circular(8*sizeUnit),
                                      ),
                                      child:  Center(
                                          child: SvgPicture.asset(svgSheepsGreenImageLogo,
                                              width: 56*sizeUnit,
                                              height: 56*sizeUnit
                                          )
                                      )
                                  )
                                : GlobalProfile.getUserByUserID(notiList[index].from).profileUrlList[0] == 'BasicImage' || notiList[index].teamRoomName == "비밀"
                                    ? Container(
                                    width:56*sizeUnit,
                                    height: 56*sizeUnit,
                                    decoration: BoxDecoration(
                                      color: hexToColor('#F8F8F8'),
                                      borderRadius: new BorderRadius.circular(8*sizeUnit),
                                    ),
                                    child:  Center(
                                        child: SvgPicture.asset(svgPersonalProfileBasicImage,
                                            width: 56*sizeUnit,
                                            height: 56*sizeUnit
                                        )
                                    )
                                )
                                    : Container(
                                  width: 56*sizeUnit,
                                  height: 56*sizeUnit,
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      new BoxShadow(
                                        color: Color.fromRGBO(166, 125, 130, 0.2),
                                        blurRadius: 4,
                                      ),],
                                  ),
                                  child: ClipRRect(
                                      borderRadius: new BorderRadius.circular(8.0*sizeUnit),
                                      child: FittedBox(
                                        child: ExtendedImage.network(getOptimizeImageURL(GlobalProfile.getUserByUserID(notiList[index].from).profileUrlList[0], 120)),
                                        fit: BoxFit.fill,
                                      )
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 8*sizeUnit),
                            child: Column(
                              children: [
                                InkWell(
                                  onTap: () async {
                                    await notiClickEvent(context, notiList[index], profileState, navigationNum);
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.only(right: 20*sizeUnit),
                                    child: Container(
                                      height: 32*sizeUnit,
                                      width: 264*sizeUnit,
                                      child: Align(
                                        alignment: Alignment.topLeft,
                                        child: Text(
                                          getNotiInformation(notiList[index]),
                                          maxLines: 2,
                                          overflow:
                                          TextOverflow.ellipsis,
                                          style: SheepsTextStyle.b3(context).copyWith(height: 1.3),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 10*sizeUnit, right: 12*sizeUnit),
                                  child: Container(
                                    height: 14*sizeUnit,
                                    width: 272*sizeUnit,
                                    child: Row(
                                      children: [
                                        Container(
                                          height: 14*sizeUnit,
                                          child: Align(
                                            alignment: Alignment.bottomLeft,
                                            child: Text(
                                                timeCheck(replaceDate(notiList[index].time)),
                                                style: SheepsTextStyle.bWriteDate(context)
                                            ),
                                          ),
                                        ),
                                        isHaveButton(context, notiList[index].type) == true
                                            ? Expanded(
                                          child: Align(
                                            alignment: Alignment.centerRight,
                                            child: GestureDetector(
                                              onTap: () async {
                                                if(notiList[index].isSend == 1) return;
                                                await NotiEvent(context, notiList[index], index).then((value) {
                                                  setState(() {

                                                  });
                                                });
                                              },
                                              child: Container(
                                                height: 14*sizeUnit,
                                                child: Text(
                                                  "확인하기>",
                                                  style: notiList[index].isSend == 0 ? SheepsTextStyle.s2(context) : SheepsTextStyle.s2(context).copyWith(color: hexToColor('#CCCCCC') ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ) : Container(),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}