import 'dart:convert';
import 'dart:io';

import 'package:cupertino_will_pop_scope/cupertino_will_pop_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/login/LoginCheckPage.dart';
import 'package:sheeps_app/login/PasswordCheckPage.dart';
import 'package:sheeps_app/network/ApiProvider.dart';
import 'package:sheeps_app/registration/model/RegistrationModel.dart';
import 'package:sheeps_app/userdata/User.dart';


class PasswordChangePage extends StatefulWidget {
  @override
  _PasswordChangePageState createState() => _PasswordChangePageState();
}

class _PasswordChangePageState extends State<PasswordChangePage> {
  String failedIcon = 'assets/images/Public/FailedIcon.svg';

  final passwordTextField = TextEditingController();
  final passwordCheckTextField = TextEditingController();

  String passWord;
  String passWordCheck;
  String errMsg;
  String errMsg4Check;

  double sizeUnit;

  UserData selectUser;

  bool validPassword() {
    RegExp exp = new RegExp(r"^[A-Za-z\d$@$!%*#?&]{1,}$");
    if(passWord == null){
      errMsg = "";
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
  void initState() {
    // TODO: implement initState
    Future.microtask( () async {
      var res = await ApiProvider().post('/Profile/Personal/FindIDForPassword', jsonEncode(
          {
            "id" : globalLoginID,
          }
      ));

      if(res == null){
        selectUser = null;
      }else{
        selectUser = UserData.fromJson(res);
      }
    }).then((value) {
      setState(() {

      });
    });

    super.initState();
  }

  Widget getSuccessPage(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 120*sizeUnit),
        Text(
          "비밀번호 변경하기",
          style: SheepsTextStyle.h1(context),
        ),
        SizedBox(height: 20*sizeUnit),
        Text(
            "기존 비밀번호에서 변경할 비밀번호를\n입력해주세요.",
            style: SheepsTextStyle.b2(context)
        ),
        SizedBox(height: 40*sizeUnit),
        Container(
          width: 320*sizeUnit,
          height: 72*sizeUnit,
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
              hintText: "변경할 비밀번호",
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
              errorStyle: SheepsTextStyle.error(context),
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
        SizedBox(height: 12*sizeUnit),
        Container(
          width: 320*sizeUnit,
          height: 72*sizeUnit,
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
              hintText: "비밀번호 확인",
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
              errorStyle: SheepsTextStyle.error(context),
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
      ],
    );
  }

  Widget getFailedPage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(failedIcon, width: 100*sizeUnit, height: 100*sizeUnit),
        Row(
          children: [
            SizedBox(height: 64*sizeUnit),
          ],
        ),
        Text(
          "가입되지 않은 번호입니다.",
          textAlign: TextAlign.center,
          style: SheepsTextStyle.h1(context),
        ),
        SizedBox(height: 20*sizeUnit),
        Text(
         "지금 가입하고, 스타트업을 시작해보세요.",
          textAlign: TextAlign.center,
          style: SheepsTextStyle.b3(context),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    sizeUnit = SheepsTextStyle.sizeUnit(context).fontSize;
    return ConditionalWillPopScope(
      shouldAddCallbacks: true,
      onWillPop: null,
      child: GestureDetector(
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
            resizeToAvoidBottomInset : false,
            body: Padding(
              padding: EdgeInsets.only(left: 20*sizeUnit, right: 20*sizeUnit),
              child:
                selectUser != null ? getSuccessPage() : getFailedPage()
            ),
            bottomNavigationBar: GestureDetector(
              onTap: (){
                if(selectUser == null) {
                  Navigator.pop(context);
                }else{
                  if(validPassword() && validPasswordCheck()){
                    //핸드폰 인증 플로우 추가 필요
                    Navigator.push(
                        context, // 기본 파라미터, SecondRoute로 전달
                        MaterialPageRoute(
                            builder: (context) =>
                                PasswordCheckPage(password: passWord)
                        )
                    ); //
                  }
                }
              },
              child: Container(
                  height: 60*sizeUnit,
                  decoration: BoxDecoration(
                    color: selectUser == null ? hexToColor("#61C680") : validPassword() && validPasswordCheck() ? hexToColor("#61C680") : hexToColor("#CCCCCC"),
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      '다음',
                      style: SheepsTextStyle.button1(context),
                    ),
                  )
              ),
            ),
          ),
        ),
      ),
    );
  }
}
