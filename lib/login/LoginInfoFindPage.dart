import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iamport_flutter/model/certification_data.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/login/iamportCertificationNamePage.dart';
import 'package:sheeps_app/network/ApiProvider.dart';
import 'package:sheeps_app/registration/model/RegistrationModel.dart';
import 'package:sheeps_app/config/GlobalAsset.dart';

class LoginInfoFindPage extends StatefulWidget {
  @override
  _LoginInfoFindPageState createState() => _LoginInfoFindPageState();
}

class _LoginInfoFindPageState extends State<LoginInfoFindPage> {
  String bottomArrow = 'assets/images/Public/bottomArrow.svg';

  List<String> phoneCompanyList = ["  선택", "  SKT", "  KT", "  LG", "  알뜰폰"];
  final idTextField = TextEditingController();
  final nameTextField = TextEditingController();
  final phoneNumberField = TextEditingController();
  double animatedHeight1 = 0.0;

  String merchantUid; // 주문번호
  String company = '아임포트'; // 회사명 또는 URL
  String carrier = '  선택'; // 통신사
  String id;
  String name; // 본인인증 할 이름
  String phone; // 본인인증 할 전화번호

  bool validateNameForPhone(String value) {
    String p = r'[$./!@#<>?":_`~;[\]\\|=+)(*&^%0-9-\s-]';
    //String str = '[ㄱ-ㅎ|가-힣|ㆍ|ᆢa-zA-Z0-9:]';

    RegExp regExp = new RegExp(p);
    bool b = regExp.hasMatch(value);
    return b;
  }

  bool validatePhoneNum(String value) {
    if (value.length != 11) return false;
    return true;
  }

  bool PhoneAuthComplete() {
    if (validatePhoneNum(phoneNumberField.text) == true &&
        validateNameForPhone(nameTextField.text) == false &&
        carrier != "  선택") {
      return true;
    } else {
      return false;
    }
  }

  bool isValidIDValue = false;

  Future<bool> isValidID(String userID) async {
    //if(false == kReleaseMode) return true;
    if (userID == null) return false;

    bool isValid = false;
    var res = await ApiProvider()
        .post('/Profile/Personal/IDCheck', jsonEncode({"id": userID}));

    if (res != null) {
      isValid = true;
    }

    return isValid;
  }

  bool findIDState = true;

  @override
  Widget build(BuildContext context) {
    double sizeUnit = SheepsTextStyle.sizeUnit(context).fontSize;
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context); //텍스트 포커스 해제
        if (!currentFocus.hasPrimaryFocus) {
          if (Platform.isIOS) {
            FocusManager.instance.primaryFocus.unfocus();
          } else {
            currentFocus.unfocus();
          }
        }
      },
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
        //사용자 스케일팩터 무시
        child: Scaffold(
          appBar: new AppBar(
            backgroundColor: hexToColor("#FFFFFF"),
            elevation: 0.0,
            centerTitle: true,
            leading: Padding(
              padding: EdgeInsets.only(left: 12 * sizeUnit),
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: SvgPicture.asset(
                    svgBackArrow,
                    width: 28 * sizeUnit,
                    height: 28 * sizeUnit,
                  ),
                ),
              ),
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                  left: 20 * sizeUnit,
                  top: 14 * sizeUnit,
                  right: 20 * sizeUnit),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (findIDState == false) {
                            idTextField.clear();
                            nameTextField.clear();
                            phoneNumberField.clear();
                          }

                          findIDState = true;
                          setState(() {});
                        },
                        child: Container(
                          decoration: findIDState
                              ? BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                    color: hexToColor('#61C680'),
                                    width: 2.0,
                                  )))
                              : null,
                          child: Text("아이디 찾기",
                              style: SheepsTextStyle.h3(context)),
                        ),
                      ),
                      SizedBox(width: 12 * sizeUnit),
                      GestureDetector(
                        onTap: () {
                          if (findIDState == true) {
                            idTextField.clear();
                            nameTextField.clear();
                            phoneNumberField.clear();
                          }

                          findIDState = false;
                          setState(() {});
                        },
                        child: Container(
                          decoration: !findIDState
                              ? BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                    color: hexToColor('#61C680'),
                                    width: 2.0,
                                  )))
                              : null,
                          child: Text("비밀번호 찾기",
                              style: SheepsTextStyle.h3(context)),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 40 * sizeUnit),
                  Container(
                    height: 40 * sizeUnit,
                    child: Text(findIDState ? '아이디 찾기' : "비밀번호 찾기",
                        style: SheepsTextStyle.h1(context)),
                  ),
                  findIDState
                      ? Container()
                      : SizedBox(height: 20 * sizeUnit),
                  findIDState
                      ? Container()
                      : Text(
                    '아이디',
                    style: SheepsTextStyle.h3(context),
                  ),
                  findIDState
                      ? Container()
                      : SizedBox(height: 8 * sizeUnit),
                  findIDState
                      ? Container()
                      : Container(
                    height: 48 * sizeUnit,
                    width: 320 * sizeUnit,
                    child: TextField(
                      controller: idTextField,
                      obscureText: false,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(8*sizeUnit),
                            borderSide: BorderSide(
                              color: Color(0xffCCCCCC),
                            )),
                        filled: true,
                        hintText: "아이디 입력",
                        suffixIcon: idTextField.text.length > 0
                            ? IconButton(
                            onPressed: () async {
                              idTextField.clear();
                              isValidIDValue = await isValidID(idTextField.text);
                            },
                            icon: Icon(
                              Icons.cancel,
                              color: Color(0xFFCCCCCC),
                              size: 12 * sizeUnit,
                            ))
                            : null,
                        fillColor: Colors.white,
                        contentPadding:
                        EdgeInsets.only(left: 12 * sizeUnit),
                        hintStyle: SheepsTextStyle.hint(context),
                        focusedBorder: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(8*sizeUnit),
                            borderSide: BorderSide(
                              color: Color(0xff888888),
                            )),
                        enabledBorder: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(8*sizeUnit),
                            borderSide: BorderSide(
                              color: idTextField.text == ""
                                  ? Color(0xffCCCCCC)
                                  : isValidIDValue == false
                                  ? Color(0xffF9423A)
                                  : hexToColor('#61C680'),
                            )),
                      ),
                      onSubmitted: (value) async {
                        isValidIDValue = await isValidID(idTextField.text);
                        setState((){
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    height: 20 * sizeUnit,
                  ),
                  Text(
                    '이름',
                    style: SheepsTextStyle.h3(context),
                  ),
                  SizedBox(
                    height: 8 * sizeUnit,
                  ),
                  Container(
                    height: 48 * sizeUnit,
                    child: TextField(
                      controller: nameTextField,
                      obscureText: false,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(8*sizeUnit),
                            borderSide: BorderSide(
                              color: Color(0xffCCCCCC),
                            )),
                        filled: true,
                        hintText: "이름 입력",
                        suffixIcon: nameTextField.text.length > 0
                            ? IconButton(
                            onPressed: () {
                              nameTextField.clear();
                            },
                            icon: Icon(
                              Icons.cancel,
                              color: Color(0xFFCCCCCC),
                              size: 12 * sizeUnit,
                            ))
                            : null,
                        fillColor: Colors.white,
                        contentPadding:
                        EdgeInsets.only(left: 12 * sizeUnit),
                        hintStyle: SheepsTextStyle.hint(context),
                        focusedBorder: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(8*sizeUnit),
                            borderSide: BorderSide(
                              color: Color(0xff888888),
                            )),
                        enabledBorder: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(8*sizeUnit),
                            borderSide: BorderSide(
                              color: nameTextField.text == ""
                                  ? Color(0xffCCCCCC)
                                  : validateNameForPhone(
                                  nameTextField.text) ==
                                  true
                                  ? Color(0xffF9423A)
                                  : hexToColor('#61C680'),
                            )),
                      ),
                      onChanged: (value) {
                        setState(() {
                          name = value;
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    height: 20 * sizeUnit,
                  ),
                  Text(
                    '핸드폰 번호',
                    style: SheepsTextStyle.h3(context),
                  ),
                  SizedBox(
                    height: 8 * sizeUnit,
                  ),
                  Row(
                    children: [
                      Container(
                        width: 80 * sizeUnit,
                        decoration: BoxDecoration(
                          borderRadius:
                          new BorderRadius.circular(8*sizeUnit),
                          border: Border.all(
                            width: 1,
                            color: carrier != "  선택"
                                ? hexToColor('#61C680')
                                : hexToColor("#cccccc"),
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                              value: carrier,
                              items: phoneCompanyList.map((e) {
                                return DropdownMenuItem(
                                  value: e,
                                  child: Text(e, style: SheepsTextStyle.b1(context)),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  carrier = value;
                                });
                              }),
                        ),
                      ),
                      SizedBox(width: 8 * sizeUnit),
                      Container(
                        width: 232*sizeUnit,
                        child: TextField(
                          keyboardType: TextInputType.numberWithOptions(
                              signed: true, decimal: true),
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          controller: phoneNumberField,
                          obscureText: false,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(8*sizeUnit),
                                borderSide: BorderSide(
                                  color: Color(0xffCCCCCC),
                                )),
                            filled: true,
                            hintText: "핸드폰 번호 입력",
                            suffixIcon: phoneNumberField.text.length > 0
                                ? IconButton(
                              onPressed: () {
                                phoneNumberField.clear();
                              },
                              icon: Icon(
                                Icons.cancel,
                                color: Color(0xFFCCCCCC),
                                size: 12 * sizeUnit,
                              ),
                            )
                                : null,
                            fillColor: Colors.white,
                            contentPadding:
                            EdgeInsets.only(left: 12 * sizeUnit),
                            hintStyle: SheepsTextStyle.hint(context),
                            focusedBorder: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(8*sizeUnit),
                                borderSide: BorderSide(
                                  color: Color(0xff888888),
                                )),
                            enabledBorder: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(8*sizeUnit),
                                borderSide: BorderSide(
                                  color: phoneNumberField.text == ""
                                      ? Color(0xffCCCCCC)
                                      : validatePhoneNum(
                                      phoneNumberField.text) ==
                                      false
                                      ? Color(0xffF9423A)
                                      : hexToColor('#61C680'),
                                )),
                          ),
                          onChanged: (value) {
                            setState(() {
                              phone = value;
                            });
                          },
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: GestureDetector(
            onTap: () {
              if (false == PhoneAuthComplete()) return;

              //비밀번호 찾기, 유효상태
              if (!findIDState && false == isValidIDValue) return;

              //핸드폰인증필요
              if (findIDState) {
                String fixCarrier = carrier;

                if (carrier == '  KT')
                  fixCarrier = 'KTF';
                else if (carrier == '  LGT') fixCarrier = 'LG';
                else if (carrier == '  알뜰폰') fixCarrier = 'MVNO';

                CertificationData data = CertificationData.fromJson({
                  'merchantUid': 'mid_${DateTime.now().millisecondsSinceEpoch}',
                  'company': '아임포트', // 회사명 또는 URL
                  'carrier': fixCarrier, // 통신사
                  'name': name,
                  'phone': phoneNumberField.text,
                });

                globalPhoneNumber = phoneNumberField.text;

                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => iamportCertificationNamePage(
                          resultPage: '/certification-result', data: data),
                    ));
              } else {
                String fixCarrier = carrier;

                if (carrier == '  KT')
                  fixCarrier = 'KTF';
                else if (carrier == '  LGT') fixCarrier = 'LG';
                else if (carrier == '  알뜰폰') fixCarrier = 'MVNO';

                CertificationData data = CertificationData.fromJson({
                  'merchantUid': 'mid_${DateTime.now().millisecondsSinceEpoch}',
                  'company': '아임포트', // 회사명 또는 URL
                  'carrier': fixCarrier, // 통신사
                  'name': name,
                  'phone': phoneNumberField.text,
//              'carrier': carrier,
                });

                globalLoginID = idTextField.text;

                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => iamportCertificationNamePage(
                          resultPage: '/certification-result-PW', data: data),
                    ));
              }
            },
            child: Container(
              height: 60*sizeUnit,
              decoration: BoxDecoration(
                color: findIDState
                    ? (PhoneAuthComplete() == true
                    ? hexToColor("#61C680")
                    : hexToColor("#CCCCCC"))
                    : PhoneAuthComplete() == true && isValidIDValue
                    ? hexToColor("#61C680")
                    : hexToColor("#CCCCCC"),
              ),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  '다음',
                  style: SheepsTextStyle.button1(context),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
