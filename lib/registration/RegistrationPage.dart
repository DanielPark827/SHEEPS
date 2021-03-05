import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/dashboard/MyHomePage.dart';
import 'package:sheeps_app/network/ApiProvider.dart';
import 'package:sheeps_app/registration/RegistrationSuccessPage.dart';
import 'package:sheeps_app/registration/bloc/RegistrationBloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sheeps_app/registration/model/RegistrationModel.dart';
import 'package:sheeps_app/config/GlobalAsset.dart';

class RegistrationPage extends StatefulWidget {
  bool isMarketingAgree;

  RegistrationPage({Key key, @required this.isMarketingAgree}) : super(key : key);

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  String ClearButtonIcon = 'assets/images/clearButtonIcon.svg';
  String bottomArrow = 'assets/images/Public/bottomArrow.svg';

  List<String> phoneCompanyList = ["선택", "SKT", "KTF", "LGT","MVNO"];
  List<String> phoneCompany = ["선택"];

  final nameTextField = TextEditingController();
  final idTextField = TextEditingController();
  final passwordTextField = TextEditingController();
  final passwordConfirmTextField = TextEditingController();
  final phoneNumberField = TextEditingController();

  double animatedHeight1 = 0.0;

  RegistrationBloc registrationBloc;

  bool _isReady;//서버중복신호방지
  bool _isPasswordChange;//패스워드 입력 전 제출방지
  bool _isIDChecked;//아이디 변경 후 서버전송 전 다음화면 방지

  double sizeUnit = 1;

  @override
  void initState() {
    // TODO: implement initState
    _isReady = true;//서버중복신호방지
    _isIDChecked = false;
    registrationBloc = BlocProvider.of<RegistrationBloc>(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    sizeUnit = SheepsTextStyle.sizeUnit(context).fontSize;
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),//사용자 스케일팩터 무시
      child: Scaffold(
        body: BlocConsumer(
            bloc: registrationBloc,
            listener: (context, state) {
              //state.model.isValidNextForNextPage;
            },
            builder: (context, state) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    if (registrationBloc.state.model.pageState == "NAME")
                      registrationName(context)
                    else if (registrationBloc.state.model.pageState == "ID")
                      registrationID(context)
                    else if (registrationBloc.state.model.pageState == "PASSWORD")
                        registrationPassword(context)
                    // else if (registrationBloc.state.model.pageState == "PHONE")
                    //   registrationCertPhone(context)
                    // else
                    //   registrationSuccess()
                  ],
                ),
              );
            }),
      ),
    );
  }

  void setPrevPage(BuildContext context) {
    if (registrationBloc.state.model.pageState == "SUCESS")
      context.bloc<RegistrationBloc>().add(PageChanged("PHONE"));
    if (registrationBloc.state.model.pageState == "PHONE")
      context.bloc<RegistrationBloc>().add(PageChanged("PASSWORD"));
    else if (registrationBloc.state.model.pageState == "PASSWORD")
      context.bloc<RegistrationBloc>().add(PageChanged("ID"));
    else if (registrationBloc.state.model.pageState == "ID")
      context.bloc<RegistrationBloc>().add(PageChanged("NAME"));
    else{
      //context.bloc<RegistrationBloc>().initialState;
      Navigator.pop(context);
    }
  }

  Widget registrationName(BuildContext context) {
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
                  BlocBuilder(
                    bloc: registrationBloc,
                    builder: (context, state) {
                      return Container(
                        width: 360*sizeUnit,
                        padding: EdgeInsets.only(left: 20*sizeUnit, right: 20*sizeUnit),
                        child: TextField(
                          controller: nameTextField,
                          obscureText: false,
                          onChanged: (val) => registrationBloc.add(UserNameChanged(val)),
                          decoration: InputDecoration(
                              filled: true,
                              hintText: "이름 입력",
                              suffixIcon: nameTextField.text.length > 0 ? IconButton(
                                  onPressed: () {
                                    nameTextField.clear();
                                    registrationBloc.add(UserNameChanged(''));
                                  },
                                  icon: Icon(Icons.cancel, color: Color(0xFFCCCCCC), size: screenWidth * 0.0333333333333333,)
                              ) : null,
                              fillColor: Colors.white,
                              contentPadding: EdgeInsets.all(12*sizeUnit),
                              hintStyle: SheepsTextStyle.hint(context),
                              errorText: state != null && (state.model.userName == "")
                                  ? null
                                  : state != null && registrationBloc.state.model.isValidForRegistration
                                  ? null
                                  : state.model.errMsg,
                              errorStyle: SheepsTextStyle.error(context),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8*sizeUnit),
                                  borderSide: BorderSide(
                                    color: state != null && (state.model.userName == "")
                                        ? hexToColor('#CCCCCC')
                                        : state != null && state.model.isValidForRegistration
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
                      );
                    },
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
                  BlocBuilder(
                    bloc: registrationBloc,
                    condition: (oldState, newState) =>
                    oldState.model.isValidForRegistration !=
                        newState.model.isValidForRegistration,
                    builder: (context, state) {
                      return Container(
                          width: 360*sizeUnit,
                          height: 60*sizeUnit,
                          child: FlatButton(
                              color: state != null &&
                                  state.model.isValidForRegistration
                                  ? hexToColor('#61C680')
                                  : hexToColor('#CCCCCC'),
                              textColor: Colors.white,
                              onPressed: state != null &&
                                  state.model.isValidForRegistration
                                  ? () {
                                registrationBloc.add(PageChanged("ID"));
                                registrationBloc.add(UserIDChanged(''));
                              }
                                  : () {},
                              child: Text(
                                "다음",
                                style: SheepsTextStyle.button1(context),
                              )
                          ),
                      );
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget registrationID(BuildContext context) {


    return Container(
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
                  padding: EdgeInsets.fromLTRB(20*sizeUnit, 0, 20*sizeUnit, 0),
                  child: Text(
                    '로그인 이메일은요?',
                    style: SheepsTextStyle.h1(context),
                  ),
                ),
                SizedBox(
                  height: 20*sizeUnit,
                ),
                Container(
                  height: 44*sizeUnit,
                  padding: EdgeInsets.fromLTRB(20*sizeUnit, 0, 20*sizeUnit, 0),
                  child: Text(
                    '로그인 이메일을 알려주세요.\n이메일 형식은 꼭 지켜야해요!',
                    style: SheepsTextStyle.b2(context)
                  ),
                ),
                SizedBox(
                  height: 48*sizeUnit,
                ),
                BlocBuilder(
                  bloc: registrationBloc,
                  builder: (context, state) {
                    return Container(
                      width: 360*sizeUnit,
                      padding: EdgeInsets.fromLTRB(20*sizeUnit, 0, 20*sizeUnit, 0),
                      child: TextField(
                        onChanged: (val) {
                          _isIDChecked = false;//아이디 체크 전 제출 방지
                          setState((){});
                        },
                        controller: idTextField,
                        obscureText: false,
                        onSubmitted: (val){
                          registrationBloc.add(UserIDChanged(val));
                          _isIDChecked = true;
                        },
                        decoration: InputDecoration(
                          filled: true,
                          hintText: "이메일 입력",
                          suffixIcon: idTextField.text.length > 0 ? IconButton(
                              onPressed: () {
                                idTextField.clear();
                                registrationBloc.add(UserIDChanged(''));
                              },
                              icon: Icon(Icons.cancel, color: Color(0xFFCCCCCC), size: screenWidth * 0.0333333333333333,)
                          ) : null,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.all(12*sizeUnit),
                          hintStyle: SheepsTextStyle.hint(context),
                          errorText: state != null && (state.model.userID == "")
                              ? null
                              : state != null && state.model.isValidForRegistration
                              ? null
                              : state.model.errMsg,
                          errorStyle: SheepsTextStyle.error(context),
                          errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8*sizeUnit),
                              borderSide: BorderSide(
                                color: hexToColor('#F9423A'),
                              )
                          ),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8*sizeUnit),
                              borderSide: BorderSide(
                                color: state != null && (state.model.userID == "")
                                    ? hexToColor('#CCCCCC')
                                    : state != null &&
                                    state.model.isValidForRegistration
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
                              )),
                        ),
                      ),
                    );
                  },
                ),

              ],
            ),
          ),
          Positioned(
            bottom: 0,
            child: Column(children: [
              SizedBox(
                height: 20*sizeUnit,
              ),
              BlocBuilder(
                bloc: registrationBloc,
                condition: (oldState, newState) =>
                oldState.model.isValidForRegistration !=
                    newState.model.isValidForRegistration,
                builder: (context, state) {
                  return Container(
                      width: 360*sizeUnit,
                      height: 60*sizeUnit,
                      child: new FlatButton(
                          color: state != null && state.model.isValidForRegistration && _isIDChecked
                              ? hexToColor('#61C680')
                              : hexToColor('#CCCCCC'),
                          textColor: Colors.white,
                          onPressed:
                          state != null && state.model.isValidForRegistration && _isIDChecked
                              ? () {
                            context
                                .bloc<RegistrationBloc>()
                                .add(PageChanged("PASSWORD"));
                            _isPasswordChange = false;
                          }
                              : () {},
                          child: Text(
                            "다음",
                            style: SheepsTextStyle.button1(context),
                          ),
                      ),
                  );
                },
              ),
            ],),
          ),
        ],
      ),
    );
  }

  Widget registrationPassword(BuildContext context) {
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
        width: screenWidth,
        height: screenHeight,
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
                    padding: EdgeInsets.fromLTRB(20*sizeUnit, 0, 20*sizeUnit, 0),
                    child: Text(
                      '비밀번호를 설정해주세요.',
                      style: SheepsTextStyle.h1(context),
                    ),
                  ),
                  SizedBox(
                    height: 20*sizeUnit,
                  ),
                  Container(
                    height: 44*sizeUnit,
                    padding: EdgeInsets.fromLTRB(20*sizeUnit, 0, 20*sizeUnit, 0),
                    child: Text(
                      '아무도 해킹할 수 없도록,\n강력한 비밀번호를 입력해 주세요!',
                      style: SheepsTextStyle.b2(context)
                    ),
                  ),
                  SizedBox(height: 48*sizeUnit),
                  BlocBuilder(
                    bloc: registrationBloc,
                    builder: (context, state) {
                      return Container(
                        width: 360*sizeUnit,
                        padding: EdgeInsets.fromLTRB(20*sizeUnit, 0, 20*sizeUnit, 0),
                        child: TextField(
                          controller: passwordTextField,
                          obscureText: true,
                          onChanged: (val){
                            registrationBloc.add(PasswordChanged(val));
                            _isPasswordChange = true;
                          },
                          decoration: InputDecoration(
                            filled: true,
                            hintText: "비밀번호 입력",
                            suffixIcon: passwordTextField.text.length > 0 ? IconButton(
                                onPressed: () {
                                  passwordTextField.clear();
                                  registrationBloc.add(PasswordChanged(''));
                                },
                                icon: Icon(Icons.cancel, color: Color(0xFFCCCCCC), size: screenWidth * 0.0333333333333333,)
                            ) : null,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.all(12*sizeUnit),
                            hintStyle: SheepsTextStyle.hint(context),
                            errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8*sizeUnit),
                                borderSide: BorderSide(
                                  color: hexToColor('#F9423A'),
                                )),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8*sizeUnit),
                                borderSide: BorderSide(
                                  color: state != null && (state.model.userPassword == "")
                                    ? hexToColor('#CCCCCC')
                                    : state != null && state.model.isValidForRegistration
                                      ? hexToColor('#61C680')
                                      : hexToColor('#F9423A'),
                                ),
                            ),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8*sizeUnit),
                                borderSide: BorderSide(
                                  color: hexToColor('#CCCCCC'),
                                )),
                            focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8*sizeUnit),
                                borderSide: BorderSide(
                                  color: hexToColor('#F9423A'),
                                )),
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 12*sizeUnit),
                  BlocBuilder(
                    bloc: registrationBloc,
                    builder: (context, state) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 360*sizeUnit,
                            padding: EdgeInsets.fromLTRB(20*sizeUnit, 0, 20*sizeUnit, 0),
                            child: TextField(
                              controller: passwordConfirmTextField,
                              obscureText: true,
                              onChanged: (val){
                                registrationBloc.add(ConfirmPasswordChanged(val));
                                _isPasswordChange = true;
                              },
                              decoration: InputDecoration(
                                filled: true,
                                hintText: "비밀번호 확인 입력",
                                suffixIcon: passwordConfirmTextField.text.length > 0 ? IconButton(
                                    onPressed: () {
                                      passwordConfirmTextField.clear();
                                      registrationBloc.add(ConfirmPasswordChanged(''));
                                    },
                                    icon: Icon(Icons.cancel, color: Color(0xFFCCCCCC), size: 12*sizeUnit,)
                                ) : null,
                                fillColor: Colors.white,
                                contentPadding: EdgeInsets.all(12*sizeUnit),
                                hintStyle: SheepsTextStyle.hint(context),
                                errorStyle: SheepsTextStyle.error(context),
                                errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8*sizeUnit),
                                    borderSide: BorderSide(
                                      color: hexToColor('#F9423A'),
                                    )),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8*sizeUnit),
                                    borderSide: BorderSide(
                                      color: state != null &&
                                          (state.model.userConfirmPassword == "")
                                          ? hexToColor('#CCCCCC')
                                          : state != null &&
                                          state.model.isValidForRegistration
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
                                    )),
                              ),
                            ),
                          ),
                          Container(
                            width: 360*sizeUnit,
                            padding: EdgeInsets.fromLTRB(32*sizeUnit, 8*sizeUnit, 20*sizeUnit, 0),
                            child: Text(
                              state.model.errMsg,
                              style: SheepsTextStyle.error(context),
                            ),
                          ),
                        ],
                      );
                    },
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
                  BlocBuilder<RegistrationBloc, RegistrationState>(
                    condition: (oldState, newState) =>
                    oldState.model.isValidForRegistration !=
                        newState.model.isValidForRegistration,
                    builder: (context, state) {
                      return Container(
                          width: 360*sizeUnit,
                          height: 60*sizeUnit,
                          child: new FlatButton(
                              color: state != null && state.model.isValidForRegistration && _isPasswordChange
                                  ? hexToColor('#61C680')
                                  : hexToColor('#CCCCCC'),
                              textColor: Colors.white,
                              onPressed:
                              state != null && state.model.isValidForRegistration && _isPasswordChange
                                  ? () {

                                debugPrint(state.model.userID);
                                debugPrint(state.model.userPassword);
                                debugPrint(state.model.userName);
                                if(_isReady){
                                  _isReady = false;
                                  var res = ApiProvider().post("/Profile/Personal/Insert", jsonEncode(
                                      {
                                        "id" : state.model.userID,
                                        "password" : state.model.userPassword,
                                        "name" : state.model.userName,
                                        "marketingAgree" : widget.isMarketingAgree
                                      }
                                  ));

                                  if(null == res){
                                    debugPrint("회원가입 실패");
                                    _isReady = true;
                                  }else{

                                    globalLoginID = state.model.userID;

                                    Navigator.pushReplacement(
                                        context, // 기본 파라미터, SecondRoute로 전달
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                RegistrationSuccessPage())
                                    );
                                  }
                                }
                              }
                                  : () {},
                              child: Text(
                                "다음",
                                style: SheepsTextStyle.button1(context),
                              ),
                          ),
                      );
                    },
                  ),

                ],
              ),
            ),
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
                          setPrevPage(context);
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
