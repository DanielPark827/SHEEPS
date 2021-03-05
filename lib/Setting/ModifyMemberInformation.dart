import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:sheeps_app/Setting/model/DummyForModifyMemberInformation.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/network/ApiProvider.dart';
import 'package:sheeps_app/userdata/GlobalProfile.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';

class ModifyMemberInformation extends StatefulWidget {
  @override
  _ModifyMemberInformationState createState() => _ModifyMemberInformationState();
}

class _ModifyMemberInformationState extends State<ModifyMemberInformation> {

  final ControllerForID = TextEditingController();
  final ControllerForExistingPassword = TextEditingController();
  final bottomArrow = 'assets/images/Public/bottomArrow.svg';

  List<String> phoneCompany = ["선택"];
  double animatedHeight1 = 0.0;
  final nameTextField = TextEditingController();
  final phoneNumberField = TextEditingController();
  bool checkBoxValue1 = false;
  bool checkBoxValue2 = false;
  bool checkBoxValue3 = false;

  String merchantUid;        // 주문번호
  String company = '아임포트'; // 회사명 또는 URL
  String carrier = 'SKT';    // 통신사
  String name;               // 본인인증 할 이름
  String phone;              // 본인인증 할 전화번호
  String minAge;
  
  double sizeUnit = 1;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    ControllerForID.text = GlobalProfile.loggedInUser.id;
  }

  final passwordTextField = TextEditingController();
  final passwordCheckTextField = TextEditingController();

  String passWord;
  String passWordCheck;
  String errMsg;
  String errMsg4Check;

  bool validPassword() {
    RegExp exp = new RegExp(r"^[A-Za-z\d$@$!%*#?&]{1,}$");
    if(passWord == null){
      errMsg = null;
      return false;
    } else if(passWord == ""){
      errMsg = "비밀번호를 입력해주세요.";
      return false;
    } else if(!exp.hasMatch(passWord)){
      errMsg = "영문, 숫자, 특수문자를 사용해주세요.";
      return false;
    } else if(passWord.length < 8){
      errMsg = '비밀번호가 너무 짧습니다.';
      return false;
    } else {
      errMsg = null;
      return true;
    }
  }

  bool validPasswordCheck(){
    if(passWordCheck == '' || passWordCheck == null){
      errMsg4Check = "비밀번호를 확인해주세요";
      return false;
    } else if(passWord != passWordCheck){
      errMsg4Check = "비밀번호가 일치하지 않아요!";
      return false;
    }else{
      errMsg4Check = null;
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    sizeUnit = SheepsTextStyle.sizeUnit(context).fontSize;
    var data = Provider.of<ModifiedMemberInformation>(context);

    bool validateNameForPhone(String value) {
      String p = r'[$./!@#<>?":_`~;[\]\\|=+)(*&^%0-9-\s-]';

      RegExp regExp = new RegExp(p);
      return regExp.hasMatch(value);
    }

    bool validatePhoneNum(String value) {
      if (value.length != 11)
        return false;
      return true;
    }



    bool PhoneAuthComplete() {
      if(
      validatePhoneNum(phoneNumberField.text) == true &&
          validateNameForPhone(nameTextField.text) == false &&
          phoneCompany[0] != "선택"){
        return true;
      }else{
        return false;
      }
    }
    bool AgreementComplete() =>
        checkBoxValue1 == true &&
            checkBoxValue2 == true &&
            checkBoxValue3 == true;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),//사용자 스케일팩터 무시
        child: Container(
          color: Colors.white,
          child: SafeArea(
            child: GestureDetector(
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
              child: Scaffold(
                backgroundColor: Colors.white,
                appBar: SheepsAppBar(context, '회원 정보 변경'),
                body: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB( 20*sizeUnit, 0, 20*sizeUnit, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height:20*sizeUnit),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            '이메일',
                            style: SheepsTextStyle.h3(context),
                          ),
                        ),
                        SizedBox(height: 8*sizeUnit),
                        buildIDController(data),
                        SizedBox(height:20*sizeUnit),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            '기존 비밀번호',
                            style: SheepsTextStyle.h3(context)
                          ),
                        ),
                        SizedBox(height: 8*sizeUnit),
                        buildExistPasswordController(data),
                        SizedBox(height:20*sizeUnit),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                              '변경할 비밀번호',
                              style: SheepsTextStyle.h3(context)
                          ),
                        ),
                        SizedBox(height: 8*sizeUnit),
                        Container(
                          width: 320*sizeUnit,
                          height: 56*sizeUnit,
                          child: TextField(
                            controller: passwordTextField,
                            obscureText: true,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8*sizeUnit),
                                  borderSide: BorderSide(
                                    color: Color(0xffCCCCCC),
                                  )),
                              filled: true,
                              hintText: "변경할 비밀번호 입력",
                              suffixIcon: passwordTextField.text.length > 0
                                  ? IconButton(
                                  onPressed: () {
                                    passwordTextField.clear();
                                  },
                                  icon: Icon(
                                    Icons.cancel,
                                    color: Color(0xFFCCCCCC),
                                    size: 12*sizeUnit,
                                  ))
                                  : null,
                              fillColor: Colors.white,
                              contentPadding: EdgeInsets.only(left: 12*sizeUnit),
                              hintStyle: SheepsTextStyle.hint(context),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8*sizeUnit),
                                  borderSide: BorderSide(
                                    color: Color(0xff888888),
                                  )
                              ),
                              errorStyle: SheepsTextStyle.error(context).copyWith(fontSize: 0),
                              errorText: errMsg,
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8*sizeUnit),
                                borderSide: BorderSide(
                                  color: Color(0xffF9423A),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8*sizeUnit),
                                  borderSide: BorderSide(
                                    color: passwordTextField.text == ""
                                        ? Color(0xffCCCCCC)
                                    // : validateNameForPhone(idTextField.text) ==
                                    // false
                                    // ? Color(0xffF9423A)
                                        : hexToColor('#61C680'),
                                  )),
                            ),
                            onChanged: (value) {
                              setState(() {
                                passWord = value;
                                validPassword();
                              });
                            },
                          ),
                        ),
                        Container(
                          width: 336*sizeUnit,
                          height: 56*sizeUnit,
                          child: TextField(
                            controller: passwordCheckTextField,
                            obscureText: true,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8*sizeUnit),
                                  borderSide: BorderSide(
                                    color: Color(0xffCCCCCC),
                                  )),
                              filled: true,
                              hintText: "변경할 비밀번호 확인",
                              suffixIcon: passwordCheckTextField.text.length > 0
                                  ? IconButton(
                                  onPressed: () {
                                    passwordCheckTextField.clear();
                                  },
                                  icon: Icon(
                                    Icons.cancel,
                                    color: Color(0xFFCCCCCC),
                                    size: 12*sizeUnit,
                                  ))
                                  : null,
                              fillColor: Colors.white,
                              contentPadding: EdgeInsets.only(left:12*sizeUnit),
                              hintStyle:SheepsTextStyle.hint(context),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8*sizeUnit),
                                  borderSide: BorderSide(
                                    color: Color(0xff888888),
                                  )),
                              errorStyle: SheepsTextStyle.error(context).copyWith(fontSize: 0),
                              errorText: errMsg4Check,
                              errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8*sizeUnit),
                                  borderSide: BorderSide(
                                    color: Color(0xffF9423A),
                                  )
                              ),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8*sizeUnit),
                                  borderSide: BorderSide(
                                    color: passwordCheckTextField.text == ""
                                        ? Color(0xffCCCCCC)
                                    // : validateNameForPhone(idTextField.text) ==
                                    // false
                                    // ? Color(0xffF9423A)
                                        : hexToColor('#61C680'),
                                  )),
                            ),
                            onChanged: (value) {
                              setState(() {
                                passWordCheck = value;
                                validPasswordCheck();
                              });
                            },
                          ),
                        ),
                        Container(
                          height: 16*sizeUnit,
                          padding: EdgeInsets.only(left: 12*sizeUnit),
                          child: Text(
                            errMsg == null
                                ? errMsg4Check == null ? "" : errMsg4Check
                                : errMsg,
                            style: SheepsTextStyle.error(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                bottomNavigationBar: GestureDetector(
                  onTap: () async {
                      if(validPassword() && validPasswordCheck() && (ControllerForExistingPassword.text != null && ControllerForExistingPassword.text != "")){
                        var res = await ApiProvider().post('/Profile/Personal/ChangePassword', jsonEncode(
                          {
                            "userID" : GlobalProfile.loggedInUser.userID,
                            "password" : ControllerForExistingPassword.text,
                            "newpassword" : passwordTextField.text
                          }
                        ));

                        if(res['res'] == "HAVENT_PASSWORD"){
                          Fluttertoast.showToast(msg: "소셜로 가입된 아이디입니다.\n비밀번호 변경이 불가능합니다.", toastLength: Toast.LENGTH_LONG, timeInSecForIosWeb: 1);
                          ControllerForExistingPassword.text = '';
                          passwordTextField.text = '';
                          passwordCheckTextField.text = '';
                          passWord = null;
                          passWordCheck = null;
                        }else if(res['res'] == "NOT_RIGHT"){
                          Fluttertoast.showToast(msg: "기존 비밀번호가 일치하지 않습니다.\n확인 후 다시 시도 해주세요.", toastLength: Toast.LENGTH_LONG, timeInSecForIosWeb: 1);
                          ControllerForExistingPassword.text = '';
                        }else{
                          Fluttertoast.showToast(msg: "비밀번호 변경이 완료되었습니다.", toastLength: Toast.LENGTH_LONG, timeInSecForIosWeb: 1);
                          ControllerForExistingPassword.text = '';
                          passwordTextField.text = '';
                          passwordCheckTextField.text = '';
                          passWord = null;
                          passWordCheck = null;
                        }
                      }
                  },
                  child: Container(
                      height: 60*sizeUnit,
                      decoration: BoxDecoration(
                        color: (validPassword() && validPasswordCheck() && (ControllerForExistingPassword.text != null && ControllerForExistingPassword.text != "")) ? hexToColor("#61C680") : hexToColor("#CCCCCC"),
                      ),
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          '수정 완료',
                          style: SheepsTextStyle.button1(context),
                        ),
                      )
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }


  SizedBox buildExistPasswordController(ModifiedMemberInformation data) {
    return SizedBox(
      height: 48*sizeUnit,
      child: TextField(
        controller: ControllerForExistingPassword,
        obscureText: true,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          isDense: true,
          hintText: '기존 비밀번호 입력',
          hintStyle: SheepsTextStyle.hint(context),
          contentPadding: EdgeInsets.fromLTRB(12*sizeUnit, 12*sizeUnit, 0,12*sizeUnit),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8*sizeUnit)),
            borderSide: BorderSide(width: 1,color: hexToColor(("#61C680"))),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8*sizeUnit)),
            borderSide: BorderSide(width: 1,color: hexToColor(("#CCCCCC"))),
          ),
        ),
      ),
    );
  }

  SizedBox buildIDController(ModifiedMemberInformation data) {
    return SizedBox(
            height: 48*sizeUnit,
            child: TextField(
              controller: ControllerForID,
                readOnly: true,
                decoration: InputDecoration(
                  hintText: '아이디를 입력해주세요',
                  hintStyle: SheepsTextStyle.hint(context),
                  border: OutlineInputBorder(),
                  isDense: true,
                  contentPadding: EdgeInsets.fromLTRB(12*sizeUnit, 12*sizeUnit, 0,12*sizeUnit),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8*sizeUnit)),
                    borderSide: BorderSide(width: 1*sizeUnit,color: hexToColor(("#61C680"))),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8*sizeUnit)),
                    borderSide: BorderSide(width: 1*sizeUnit,color: hexToColor(("#CCCCCC"))),
                  ),
                ),
            ),
          );
  }
}
