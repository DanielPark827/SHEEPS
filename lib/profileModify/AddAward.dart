import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/profileModify/UploadForPersonalAward.dart';
import 'package:sheeps_app/profileModify/models/DummyForProfileModify.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/config/GlobalAsset.dart';

class AddAward extends StatefulWidget {
  @override
  _AddAwardState createState() => _AddAwardState();
}

class _AddAwardState extends State<AddAward> {
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
    ModifiedProfile _ModifiedProfile = Provider.of<ModifiedProfile>(context);
    sizeUnit = SheepsTextStyle.sizeUnit(context).fontSize;

    return GestureDetector(
      onTap: (){
        FocusScopeNode currentFocus = FocusScope.of(context);
        if(!currentFocus.hasPrimaryFocus){currentFocus.unfocus();}//텍스트 포커스 해제
      },
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),//사용자 스케일팩터 무시
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: SheepsAppBar(context, '수상 추가',
          backFunc: (){
            _ModifiedProfile.ChangeAwardUploadComplete(false);
            _ModifiedProfile.ChangeIfAddAwardComplete(false);
            if(_ModifiedProfile.AwardList.length < _ModifiedProfile.AwardFile.length) {
              _ModifiedProfile.removeEndFile(3);
              _ModifiedProfile.ChangeAwardUploadComplete(false);
            }
            _ModifiedProfile.resetModifiedProfile();
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
                  buildAwardNameController(_ModifiedProfile),
                  SizedBox(height: 20*sizeUnit),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      '상격',
                      style: SheepsTextStyle.h3(context),
                    ),
                  ),
                  SizedBox(height: 8*sizeUnit),
                  buildAwardGradeController(_ModifiedProfile),
                  SizedBox(height: 20*sizeUnit),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      '주관기관',
                      style: SheepsTextStyle.h3(context),
                    ),
                  ),
                  SizedBox(height: 8*sizeUnit),
                  buildAwardAgencyController(_ModifiedProfile),
                  SizedBox(height: 20*sizeUnit),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      '수상일',
                      style: SheepsTextStyle.h3(context),
                    ),
                  ),
                  SizedBox(height: 8*sizeUnit),
                  buildChangeAwardTime(context, _ModifiedProfile),
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
                          style: SheepsTextStyle.info2(context),
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
                                    UploadForPersonalAward()) // SecondRoute를 생성하여 적재
                        ).then((value) {
                          CheckForAddAward_MyProfileModify(_ModifiedProfile);
                        });
                      },
                      child: _ModifiedProfile.AwardUploadComplete == true ? Container(
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
                                width: 16*sizeUnit,
                                height: 16*sizeUnit,
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
                                  '증빙 자료 업로드',
                                  style: SheepsTextStyle.hint4Profile(context),
                                ),
                              ),
                            ),
                            Expanded(child: SizedBox()),
                            Padding(
                              padding: EdgeInsets.only(right: 8*sizeUnit),
                              child: SvgPicture.asset(
                                svgGreyNextIcon2,
                                width: 16*sizeUnit,
                                height: 16*sizeUnit,
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
              if(_ModifiedProfile.IfAddAwardComplete == true) {
                _ModifiedProfile.AddAwardList('${_ModifiedProfile.AwardName} / ${_ModifiedProfile.AwardGrader} / ${_ModifiedProfile.AwardAgency}');
                _ModifiedProfile.ChangeAwardUploadComplete(false);
                _ModifiedProfile.ChangeIfAddAwardComplete(false);

                _ModifiedProfile.ChangeAwardName(null);
                _ModifiedProfile.ChangeAwardGrader(null);
                _ModifiedProfile.ChangeAwardAgency(null);
                _ModifiedProfile.ChangeAwardTime(null);

                Navigator.pop(context);
              } else {
              }
            },
            child: Container(
                height: 60*sizeUnit,
                  color: _ModifiedProfile.IfAddAwardComplete == true ? hexToColor("#61C680") : hexToColor("#CCCCCC"),
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

  GestureDetector buildChangeAwardTime(BuildContext context, ModifiedProfile _ModifiedProfile) {
    return GestureDetector(
            onTap: (){
              DatePicker.showDatePicker(context,
                  showTitleActions: true,
                  minTime: DateTime(DateTime.now().year-20, 1, 1),
                  maxTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
                  theme: DatePickerTheme(
                      headerColor: Colors.white,
                      backgroundColor: Colors.white,
                      itemStyle: TextStyle(
                          color: Colors.black, fontSize: 18*sizeUnit),
                      doneStyle: TextStyle(color: Colors.white, fontSize:16*sizeUnit)),
                  onChanged: (date) {
                    _ModifiedProfile.ChangeAwardTime(DateFormat('y.MM').format(date));
                    CheckForAddAward_MyProfileModify(_ModifiedProfile);
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
                    '${_ModifiedProfile.AwardTime == null ? '수상년월':_ModifiedProfile.AwardTime}',
                    style: SheepsTextStyle.hint4Profile(context).copyWith(color: hexToColor("${_ModifiedProfile.AwardTime == null ? "#CCCCCC" : "#222222"}")),
                  ),
                ),
              ),
            ),
          );
  }

  TextField buildAwardAgencyController(ModifiedProfile _ModifiedProfile) {
    return TextField(
            controller: AwardAgencyController,
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
                _ModifiedProfile.ChangeAwardAgency(text);
                CheckForAddAward_MyProfileModify(_ModifiedProfile);
              }
            },
          );
  }

  TextField buildAwardGradeController(ModifiedProfile _ModifiedProfile) {
    return TextField(
            controller: AwardGradeController,
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
                _ModifiedProfile.ChangeAwardGrader(text);
                CheckForAddAward_MyProfileModify(_ModifiedProfile);
              }

            },
          );
  }

  TextField buildAwardNameController(ModifiedProfile _ModifiedProfile) {
    return TextField(
            controller: AwardNameController,
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
                _ModifiedProfile.ChangeAwardName(text);
                CheckForAddAward_MyProfileModify(_ModifiedProfile);
              }

            },
          );
  }

  void CheckForAddAward_MyProfileModify(ModifiedProfile _ModifiedProfile) {
    if( _ModifiedProfile.AwardName != null && _ModifiedProfile.AwardGrader != null && _ModifiedProfile.AwardAgency != null &&  _ModifiedProfile.AwardTime != null && _ModifiedProfile.AwardUploadComplete == true &&
        _ModifiedProfile.AwardName != "" && _ModifiedProfile.AwardGrader != "" && _ModifiedProfile.AwardAgency != "" &&  _ModifiedProfile.AwardTime != "") {
      _ModifiedProfile.ChangeIfAddAwardComplete(true);
    } else {
      _ModifiedProfile.ChangeIfAddAwardComplete(false);
    }
  }
}
