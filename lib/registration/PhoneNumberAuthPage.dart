import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iamport_flutter/model/certification_data.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/dashboard/MyHomePage.dart';
import 'package:sheeps_app/registration/AuthSuccessPage.dart';
import 'package:sheeps_app/registration/iamportCertificationPage.dart';
import 'package:sheeps_app/registration/model/RegistrationModel.dart';
import 'package:sheeps_app/config/GlobalAsset.dart';

class PhoneNumberAuthPage extends StatefulWidget {


  @override
  _PhoneNumberAuthPageState createState() => _PhoneNumberAuthPageState();
}

class _PhoneNumberAuthPageState extends State<PhoneNumberAuthPage> {
  String ClearButtonIcon = 'assets/images/clearButtonIcon.svg';
  String bottomArrow = 'assets/images/Public/bottomArrow.svg';

  List<String> phoneCompanyList = ["  선택", "  SKT", "  KT", "  LG","  알뜰폰"];
  double animatedHeight1 = 0.0;

  final phoneNumberField = TextEditingController();
  final nameTextField = TextEditingController();

  String merchantUid;        // 주문번호
  String company = '아임포트'; // 회사명 또는 URL
  String carrier = '  선택';    // 통신사
  String name;               // 본인인증 할 이름
  String phone;              // 본인인

  bool PhoneAuthComplete() {
    if ( validatePhoneNum(phoneNumberField.text) == true &&
        validateNameForPhone(nameTextField.text) == false &&
        carrier != "  선택") {

      return true;
    } else {
      return false;
    }
  }

  bool validateNameForPhone(String value) {
    String p = r'[$./!@#<>?":_`~;[\]\\|=+)(*&^%0-9-\s-]';
    //String str = '[ㄱ-ㅎ|가-힣|ㆍ|ᆢa-zA-Z0-9:]';

    RegExp regExp = new RegExp(p);
    bool b= regExp.hasMatch(value);
    return b;
  }// 증 할 전화번호

  bool validatePhoneNum(String value) {
    if (value.length != 11)
      return false;
    return true;
  }

  double sizeUnit = 1;

  @override
  Widget build(BuildContext context) {
    sizeUnit = SheepsTextStyle.sizeUnit(context).fontSize;
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context); //텍스트 포커스 해제
        if (!currentFocus.hasPrimaryFocus) {
          if(Platform.isIOS){
            FocusManager.instance.primaryFocus.unfocus();
          } else{
            currentFocus.unfocus();
          }
        }
      },
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),//사용자 스케일팩터 무시
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: new AppBar(
            backgroundColor: hexToColor("#FFFFFF"),
            elevation: 0.0,
            centerTitle: true,
            leading: Padding(
              padding: EdgeInsets.fromLTRB(12*sizeUnit, 0, 0, 0),
              child: GestureDetector(
                onTap: (){
                  Navigator.pop(context, 'HotReload');
                },
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: SvgPicture.asset(
                    svgBackArrow,
                    width: 28*sizeUnit,
                    height: 28*sizeUnit,
                  ),
                ),
              ),
            ),
            title: Text("회원가입",
              style: SheepsTextStyle.appBar(context),
            ),
          ),
          body: SafeArea(
            child: Container(
              width: 360*sizeUnit,
              height: MediaQuery.of(context).size.height,
              color: Colors.white,
              padding: EdgeInsets.fromLTRB(20*sizeUnit, 0, 20*sizeUnit, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 60*sizeUnit,
                  ),
                  Container(
                    height: 40*sizeUnit,
                    child: Text(
                      '휴대폰 본인인증',
                      style: SheepsTextStyle.h1(context),
                    ),
                  ),
                  SizedBox(
                    height: 20*sizeUnit,
                  ),
                  Container(
                    height: 44*sizeUnit,
                    child: Text(
                      '실명과 통신사 및 휴대폰 번호를 입력하고\n본인인증을 진행해주세요.',
                      style: SheepsTextStyle.b2(context),
                    ),
                  ),
                  SizedBox(height: 20*sizeUnit),
                  Container(
                    child: Text(
                      '이름',
                      style: SheepsTextStyle.h3(context),
                    ),
                  ),
                  SizedBox(height: 8*sizeUnit),
                  Container(
                    width: 320*sizeUnit,
                    height: 48*sizeUnit,
                    child: TextField(
                      controller: nameTextField,
                      obscureText: false,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8*sizeUnit),
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
                              size: 12*sizeUnit,
                            ))
                            : null,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.fromLTRB(12*sizeUnit,
                            0, 0,0),
                        hintStyle: SheepsTextStyle.hint(context),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4*sizeUnit),
                            borderSide: BorderSide(
                              color: nameTextField.text == ""
                                  ? Color(0xffCCCCCC)
                                  : validateNameForPhone(nameTextField.text) == true
                                  ? Color(0xffF9423A)
                                  : hexToColor('#61C680'),
                            )),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8*sizeUnit),
                            borderSide: BorderSide(
                              color: hexToColor('#CCCCCC'),
                            )),
                        focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4.0*sizeUnit),
                            borderSide: BorderSide(
                              color: hexToColor('#F9423A'),
                            )),
                      ),
                      onChanged: (value) {
                        setState(() {
                          name = value;
                        });
                      },
                    ),
                  ),
                  SizedBox(height: 20*sizeUnit),
                  Container(
                    child: Text(
                      '핸드폰 번호',
                      style: SheepsTextStyle.h3(context),
                    ),
                  ),
                  SizedBox(height: 8*sizeUnit),
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: new BorderRadius.circular(8*sizeUnit),
                          border: Border.all(
                            width: 1,
                            color: carrier!= "  선택"? hexToColor('#61C680'): hexToColor("#cccccc"),
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
                              }
                          ),
                        ),
                      ),
                      Container(
                        width: 8*sizeUnit,
                      ),
                      Expanded(
                        child: Container(
                          child: TextField(
                            keyboardType: TextInputType.numberWithOptions(signed: true, decimal: true),
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            controller: phoneNumberField,
                            obscureText: false,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8*sizeUnit),
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
                                    size: 12*sizeUnit,
                                  ))
                                  : null,
                              fillColor: Colors.white,
                              contentPadding: EdgeInsets.fromLTRB(12*sizeUnit,
                                  0, 0,0),
                              hintStyle: SheepsTextStyle.hint(context),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8*sizeUnit),
                                  borderSide: BorderSide(
                                    color: Color(0xff888888),
                                  )),
                              /*  errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(4*sizeUnit),
                                        borderSide: BorderSide(
                                          color: Color(0xffF9423A),
                                        )),*/
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8*sizeUnit),
                                  borderSide: BorderSide(
                                    color: phoneNumberField.text == ""
                                        ? Color(0xffCCCCCC)
                                        : validatePhoneNum(phoneNumberField.text) ==
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
                        ),
                      )
                    ],
                  ),
                  Spacer(),
                  SizedBox(height: 20*sizeUnit),
                ],
              ),
            ),
          ),
          bottomNavigationBar: GestureDetector(
              onTap: () async {
                if(false == PhoneAuthComplete()) return;

                String fixCarrier = carrier;

                if(carrier == '  KT') fixCarrier = 'KTF';
                else if(carrier == '  LGT') fixCarrier = 'LG';
                else if(carrier == '  알뜰폰') fixCarrier = 'MVNO';

                CertificationData data = CertificationData.fromJson({
                  'merchantUid': 'mid_${DateTime.now().millisecondsSinceEpoch}',  // 주문번호
                  'company': '아임포트',                                            // 회사명 또는 URL
                  'carrier': fixCarrier,                                               // 통신사
                  'name': name,                                                 // 이름
                  'phone': phone,
                });

                globalPhoneNumber = phone;

                Navigator.pushReplacement(context, MaterialPageRoute(
                  builder: (context) => iamportCertificationPage(resultPage: AuthSuccessPage(),data: data,),
                ));
              },
              child: Container(
                  width: 360*sizeUnit,
                  height: 60*sizeUnit,
                  color: PhoneAuthComplete() == true  ? hexToColor("#61C680") : hexToColor("#CCCCCC"),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      "다음",
                      style: SheepsTextStyle.button1(context),
                    ),
                  ))
          ),
        ),
      ),
    );
  }
}
