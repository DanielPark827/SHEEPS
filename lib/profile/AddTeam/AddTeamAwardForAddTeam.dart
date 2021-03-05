import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/profile/AddTeam/UploadForAward.dart';
import 'package:sheeps_app/profile/models/ModelAddTeam.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/config/GlobalAsset.dart';

class AddTeamAwardForAddTeam extends StatefulWidget {
  @override
  _AddTeamAwardState createState() => _AddTeamAwardState();
}

class _AddTeamAwardState extends State<AddTeamAwardForAddTeam> {
  final AwardNameController = TextEditingController();
  final AwardGradeController = TextEditingController();
  final AwardAgencyController = TextEditingController();

  bool ValidationFlag1 = false;
  bool ValidationFlag2 = false;
  bool ValidationFlag3 = false;

  double sizeUnit = 1;

  bool Validation_OnlyString(String value, String target) {
    String p = r'[$./!@#<>?":_`~;[\]\\|=+)(*&^%0-9-\s-]';

    RegExp regExp = new RegExp(p);
    setState(() {
      if(target == "대회명") {
        ValidationFlag1 = regExp.hasMatch(value);
      } else if(target == "상격") {
        ValidationFlag2 = regExp.hasMatch(value);
      }
      else if(target == "주관기관") {
        ValidationFlag3 = regExp.hasMatch(value);
      }
    });
    return regExp.hasMatch(value);
  }
  bool Validation_NoSpecialChar(String value, String target) {
    String p = r'[$./!@#<>?":_`~;[\]\\|=+)(*&^%]';

    RegExp regExp = new RegExp(p);
    setState(() {
      if(target == "대회명") {
        ValidationFlag1 = regExp.hasMatch(value);
      } else if(target == "상격") {
        ValidationFlag2 = regExp.hasMatch(value);
      }
      else if(target == "주관기관") {
        ValidationFlag3 = regExp.hasMatch(value);
      }
    });
    return regExp.hasMatch(value);
  }

  @override
  Widget build(BuildContext context) {
    sizeUnit = SheepsTextStyle.sizeUnit(context).fontSize;
    ModelAddTeam _ModifiedTeamProfile = Provider.of<ModelAddTeam>(context);
    return GestureDetector(
      onTap: (){
        FocusScopeNode currentFocus = FocusScope.of(context);
        if(!currentFocus.hasPrimaryFocus){currentFocus.unfocus();}//텍스트 포커스 해제
      },
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),//사용자 스케일팩터 무시
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: SheepsAppBar(
            context, 
            '수상 내역 추가',
            backFunc: (){
              if(_ModifiedTeamProfile.TeamAwardList.length < _ModifiedTeamProfile.AwardFile.length) {
                _ModifiedTeamProfile.removeEndFile(3);
                _ModifiedTeamProfile.ChangeIfAddTeamAwardUploadComplete(false);
              }
              _ModifiedTeamProfile.resetModelAddTeam();
              Navigator.pop(context);
            },
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12*sizeUnit),
              child: Column(
                children: [
                  SizedBox(height: 16*sizeUnit),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      '대회명',
                      style: SheepsTextStyle.h3(context),
                    ),
                  ),
                  SizedBox(height: 8*sizeUnit),
                  TextField(
                    controller: AwardNameController,
                    style: SheepsTextStyle.b3(context),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding: EdgeInsets.all(12*sizeUnit),
                      hintText: '예) 쉽스경진대회',
                      hintStyle: SheepsTextStyle.hint4Profile(context),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(width: 1,color: hexToColor(("#61C680"))),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(width: 1,color: hexToColor(("#CCCCCC"))),
                      ),
                        errorText: ValidationFlag1 ? '특수문자는 들어갈 수 없습니다.' : null
                    ),
                    onChanged: (text) {
                      if(!Validation_NoSpecialChar(text, "대회명")) {
                        _ModifiedTeamProfile.ChangeTeamAwardName(text);
                        CheckForAddAward_AddTeam(_ModifiedTeamProfile);
                      }
                    },
                  ),
                  SizedBox(height: 20*sizeUnit),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      '상격',
                      style: SheepsTextStyle.h3(context),
                    ),
                  ),
                  SizedBox(height: 8*sizeUnit),
                  TextField(
                    controller: AwardGradeController,
                    style: SheepsTextStyle.b3(context),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding: EdgeInsets.all(12*sizeUnit),
                      hintText: '예) 최우수상',
                      hintStyle: SheepsTextStyle.hint4Profile(context),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(width: 1,color: hexToColor(("#61C680"))),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(width: 1,color: hexToColor(("#CCCCCC"))),
                      ),
                        errorText: ValidationFlag2 ? '특수문자는 들어갈 수 없습니다.' : null
                    ),
                    onChanged: (text) {
                      if(!Validation_NoSpecialChar(text, "상격")) {
                        _ModifiedTeamProfile.ChangeTeamAwardGrade(text);
                        CheckForAddAward_AddTeam(_ModifiedTeamProfile);
                      }
                    },
                  ),
                  SizedBox(height: 20*sizeUnit),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      '주관기관',
                      style: SheepsTextStyle.h3(context),
                    ),
                  ),
                  SizedBox(height: 8*sizeUnit),
                  TextField(
                    controller: AwardAgencyController,
                    style: SheepsTextStyle.b3(context),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding: EdgeInsets.all(12*sizeUnit),
                      hintText: '예) 중소벤처기업부',
                      hintStyle: SheepsTextStyle.hint4Profile(context),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(width: 1,color: hexToColor(("#61C680"))),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(width: 1,color: hexToColor(("#CCCCCC"))),
                      ),
                        errorText: ValidationFlag3 ? '특수문자는 들어갈 수 없습니다.' : null
                    ),
                    onChanged: (text) {
                      if(!Validation_NoSpecialChar(text, "주관기관")) {
                        _ModifiedTeamProfile.ChangeTeamAwardAgency(text);
                        CheckForAddAward_AddTeam(_ModifiedTeamProfile);
                      }
                    },
                  ),
                  SizedBox(height: 20*sizeUnit),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      '수상일',
                      style: SheepsTextStyle.h3(context),
                    ),
                  ),
                  SizedBox(height: 8*sizeUnit),
                  GestureDetector(
                    onTap: (){
                      DatePicker.showDatePicker(context,
                          showTitleActions: true,
                          minTime: DateTime(DateTime.now().year-20, 1, 1),
                          maxTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
                          theme: DatePickerTheme(
                              headerColor: Colors.white,
                              backgroundColor: Colors.white,
                              itemStyle: TextStyle(
                                color: Colors.black, fontSize: screenWidth*( 18/360),),
                              doneStyle: TextStyle(color: Colors.white, fontSize: screenWidth*( 16/360),)),
                          onChanged: (date) {
                            _ModifiedTeamProfile.ChangeTeamAwardTime(DateFormat('y.MM').format(date));
                            CheckForAddAward_AddTeam(_ModifiedTeamProfile);
                          },
                          currentTime: DateTime.now(), locale: LocaleType.ko);
                    },
                    child: Container(
                      width: 336*sizeUnit,
                      height: 40*sizeUnit,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        border: Border.all(color: hexToColor("#CCCCCC")),
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.only(left: 12*sizeUnit),
                          child: Text(
                            '${_ModifiedTeamProfile.getTeamAwardTime() == null ? '수상년월':_ModifiedTeamProfile.getTeamAwardTime()}',
                            style: _ModifiedTeamProfile.getTeamAwardTime() == null
                              ? SheepsTextStyle.hint4Profile(context)
                              : SheepsTextStyle.b3(context),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20*sizeUnit),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          '증빙 자료',
                          style: SheepsTextStyle.h3(context),
                        ),
                      ),
                      SizedBox(width: 8*sizeUnit),
                      Padding(
                        padding: EdgeInsets.only(bottom: 2),
                        child: Text(
                          '상장 사본, 수상 증명서 등',
                          style: SheepsTextStyle.info2(context)
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 8*sizeUnit),
                  GestureDetector(
                      onTap: (){
                        Navigator.push(
                            context, // 기본 파라미터, SecondRoute로 전달
                            MaterialPageRoute(
                                builder: (context) =>
                                    UploadForAward()) // SecondRoute를 생성하여 적재
                        ).then((value) {
                          CheckForAddAward_AddTeam(_ModifiedTeamProfile);
                        });
                      },
                      child: _ModifiedTeamProfile.IfAddTeamAwardUploadComplte == true ? Container(
                        width: 336*sizeUnit,
                        height: 40*sizeUnit,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          border: Border.all(color: hexToColor("#61C680")),
                        ),
                        child: Row(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: EdgeInsets.only(left: 12*sizeUnit),
                                child: Text(
                                  '업로드 완료',
                                  style: SheepsTextStyle.b1(context).copyWith(color: Color(0xFF61C680)),
                                ),
                              ),
                            ),
                            Expanded(child: SizedBox()),
                            Padding(
                              padding: EdgeInsets.only(right: 4*sizeUnit),
                              child: SvgPicture.asset(
                                svgGreyNextIcon2,
                                width: 12*sizeUnit,
                                height: 12*sizeUnit,
                                color: hexToColor("#61C680"),
                              ),
                            ),
                          ],
                        ),
                      )
                          : Container(
                        width: 336*sizeUnit,
                        height: 40*sizeUnit,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          border: Border.all(color: hexToColor("#CCCCCC")),
                        ),
                        child: Row(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: EdgeInsets.only(left: 12*sizeUnit),
                                child: Text(
                                  '이미지 업로드',
                                  style: SheepsTextStyle.hint4Profile(context),
                                ),
                              ),
                            ),
                            Expanded(child: SizedBox()),
                            Padding(
                              padding: EdgeInsets.only(right: 4*sizeUnit),
                              child: SvgPicture.asset(
                                svgGreyNextIcon2,
                                width: 12*sizeUnit,
                                height: 12*sizeUnit,
                              ),
                            ),
                          ],
                        ),
                      )
                  )
                ],
              ),
            ),
          ),
          bottomNavigationBar: GestureDetector(
            onTap: (){
              if(_ModifiedTeamProfile.IfAddTeamAwardComplete == true) {
                _ModifiedTeamProfile.AddTeamAwardList('${_ModifiedTeamProfile.getTeamAwardName()} / ${_ModifiedTeamProfile.getTeamAwardGrade()} / ${_ModifiedTeamProfile.getTeamAwardAgency()}');
                _ModifiedTeamProfile.ChangeIsAddAwardUploadComplte(false);
                _ModifiedTeamProfile.ChangeIfAddAwardComplete(false);

                _ModifiedTeamProfile.resetModelAddTeam();
                Navigator.pop(context);
              } else {
              }
            },
            child: Container(
                height: 60*sizeUnit,
                decoration: BoxDecoration(
                  color: _ModifiedTeamProfile.IfAddTeamAwardComplete == true ? hexToColor("#61C680") : hexToColor("#CCCCCC"),
                ),
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    '수상 경력 추가',
                    style: SheepsTextStyle.button1(context),
                  ),
                )
            ),
          ),
        ),
      ),
    );
  }

  void CheckForAddAward_AddTeam(ModelAddTeam _ModifiedTeamProfile) {
    if(_ModifiedTeamProfile.TeamAwardName != "" && _ModifiedTeamProfile.TeamAwardGrade != "" && _ModifiedTeamProfile.TeamAwardAgency != "" && _ModifiedTeamProfile.TeamAwardTime != "" && _ModifiedTeamProfile.IfAddTeamAwardUploadComplte == true &&
        _ModifiedTeamProfile.TeamAwardName != null && _ModifiedTeamProfile.TeamAwardGrade != null && _ModifiedTeamProfile.TeamAwardAgency != null && _ModifiedTeamProfile.TeamAwardTime != null) {
      _ModifiedTeamProfile.ChangeIfAddTeamAwardComplete(true);
    } else {
      _ModifiedTeamProfile.ChangeIfAddTeamAwardComplete(false);
    }
  }
}
