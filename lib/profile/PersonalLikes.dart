import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/network/ApiProvider.dart';
import 'package:sheeps_app/profile/models/ModelPersonalLikes.dart';
import 'package:sheeps_app/userdata/GlobalProfile.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/config/GlobalAsset.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PersonalLikes extends StatefulWidget {
  List<ModelPersonalLikes> personalLikesList;

  PersonalLikes({Key key, this.personalLikesList}) : super(key : key);

  @override
  _PersonalLikesState createState() => _PersonalLikesState();
}

class _PersonalLikesState extends State<PersonalLikes> with TickerProviderStateMixin {
  AnimationController extendedController;

  List<String> LikesList = [];
  int ListIndex = 0;

  List<ModelPersonalLikes> PersonalLikesList = [];

  double sizeUnit = 1;

  Future<bool> init(BuildContext context) async {
    var list = await ApiProvider().post('/Profile/Personal/SelectLIke', jsonEncode(
        {
          "userID" : GlobalProfile.loggedInUser.userID,
        }
    ));
    if(null != list) {

      PersonalLikesList.clear();
      for(int i = 0; i < list.length; ++i){
        Map<String, dynamic> data = list[i];

        ModelPersonalLikes item = ModelPersonalLikes.fromJson(data);

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

  @override
  void initState() {
//    // TODO: implement initState
    super.initState();
    PersonalLikesList = widget.personalLikesList;

    extendedController = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 3),
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

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),//사용자 스케일팩터 무시
        child: Container(
          color: Colors.white,
          child: SafeArea(
            child: Scaffold(
              backgroundColor: Colors.white,
              appBar: SheepsAppBar(context,'좋아요 한 개인 프로필'),
              body: Container(
                color: Colors.white,
                padding:EdgeInsets.only(
                  top: 20*sizeUnit,
                  left: 8*sizeUnit,
                  right: 8*sizeUnit,
                ),
                child: PersonalLikesList.length > 0
                  ? GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      childAspectRatio: 160 / 284,
                      crossAxisCount: 2,
                      mainAxisSpacing: 8*sizeUnit,
                      crossAxisSpacing: 8*sizeUnit,
                    ),
                    itemCount: PersonalLikesList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return SheepsPersonalProfileCard(context,GlobalProfile.getUserByUserID(PersonalLikesList[index].TargetID),index,extendedController);
                    },
                  )
                  : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(svgGreySheepEyeX,width: 192*sizeUnit ,height: 138*sizeUnit),
                      SizedBox(height: 40*sizeUnit),
                      Center(
                        child: Text(
                          '좋아요 한 개인 프로필이 없습니다.\n마음에 드는 프로필을 \'좋아해\'주세요!',
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
