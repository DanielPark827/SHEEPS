import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:sheeps_app/TeamProfileModifys/UploadForTeamIdentified.dart';
import 'package:sheeps_app/TeamProfileModifys/model/DummyForTeamProfileModify.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/GlobalAsset.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';

class AddIdentified extends StatefulWidget {
  @override
  _AddIdentifiedState createState() => _AddIdentifiedState();
}

class _AddIdentifiedState extends State<AddIdentified> {
  final NameController = TextEditingController();
  final AgencyController = TextEditingController();

  bool ValidationFlag1 = false;
  bool ValidationFlag2 = false;
  double sizeUnit = 1;

  bool Validation_OnlyString(String value, String target) {
    String p = r'[$./!@#<>?":_`~;[\]\\|=+)(*&^%0-9-\s-]';

    RegExp regExp = new RegExp(p);
    setState(() {
      if(target == "인증명") {
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
      if(target == "인증명") {
        ValidationFlag1 = regExp.hasMatch(value);
      } else if(target == "주관기관") {
        ValidationFlag2 = regExp.hasMatch(value);
      }
    });
    return regExp.hasMatch(value);
  }

  @override
  Widget build(BuildContext context) {
    ModelTeamProfile _ModifiedTeamProfile = Provider.of<ModelTeamProfile>(context);
    sizeUnit = SheepsTextStyle.sizeUnit(context).fontSize;

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),//사용자 스케일팩터 무시
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: SheepsAppBar(
          context,
          '인증 추가',
          backFunc: (){
            if(_ModifiedTeamProfile.IdentifiedList.length < _ModifiedTeamProfile.IdentifiedFile.length) {
              _ModifiedTeamProfile.removeEndFile(1);
              _ModifiedTeamProfile.ChangeIfAddIdentifiedUploadComplete(false);
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
                SizedBox(height: 20*sizeUnit),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    '인증명',
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
                    hintText: '예) 벤처기업인증',
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
                    if(!Validation_NoSpecialChar(text, "인증명")) {
                      _ModifiedTeamProfile.ChangeIdentifiedName(text);
                      CheckForAddIdentified_TeamModify(_ModifiedTeamProfile);
                    }
                  },
                ),
                SizedBox(height: 20*sizeUnit),
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
                      errorText: ValidationFlag2 ? '특수문자는 들어갈 수 없습니다.' : null
                  ),
                  onChanged: (text) {
                    if(!Validation_NoSpecialChar(text, "주관기관")) {
                      _ModifiedTeamProfile.ChangeIdentifiedAgency(text);
                      CheckForAddIdentified_TeamModify(_ModifiedTeamProfile);
                    }
                  },
                ),
                SizedBox(height: 20*sizeUnit),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    '증빙 자료',
                    style: SheepsTextStyle.h3(context),
                  ),
                ),
                SizedBox(height: 8*sizeUnit),
                GestureDetector(
                    onTap: (){
                      Navigator.push(
                          context, // 기본 파라미터, SecondRoute로 전달
                          MaterialPageRoute(
                              builder: (context) =>
                                  UploadForTeamIdentified()) // SecondRoute를 생성하여 적재
                      ).then((value) {
                        CheckForAddIdentified_TeamModify(_ModifiedTeamProfile);
                      });
                    },
                    child: _ModifiedTeamProfile.IfAddIdentifiedUploadComplete == true ? Container(
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

            if(_ModifiedTeamProfile.IfAddIdentifiedComplete == true) {
              _ModifiedTeamProfile.AddIdentifiedList('${_ModifiedTeamProfile.IdentifiedName} / ${_ModifiedTeamProfile.IdentifiedAgency}');
              _ModifiedTeamProfile.ChangeIfAddIdentifiedUploadComplete(false);
              _ModifiedTeamProfile.ChangeIfAddIdentifiedComplete(false);

              _ModifiedTeamProfile.resetModelAddTeam();
              Navigator.pop(context);
            } else {
            }
          },
          child: Container(
              height: 60*sizeUnit,
              decoration: BoxDecoration(
                color: _ModifiedTeamProfile.IfAddIdentifiedComplete == true ? hexToColor("#61C680") : hexToColor("#CCCCCC"),
              ),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  '인증 추가',
                  style: SheepsTextStyle.button1(context),
                ),
              )
          ),
        ),
      ),
    );
  }

  void CheckForAddIdentified_TeamModify(ModelTeamProfile _ModifiedTeamProfile) {
    if( _ModifiedTeamProfile.IdentifiedName != null && _ModifiedTeamProfile.IdentifiedAgency != null && _ModifiedTeamProfile.IfAddIdentifiedUploadComplete == true &&
        _ModifiedTeamProfile.IdentifiedName != "" && _ModifiedTeamProfile.IdentifiedAgency != "") {
      _ModifiedTeamProfile.ChangeIfAddIdentifiedComplete(true);
    } else {_ModifiedTeamProfile.ChangeIfAddIdentifiedComplete(false);}
  }
}
