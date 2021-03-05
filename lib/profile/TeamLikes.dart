import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/network/ApiProvider.dart';
import 'package:sheeps_app/profile/models/ModelTeamLikes.dart';
import 'package:sheeps_app/userdata/GlobalProfile.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sheeps_app/config/GlobalAsset.dart';

class TeamLikes extends StatefulWidget {
  List<ModelTeamLikes> teamLikesList = [];

  TeamLikes({Key key, this.teamLikesList}) : super(key : key);

  @override
  _TeamLikesState createState() => _TeamLikesState();
}

class _TeamLikesState extends State<TeamLikes> with SingleTickerProviderStateMixin {
  List<ModelTeamLikes> TeamLikesList = [];
  AnimationController extendedController;
  int ListIndex = 0;

  double sizeUnit = 1;

  @override
  void initState() {
    super.initState();
    TeamLikesList = widget.teamLikesList;
    extendedController = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 3),
        lowerBound: 0.0,
        upperBound: 1.0);
  }


  @override
  void dispose() {
    extendedController.dispose();
    super.dispose();
  }

  Future<bool> init(BuildContext context) async {
    var list = await ApiProvider().post('/Team/SelectLike', jsonEncode(
        {
          "userID" : GlobalProfile.loggedInUser.userID,
        }
    ));


    if(null != list) {
      TeamLikesList.clear();
      for(int i = 0; i < list.length; ++i){
        Map<String, dynamic> data = list[i];

        ModelTeamLikes item = ModelTeamLikes.fromJson(data);

        TeamLikesList.add(item);
        //await NotiDBHelper().createData(noti);
      }
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    sizeUnit = SheepsTextStyle.sizeUnit(context).fontSize;

    Future.microtask(() async {
      for(int i = 0 ; i < TeamLikesList.length; ++i){
        await GlobalProfile.getFutureTeamByID(TeamLikesList[i].TeamID);
      }
    });

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),//사용자 스케일팩터 무시
        child: Container(
          color: Colors.white,
          child: SafeArea(
            child: Scaffold(
              backgroundColor: Colors.white,
              appBar: SheepsAppBar(context,'좋아요 한 팀 프로필'),
              body: Container(
                padding:EdgeInsets.only(
                  top: 20*sizeUnit,
                  left: 8*sizeUnit,
                  right: 8*sizeUnit,
                ),
                child: TeamLikesList.length > 0
                  ? GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        childAspectRatio:160 / 284,
                        crossAxisCount: 2,
                        mainAxisSpacing: 8*sizeUnit,
                        crossAxisSpacing: 8*sizeUnit,
                      ),
                      itemCount: TeamLikesList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return SheepsTeamProfileCard(context,GlobalProfile.getTeamByID(TeamLikesList[index].TeamID),index,extendedController);
                      },
                  )
                  : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(svgGreySheepEyeX,width: 192*sizeUnit ,height: 138*sizeUnit),
                      SizedBox(height: 40*sizeUnit),
                      Center(
                        child: Text(
                          '좋아요 한 팀 프로필이 없습니다.\n마음에 드는 프로필을 \'좋아해\'주세요!',
                          style: SheepsTextStyle.b2(context),
                          textAlign: TextAlign.center,
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