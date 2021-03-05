import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/GlobalAsset.dart';
import 'package:sheeps_app/profileModify/UploadForPersonalCareer.dart';
import 'package:sheeps_app/profileModify/models/DummyForProfileModify.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';

class AddCareer extends StatefulWidget {
  @override
  _AddCareerState createState() => _AddCareerState();
}

class _AddCareerState extends State<AddCareer> {

  final NameOfCompanyController = TextEditingController();
  final RoleController = TextEditingController();

  bool ValidationFlag1 = false;
  bool ValidationFlag2 = false;

  double sizeUnit = 1;



  bool Validation_OnlyString(String value, String target) {
    String p = r'[$./!@#<>?":_`~;[\]\\|=+)(*&^%0-9-\s-]';

    RegExp regExp = new RegExp(p);
    setState(() {
      if(target == "기업명") {
        ValidationFlag1 = regExp.hasMatch(value);
      } else if(target == "역할") {
        ValidationFlag2 = regExp.hasMatch(value);
      }
    });
    return regExp.hasMatch(value);
  }
  bool Validation_NoSpecialChar(String value, String target) {
    String p = r'[$.!@#<>?":_`~;[\]\\|=+)(*&^%]';

    RegExp regExp = new RegExp(p);
    setState(() {
      if(target == "기업명") {
        ValidationFlag1 = regExp.hasMatch(value);
      } else if(target == "역할") {
        ValidationFlag2 = regExp.hasMatch(value);
      }
    });
    return regExp.hasMatch(value);
  }

  @override
  Widget build(BuildContext context) {
    sizeUnit = SheepsTextStyle.sizeUnit(context).fontSize;
    ModifiedProfile _ModifiedProfile = Provider.of<ModifiedProfile>(context);

    return GestureDetector(
      onTap: (){
        FocusScopeNode currentFocus = FocusScope.of(context);
        if(!currentFocus.hasPrimaryFocus){currentFocus.unfocus();}//텍스트 포커스 해제
      },
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),//사용자 스케일팩터 무시
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: SheepsAppBar(context,'경력 추가',
              backFunc:(){
                _ModifiedProfile.ChangeCareerUploadComplete(false);
                _ModifiedProfile.MakeIfAddCareerCompleteOff();

                if(_ModifiedProfile.CareerList.length < _ModifiedProfile.CareerFile.length) {
                  _ModifiedProfile.removeEndFile(1);
                  _ModifiedProfile.ChangeCareerUploadComplete(false);
                }
                _ModifiedProfile.resetModifiedProfile();
                Navigator.pop(context);
              }
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
                      '기업명',
                      style: SheepsTextStyle.h3(context),
                    ),
                  ),
                  SizedBox(height: 8*sizeUnit),
                  buildNameOfCompanyController(_ModifiedProfile),
                  SizedBox(height: 20*sizeUnit),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      '역할',
                      style: SheepsTextStyle.h3(context),
                    ),
                  ),
                  SizedBox(height: 8*sizeUnit),
                  buildRoleController(_ModifiedProfile),
                  SizedBox(height: 20*sizeUnit),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          '기간',
                          style: SheepsTextStyle.h3(context),
                        ),
                      ),
                      SizedBox(width: 8*sizeUnit),
                      GestureDetector(
                          onTap: (){
                            _ModifiedProfile.ChangeCareerIfHoldOffice();
                            if(_ModifiedProfile.IfHoldOffice) {
                              _ModifiedProfile.ChangeCareerEnd('현재');
                            } else {
                              _ModifiedProfile.ChangeCareerEnd(null);
                            }
                          },
                          child: !_ModifiedProfile.IfHoldOffice ? Padding(
                            padding: EdgeInsets.only(top: 4*sizeUnit),
                            child: SvgPicture.asset(
                              svgCheckBoxEmpty,
                              width: 16*sizeUnit,
                              height: 16*sizeUnit,
                            ),
                          ) : Padding(
                            padding: EdgeInsets.only(top: 4*sizeUnit),
                            child: SvgPicture.asset(
                              svgCheckBoxGreen,
                              width: 16*sizeUnit,
                              height: 16*sizeUnit,
                            ),
                          )
                      ),
                      SizedBox(width: 4*sizeUnit),
                      Container(
                        height: 22*sizeUnit,
                        child: Align(
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            '재직 중',
                            style: SheepsTextStyle.hint4Profile(context),
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 8*sizeUnit),
                  buildTimeController(context, _ModifiedProfile, screenHeight, screenWidth),
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
                          '4대보험 증명원, 재직증명서 등',
                          style: SheepsTextStyle.info2(context),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 8*sizeUnit),
                  buildImageUploadButton(context, _ModifiedProfile)
                ],
              ),
            ),
          ),
          bottomNavigationBar: GestureDetector(
            onTap: (){
              String addWorking = '';
              if(_ModifiedProfile.End == '현재') {
                _ModifiedProfile.ChangeCareerEnd(DateFormat('y.MM').format(DateTime.now()));
                addWorking = "재직중";
              }
              _ModifiedProfile.ChangeCareerYears(_ModifiedProfile.EndYears - _ModifiedProfile.StartYears);

              List<String> startList = _ModifiedProfile.Start.split('.');
              List<String> endList = _ModifiedProfile.End.split('.');
              int diffYear = int.parse(endList[0]) - int.parse(startList[0]);
              int diffMonth = int.parse(endList[1]) - int.parse(startList[1]);

              if(diffMonth > 12){
                diffYear += 1;
                diffMonth -= 12;
              }else if(diffMonth < 0){
                diffYear -= 1;
                diffMonth = 12 - diffMonth.abs();
              }

              String diffYearString = diffYear != 0 ? diffYear.toString() + "년" : "";
              String diffMonthString = diffMonth != 0 ? diffMonth.toString() + "개월" : "";

              if(_ModifiedProfile.IfAddCareerComplete == true) {
                _ModifiedProfile.AddCareerStartAndEnd(_ModifiedProfile.Start, _ModifiedProfile.End);
                _ModifiedProfile.AddIfHoldOfficeList(_ModifiedProfile.IfHoldOffice);
                _ModifiedProfile.AddCareerList('${_ModifiedProfile.Company} / ${_ModifiedProfile.Role} / $diffYearString $diffMonthString $addWorking');
                _ModifiedProfile.ChangeCareerUploadComplete(false);
                _ModifiedProfile.MakeIfAddCareerCompleteOff();

                _ModifiedProfile.ChangeCareerCompany(null);
                _ModifiedProfile.ChangeCareerRole(null);
                _ModifiedProfile.ChangeCareerStart(null);
                _ModifiedProfile.ChangeCareerEnd(null);
                _ModifiedProfile.ChangeCareerUploadComplete(false);
                Navigator.pop(context);
              } else {
              }
            },
            child: Container(
                height: 60*sizeUnit,
                decoration: BoxDecoration(
                  color: _ModifiedProfile.IfAddCareerComplete == true ? hexToColor("#61C680") : hexToColor("#CCCCCC"),
                ),
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    '경력 추가',
                    style: SheepsTextStyle.button1(context),
                  ),
                )
            ),
          ),
        ),
      ),
    );
  }

  GestureDetector buildImageUploadButton(BuildContext context, ModifiedProfile _ModifiedProfile) {
    return GestureDetector(
            onTap: (){
              Navigator.push(
                  context, // 기본 파라미터, SecondRoute로 전달
                  MaterialPageRoute(
                      builder: (context) =>
                          UploadForPersonalCareer()) // SecondRoute를 생성하여 적재
              ).then((value) {
                CheckForAddCareer_MyProfileModify(_ModifiedProfile);
              });
            },
            child: _ModifiedProfile.CareerUploadComplete == true ? Container(
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
                        style: SheepsTextStyle.hint4Profile(context).copyWith(color: hexToColor("#61C680")),
                      ),
                    ),
                  ),
                  Expanded(child: SizedBox()),
                  Padding(
                    padding: EdgeInsets.only(right: 8*sizeUnit),
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
                        '증빙자료 업로드 업로드',
                        style: SheepsTextStyle.hint4Profile(context)
                      ),
                    ),
                  ),
                  Expanded(child: SizedBox()),
                  Padding(
                    padding: EdgeInsets.only(right: 8*sizeUnit),
                    child: SvgPicture.asset(
                      svgGreyNextIcon2,
                      width: 12*sizeUnit,
                      height: 12*sizeUnit,
                    ),
                  ),
                ],
              ),
            )
          );
  }

  Row buildTimeController(BuildContext context, ModifiedProfile _ModifiedProfile, double screenHeight, double screenWidth) {
    return Row(
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
                        _ModifiedProfile.ChangeCareerStart(DateFormat('y.MM').format(date));
                        _ModifiedProfile.ChangeCareerStartYears(date.year);
                        CheckForAddCareer_MyProfileModify(_ModifiedProfile);
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
                        '${_ModifiedProfile.Start == null ? '입사일 선택':_ModifiedProfile.Start}',
                        style: SheepsTextStyle.hint4Profile(context).copyWith(color: hexToColor("${_ModifiedProfile.Start == null ? "#D2D2D2" : "#222222"}")),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12*sizeUnit),
              Container(
                height: 1,
                width: 6*sizeUnit,
                decoration: BoxDecoration(
                  color: Color(0xFFCCCCCC),
                ),
              ),
              SizedBox(width: 12*sizeUnit),
              GestureDetector(
                onTap: (){
                  if(!_ModifiedProfile.IfHoldOffice) {
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
                          _ModifiedProfile.ChangeCareerEnd(DateFormat('y.MM').format(date));
                          _ModifiedProfile.ChangeCareerEndYears(date.year);
                          CheckForAddCareer_MyProfileModify(_ModifiedProfile);
                        },
                        currentTime: DateTime.now(), locale: LocaleType.ko);
                  }
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
                        '${_ModifiedProfile.End == null ? '퇴사일 선택':_ModifiedProfile.End}',
                        style: SheepsTextStyle.hint4Profile(context).copyWith(color: hexToColor("${_ModifiedProfile.End == null ? "#D2D2D2" : "#222222"}")),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
  }

  TextField buildRoleController(ModifiedProfile _ModifiedProfile) {
    return TextField(
            controller: RoleController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
              contentPadding: EdgeInsets.all(12*sizeUnit),
              hintText: '예) CEO, 서버 개발, UXUI 등',
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
              if(!Validation_NoSpecialChar(text, "역할")) {
                _ModifiedProfile.ChangeCareerRole(text);
                CheckForAddCareer_MyProfileModify(_ModifiedProfile);
              }
            },
          );
  }

  TextField buildNameOfCompanyController(ModifiedProfile _ModifiedProfile) {
    return TextField(
            controller: NameOfCompanyController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
              contentPadding: EdgeInsets.all(12*sizeUnit),
              hintText: '예) 주식회사 쉽스',
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
              if(!Validation_NoSpecialChar(text, "기업명")) {
                _ModifiedProfile.ChangeCareerCompany(text);
                CheckForAddCareer_MyProfileModify(_ModifiedProfile);
              }
            },
          );
  }

  void CheckForAddCareer_MyProfileModify(ModifiedProfile _ModifiedProfile) {
    if( _ModifiedProfile.Company != null && _ModifiedProfile.Role != null && _ModifiedProfile.Start != null && _ModifiedProfile.End != null && _ModifiedProfile.CareerUploadComplete == true &&
        _ModifiedProfile.Company != "" && _ModifiedProfile.Role != "" && _ModifiedProfile.Start != "" && _ModifiedProfile.End != "") {
      _ModifiedProfile.MakeIfAddCareerCompleteOn();
    } else {
      _ModifiedProfile.MakeIfAddCareerCompleteOff();
    }
  }
}
