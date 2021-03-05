import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/profile/models/ModelAddTeam.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/config/GlobalAsset.dart';

class SelectAddTeamCategory extends StatelessWidget {
  double sizeUnit = 1;

  Widget getColumn(BuildContext context, ModelAddTeam _ModifiedTeamProfile, String text){
    return GestureDetector(
      onTap: (){
        _ModifiedTeamProfile.ChangeTeamCategory(text);
        Navigator.pop(context);
      },
      child: Container(
        color: Colors.white,
        height: 48*sizeUnit,
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 12*sizeUnit),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  text,
                  style: SheepsTextStyle.b1(context),
                ),
              ),
            ),
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
  }

  @override
  Widget build(BuildContext context) {
    sizeUnit = SheepsTextStyle.sizeUnit(context).fontSize;
    ModelAddTeam _ModifiedTeamProfile = Provider.of<ModelAddTeam>(context);

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),//사용자 스케일팩터 무시
      child: Scaffold(
        backgroundColor: hexToColor("#F8F8F8"),
        appBar: SheepsAppBar(context, '팀 분류 선택'),
        body: ScrollConfiguration(
          behavior: MyBehavior(),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 20*sizeUnit),
                Container(
                  width: 360*sizeUnit,
                  height: 32*sizeUnit,
                  color: Colors.transparent,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12*sizeUnit),
                    child: Row(
                      children: [
                        Text(
                          '팀 유형',
                          style: SheepsTextStyle.h4(context),
                        ),
                      ],
                    ),
                  ),
                ),
                getColumn(context, _ModifiedTeamProfile, "예비창업팀"),
                Divider(color: hexToColor("#E5E5E5"),height: 0.5,),
                getColumn(context, _ModifiedTeamProfile, "창업팀"),
                Divider(color: hexToColor("#E5E5E5"),height: 0.5,),
                getColumn(context, _ModifiedTeamProfile, "프로젝트팀"),
                Divider(color: hexToColor("#E5E5E5"),height: 0.5,),
                getColumn(context, _ModifiedTeamProfile, "소모임"),
                SizedBox(height: 20*sizeUnit),
                Container(
                  width: 360*sizeUnit,
                  height: 32*sizeUnit,
                  color: Colors.transparent,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12*sizeUnit),
                    child: Row(
                      children: [
                        Text(
                          '기업 유형',
                          style: SheepsTextStyle.h4(context),
                        ),
                      ],
                    ),
                  ),
                ),
                getColumn(context, _ModifiedTeamProfile, "개인기업"),
                Divider(color: hexToColor("#E5E5E5"),height: 0.5,),
                getColumn(context, _ModifiedTeamProfile, "법인기업"),
                Divider(color: hexToColor("#E5E5E5"),height: 0.5,),
                getColumn(context, _ModifiedTeamProfile, "사회적기업"),
                Divider(color: hexToColor("#E5E5E5"),height: 0.5,),
                getColumn(context, _ModifiedTeamProfile, "협동조합"),
                Divider(color: hexToColor("#E5E5E5"),height: 0.5,),
                getColumn(context, _ModifiedTeamProfile, "기관"),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
