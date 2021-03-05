import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/GlobalAsset.dart';
import 'package:sheeps_app/profile/AddTeam/UploadForProject.dart';
import 'package:sheeps_app/profile/models/ModelAddTeam.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';

class AddProjectForAddTeam extends StatefulWidget {
  @override
  _AddProjectState createState() => _AddProjectState();
}

class _AddProjectState extends State<AddProjectForAddTeam> {
  final NameController = TextEditingController();
  final AgencyController = TextEditingController();

  bool ValidationFlag1 = false;
  bool ValidationFlag2 = false;

  double sizeUnit = 1;

  bool Validation_OnlyString(String value, String target) {
    String p = r'[$./!@#<>?":_`~;[\]\\|=+)(*&^%0-9-\s-]';

    RegExp regExp = new RegExp(p);
    setState(() {
      if(target == "프로젝트명") {
        ValidationFlag1 = regExp.hasMatch(value);
      } else if(target == "주관기관") {
        ValidationFlag2 = regExp.hasMatch(value);
      }
    });
    return regExp.hasMatch(value);
  }
  bool Validation_NoSpecialChar(String value, String target) {
    String p = r'[$./!@#<>?":_`~;[\]\\|=+)(*&^%]';

    RegExp regExp = new RegExp(p);
    setState(() {
      if(target == "프로젝트명") {
        ValidationFlag1 = regExp.hasMatch(value);
      } else if(target == "주관기관") {
        ValidationFlag2 = regExp.hasMatch(value);
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
            '수행 내역 추가',
            backFunc: (){
              if(_ModifiedTeamProfile.ProjectList.length < _ModifiedTeamProfile.ProjectFile.length) {
                _ModifiedTeamProfile.removeEndFile(2);
                _ModifiedTeamProfile.ChangeIfAddProjectUploadComplete(false);
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
                      '프로젝트명',
                      style: SheepsTextStyle.h3(context),
                    ),
                  ),
                  SizedBox(height: 8*sizeUnit),
                  TextField(
                    controller: NameController,
                    style: SheepsTextStyle.b3(context),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding: EdgeInsets.all(12*sizeUnit),
                      hintText: '예) WEB UI 디자인 용역 / 스터디 어플리케이션 개발',
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
                      if(!Validation_NoSpecialChar(text, "프로젝트명")) {
                        _ModifiedTeamProfile.ChangeProjectName(text);
                        CheckForAddProject_AddTeam(_ModifiedTeamProfile);
                      }
                    },
                  ),
                  SizedBox(height: 16*sizeUnit),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      '주관 기관',
                      style: SheepsTextStyle.h3(context),
                    ),
                  ),
                  SizedBox(height: 8*sizeUnit),
                  TextField(
                    controller: AgencyController,
                    style: SheepsTextStyle.b3(context),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding: EdgeInsets.all(12*sizeUnit),
                      hintText: '예) 주식회사 쉽스 / 자체 프로젝트',
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
                      if(!Validation_NoSpecialChar(text, "주관기관")) {
                        _ModifiedTeamProfile.ChangeProjectAgency(text);
                        CheckForAddProject_AddTeam(_ModifiedTeamProfile);
                      }
                    },
                  ),
                  SizedBox(height: 16*sizeUnit),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      '기간',
                      style: SheepsTextStyle.h3(context),
                    ),
                  ),
                  SizedBox(height: 8*sizeUnit),
                  Row(
                    children: [
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
                                      color: Colors.black, fontSize: 18),
                                  doneStyle: TextStyle(color: Colors.white, fontSize: 16)),
                              onChanged: (date) {
                                _ModifiedTeamProfile.ChangeProjectStart(DateFormat('y.MM').format(date));
                                CheckForAddProject_AddTeam(_ModifiedTeamProfile);
                              },
                              currentTime: DateTime.now(), locale: LocaleType.ko);
                        },
                        child: Container(
                          width: 152*sizeUnit,
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
                                '${_ModifiedTeamProfile.ProjectStart == null ? '시작년월':_ModifiedTeamProfile.ProjectStart}',
                                style: _ModifiedTeamProfile.ProjectStart == null
                                    ? SheepsTextStyle.hint4Profile(context)
                                    : SheepsTextStyle.b3(context),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12*sizeUnit),
                      Container(
                        height: 1,
                        width: 8*sizeUnit,
                        decoration: BoxDecoration(
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(width: 12*sizeUnit),
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
                                      color: Colors.black, fontSize: 18),
                                  doneStyle: TextStyle(color: Colors.white, fontSize: 16)),
                              onChanged: (date) {
                                _ModifiedTeamProfile.ChangeProjectEnd(DateFormat('y.MM').format(date));
                                CheckForAddProject_AddTeam(_ModifiedTeamProfile);

                              },
                              currentTime: DateTime.now(), locale: LocaleType.ko);
                        },
                        child: Container(
                          width: 152*sizeUnit,
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
                                '${_ModifiedTeamProfile.ProjectEnd == null ? '종료년월':_ModifiedTeamProfile.ProjectEnd}',
                                style: _ModifiedTeamProfile.ProjectEnd == null
                                    ? SheepsTextStyle.hint4Profile(context)
                                    : SheepsTextStyle.b3(context),
                              ),
                            ),
                          ),
                        ),
                      ),

                    ],
                  ),
                  SizedBox(height: 8*sizeUnit),
                  Row(
                    children: [
                      Text(
                        '증빙 자료',
                        style: SheepsTextStyle.h3(context),
                      ),
                      SizedBox(width: 8*sizeUnit),
                      Text(
                        '인증 서류 사본을 업로드 해주세요.',
                        style: SheepsTextStyle.info2(context),
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
                                    UploadForProject()) // SecondRoute를 생성하여 적재
                        ).then((value) {
                          CheckForAddProject_AddTeam(_ModifiedTeamProfile);
                        });
                      },
                      child: _ModifiedTeamProfile.IfAddProjectUploadComplete == true ? Container(
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
                                color: hexToColor('#61C680'),
                                width: 12*sizeUnit,
                                height: 12*sizeUnit,
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
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: GestureDetector(
            onTap: (){
              if(_ModifiedTeamProfile.IfAddProjectComplete == true) {
                _ModifiedTeamProfile.AddProjectList('${_ModifiedTeamProfile.ProjectName} / ${_ModifiedTeamProfile.ProjectStart} ~ ${_ModifiedTeamProfile.ProjectEnd}');
                _ModifiedTeamProfile.ChangeIfAddProjectUploadComplete(false);
                _ModifiedTeamProfile.ChangeIfAddProjectComplete(false);

                _ModifiedTeamProfile.resetModelAddTeam();
                Navigator.pop(context);
              } else {
              }
            },
            child: Container(
                height: 60*sizeUnit,
                decoration: BoxDecoration(
                  color: _ModifiedTeamProfile.IfAddProjectComplete == true ? hexToColor("#61C680") : hexToColor("#CCCCCC"),
                ),
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    '수행 내역 추가',
                    style: SheepsTextStyle.button1(context),
                  ),
                )
            ),
          ),
        ),
      ),
    );
  }

  void CheckForAddProject_AddTeam(ModelAddTeam _ModifiedTeamProfile) {
    if(_ModifiedTeamProfile.ProjectName != null && _ModifiedTeamProfile.ProjectAgency != null && _ModifiedTeamProfile.ProjectStart != null && _ModifiedTeamProfile.ProjectEnd != null && _ModifiedTeamProfile.IfAddProjectUploadComplete == true &&
        _ModifiedTeamProfile.ProjectName != null && _ModifiedTeamProfile.ProjectAgency != "" && _ModifiedTeamProfile.ProjectStart != "" && _ModifiedTeamProfile.ProjectEnd != "") {
      _ModifiedTeamProfile.ChangeIfAddProjectComplete(true);
    } else {
      _ModifiedTeamProfile.ChangeIfAddProjectComplete(false);
    }
  }
}
