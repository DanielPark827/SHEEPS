import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/dashboard/MyHomePage.dart';
import 'package:sheeps_app/network/ApiProvider.dart';
import 'package:sheeps_app/registration/AuthSuccessPage.dart';
import 'package:sheeps_app/config/GlobalAsset.dart';

// ignore: must_be_immutable
class NameUpdatePage extends StatefulWidget {
  String email;

  NameUpdatePage({Key key, @required this.email}) : super(key : key);

  @override
  _NameUpdatePageState createState() => _NameUpdatePageState();
}

class _NameUpdatePageState extends State<NameUpdatePage> {

  final nameTextField = TextEditingController();

  String errMsg = '';
  bool isValid = false;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    nameTextField.dispose();
    super.dispose();
  }

  Future<bool> isValidName(String userName) async {
    if(userName.isEmpty){
      errMsg = "";
      return false;
    }

    int utf8Length = utf8.encode(userName).length;

    RegExp regExp = new RegExp(r'[$./!@#<>?":_`~;[\]\\|=+)(*&^%\s-]');

    bool isCheck = true;
    if(regExp.hasMatch(userName)){
      isCheck = false;
      errMsg = "특수문자가 들어갈 수 없어요.";
    }else if(userName.length < 2){
      isCheck = false;
      errMsg = "너무 짧아요. 2자 이상 작성해주세요.";
    }else if(userName.length > 15 || utf8Length > 30){
      isCheck = false;
      errMsg = "너무 길어요. 한글 10자 또는 영어 15자 이하로 작성해 주세요.";
    }

    return isCheck;
  }


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
      child: Container(
        width: 360*sizeUnit,
        height: MediaQuery.of(context).size.height,
        color: Colors.white,
        child: Stack(
          children: [
            Positioned(
              top: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  appBar("회원가입"),
                  SizedBox(
                    height: 60*sizeUnit,
                  ),
                  Container(
                    height: 36*sizeUnit,
                    padding: EdgeInsets.only(left: 20*sizeUnit),
                    child: Text(
                      '이름이 뭐예요?',
                      style: SheepsTextStyle.h1(context),
                    ),
                  ),
                  SizedBox(
                    height: 20*sizeUnit,
                  ),
                  Container(
                    height: 44*sizeUnit,
                    padding: EdgeInsets.only(left: 20*sizeUnit),
                    child: Text(
                        '쉽스에서 활동할 이름을 알려주세요.\n꼭 실명이 아니어도 괜찮아요!',
                        style: SheepsTextStyle.b2(context)
                    ),
                  ),
                  SizedBox(
                    height: 48*sizeUnit,
                  ),
                  Container(
                    width: 360*sizeUnit,
                    height: 72*sizeUnit,
                    padding: EdgeInsets.only(left: 20*sizeUnit, right: 20*sizeUnit),
                    child: TextField(
                      controller: nameTextField,
                      obscureText: false,
                      onChanged: (val) {
                        setState(() async{
                          isValid = await isValidName(val);
                        });
                      },
                      decoration: InputDecoration(
                          filled: true,
                          hintText: "이름 입력",
                          suffixIcon: nameTextField.text.length > 0 ? IconButton(
                              onPressed: () {
                                nameTextField.clear();
                                isValid = false;
                              },
                              icon: Icon(Icons.cancel, color: Color(0xFFCCCCCC), size: screenWidth * 0.0333333333333333,)
                          ) : null,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.only(left: 20*sizeUnit),
                          hintStyle: SheepsTextStyle.hint(context),
                          errorText: nameTextField.text.isEmpty ? null : !isValid ? errMsg : null,
                          errorStyle: SheepsTextStyle.error(context),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8*sizeUnit),
                              borderSide: BorderSide(
                                color: nameTextField.text.isEmpty ?  hexToColor('#CCCCCC')
                                    : isValid
                                    ? hexToColor('#61C680')
                                    : hexToColor('#F9423A'),
                              )),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8*sizeUnit),
                              borderSide: BorderSide(
                                color: hexToColor('#CCCCCC'),
                              )),
                          focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8*sizeUnit),
                              borderSide: BorderSide(
                                color: hexToColor('#F9423A'),
                              ))
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              child: Column(
                children: [
                  SizedBox(
                    height: 20*sizeUnit,
                  ),
                  Container(
                    width: 360*sizeUnit,
                    height: 60*sizeUnit,
                    child: FlatButton(
                        color: isValid
                            ? hexToColor('#61C680')
                            : hexToColor('#CCCCCC'),
                        textColor: Colors.white,
                        onPressed: () async {
                          
                          var res = await ApiProvider().post('/Profile/NameUpdate', jsonEncode(
                            {
                              "id" : widget.email,
                              "name" : nameTextField.text
                            })
                          );

                          if(res == true){
                            Navigator.pushReplacement(context, MaterialPageRoute(
                              builder: (context) => AuthSuccessPage(),
                            ));
                          }else{
                            Fluttertoast.showToast(msg: "소셜로 가입된 아이디입니다.\n비밀번호 변경이 불가능합니다.", toastLength: Toast.LENGTH_LONG, timeInSecForIosWeb: 1);
                          }
                        },
                        child: Text(
                          "다음",
                          style: SheepsTextStyle.button1(context),
                        )
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }



  Widget appBar(String text) {
    return Column(
      children: [
        SizedBox(
          height: 24*sizeUnit,
        ),
        Container(
          width: 360*sizeUnit,
          height: 60*sizeUnit,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: 90*sizeUnit,
                child: Row(
                  children: [
                    SizedBox(
                      width: 12*sizeUnit,
                    ),
                    GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: SvgPicture.asset(
                          svgBackArrow,
                          width: 28*sizeUnit,
                          height: 28*sizeUnit,
                        )),
                  ],
                ),
              ),
              Spacer(flex: 1,),
              Text(
                text,
                style: SheepsTextStyle.appBar(context),
              ),
              Spacer(flex: 1,),
              Container(width:90*sizeUnit),
            ],
          ),
        ),
      ],
    );
  }
}
