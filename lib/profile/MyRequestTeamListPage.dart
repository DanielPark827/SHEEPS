
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sheeps_app/TeamProfileModifys/model/Team.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/network/ApiProvider.dart';
import 'package:sheeps_app/userdata/GlobalProfile.dart';
import 'package:sheeps_app/userdata/MyBadge.dart';
import 'package:sheeps_app/config/GlobalAsset.dart';
import 'DetailTeamProfile.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';

class MyRequestTeamListPage extends StatefulWidget {
  @override
  _MyRequestTeamListPageState createState() => _MyRequestTeamListPageState();
}

class _MyRequestTeamListPageState extends State<MyRequestTeamListPage> with TickerProviderStateMixin {

  List<Team> requestList = List<Team>();
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

    Future.microtask(() async {
      var res = await ApiProvider().post('/Team/Invite/Select', jsonEncode({
        "userID" : GlobalProfile.loggedInUser.userID
      }));

      if(res != null){
        for(int i = 0 ; i < res.length; ++i){
          requestList.add(await GlobalProfile.getFutureTeamByID(res[i]['TeamID']));
        }

        if(mounted){
          setState(() {

          });
        }
      }
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
                backgroundColor: Colors.white,
                appBar: SheepsAppBar(context,'보낸 팀 요청'),
                body: Container(
                  padding:EdgeInsets.only(
                    top: 20*sizeUnit,
                    left: 8*sizeUnit,
                    right: 8*sizeUnit,
                  ),
                  child: requestList.length > 0
                    ? GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        childAspectRatio:160 / 284,
                        crossAxisCount: 2,
                        mainAxisSpacing: 8*sizeUnit,
                        crossAxisSpacing: 8*sizeUnit,
                      ),
                      itemCount: requestList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return SheepsTeamProfileCard(context,GlobalProfile.getTeamByID(requestList[index].id),index,extendedController);
                      },
                      /*
                      children: List.generate(requestList.length, (index) {
                        if(index == requestList.length){
                          return Container();
                        }
                        return Container(
                          width: MediaQuery.of(context).size.width * 0.4444444444444444,
                          // height: screenHeight * 0.41875,
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
                                      width: screenWidth * (160/360),
                                      height: screenWidth * (160/360),
                                      child: GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                PageRouteBuilder(
                                                    transitionDuration:
                                                    Duration(milliseconds: 300),
                                                    pageBuilder: (_, __, ___) => DetailTeamProfile(
                                                      index: index,
                                                      team: requestList[index],
                                                    )));
                                          },
                                          child:
                                          requestList[index].profileUrlList[0] == 'BasicImage' ?
                                          Container(
                                            decoration: BoxDecoration(
                                              color: hexToColor('#F8F8F8'),
                                              borderRadius: new BorderRadius.circular(8*sizeUnit),
                                            ),
                                            child:  Center(child: SvgPicture.asset(svgPersonalProfileBasicImage,width: screenWidth * (87/360),height: screenHeight * (63/640), )),
                                          ) :
                                          Container(
                                              width: screenWidth * (160/360),
                                              height: screenWidth * (160/360),
                                              decoration: BoxDecoration(
                                                boxShadow: [
                                                  new BoxShadow(
                                                    color: Color.fromRGBO(116, 125, 130, 0.2),
                                                    blurRadius: 8,
                                                  ),
                                                ],
                                              ),
                                              child: FittedBox(
                                                  child:   getExtendedImage(requestList[index].profileUrlList[0], 160, extendedController),
                                                fit: BoxFit.fill,
                                              )
                                          )
                                      ),
                                    ),
                                    Container(
                                      color: Colors.black.withOpacity(0.8),
                                    ),
                                    requestList[index].badge1 != 0
                                        ? Badge1(context, index)
                                        : Container(),
                                    requestList[index].badge2 != 0
                                        ? Badge2(context, index)
                                        : Container(),
                                    requestList[index].badge3 != 0
                                        ? Badge3(context, index)
                                        : Container(),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.height * 0.0125,
                              ),
                              name(index, context),
                              SizedBox(
                                height: MediaQuery.of(context).size.height * 0.00625,
                              ),
                              Wrap(
                                runSpacing:  MediaQuery.of(context).size.height * 0.00625,
                                spacing: MediaQuery.of(context).size.height * 0.00625,
                                children: [
                                  Tag3(context, index),
                                  Tag1(context, index),
                                  Tag2(context, index),
                                ],
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.height * 0.0125,
                              ),
                              Container(
                                child: Text(
                                  requestList[index].information,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: MediaQuery.of(context).size.height * 0.01875,
                                      color: Color(0xff888888)),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      */
                    )
                    : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(svgGreySheepEyeX,width: 192*sizeUnit ,height: 138*sizeUnit),
                        SizedBox(height: 40*sizeUnit),
                        Center(
                          child: Text(
                            '보낸 팀 요청이 없습니다.\n마음에 드는 팀에게 참가 요청을 보내세요!',
                            style: SheepsTextStyle.b2(context),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                )
            ),
          ),
        ),
      ),
    );
  }

  Positioned Badge3(BuildContext context, int index) {
    return Positioned(
      right: MediaQuery.of(context).size.width * 0.1777777777777778,
      bottom: MediaQuery.of(context).size.height * 0.0125,
      child: Container(
        //width: screenWidth * 0.3333333,
        // height: screenWidth * 0.3333333,
        width: MediaQuery.of(context).size.height * 0.0375,
        height: MediaQuery.of(context).size.height * 0.0375,

        decoration: BoxDecoration(
          boxShadow: [
            new BoxShadow(
              color: Color.fromRGBO(166, 125, 130, 0.2),
              blurRadius: 4,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: new BorderRadius.circular(8*sizeUnit),
          child: FittedBox(
            child: SvgPicture.asset(
              badgeList[requestList[index].badge3].image,
            ),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Positioned Badge2(BuildContext context, int index) {
    return Positioned(
      right: MediaQuery.of(context).size.width * 0.1,
      bottom: MediaQuery.of(context).size.height * 0.0125,
      child: Container(
        //width: screenWidth * 0.3333333,
        // height: screenWidth * 0.3333333,
        width: MediaQuery.of(context).size.height * 0.0375,
        height: MediaQuery.of(context).size.height * 0.0375,

        decoration: BoxDecoration(
          boxShadow: [
            new BoxShadow(
              color: Color.fromRGBO(166, 125, 130, 0.2),
              blurRadius: 4,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: new BorderRadius.circular(8*sizeUnit),
          child: FittedBox(
            child: SvgPicture.asset(
              badgeList[requestList[index].badge2].image,
            ),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Positioned Badge1(BuildContext context, int index) {
    return Positioned(
      right: MediaQuery.of(context).size.width * 0.0222222222222222,
      bottom: MediaQuery.of(context).size.height * 0.0125,
      child: Container(
        //width: screenWidth * 0.3333333,
        // height: screenWidth * 0.3333333,
        width: MediaQuery.of(context).size.height * 0.0375,
        height: MediaQuery.of(context).size.height * 0.0375,

        decoration: BoxDecoration(
          boxShadow: [
            new BoxShadow(
              color: Color.fromRGBO(166, 125, 130, 0.2),
              blurRadius: 4,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: new BorderRadius.circular(8*sizeUnit),
          child: FittedBox(
            child: SvgPicture.asset(
              badgeList[requestList[index].badge1].image,
            ),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Container Tag3(BuildContext context, int index) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.028125,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
            MediaQuery.of(context).size.width * 0.022222,
            MediaQuery.of(context).size.height * 0.003125,
            MediaQuery.of(context).size.width * 0.022222,
            MediaQuery.of(context).size.height * 0.003125),
        child: Text(
          requestList[index].category,
          style: TextStyle(
            fontSize: MediaQuery.of(context).size.height * 0.015625,
            color: hexToColor("#222222"),
          ),
        ),
      ),
      decoration: BoxDecoration(
        borderRadius: new BorderRadius.circular(4*sizeUnit),
        color: hexToColor("#E5E5E5"),
      ),
    );
  }

  Container Tag2(BuildContext context, int index) {
    String location = (requestList[index].location == null || requestList[index].location == '') ? '' : requestList[index].location;
    String subLocation = (requestList[index].subLocation == null || requestList[index].subLocation == '') ? '' : requestList[index].subLocation;

    return Container(
      height: MediaQuery.of(context).size.height * 0.028125,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
            MediaQuery.of(context).size.width * 0.022222,
            MediaQuery.of(context).size.height * 0.003125,
            MediaQuery.of(context).size.width * 0.022222,
            MediaQuery.of(context).size.height * 0.003125),
        child: Text(
          location + subLocation,
          style: TextStyle(
            fontSize: MediaQuery.of(context).size.height * 0.015625,
            color: hexToColor("#222222"),
          ),
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
      height: MediaQuery.of(context).size.height * 0.028125,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
            MediaQuery.of(context).size.width * 0.022222,
            MediaQuery.of(context).size.height * 0.003125,
            MediaQuery.of(context).size.width * 0.022222,
            MediaQuery.of(context).size.height * 0.003125),
        child: Text(
          requestList[index].part,
          style: TextStyle(
            fontSize: MediaQuery.of(context).size.height * 0.015625,
            color: hexToColor("#222222"),
          ),
        ),
      ),
      decoration: BoxDecoration(
        borderRadius: new BorderRadius.circular(4*sizeUnit),
        color: hexToColor("#E5E5E5"),
      ),
    );
  }

  Text name(int index, BuildContext context) {
    return Text(
      requestList[index].name,
      style: TextStyle(
        fontSize: MediaQuery.of(context).size.height * 0.025,
        fontWeight: FontWeight.bold,
        color: Color(0xff222222),
      ),
    );
  }
}
