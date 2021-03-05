import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/profileModify/UploadForPersonalCertification.dart';
import 'package:sheeps_app/profileModify/models/DummyForProfileModify.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/config/GlobalAsset.dart';

class AddCertification extends StatefulWidget {
  @override
  _AddCertificationState createState() => _AddCertificationState();
}

class _AddCertificationState extends State<AddCertification> {
  final NameController = TextEditingController();
  final AgencyController = TextEditingController();

  double sizeUnit = 1;

  bool ValidationFlag1 = false;
  bool ValidationFlag2 = false;

  bool Validation_OnlyString(String value, String target) {
    String p = r'[$./!@#<>?":_`~;[\]\\|=+)(*&^%0-9-\s-]';

    RegExp regExp = new RegExp(p);
    setState(() {
      if(target == "자격명") {
        ValidationFlag1 = regExp.hasMatch(value);
      } else if(target == "발급기관") {
        ValidationFlag2 = regExp.hasMatch(value);
      }
    });
    return regExp.hasMatch(value);
  }
  bool Validation_NoSpecialChar(String value, String target) {
    String p = r'[$./!@#<>?":_`~;[\]\\|=+)(*&^%]';

    RegExp regExp = new RegExp(p);
    setState(() {
      if(target == "자격명") {
        ValidationFlag1 = regExp.hasMatch(value);
      } else if(target == "발급기관") {
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
          appBar: SheepsAppBar(context,'자격증 추가',
          backFunc: (){
            _ModifiedProfile.ChangeCareerUploadComplete(false);
            _ModifiedProfile.ChangeIfAddCertificationComplete(false);

            if(_ModifiedProfile.CertificationList.length < _ModifiedProfile.CertificationFile.length) {
              _ModifiedProfile.removeEndFile(2);
              _ModifiedProfile.ChangeCertificationUploadComplete(false);
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
                      '자격명',
                      style: SheepsTextStyle.h3(context),
                    ),
                  ),
                  SizedBox(height: 8*sizeUnit),
                  buildNameController(_ModifiedProfile),
                  SizedBox(height: 20*sizeUnit),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      '발급 기관',
                      style: SheepsTextStyle.h3(context),
                    ),
                  ),
                  SizedBox(height: 8*sizeUnit),
                  buildAgencyController(_ModifiedProfile),
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
                          '자격증 사본, 합격증명서 등',
                          style: SheepsTextStyle.info2(context),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 8*sizeUnit),
                  buildImageUpload(context, _ModifiedProfile)
                ],
              ),
            ),
          ),
          bottomNavigationBar: GestureDetector(
            onTap: (){
              if(_ModifiedProfile.IfAddCertificationComplete== true) {
                _ModifiedProfile.AddCertificationList('${_ModifiedProfile.CertificationName} / ${_ModifiedProfile.CertificationAgency}');
                _ModifiedProfile.ChangeCertificationUploadComplete(false);
                _ModifiedProfile.ChangeIfAddCertificationComplete(false);

                _ModifiedProfile.ChangeCertificationName(null);
                _ModifiedProfile.ChangeAgency(null);
                _ModifiedProfile.ChangeCertificationUploadComplete(false);

                Navigator.pop(context);
              } else {

              }
            },
            child: Container(
                height: 60*sizeUnit,
                decoration: BoxDecoration(
                  color: _ModifiedProfile.IfAddCertificationComplete == true ? hexToColor("#61C680") : hexToColor("#CCCCCC"),
                ),
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    '자격증 추가',
                    style: SheepsTextStyle.button1(context),
                  ),
                )
            ),
          ),
        ),
      ),
    );
  }

  GestureDetector buildImageUpload(BuildContext context, ModifiedProfile _ModifiedProfile) {
    return GestureDetector(
              onTap: (){
                Navigator.push(
                    context, // 기본 파라미터, SecondRoute로 전달
                    MaterialPageRoute(
                        builder: (context) =>
                            UploadForPersonalCertification()) // SecondRoute를 생성하여 적재
                ).then((value) {
                  CheckForAddCertification_MyProfileModify(_ModifiedProfile);
                });
              },
              child: _ModifiedProfile.CertificationUploadComplete == true ? Container(
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
                        color: hexToColor('#61C680'),
                        width: 16*sizeUnit,
                        height: 16*sizeUnit,
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
                          style: SheepsTextStyle.hint4Profile(context)
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
          );
  }


  TextField buildAgencyController(ModifiedProfile _ModifiedProfile) {
    return TextField(
      controller: AgencyController,
      style: SheepsTextStyle.b3(context),
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        isDense: true,
        contentPadding: EdgeInsets.all(12*sizeUnit),
        hintText: '예) 한국산업인력공단',
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
        if(!Validation_NoSpecialChar(text, "발급기관")) {
          _ModifiedProfile.ChangeAgency(text);
          CheckForAddCertification_MyProfileModify(_ModifiedProfile);
        }
      },
    );
  }

  TextField buildNameController(ModifiedProfile _ModifiedProfile) {
    return TextField(
      controller: NameController,
      style: SheepsTextStyle.b3(context),
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        isDense: true,
        contentPadding: EdgeInsets.all(12*sizeUnit),
        hintText: '예) 정보처리기능사',
        hintStyle: SheepsTextStyle.hint4Profile(context),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8*sizeUnit)),
          borderSide: BorderSide(width: 1,color: hexToColor(("#61C680"))),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8*sizeUnit)),
          borderSide: BorderSide(width: 1,color: hexToColor(("#CCCCCC"))),
        ),
          errorText: ValidationFlag1 ? '특수문자는 들어갈 수 없습니다.' : null
      ),
      onChanged: (text) {
        if(!Validation_NoSpecialChar(text, "자격명")) {
          _ModifiedProfile.ChangeCertificationName(text);
          CheckForAddCertification_MyProfileModify(_ModifiedProfile);
        }

      },
    );
  }

  void CheckForAddCertification_MyProfileModify(ModifiedProfile _ModifiedProfile) {
    if(_ModifiedProfile.CertificationName != null &&  _ModifiedProfile.CertificationAgency != null  && _ModifiedProfile.CertificationUploadComplete == true &&
        _ModifiedProfile.CertificationName != "" &&  _ModifiedProfile.CertificationAgency != "" ) {
      _ModifiedProfile.ChangeIfAddCertificationComplete(true);
    } else {
      _ModifiedProfile.ChangeIfAddCertificationComplete(false);
    }
  }
}
