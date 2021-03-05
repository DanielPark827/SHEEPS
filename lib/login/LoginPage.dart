import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/login/LoginInfoFindPage.dart';
import 'package:sheeps_app/registration/PhoneNumberAuthPage.dart';
import 'package:sheeps_app/registration/model/RegistrationModel.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/constants.dart';
import 'package:sheeps_app/network/ApiProvider.dart';
import 'package:sheeps_app/network/SocketProvider.dart';

import 'bloc/LoginBloc.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();

  final int OrderInrecentConnection = 0;
  final int OrderInHavingBadge = 1;
  final int OrderInSignUp = 2;

  bool _isReady = true; //서버중복신호방지
  double sizeUnit;

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  LoginBloc loginBloc;

  @override
  void initState() {
    // TODO: implement initState
    loginBloc = BlocProvider.of<LoginBloc>(context);
    _isReady = true; //서버중복신호방지

    if (!kReleaseMode) {
      _idController.text = "";
      _passwordController.text = "";
    }

//    initBadgeList();

    super.initState();
  }

  String loginID;
  String loginPassword;
  String errMsg4ID;
  String errMsg4Password;

  bool validID(String id) {
    if(!kReleaseMode) return true;

    loginID = id;
    RegExp regExp = new RegExp(
        r'^[0-9a-zA-Z][0-9a-zA-Z\_\-\.\+]+[0-9a-zA-Z]@[0-9a-zA-Z][0-9a-zA-Z\_\-]*[0-9a-zA-Z](\.[a-zA-Z]{2,6}){1,2}$');
    if (regExp.hasMatch(loginID)) {
      errMsg4ID = null;
      return true;
    } else {
      errMsg4ID = "이메일을 정확히 입력해주세요.";
      return false;
    }
  }

  bool validPassword(String password){
    if(!kReleaseMode) return true;

    loginPassword = password;
    if (password.length<1 || password == null){
      errMsg4Password = "비밀번호를 입력해주세요.";
      return false;
    } else {
      errMsg4Password = null;
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    SocketProvider provider = Provider.of<SocketProvider>(context);
    sizeUnit = SheepsTextStyle.sizeUnit(context).fontSize;

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
          appBar: SheepsAppBar(context, ''),
          body: Container(
            width: screenWidth,
            height: screenHeight,
            color: Colors.white,
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(20 * sizeUnit),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 100 * sizeUnit,
                    ),
                    Container(
                      height: 76 * sizeUnit,
                      child: Text(
                        '우리가 그리워서\n돌아오셨군요!',
                        style: SheepsTextStyle.h1(context),
                      ),
                    ),
                    Row(
                      children: [
                        SizedBox(
                          height: 60 * sizeUnit,
                        ),
                      ],
                    ),
                    Container(
                      width: 320 * sizeUnit,
                      height: 60 * sizeUnit,
                      child: TextField(
                        controller: _idController,
                        obscureText: false,
                        onChanged: (val) {
                          validID(val);
                          setState(() {

                          });
                        },
                        decoration: InputDecoration(
                          filled: true,
                          hintText: "이메일 입력",
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.fromLTRB(
                              12 * sizeUnit, 12 * sizeUnit, 0, 14 * sizeUnit),
                          hintStyle: SheepsTextStyle.hint(context),
                          errorText: errMsg4ID,
                          errorStyle: SheepsTextStyle.error(context)
                              .copyWith(fontSize: 0),
                          errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8 * sizeUnit),
                              borderSide: BorderSide(
                                color: hexToColor('#F9423A'),
                              )),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8 * sizeUnit),
                              borderSide: BorderSide(
                                color: loginID == null
                                    ? Color(0xFFCCCCCC)
                                    : Color(0xFF61C680),
                              )),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8 * sizeUnit),
                              borderSide: BorderSide(
                                color: hexToColor('#CCCCCC'),
                              )),
                          focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8 * sizeUnit),
                              borderSide: BorderSide(
                                color: hexToColor('#F9423A'),
                              )),
                        ),
                      ),
                    ),
                    Container(
                      width: 320 * sizeUnit,
                      height: 48 * sizeUnit,
                      child: TextField(
                        controller: _passwordController,
                        obscureText: true,
                        onChanged: (val){
                          validPassword(val);
                          setState(() {

                          });
                        },
                        decoration: InputDecoration(
                            filled: true,
                            hintText: "비밀번호 입력",
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.fromLTRB(
                                12 * sizeUnit, 12 * sizeUnit, 0, 14 * sizeUnit),
                            hintStyle: SheepsTextStyle.hint(context),
                            enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(8 * sizeUnit),
                                borderSide: BorderSide(
                                  color: loginPassword == null || loginPassword == ""
                                      ? Color(0xFFCCCCCC)
                                      : Color(0xFF61C680),
                                )),
                            focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(8 * sizeUnit),
                                borderSide: BorderSide(
                                  color: hexToColor('#CCCCCC'),
                                )),
                            focusedErrorBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(8 * sizeUnit),
                                borderSide: BorderSide(
                                  color: hexToColor('#F9423A'),
                                ))),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 12*sizeUnit, top: 12*sizeUnit),
                      child: Container(
                        height: 20*sizeUnit,
                        child: Text(
                            errMsg4ID != null
                            ? errMsg4ID
                            : errMsg4Password != null
                              ? errMsg4Password
                              : "",
                            style: SheepsTextStyle.error(context)
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 28 * sizeUnit,
                    ),
                    Container(
                        width: 320 * sizeUnit,
                        height: 48 * sizeUnit,
                        child: new FlatButton(
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(8 * sizeUnit)),
                          color: kPrimaryColor,
                          onPressed: () {
                            if (_isReady && validID(loginID) && validPassword(loginPassword)) {
                              _isReady = false; //서버중복신호방지
                              (() async {

                                String loginURL = !kReleaseMode ? '/Profile/Personal/DebugLogin' : '/Profile/Personal/Login';

                                var result = await ApiProvider().post(loginURL,jsonEncode({
                                  "id": _idController.text,
                                  "password":_passwordController.text,
                                }));

                                if (null != result) {
                                  if (result['result'] == null) {
                                    if (result['res'] == 2) {
                                      Function okFunc = () {
                                        globalLoginID = _idController.text;

                                        Navigator.pop(context);

                                        Navigator.push(
                                            context,
                                            // 기본 파라미터, SecondRoute로 전달
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    PhoneNumberAuthPage()));
                                      };

                                      Function cancelFunc = () {
                                        Navigator.pop(context);
                                      };

                                      _isReady = true; //서버중복신호방지
                                      showSheepsDialog(
                                        context: context,
                                        title: '핸드폰 인증 필요',
                                        isLogo: false,
                                        description: "해당 아이디는 핸드폰 인증이 필요합니다.\n인증 페이지로 가시겠어요?",
                                        okText: '갈게요',
                                        okFunc: okFunc,
                                        cancelText: '좀 더 생각해볼게요',
                                        cancelFunc: cancelFunc,
                                      );
                                      return;
                                    } else {
                                      Function okFunc = () {
                                        ApiProvider().post('/Personal/Logout',jsonEncode(
                                            {
                                              "userID": result['userID'],
                                              "isSelf" : 0
                                            }
                                        ),isChat: true);

                                        Navigator.pop(context);
                                      };

                                      showSheepsDialog(
                                        context: context,
                                        title: "로그아웃",
                                        isLogo: false,
                                        description: "해당 아이디는 이미 로그인 중입니다.\n로그아웃을 요청하시겠어요?",
                                        okText: "로그아웃 할게요",
                                        okFunc: okFunc,
                                        cancelText: "좀 더 생각해볼게요",
                                      );
                                      _isReady = true; //서버중복신호방지
                                      return;
                                    }
                                  }

                                  final SharedPreferences prefs = await SharedPreferences.getInstance();
                                  prefs.setBool('autoLoginKey', true);
                                  prefs.setString('autoLoginId',_idController.text);
                                  prefs.setString('autoLoginPw',_passwordController.text);
                                  prefs.setString('socialLogin', 0.toString());

                                  globalLogin(context, provider, result);
                                } else {

                                  showSheepsDialog(
                                    context: context,
                                    title: "로그인 실패",
                                    description: "가입하지 않은 아이디이거나\n잘못된 비밀번호입니다",
                                    isCancelButton: false,
                                  );
                                  _isReady = true; //서버중복신호방지
                                }
                              })();
                            } else {
                              setState(() {
                                debugPrint("login fail");
                              });
                              _isReady = true;
                            }
                          },
                          child: Text(
                            "로그인",
                            style: SheepsTextStyle.button1(context),
                          ),
                        )),
                    SizedBox(
                      height: 20 * sizeUnit,
                    ),
                    Container(
                      width: screenWidth,
                      height: 16 * sizeUnit,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Align(
                            child: Text(
                              "아이디 또는 비밀번호가",
                              style: SheepsTextStyle.info1(context),
                            ),
                          ),
                          Align(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context, // 기본 파라미터, SecondRoute로 전달
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            LoginInfoFindPage()));
                              },
                              child: Text(
                                " 기억이 나지 않다면?",
                                style: SheepsTextStyle.infoStrong(context),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  TextField buildTextField(TextEditingController controller, String hintText,
      bool isObscure, ValueChanged<String> onChangedCallback) {
    return TextField(
      controller: controller,
      obscureText: isObscure,
      onChanged: onChangedCallback,
      decoration: InputDecoration(
        filled: true,
        hintText: hintText,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.only(left: 12 * sizeUnit),
        hintStyle: SheepsTextStyle.hint(context),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8 * sizeUnit),
          borderSide: BorderSide(color: hexToColor('#CCCCCC')),
        ),
      ),
    );
  }
}
