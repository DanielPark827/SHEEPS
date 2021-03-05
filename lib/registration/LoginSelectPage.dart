import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:cupertino_will_pop_scope/cupertino_will_pop_scope.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/login/LoginPage.dart';
import 'package:sheeps_app/login/bloc/LoginBloc.dart';
import 'package:sheeps_app/network/ApiProvider.dart';
import 'package:sheeps_app/network/SocketProvider.dart';
import 'package:sheeps_app/registration/NameUpdatePage.dart';
import 'package:sheeps_app/registration/PageTermsOfService.dart';
import 'package:sheeps_app/registration/PhoneNumberAuthPage.dart';
import 'package:sheeps_app/registration/RegistrationPage.dart';
import 'package:sheeps_app/registration/bloc/RegistrationBloc.dart';
import 'package:sheeps_app/registration/bloc/UserRepository.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sheeps_app/registration/model/RegistrationModel.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:sheeps_app/config/GlobalAsset.dart';


class LoginSelectPage extends StatefulWidget {
  @override
  _LoginSelectPageState createState() => _LoginSelectPageState();
}

class _LoginSelectPageState extends State<LoginSelectPage> {
  final String svgGoogleLogo = 'assets/images/LoginReg/googleLogo.svg';
  final String svgAppleWhiteLogo = 'assets/images/LoginReg/appleWhiteLogo.svg';

  //RegistrationBloc registrationBloc;

  bool _isReady;//서버중복신호방지

  @override
  void initState() {
    // TODO: implement initState
    //registrationBloc = BlocProvider.of<RegistrationBloc>(context);
    _isReady = true;//서버중복신호방지

    super.initState();
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  User currentUser;
  String name = "";
  String email = "";


  Future<String> googleLogin(SocketProvider provider) async {
    if(googleSignIn == null) return null;

    GoogleSignInAccount account;

    try{
      account = await googleSignIn.signIn();
    }catch (err) {
      Fluttertoast.showToast(msg: err, toastLength: Toast.LENGTH_LONG, timeInSecForIosWeb: 1);
    }

    if(account == null) return null;

    final GoogleSignInAuthentication googleAuth = await account.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final UserCredential authResult = await _auth.signInWithCredential(credential);
    final User user = authResult.user;

    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    currentUser = _auth.currentUser;
    assert(user.uid == currentUser.uid);

    setState(() {
      email = user.email;
      name = user.displayName;
    });
    debugPrint('구글 로그인 성공: $user');

    var result = await ApiProvider().post('/Profile/SocialLogin', jsonEncode(
        {
          "id" : email,
          "name" : name,
          "social" : 1,
        }
    ));

    if(result != null){
      //핸드폰 페이지로 이동
      globalLoginID = email;
      if(result['res'] == 2 || result['res'] == '2'){
        Navigator.push(
            context, // 기본 파라미터, SecondRoute로 전달
            MaterialPageRoute(
                builder: (context) =>
                    PageTermsOfService(loginType: 1,))
        );
      }else{ // 로그인
        if(result['result'] == null){
          Function okFunc = () {
            ApiProvider().post('/Personal/Logout', jsonEncode(
                {
                  "userID" : result['userID'],
                  "isSelf" : 0
                }
            ),isChat:  true);

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
          return null;
        }

        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool('autoLoginKey',true);
        prefs.setString('autoLoginId', email);
        prefs.setString('autoLoginPw', name);
        prefs.setString('socialLogin', 1.toString());

        globalLogin(context, provider, result);
      }
    }

    return '구글 로그인 성공: $user';
  }

  Future<UserCredential> signInWithApple() async {
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    final oauthCredential = OAuthProvider("apple.com").credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
    );

    return await FirebaseAuth.instance.signInWithCredential(oauthCredential);
  }

  Future<String> appleLogin(SocketProvider provider) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    final oauthCredential = OAuthProvider("apple.com").credential(
      idToken: credential.identityToken,
      accessToken: credential.authorizationCode,
    );

    UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(oauthCredential);

    email = userCredential.user.email;
    name = userCredential.user.displayName != null || userCredential.user.displayName == ''? userCredential.user.displayName : "MUSTCHANGEAPPLEID";


    prefs.setString('autoLoginAppleId', email);
    prefs.setString('autoLoginApplePw', name);
    prefs.setString('socialLogin', 2.toString());

    var result = await ApiProvider().post('/Profile/SocialLogin', jsonEncode(
        {
          "id" : email,
          "name" : name,
          "social" : 2
        }
    ));

    if(result != null){
      //핸드폰 페이지로 이동
      globalLoginID = email;
      if(result['res'] == 3){
        Navigator.push(
            context, // 기본 파라미터, SecondRoute로 전달
            MaterialPageRoute(
                builder: (context) =>
                    PageTermsOfService(loginType: 2,))
        );
      }else{ // 로그인
        if(result['result'] == null){
          Function okFunc = () {
            ApiProvider().post('/Personal/Logout', jsonEncode(
                {
                  "userID" : result['userID'],
                  "isSelf" : 0
                }
            ), isChat: true);

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

          return null;
        }

        prefs.setBool('autoLoginKey',true);
        prefs.setString('autoLoginAppleId', email);
        prefs.setString('autoLoginApplePw', name);
        prefs.setString('socialLogin', 2.toString());

        globalLogin(context, provider, result);
      }
    }

    return null;
  }

  void googleSignOut() async {
    await _auth.signOut();
    await googleSignIn.signOut();

    setState(() {
      email = "";
      name = "";
    });
  }

  final GlobalKey<ScaffoldState> _globalKey = GlobalKey();
  static DateTime currentBackPressTime;
  _isEnd(){
    DateTime now = DateTime.now();
    if(currentBackPressTime == null || now.difference(currentBackPressTime) > Duration(seconds: 2)){
      currentBackPressTime = now;
      Fluttertoast.showToast(
          msg: "뒤로가기를 한 번 더 입력하시면 종료됩니다.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Color.fromRGBO(22, 22, 22, 0.3),
          textColor: Colors.white,
          fontSize: 14,
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    double sizeUnit = SheepsTextStyle.sizeUnit(context).fontSize;
    SocketProvider provider = Provider.of<SocketProvider>(context);

    setScreenWidth(context);
    setScreenHeight(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),//사용자 스케일팩터 무시
        child: Scaffold(
          key: _globalKey,
          body: ConditionalWillPopScope(
            shouldAddCallbacks: true,
            onWillPop: () async {
              bool result = _isEnd();
              return await Future.value(result);
            },
            child: Container(
              padding: EdgeInsets.fromLTRB(20 *sizeUnit, 0, 20 *sizeUnit, 0),
              color: Colors.white,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      svgSheepsGreenImageLogo,
                      width: 145 *sizeUnit,
                      height: 105 *sizeUnit,
                    ),
                    SizedBox(height: 16 *sizeUnit),
                    SvgPicture.asset(
                      svgSheepsGreenWriteLogo,
                      width: 150 *sizeUnit,
                      height:  28 *sizeUnit,
                    ),
                    SizedBox(height: 92 *sizeUnit),
                    Container(
                      width: 320 *sizeUnit,
                      height: 48 *sizeUnit,
                      decoration: BoxDecoration(
                        boxShadow: [
                          new BoxShadow(
                            color: Color.fromRGBO(166, 125, 130, 0.2),
                            blurRadius: 8 *sizeUnit,
                          ),],
                      ),
                      child: new FlatButton(
                          color: hexToColor("#61C680"),
                          shape: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8 *sizeUnit),
                            borderSide: BorderSide(style: BorderStyle.none),
                          ),
                          child: Text(
                            "30초만에 회원 가입하기",
                            style: SheepsTextStyle.button1(context),
                          ),
                          onPressed: (){

                            Navigator.push(
                                context, // 기본 파라미터, SecondRoute로 전달
                                MaterialPageRoute(
                                    builder: (context) =>
                                        PageTermsOfService(loginType: 0,))
                            );
                          }
                      ),
                    ),

                    Platform.isIOS ?
                    SizedBox(height: 12 *sizeUnit) : Container(),

                    Platform.isIOS ?
                    Container(
                      width: 320 *sizeUnit,
                      height: 48 *sizeUnit,
                      decoration: BoxDecoration(
                        boxShadow: [
                          new BoxShadow(
                            color: Color.fromRGBO(166, 125, 130, 0.2),
                            blurRadius: 8 *sizeUnit,
                          ),],
                      ),
                      child: new FlatButton(
                        color: Colors.black,
                        shape: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8*sizeUnit),
                          borderSide: BorderSide(style: BorderStyle.none),
                        ),
                        onPressed: () {
                          if(_isReady){
                            _isReady = false;
                            appleLogin(provider);
                            Future.delayed(Duration(milliseconds: 500),(){_isReady = true;});
                          }
                        },
                        child:new Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Align(
                              alignment: Alignment.center,
                              child: Container(
                                child:SvgPicture.asset(svgAppleWhiteLogo, width: 24 *sizeUnit , height: 24 *sizeUnit),
                              ),
                            ),
                            SizedBox(width: 10 *sizeUnit),
                            Align(
                              alignment: Alignment.center,
                              child: Container(
                                child: Text('Apple 계정으로 로그인',
                                    style: SheepsTextStyle.button1(context)
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ) : Container(),

                    SizedBox(height: 12 *sizeUnit,),
                    Container(
                      width: 320 *sizeUnit,
                      height: 44 *sizeUnit,
                      decoration: BoxDecoration(
                        boxShadow: [
                          new BoxShadow(
                            color: Color.fromRGBO(166, 125, 130, 0.2),
                            blurRadius: 8 *sizeUnit,
                          ),],
                      ),
                      child: new FlatButton(
                        color: Colors.white,
                        shape: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8 *sizeUnit),
                          borderSide: BorderSide(style: BorderStyle.none),
                        ),
                        onPressed: () {
                          if(_isReady){
                            _isReady = false;//서버 중복 신호 방지
                            googleLogin(provider);
                            Future.delayed(Duration(milliseconds: 500),(){_isReady = true;});
                          }
                        },
                        child:new Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Align(
                              alignment: Alignment.center,
                              child: Container(
                                child:SvgPicture.asset(svgGoogleLogo, width: 24 *sizeUnit , height:  24 *sizeUnit),
                              ),
                            ),
                            SizedBox(width: 10 *sizeUnit),
                            Align(
                              alignment: Alignment.center,
                              child: Container(
                                child: Text('Google 계정으로 로그인',
                                    style: SheepsTextStyle.button2(context)
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20 *sizeUnit),
                    Text.rich(
                        TextSpan(
                            text: "이미 계정을 보유하고 있다면? ",
                            style: SheepsTextStyle.info1(context),
                            children: <TextSpan>[
                              TextSpan(text: "로그인",
                                  style: SheepsTextStyle.infoStrong(context),
                                  recognizer: new TapGestureRecognizer()..onTap = () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context){
                                      return BlocProvider(
                                        create: (ctx) => LoginBloc(),
                                        child: LoginPage(),
                                      );
                                    }));
                                  }
                              ),
                            ]
                        )
                    ),
                  ]
              ),
            ),
          ),
        ),
      ),
    );
  }
}